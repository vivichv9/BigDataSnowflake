#!/bin/bash
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d "$POSTGRES_DB"  <<-EOSQL
    -- Вставка стран
    INSERT INTO normalized.countries (country_name)
    SELECT DISTINCT customer_country FROM lab1.mock_data
    UNION
    SELECT DISTINCT seller_country FROM lab1.mock_data
    UNION
    SELECT DISTINCT store_country FROM lab1.mock_data
    UNION
    SELECT DISTINCT supplier_country FROM lab1.mock_data;

    -- Вставка городов (упрощенный вариант, так как в данных нет четкого соответствия)
    INSERT INTO normalized.cities (city_name, country_id)
    SELECT DISTINCT store_city, c.country_id
    FROM lab1.mock_data m
    JOIN normalized.countries c ON m.store_country = c.country_name
    WHERE store_city IS NOT NULL;

    -- Вставка почтовых индексов (упрощенный вариант)
    INSERT INTO normalized.postal_codes (postal_code, city_id)
    SELECT DISTINCT customer_postal_code, ci.city_id
    FROM lab1.mock_data m
    JOIN normalized.countries co ON m.customer_country = co.country_name
    JOIN normalized.cities ci ON m.store_city = ci.city_name AND co.country_id = ci.country_id
    WHERE customer_postal_code IS NOT NULL;

    -- Вставка типов питомцев
    INSERT INTO normalized.pet_types (pet_type_name, pet_category)
    SELECT DISTINCT customer_pet_type, pet_category FROM lab1.mock_data
    WHERE customer_pet_type IS NOT NULL;

    -- Вставка пород питомцев
    INSERT INTO normalized.pet_breeds (pet_breed_name, pet_type_id)
    SELECT DISTINCT m.customer_pet_breed, pt.pet_type_id
    FROM lab1.mock_data m
    JOIN normalized.pet_types pt ON m.customer_pet_type = pt.pet_type_name
    WHERE customer_pet_breed IS NOT NULL;

    -- Вставка клиентов
    INSERT INTO normalized.customers (first_name, last_name, age, email, postal_code_id, pet_type_id, pet_name, pet_breed_id)
    SELECT
        m.customer_first_name,
        m.customer_last_name,
        m.customer_age,
        m.customer_email,
        pc.postal_code_id,
        pt.pet_type_id,
        m.customer_pet_name,
        pb.pet_breed_id
    FROM lab1.mock_data m
    LEFT JOIN normalized.postal_codes pc ON m.customer_postal_code = pc.postal_code
    LEFT JOIN normalized.pet_types pt ON m.customer_pet_type = pt.pet_type_name
    LEFT JOIN normalized.pet_breeds pb ON m.customer_pet_breed = pb.pet_breed_name AND pt.pet_type_id = pb.pet_type_id;

    -- Вставка продавцов
    INSERT INTO normalized.sellers (first_name, last_name, email, postal_code_id)
    SELECT
        m.seller_first_name,
        m.seller_last_name,
        m.seller_email,
        pc.postal_code_id
    FROM lab1.mock_data m
    LEFT JOIN normalized.postal_codes pc ON m.seller_postal_code = pc.postal_code;

    -- Вставка поставщиков
    INSERT INTO normalized.suppliers (supplier_name, contact_person, email, phone, address, city_id)
    SELECT DISTINCT
        m.supplier_name,
        m.supplier_contact,
        m.supplier_email,
        m.supplier_phone,
        m.supplier_address,
        ci.city_id
    FROM lab1.mock_data m
    JOIN normalized.cities ci ON m.supplier_city = ci.city_name;

    -- Вставка магазинов
    INSERT INTO normalized.stores (store_name, location, city_id, state, phone, email)
    SELECT DISTINCT
        m.store_name,
        m.store_location,
        ci.city_id,
        m.store_state,
        m.store_phone,
        m.store_email
    FROM lab1.mock_data m
    JOIN normalized.cities ci ON m.store_city = ci.city_name;

    -- Вставка категорий продуктов
    INSERT INTO normalized.product_categories (category_name)
    SELECT DISTINCT product_category FROM lab1.mock_data;

    -- Вставка брендов продуктов
    INSERT INTO normalized.product_brands (brand_name)
    SELECT DISTINCT product_brand FROM lab1.mock_data
    WHERE product_brand IS NOT NULL;

    -- Вставка материалов продуктов
    INSERT INTO normalized.product_materials (material_name)
    SELECT DISTINCT product_material FROM lab1.mock_data
    WHERE product_material IS NOT NULL;

    -- Вставка продуктов
    INSERT INTO normalized.products (
        product_name, category_id, price, weight, color, size, brand_id,
        material_id, description, rating, reviews, release_date, expiry_date,
        supplier_id, quantity_in_stock
    )
    SELECT
        m.product_name,
        pc.category_id,
        m.product_price,
        m.product_weight,
        m.product_color,
        m.product_size,
        pb.brand_id,
        pm.material_id,
        m.product_description,
        m.product_rating,
        m.product_reviews,
        m.product_release_date,
        m.product_expiry_date,
        s.supplier_id,
        m.product_quantity
    FROM lab1.mock_data m
    JOIN normalized.product_categories pc ON m.product_category = pc.category_name
    LEFT JOIN normalized.product_brands pb ON m.product_brand = pb.brand_name
    LEFT JOIN normalized.product_materials pm ON m.product_material = pm.material_name
    LEFT JOIN normalized.suppliers s ON m.supplier_name = s.supplier_name;

    -- Вставка продаж
    INSERT INTO normalized.sales (
        sale_date, customer_id, seller_id, product_id, quantity, total_price
    )
    SELECT
        m.sale_date,
        m.sale_customer_id,
        m.sale_seller_id,
        m.sale_product_id,
        m.sale_quantity,
        m.sale_total_price
    FROM lab1.mock_data m;
EOSQL