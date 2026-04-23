-- Schema Initialization
-- SCHEMA 1: OLTP (Transactional / Source)
-- Normalized, write-optimized


-- Create a schema named oltp
CREATE SCHEMA IF NOT EXISTS oltp;

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users
CREATE TABLE IF NOT EXISTS oltp.users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    country VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
);

-- Categories
CREATE TABLE IF NOT EXISTS oltp.categories (
    categorie_id SERIAL PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    parent_category_id INT REFERENCES oltp.categories(categorie_id) ON DELETE SET NULL
);

-- Products
CREATE TABLE IF NOT EXISTS oltp.products (
    product_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id INT REFERENCES oltp.categories(categorie_id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    stock_qty INT NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Orders

-- Create enum
CREATE TYPE oltp.order_status AS ENUM (
    'pending', 'processing', 'shipped', 'delivered', 'cancelled'
);

-- create table
CREATE TABLE IF NOT EXISTS oltp.orders (
    order_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES oltp.users(user_id) ON DELETE CASCADE,
    total_amount NUMERIC(10, 2) NOT NULL DEFAULT 0,
    status oltp.order_status NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    shipping_at TIMESTAMP
);

-- Order items One order can have many product 
CREATE TABLE IF NOT EXISTS oltp.order_items (
    item_id SERIAL PRIMARY KEY,
    order_id  UUID NOT NULL REFERENCES oltp.order(order_id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES oltp.product(product_id) ON DELETE RESTRICT,
    quantity INT NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC(10, 2) NOT NULL,
    discount NUMERIC(10, 2) DEFAULT 0 CHECK (discount >= 0 AND discount <= 100)
);

-- Click stream event forr tracking user behaviour
CREATE TYPE oltp.event_type AS ENUM (
    'page_view', 'product_view', 'add_to_cart', 'remove_from_cart', 'checkout', 'purchase'
);

CREATE TABLE IF NOT EXISTS oltp.clickstream_events (
    event_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES oltp.users(user_id) ON DELETE SET NULL,
    product_id UUID REFERENCES oltp.products(product_id) ON DELETE SET NULL,
    event_type oltp.event_type NOT NULL,
    session_id UUID NOT NULL,
    event_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Index
CREATE INDEX IF NOT EXISTS idx_order_user_id ON oltp.order(order_id); 
CREATE INDEX IF NOT EXISTS idx_order_created_at ON oltp.order(created_at); 
CREATE INDEX IF NOT EXISTS idx_order_items_order ON oltp.order_items(order_id); 
CREATE INDEX IF NOT EXISTS idx_clickstream_user ON oltp.clickstream_events(user_id); 
CREATE INDEX IF NOT EXISTS idx_clickstream_event ON oltp.clickstream_events(event_at); 