--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

-- Started on 2025-06-15 17:35:39

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 227 (class 1255 OID 16654)
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO zooshop_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 226 (class 1259 OID 16715)
-- Name: cart_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_items (
    id integer NOT NULL,
    user_id integer,
    product_id integer,
    quantity integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.cart_items OWNER TO zooshop_user;

--
-- TOC entry 225 (class 1259 OID 16714)
-- Name: cart_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cart_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cart_items_id_seq OWNER TO zooshop_user;

--
-- TOC entry 4960 (class 0 OID 0)
-- Dependencies: 225
-- Name: cart_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cart_items_id_seq OWNED BY public.cart_items.id;


--
-- TOC entry 224 (class 1259 OID 16696)
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    id integer NOT NULL,
    order_id integer,
    product_id integer,
    quantity integer NOT NULL,
    price_at_purchase numeric(10,2) DEFAULT 0.00 NOT NULL
);


ALTER TABLE public.order_items OWNER TO zooshop_user;

--
-- TOC entry 223 (class 1259 OID 16695)
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_id_seq OWNER TO zooshop_user;

--
-- TOC entry 4961 (class 0 OID 0)
-- Dependencies: 223
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- TOC entry 222 (class 1259 OID 16680)
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    user_id integer,
    total_amount numeric(10,2) NOT NULL,
    status character varying(50) DEFAULT 'pending'::character varying,
    order_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    shipping_address text,
    contact_phone character varying(50),
    contact_email character varying(100),
    delivery_address character varying(255),
    full_name character varying(255)
);


ALTER TABLE public.orders OWNER TO zooshop_user;

--
-- TOC entry 221 (class 1259 OID 16679)
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_id_seq OWNER TO zooshop_user;

--
-- TOC entry 4962 (class 0 OID 0)
-- Dependencies: 221
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- TOC entry 218 (class 1259 OID 16643)
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    price numeric(10,2) NOT NULL,
    category character varying(100),
    image_url character varying(255),
    stock_quantity integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.products OWNER TO zooshop_user;

--
-- TOC entry 217 (class 1259 OID 16642)
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_id_seq OWNER TO zooshop_user;

--
-- TOC entry 4963 (class 0 OID 0)
-- Dependencies: 217
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- TOC entry 220 (class 1259 OID 16668)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO zooshop_user;

--
-- TOC entry 219 (class 1259 OID 16667)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO zooshop_user;

--
-- TOC entry 4964 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4774 (class 2604 OID 16718)
-- Name: cart_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items ALTER COLUMN id SET DEFAULT nextval('public.cart_items_id_seq'::regclass);


--
-- TOC entry 4772 (class 2604 OID 16699)
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- TOC entry 4769 (class 2604 OID 16683)
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- TOC entry 4763 (class 2604 OID 16646)
-- Name: products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- TOC entry 4767 (class 2604 OID 16671)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 4954 (class 0 OID 16715)
-- Dependencies: 226
-- Data for Name: cart_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_items (id, user_id, product_id, quantity) FROM stdin;
\.


--
-- TOC entry 4952 (class 0 OID 16696)
-- Dependencies: 224
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_items (id, order_id, product_id, quantity, price_at_purchase) FROM stdin;
2	3	2	1	0.00
3	3	1	1	0.00
4	4	1	3	550.00
5	5	2	1	85.50
6	6	8	1	120.00
\.


--
-- TOC entry 4950 (class 0 OID 16680)
-- Dependencies: 222
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, user_id, total_amount, status, order_date, shipping_address, contact_phone, contact_email, delivery_address, full_name) FROM stdin;
3	3	635.50	pending	2025-06-12 13:52:04.676259+03	\N	+380935831950	\N	Київ, вул Лебідь, 5, 10	chichilav
4	4	1650.00	pending	2025-06-12 15:26:59.293702+03	\N	+380663516859	\N	Київ, Лебідь, 3, 9	hekwey
5	4	85.50	pending	2025-06-12 15:39:58.455412+03	\N	+380508319830	\N	Львів, Мазепи, 4, 46	hekwey
6	4	120.00	pending	2025-06-13 12:56:20.569365+03	\N	+380935831950	\N	Київ, Лебідь, 3, 9	hekwey
\.


--
-- TOC entry 4946 (class 0 OID 16643)
-- Dependencies: 218
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, name, description, price, category, image_url, stock_quantity, created_at, updated_at) FROM stdin;
8	Ласощі для котів "Котяча мрія"	Натуральні ласощі з лососем, для заохочення та здоров'я шерсті.	120.00	Ласощі для котів	duck-cat-food.jpg	249	2025-06-10 15:53:21.505264+03	2025-06-13 12:56:20.569365+03
1	Сухий корм для собак "Амброзія"	Повнораціонний корм для дорослих собак великих порід, з куркою та овочами.	550.00	Корм для собак	../images/dry-dog-food-picture.jpg	146	2025-06-10 15:53:21.505264+03	2025-06-12 18:09:57.711652+03
2	Іграшка для котів "Мишка з дзвіночком"	Яскрава іграшка для котів, допомагає розвивати мисливські інстинкти.	85.50	Іграшки для котів	../images/cat-toy-picture.jpg	298	2025-06-10 15:53:21.505264+03	2025-06-12 18:11:54.990498+03
3	Акваріум 20л з фільтром	Компактний акваріум для рибок, ідеально підходить для початківців.	1200.00	Акваріуми	../images/aquarium-picture.jpg	30	2025-06-10 15:53:21.505264+03	2025-06-12 18:11:54.990498+03
4	Наповнювач для котячого туалету	Натуральний деревний наповнювач, добре поглинає запахи.	250.00	Гігієна	../images/cat-litter-filler-picture.jpg	200	2025-06-10 15:53:21.505264+03	2025-06-12 18:11:54.990498+03
5	Лежанка для собак "Затишок"	М'яка і зручна лежанка для середніх собак, знімний чохол.	780.00	Аксесуари для собак	../images/black-dog-bed.jpg	50	2025-06-10 15:53:21.505264+03	2025-06-12 18:11:54.990498+03
6	Шампунь для гризунів	М'який шампунь для хом'яків та морських свинок, 200мл.	150.00	Гігієна для гризунів	../images/rodent-shampoo.jpg	100	2025-06-10 15:53:21.505264+03	2025-06-12 18:11:54.990498+03
7	Клітка для птахів "Співочий сад"	Простора клітка з годівницею та поїлкою для невеликих птахів.	950.00	Товари для птахів	../images/bird-cage.jpg	20	2025-06-10 15:53:21.505264+03	2025-06-12 18:11:54.990498+03
\.


--
-- TOC entry 4948 (class 0 OID 16668)
-- Dependencies: 220
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, email, password_hash, created_at) FROM stdin;
1	testuser	test@example.com	testpassword123	2025-06-10 15:52:19.133751+03
2	helin	helinfrank@gmail.com	$2b$10$hFx1jQDVGlIU/a4LzEZuV.fw3v9vqv8Nk0bA0CRwusdHgT4bEBejG	2025-06-10 16:47:11.97953+03
3	chichilav	chichilavsso@gmail.com	$2b$10$KjM3zNezeyxmLbt9xE8NtOVU63S/ZZuQW7uLo4cTuL9VHlUG9G9I.	2025-06-10 16:52:39.005766+03
4	hekwey	hekwey@gmail.com	$2b$10$B3JlCNpn3izjX2XiBn4oqOvP2.LyQP40pZq0wK354PTZDXKKsJciG	2025-06-12 15:06:50.410621+03
5	olena	olenapetrivna@gmail.com	$2b$10$youPOAJRbym0g8/hKjLPauo5A0C48rDCpzie.j3tF0fli.a3xQK.u	2025-06-13 12:30:21.574071+03
6	karinagrig	karinagrina@gmail.com	$2b$10$k2DtAj7G.7TB/ZYsZF5Lg.qjfGCRYYJ1PTgDPRDOowYvMxeIXnYuu	2025-06-13 13:00:50.977489+03
\.


--
-- TOC entry 4965 (class 0 OID 0)
-- Dependencies: 225
-- Name: cart_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cart_items_id_seq', 1, false);


--
-- TOC entry 4966 (class 0 OID 0)
-- Dependencies: 223
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_items_id_seq', 6, true);


--
-- TOC entry 4967 (class 0 OID 0)
-- Dependencies: 221
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_seq', 6, true);


--
-- TOC entry 4968 (class 0 OID 0)
-- Dependencies: 217
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 8, true);


--
-- TOC entry 4969 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 6, true);


--
-- TOC entry 4791 (class 2606 OID 16721)
-- Name: cart_items cart_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_pkey PRIMARY KEY (id);


--
-- TOC entry 4793 (class 2606 OID 16723)
-- Name: cart_items fk_cart_user; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT fk_cart_user UNIQUE (user_id, product_id);


--
-- TOC entry 4787 (class 2606 OID 16701)
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- TOC entry 4785 (class 2606 OID 16689)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- TOC entry 4777 (class 2606 OID 16653)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- TOC entry 4789 (class 2606 OID 16703)
-- Name: order_items unique_order_product; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT unique_order_product UNIQUE (order_id, product_id);


--
-- TOC entry 4779 (class 2606 OID 16678)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4781 (class 2606 OID 16674)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4783 (class 2606 OID 16676)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 4799 (class 2620 OID 16655)
-- Name: products update_products_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 4797 (class 2606 OID 16729)
-- Name: cart_items cart_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- TOC entry 4798 (class 2606 OID 16724)
-- Name: cart_items cart_items_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4795 (class 2606 OID 16704)
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- TOC entry 4796 (class 2606 OID 16709)
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- TOC entry 4794 (class 2606 OID 16690)
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


-- Completed on 2025-06-15 17:35:39

--
-- PostgreSQL database dump complete
--

