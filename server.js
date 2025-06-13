require('dotenv').config(); // Цей рядок має бути ПЕРШИМ у файлі!

const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { Pool } = require('pg');

const app = express();
const port = 3000;

// Middleware
app.use(bodyParser.json());
app.use(cors()); // Дозволяє запити з фронтенду

// Налаштування підключення до PostgreSQL
const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_DATABASE,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
});

// Перевірка підключення до БД
console.log('Executing DB query: SELECT NOW() for connection check');
pool.query('SELECT NOW()', (err, res) => {
    if (err) {
        console.error('Помилка підключення до бази даних:', err);
    } else {
        console.log('Підключено до PostgreSQL:', res.rows[0].now);
    }
});

// Секретний ключ для JWT
const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
    console.error('Помилка: JWT_SECRET не встановлено! Будь ласка, додайте JWT_SECRET до файлу .env');
    process.exit(1);
}

// Middleware для перевірки JWT токена
function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    console.log('--- authenticateToken START ---'); // Новий лог
    console.log('Received authHeader:', authHeader);
    console.log('Extracted token:', token);

    if (token == null) {
        console.log('Token is null or undefined (401).'); // Змінений лог
        return res.status(401).json({ message: 'Токен відсутній або недійсний. Будь ласка, увійдіть.' });
    }

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) {
            console.error('Помилка верифікації токена:', err);
            // Додайте детальніший лог для JsonWebTokenError
            if (err.name === 'TokenExpiredError') {
                console.error('Token expiration details: Token expired at', err.expiredAt);
                return res.status(403).json({ message: 'Токен недійсний (термін дії закінчився). Будь ласка, увійдіть знову.' });
            } else if (err.name === 'JsonWebTokenError') {
                console.error('JWT Error type:', err.name, 'Message:', err.message);
                return res.status(403).json({ message: 'Токен недійсний (помилка підпису або формату). Будь ласка, увійдіть знову.' });
            }
            console.log('Unknown JWT verification error (403).'); // Змінений лог
            return res.status(403).json({ message: 'Токен недійсний або термін дії закінчився. Будь ласка, увійдіть знову.' });
        }
        req.user = user;
        console.log('Token successfully verified for user ID:', user.id, 'Username:', user.username); // Додатковий лог
        console.log('--- authenticateToken END (Success) ---'); // Новий лог
        next();
    });
}

// Маршрут реєстрації
app.post('/api/register', async (req, res) => {
    const { username, email, password } = req.body;

    if (!username || !email || !password) {
        return res.status(400).json({ message: 'Будь лаaska, введіть ім\'я користувача, пошту та пароль.' });
    }

    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        console.log('Executing DB query: INSERT INTO users');
        const result = await pool.query(
            'INSERT INTO users (username, email, password_hash) VALUES ($1, $2, $3) RETURNING id, username, email',
            [username, email, hashedPassword]
        );
        res.status(201).json({ message: 'Користувач успішно зареєстрований!', user: result.rows[0] });
    } catch (error) {
        if (error.code === '23505') { // PostgreSQL error code for unique violation
            if (error.constraint === 'users_username_key') {
                return res.status(409).json({ message: 'Користувач з таким ім\'ям вже існує.' });
            }
            if (error.constraint === 'users_email_key') {
                return res.status(409).json({ message: 'Користувач з такою поштою вже існує.' });
            }
        }
        console.error('Помилка реєстрації:', error);
        res.status(500).json({ message: 'Помилка сервера під час реєстрації.', error: error.message });
    }
});

// Маршрут входу
app.post('/api/login', async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ message: 'Будь ласка, введіть пошту та пароль.' });
    }

    try {
        console.log('Executing DB query: SELECT user for login');
        const userResult = await pool.query(
            'SELECT id, username, email, password_hash FROM users WHERE email = $1',
            [email]
        );

        if (userResult.rows.length === 0) {
            return res.status(400).json({ message: 'Невірний логін або пароль.' });
        }

        const user = userResult.rows[0];
        const isPasswordValid = await bcrypt.compare(password, user.password_hash);

        if (!isPasswordValid) {
            return res.status(400).json({ message: 'Невірний логін або пароль.' });
        }

        // Генеруємо JWT токен
        const token = jwt.sign(
            { id: user.id, username: user.username, email: user.email },
            JWT_SECRET,
            { expiresIn: '1h' } // Термін дії токена - 1 година
        );

        res.status(200).json({
            message: 'Вхід успішний!',
            token: token,
            user: { id: user.id, username: user.username, email: user.email }
        });

    } catch (error) {
        console.error('Помилка входу:', error);
        res.status(500).json({ message: 'Помилка сервера під час входу.', error: error.message });
    }
});

// Маршрут для отримання всіх продуктів (захищений)
app.get('/api/products', authenticateToken, async (req, res) => {
    try {
        console.log('Executing DB query: SELECT all products');
        const result = await pool.query('SELECT * FROM products ORDER BY id ASC');
        console.log('Successfully fetched products from DB. Rows count:', result.rows.length); // ДОДАНО
        res.status(200).json(result.rows);
    } catch (error) {
        console.error('Помилка при отриманні товарів з БД:', error); // ЗМІНЕНО лог
        res.status(500).json({ message: 'Помилка сервера при отриманні товарів.', error: error.message });
    }
});


// Маршрут для отримання даних профілю поточного користувача
app.get('/api/profile', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id;

        console.log(`Executing DB query: SELECT username, email FROM users WHERE id = ${userId}`);
        const userResult = await pool.query(
            'SELECT username, email FROM users WHERE id = $1',
            [userId]
        );

        if (userResult.rows.length === 0) {
            console.warn('Profile not found for user ID:', userId); // ДОДАНО
            return res.status(404).json({ message: 'Користувача не знайдено.' });
        }

        const userData = userResult.rows[0];

        console.log(`Executing DB query for profile orders for user ID: ${userId}`);
        const ordersResult = await pool.query(
    `SELECT
        o.id AS order_id,
        o.total_amount,
        o.order_date,
        o.status,
        o.delivery_address,
        o.contact_phone,
        o.full_name AS customer_full_name,
        json_agg(
            json_build_object(
                'product_id', oi.product_id,
                'product_name', p.name,
                'quantity', oi.quantity,
                'price_at_purchase', oi.price_at_purchase,
                'image_url', p.image_url
            )
        ) AS items
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN products p ON oi.product_id = p.id
    WHERE o.user_id = $1
    GROUP BY o.id, o.total_amount, o.order_date, o.status, o.delivery_address, o.contact_phone, o.full_name
    ORDER BY o.order_date DESC;`,
    [userId]
);
        console.log('Successfully fetched profile and orders from DB for user ID:', userId); // ДОДАНО

        res.status(200).json({
            message: 'Дані профілю успішно отримано.',
            user: userData,
            orders: ordersResult.rows
        });

    } catch (error) {
        console.error('Помилка при отриманні даних профілю з БД:', error); // ЗМІНЕНО лог
        res.status(500).json({ message: 'Помилка сервера при отриманні даних профілю.', error: error.message });
    }
});


// НОВИЙ МАРШРУТ: Оформлення замовлення
app.post('/api/orders', authenticateToken, async (req, res) => {
    const { items, deliveryDetails } = req.body;
    const userId = req.user.id;

    if (!items || items.length === 0) {
        return res.status(400).json({ message: 'Кошик порожній. Додайте товари для оформлення замовлення.' });
    }
    if (!deliveryDetails || !deliveryDetails.fullName || !deliveryDetails.address || !deliveryDetails.phone) {
        return res.status(400).json({ message: 'Будь ласка, введіть повні дані для доставки.' });
    }

    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        console.log('Transaction BEGIN');

        let totalAmount = 0;
        const productsInOrder = [];

        for (const item of items) {
            console.log(`Executing DB query: SELECT product ${item.id} for update`);
            const productResult = await client.query('SELECT id, name, price, stock_quantity FROM products WHERE id = $1 FOR UPDATE', [item.id]);

            if (productResult.rows.length === 0) {
                throw new Error(`Товар з ID ${item.id} не знайдено.`);
            }

            const product = productResult.rows[0];

            if (product.stock_quantity < item.quantity) {
                throw new Error(`Недостатньо ${product.name} на складі. Доступно: ${product.stock_quantity}, запитано: ${item.quantity}.`);
            }

            console.log(`Executing DB query: UPDATE stock for product ${product.id}`);
            await client.query(
                'UPDATE products SET stock_quantity = stock_quantity - $1 WHERE id = $2',
                [item.quantity, product.id]
            );

            totalAmount += product.price * item.quantity;
            productsInOrder.push({
                product_id: product.id,
                quantity: item.quantity,
                price_at_purchase: product.price
            });
        }

        console.log('Executing DB query: INSERT INTO orders');
        const orderResult = await client.query(
            `INSERT INTO orders (user_id, total_amount, delivery_address, contact_phone, full_name, status)
             VALUES ($1, $2, $3, $4, $5, 'pending') RETURNING id, order_date, status`,
            [userId, totalAmount, deliveryDetails.address, deliveryDetails.phone, deliveryDetails.fullName]
        );
        const orderId = orderResult.rows[0].id;

        for (const item of productsInOrder) {
            console.log(`Executing DB query: INSERT INTO order_items for order ${orderId}, product ${item.product_id}`);
            await client.query(
                'INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase) VALUES ($1, $2, $3, $4)',
                [orderId, item.product_id, item.quantity, item.price_at_purchase]
            );
        }

        await client.query('COMMIT');
        console.log('Transaction COMMITTED');
        res.status(201).json({
            message: 'Замовлення успішно оформлено!',
            orderId: orderId,
            totalAmount: totalAmount,
            orderDate: orderResult.rows[0].order_date,
            status: orderResult.rows[0].status
        });

    } catch (error) {
        await client.query('ROLLBACK');
        console.log('Transaction ROLLED BACK');
        console.error('Помилка при оформленні замовлення:', error);
        let errorMessage = 'Помилка сервера при оформленні замовлення.';
        if (error.message.includes('Недостатньо') || error.message.includes('не знайдено')) {
            errorMessage = error.message;
        }
        res.status(500).json({ message: errorMessage, error: error.message });
    } finally {
        client.release();
    }
});


// ДОДАНО: Обробник помилок, якщо жоден маршрут не обробив запит
app.use((req, res, next) => {
    console.warn(`404 Not Found: Request to ${req.method} ${req.originalUrl} not handled by any route.`);
    res.status(404).send('<!DOCTYPE html><html lang="uk"><head><meta charset="UTF-8"><title>404 Не знайдено</title></head><body><h1>404 - Сторінку не знайдено</h1><p>Вибачте, але запитувана сторінка не існує.</p></body></html>');
});

// ДОДАНО: Глобальний обробник помилок (якщо помилка не була оброблена раніше)
app.use((err, req, res, next) => {
    console.error('Глобальна помилка сервера:', err.stack);
    res.status(500).json({
        message: 'Сталася неочікувана помилка на сервері. Будь ласка, спробуйте пізніше.',
        error: err.message
    });
});


// Запуск сервера
app.listen(port, () => {
    console.log(`Сервер працює на http://localhost:${port}`);
});