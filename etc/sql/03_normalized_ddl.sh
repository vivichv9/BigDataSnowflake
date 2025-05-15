#!/bin/bash
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d "$POSTGRES_DB"  <<-EOSQL
    CREATE SCHEMA IF NOT EXISTS normalized;

    -- Таблица стран (общая для клиентов, продавцов, поставщиков и магазинов)
    CREATE TABLE IF NOT EXISTS normalized.countries (
        country_id SERIAL PRIMARY KEY,
        country_name VARCHAR(50) UNIQUE NOT NULL
    );

    -- Таблица городов
    CREATE TABLE IF NOT EXISTS normalized.cities (
        city_id SERIAL PRIMARY KEY,
        city_name VARCHAR(50) NOT NULL,
        country_id INTEGER REFERENCES normalized.countries(country_id) NOT NULL
    );

    -- Таблица почтовых индексов
    CREATE TABLE IF NOT EXISTS normalized.postal_codes (
        postal_code_id SERIAL PRIMARY KEY,
        postal_code VARCHAR(50),
        city_id INTEGER REFERENCES normalized.cities(city_id) NOT NULL
    );


    -- Таблица типов питомцев
    CREATE TABLE IF NOT EXISTS normalized.pet_types (
        pet_type_id SERIAL PRIMARY KEY,
        pet_type_name VARCHAR(50) NOT NULL,
        pet_category VARCHAR(50) NOT NULL
    );

    -- Таблица пород питомцев
    CREATE TABLE IF NOT EXISTS normalized.pet_breeds (
        pet_breed_id SERIAL PRIMARY KEY,
        pet_breed_name VARCHAR(50) NOT NULL,
        pet_type_id INTEGER REFERENCES normalized.pet_types(pet_type_id) NOT NULL
    );

    -- Таблица клиентов
    CREATE TABLE IF NOT EXISTS normalized.customers (
        customer_id SERIAL PRIMARY KEY,
        first_name VARCHAR(50) NOT NULL,
        last_name VARCHAR(50) NOT NULL,
        age SMALLINT,
        email VARCHAR(50) NOT NULL,
        postal_code_id INTEGER REFERENCES normalized.postal_codes(postal_code_id),
        pet_type_id INTEGER REFERENCES normalized.pet_types(pet_type_id),
        pet_name VARCHAR(50),
        pet_breed_id INTEGER REFERENCES normalized.pet_breeds(pet_breed_id)
    );

    -- Таблица продавцов
    CREATE TABLE IF NOT EXISTS normalized.sellers (
        seller_id SERIAL PRIMARY KEY,
        first_name VARCHAR(50) NOT NULL,
        last_name VARCHAR(50) NOT NULL,
        email VARCHAR(50) NOT NULL,
        postal_code_id INTEGER REFERENCES normalized.postal_codes(postal_code_id)
    );

    -- Таблица поставщиков
    CREATE TABLE IF NOT EXISTS normalized.suppliers (
        supplier_id SERIAL PRIMARY KEY,
        supplier_name VARCHAR(50) NOT NULL,
        contact_person VARCHAR(50),
        email VARCHAR(50),
        phone VARCHAR(50),
        address VARCHAR(50),
        city_id INTEGER REFERENCES normalized.cities(city_id)
    );

    -- Таблица магазинов
    CREATE TABLE IF NOT EXISTS normalized.stores (
        store_id SERIAL PRIMARY KEY,
        store_name VARCHAR(50) NOT NULL,
        location VARCHAR(50),
        city_id INTEGER REFERENCES normalized.cities(city_id),
        state VARCHAR(50),
        phone VARCHAR(50),
        email VARCHAR(50)
    );

    -- Таблица категорий продуктов
    CREATE TABLE IF NOT EXISTS normalized.product_categories (
        category_id SERIAL PRIMARY KEY,
        category_name VARCHAR(50) UNIQUE NOT NULL
    );

    -- Таблица брендов продуктов
    CREATE TABLE IF NOT EXISTS normalized.product_brands (
        brand_id SERIAL PRIMARY KEY,
        brand_name VARCHAR(50) UNIQUE NOT NULL
    );

    -- Таблица материалов продуктов
    CREATE TABLE IF NOT EXISTS normalized.product_materials (
        material_id SERIAL PRIMARY KEY,
        material_name VARCHAR(50) UNIQUE NOT NULL
    );

    -- Таблица продуктов
    CREATE TABLE IF NOT EXISTS normalized.products (
        product_id SERIAL PRIMARY KEY,
        product_name VARCHAR(50) NOT NULL,
        category_id INTEGER REFERENCES normalized.product_categories(category_id) NOT NULL,
        price MONEY NOT NULL,
        weight DOUBLE PRECISION,
        color VARCHAR(50),
        size VARCHAR(50),
        brand_id INTEGER REFERENCES normalized.product_brands(brand_id),
        material_id INTEGER REFERENCES normalized.product_materials(material_id),
        description TEXT,
        rating DOUBLE PRECISION,
        reviews INTEGER,
        release_date DATE,
        expiry_date DATE,
        supplier_id INTEGER REFERENCES normalized.suppliers(supplier_id),
        quantity_in_stock INTEGER NOT NULL
    );

    -- Таблица продаж
    CREATE TABLE IF NOT EXISTS normalized.sales (
        sale_id SERIAL PRIMARY KEY,
        sale_date DATE,
        customer_id INTEGER REFERENCES normalized.customers(customer_id),
        seller_id INTEGER REFERENCES normalized.sellers(seller_id),
        product_id INTEGER REFERENCES normalized.products(product_id),
        quantity INTEGER,
        total_price MONEY ,
        store_id INTEGER REFERENCES normalized.stores(store_id)
    );
EOSQL