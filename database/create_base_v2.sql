CREATE TYPE location AS (
    longitude DOUBLE PRECISION,
    latitude DOUBLE PRECISION
);

CREATE TYPE maintenance_status AS ENUM (
    'waiting',
    'processing',
    'finish'
);

CREATE TYPE invoice_recipient AS ENUM(
    'drivncook',
    'customer',
    'user'
);

CREATE TYPE type_address AS ENUM(
    'delivery',
    'invoice'
);

CREATE TABLE admin (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    first_name VARCHAR[100],
    last_name VARCHAR[100],
    email VARCHAR[255],
    password CHAR[60],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE truck (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    matriculation VARCHAR[50],
    location location,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE warehouse (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    location location,
    name VARCHAR[100],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE warehouse_category (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    name VARCHAR[120],
    parent_id INTEGER DEFAULT NULL REFERENCES warehouse_category(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE warehouse_item (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    name VARCHAR[255],
    price FLOAT,
    tva FLOAT,
    categories INTEGER REFERENCES categories(id) DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE warehouse_stock_item (
    item INTEGER REFERENCES warehouse_item(id),
    warehouse INTEGER REFERENCES warehouse(id),
    quantity INTEGER
);

CREATE TABLE maintenance (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    truck_id INTEGER REFERENCES truck(id),
    status maintenance_status NOT NULL DEFAULT 'waiting',
    invoice INTEGER DEFAULT NULL REFERENCES invoice(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE maintenance_info (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    maintenance_id INTEGER REFERENCES maintenance(id),
    info TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE invoice (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    recipient invoice_recipient,
    "from" VARCHAR[255],
    user_id INTEGER DEFAULT NULL REFERENCES "user"(id),
    customer_id INTEGER DEFAULT NULL REFERENCES customer(id),
    status boolean DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE invoice_line (
    invoice_id INTEGER REFERENCES invoice(id),
    text VARCHAR[255],
    quantity INT,
    price FLOAT
);

CREATE TABLE "user" (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    truck_id INTEGER REFERENCES truck(id) DEFAULT NULL,
    first_name VARCHAR[100],
    last_name VARCHAR[100],
    email VARCHAR[255],
    password CHAR[60],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE card_category (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    name VARCHAR[100],
    card INTEGER REFERENCES card(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE card (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    name VARCHAR[100],
    user_id INTEGER REFERENCES user(id)
);

CREATE TABLE card_item (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    category_id INTEGER REFERENCES card_category(id),
    name VARCHAR[120],
    price FLOAT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE event (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    name VARCHAR[100],
    start_at TIMESTAMP,
    end_at TIMESTAMP,
    begin_register_at TIMESTAMP,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE event_user (
    event_id INTEGER REFERENCES event(id),
    user_id INTEGER REFERENCES user(id),
    PRIMARY KEY (event_id, user_id)
);

CREATE TABLE promotion (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    user_id INTEGER REFERENCES "user"(id),
    name VARCHAR[100],
    code VARCHAR[12] DEFAULT NULL,
    start_at TIMESTAMP,
    end_at TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE promotion_target (
    promotion_id INTEGER REFERENCES promotion(id) PRIMARY KEY,
    card_item_id INTEGER REFERENCES card_item(id) DEFAULT NULL,
    card_category INTEGER REFERENCES card_category(id) DEFAULT NULL
);

CREATE TABLE customer (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    first_name VARCHAR[100],
    last_name VARCHAR[100],
    email VARCHAR[255],
    password CHAR[60],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE address (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    country VARCHAR[100],
    city VARCHAR[100],
    address_line_1 VARCHAR[255],
    address_line_2 VARCHAR[255],
    type type_address,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE address_customer (
    address_id INTEGER REFERENCES address(id),
    customer_id INTEGER REFERENCES customer(id),
    PRIMARY KEY (customer_id, address_id)
);

CREATE TABLE fidelity_card (
    customer_id INTEGER REFERENCES customer(id) PRIMARY KEY,
    nb_point INTEGER,
    end_at TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    customer_id INTEGER REFERENCES customer(id),
    user_id INTEGER REFERENCES "user"(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_line (
    order_id INTEGER REFERENCES order(id),
    text VARCHAR[255],
    quantity INT,
    price FLOAT
);

