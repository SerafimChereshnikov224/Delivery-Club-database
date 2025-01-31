
BEGIN;


CREATE TABLE IF NOT EXISTS public.addresses
(
    id serial NOT NULL,
    street character varying(100) COLLATE pg_catalog."default" NOT NULL,
    house_number character varying(10) COLLATE pg_catalog."default" NOT NULL,
    city character varying(100) COLLATE pg_catalog."default" NOT NULL,
    apartment_number character varying(10) COLLATE pg_catalog."default",
    user_id integer,
    CONSTRAINT addresses_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.collections
(
    id serial NOT NULL,
    name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    theme character varying(100) COLLATE pg_catalog."default",
    creation_date date NOT NULL,
    CONSTRAINT collections_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.couriers
(
    id serial NOT NULL,
    full_name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    registration_date date NOT NULL,
    phone_number character varying(15) COLLATE pg_catalog."default",
    status character varying(20) COLLATE pg_catalog."default" DEFAULT 'active'::character varying,
    CONSTRAINT couriers_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.dishes
(
    id serial NOT NULL,
    name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    recipe text COLLATE pg_catalog."default",
    weight integer,
    price numeric(10, 2) NOT NULL,
    restaurant_id integer,
    CONSTRAINT dishes_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.order_dish
(
    id serial NOT NULL,
    order_id integer,
    dish_id integer,
    CONSTRAINT order_dish_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.order_product
(
    id serial NOT NULL,
    order_id integer,
    product_id integer,
    CONSTRAINT order_product_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.orders
(
    id serial NOT NULL,
    order_number character varying(50) COLLATE pg_catalog."default" NOT NULL,
    creation_date timestamp without time zone NOT NULL DEFAULT now(),
    user_id integer NOT NULL,
    payment_method_id integer NOT NULL,
    courier_id integer,
    total_amount numeric(10, 2) NOT NULL DEFAULT 0.00,
    order_status character varying(20) COLLATE pg_catalog."default" DEFAULT 'pending'::character varying,
    close_date timestamp without time zone,
    CONSTRAINT orders_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.payments
(
    id serial NOT NULL,
    card_number character varying(16) COLLATE pg_catalog."default" NOT NULL,
    payment_type character varying(50) COLLATE pg_catalog."default" NOT NULL,
    user_id integer NOT NULL,
    CONSTRAINT payments_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.products
(
    id serial NOT NULL,
    name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    type character varying(100) COLLATE pg_catalog."default",
    weight integer,
    price numeric(10, 2) NOT NULL,
    store_id integer,
    CONSTRAINT products_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.promocodes
(
    id serial NOT NULL,
    creation_date date NOT NULL,
    expiration_date date NOT NULL,
    discount_in_rubles numeric(10, 2),
    discount_in_percent numeric(5, 2),
    name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    collection_id integer,
    CONSTRAINT promocodes_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.restaurant_collection
(
    id serial NOT NULL,
    collection_id integer,
    restaurant_id integer,
    CONSTRAINT restaurant_collection_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.restaurants
(
    id serial NOT NULL,
    name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    rating numeric(2, 1),
    theme character varying(100) COLLATE pg_catalog."default",
    review_link character varying(255) COLLATE pg_catalog."default",
    address_id integer,
    CONSTRAINT restaurants_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.store_collection
(
    id serial NOT NULL,
    collection_id integer,
    store_id integer,
    CONSTRAINT store_collection_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.stores
(
    id serial NOT NULL,
    name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    specialization character varying(100) COLLATE pg_catalog."default",
    review_link character varying(255) COLLATE pg_catalog."default",
    address_id integer,
    CONSTRAINT stores_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.user_promocode
(
    id serial NOT NULL,
    user_id integer,
    promocode_id integer,
    CONSTRAINT user_promocode_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.users
(
    id serial NOT NULL,
    full_name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    registration_date timestamp without time zone NOT NULL DEFAULT now(),
    password character varying(255) COLLATE pg_catalog."default" NOT NULL,
    login character varying(255) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT users_pkey PRIMARY KEY (id),
    CONSTRAINT users_login_key UNIQUE (login)
);

ALTER TABLE IF EXISTS public.addresses
    ADD CONSTRAINT addresses_user_id_fkey FOREIGN KEY (user_id)
    REFERENCES public.users (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.dishes
    ADD CONSTRAINT dishes_restaurant_id_fkey FOREIGN KEY (restaurant_id)
    REFERENCES public.restaurants (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.order_dish
    ADD CONSTRAINT order_dish_dish_id_fkey FOREIGN KEY (dish_id)
    REFERENCES public.dishes (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.order_dish
    ADD CONSTRAINT order_dish_order_id_fkey FOREIGN KEY (order_id)
    REFERENCES public.orders (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.order_product
    ADD CONSTRAINT order_product_order_id_fkey FOREIGN KEY (order_id)
    REFERENCES public.orders (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.order_product
    ADD CONSTRAINT order_product_product_id_fkey FOREIGN KEY (product_id)
    REFERENCES public.products (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.orders
    ADD CONSTRAINT orders_courier_id_fkey FOREIGN KEY (courier_id)
    REFERENCES public.couriers (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;


ALTER TABLE IF EXISTS public.orders
    ADD CONSTRAINT orders_payment_method_id_fkey FOREIGN KEY (payment_method_id)
    REFERENCES public.payments (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;


ALTER TABLE IF EXISTS public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id)
    REFERENCES public.users (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;


ALTER TABLE IF EXISTS public.payments
    ADD CONSTRAINT payments_user_id_fkey FOREIGN KEY (user_id)
    REFERENCES public.users (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;


ALTER TABLE IF EXISTS public.products
    ADD CONSTRAINT products_store_id_fkey FOREIGN KEY (store_id)
    REFERENCES public.stores (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.promocodes
    ADD CONSTRAINT promocodes_collection_id_fkey FOREIGN KEY (collection_id)
    REFERENCES public.collections (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.restaurant_collection
    ADD CONSTRAINT restaurant_collection_collection_id_fkey FOREIGN KEY (collection_id)
    REFERENCES public.collections (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.restaurant_collection
    ADD CONSTRAINT restaurant_collection_restaurant_id_fkey FOREIGN KEY (restaurant_id)
    REFERENCES public.restaurants (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.restaurants
    ADD CONSTRAINT restaurants_address_id_fkey FOREIGN KEY (address_id)
    REFERENCES public.addresses (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.store_collection
    ADD CONSTRAINT store_collection_collection_id_fkey FOREIGN KEY (collection_id)
    REFERENCES public.collections (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.store_collection
    ADD CONSTRAINT store_collection_store_id_fkey FOREIGN KEY (store_id)
    REFERENCES public.stores (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.stores
    ADD CONSTRAINT stores_address_id_fkey FOREIGN KEY (address_id)
    REFERENCES public.addresses (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.user_promocode
    ADD CONSTRAINT user_promocode_promocode_id_fkey FOREIGN KEY (promocode_id)
    REFERENCES public.promocodes (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public.user_promocode
    ADD CONSTRAINT user_promocode_user_id_fkey FOREIGN KEY (user_id)
    REFERENCES public.users (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

END;