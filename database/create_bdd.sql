CREATE TYPE location AS (
    longitude DOUBLE PRECISION,
    latitude DOUBLE PRECISION
);

CREATE TYPE schedule AS (
    text_schedule TEXT
);

CREATE TYPE customer_status AS ENUM (
    'banned',
    'active',
    'unvalidated'
);

CREATE TYPE type_address AS ENUM (
    'facturation',
    'livraison'
);

CREATE TYPE type_promo AS ENUM (
    'all',
    'code',
    'product'
);

CREATE TYPE ticket_status AS ENUM (
    'open',
    'close',
    'in progress'
);


CREATE TYPE type_event AS ENUM (
    'tasting',
    'paulée',
    'wine&music',
    'masterclass'
);

-- table

CREATE table franchisee (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    name VARCHAR[100],
    qr_code VARCHAR[255],
    created_at TIMESTAMP
);

CREATE TABLE admin_franchisee (
    id serial UNIQUE NOT NULL PRIMARY KEY,
    first_name VARCHAR[100],
    last_name VARCHAR[100],
    email VARCHAR[255],
    password CHAR[60],
    created_at TIMESTAMP
);

CREATE TABLE access_franchisee (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    name VARCHAR[120],
    created_at TIMESTAMP
);

CREATE TABLE access_franchisee_x_admin_franchisee (
    admin_franchisee_id INTEGER REFERENCES admin_franchisee(id),
    access_franchisee_id INTEGER REFERENCES access_franchisee(id),
    PRIMARY KEY (admin_franchisee_id, access_franchisee_id)
);

CREATE TABLE franchisee_x_admin_franchisee (
    franchisee_id INTEGER REFERENCES franchisee(id),
    admin_franchisee_id INTEGER REFERENCES admin_franchisee(id),
    PRIMARY KEY (franchisee_id, admin_franchisee_id)
);

CREATE TABLE truck (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    franchisees_id INTEGER REFERENCES franchisee(id),
    name VARCHAR[100],
    location location,
    created_at TIMESTAMP,
    schedule schedule
);

CREATE TABLE promotion (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    name VARCHAR[120],
    type type_promo,
    amount REAL,
    order_level INTEGER NULL,
    start_at TIMESTAMP,
    end_at TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE customer (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    first_name VARCHAR[100],
    last_name VARCHAR[100],
    email VARCHAR[255],
    password CHAR[60],
    created_at TIMESTAMP,
    status customer_status
);

CREATE TABLE ticket (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    customer_id INTEGER REFERENCES customer(id),
    text text,
    created_at TIMESTAMP,
    status ticket_status DEFAULT 'open'
);

CREATE TABLE fidelity_card (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    customer_id INTEGER REFERENCES customer(id),
    perumtion_date TIMESTAMP,
    created_at TIMESTAMP,
    point INTEGER
);

CREATE TABLE address (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    id_customer INTEGER REFERENCES customer(id),
    country VARCHAR[255],
    city VARCHAR[255],
    number VARCHAR[30],
    address_line VARCHAR[255],
    type type_address,
    created_at TIMESTAMP
);

CREATE TABLE event (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    name VARCHAR[120],
    start_at TIMESTAMP,
    end_at TIMESTAMP,
    created_at TIMESTAMP,
    enter_price REAL,
    type type_event
);

CREATE TABLE event_x_truck (
    event_id INTEGER REFERENCES event(id),
    truck_id INTEGER REFERENCES truck(id),
    PRIMARY KEY (event_id, truck_id)
);

CREATE TABLE event_x_customer_id (
    event_id INTEGER REFERENCES event(id),
    customer_id INTEGER REFERENCES customer(id),
    PRIMARY KEY (event_id, customer_id)
);

CREATE TABLE admin (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    first_name VARCHAR[100],
    last_name VARCHAR[100],
    email VARCHAR[255],
    password CHAR[60],
    created_at TIMESTAMP
);

CREATE TABLE access_admin (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    name VARCHAR[120],
    created_at TIMESTAMP
);

CREATE TABLE access_admin_x_admin (
    admin_id INTEGER REFERENCES admin(id),
    access_admin_id INTEGER REFERENCES access_admin(id),
    PRIMARY KEY (admin_id, access_admin_id)
);

CREATE TABLE provider (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    name VARCHAR[120],
    contact VARCHAR[255],
    country VARCHAR[255],
    created_at TIMESTAMP
);

CREATE TABLE categories (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    name VARCHAR[120],
    created_at TIMESTAMP
);

CREATE TABLE item (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    name VARCHAR[255],
    price REAL,
    categories INTEGER REFERENCES categories(id),
    created_at TIMESTAMP
);

CREATE TABLE warehouse (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    location location,
    name VARCHAR[100],
    created_at TIMESTAMP
);

CREATE TABLE item_stock (
    warehouses_id  INTEGER REFERENCES warehouse(id),
    item_id INTEGER REFERENCES item(id),
    quantity INTEGER,
    PRIMARY KEY (warehouses_id, item_id)
);

CREATE TABLE order_provider (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    provider_id INTEGER REFERENCES provider(id),
    admin_id INTEGER REFERENCES admin(id),
    created_at TIMESTAMP
);

CREATE TABLE order_provider_line (
    order_provider_id INTEGER REFERENCES order_provider(id),
    item_id INTEGER,
    quantity REAL,
    PRIMARY KEY (order_provider_id, item_id)
);

CREATE TABLE order_franchisee (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    admin_Franchisees_id INTEGER REFERENCES admin_franchisee(id),
    created_at TIMESTAMP
);

CREATE TABLE order_franchisee_line (
    order_franchisee_id INTEGER REFERENCES order_franchisee(id),
    item_id INTEGER REFERENCES item(id),
    quantity INTEGER,
    price REAL,
    PRIMARY KEY (order_franchisee_id, item_id)
);

CREATE TABLE customer_order (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    customer_id INTEGER REFERENCES customer(id),
    created_at TIMESTAMP,
    truck_id INTEGER REFERENCES truck(id)
);

CREATE TABLE card_categories (
    id  SERIAL UNIQUE NOT NULL PRIMARY KEY,
    name VARCHAR[100],
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE card (
    id  SERIAL UNIQUE NOT NULL PRIMARY KEY,
    name varchar[120],
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    truck_id INTEGER REFERENCES truck(id)
);

CREATE TABLE card_categories_x_card (
    card_id  INTEGER REFERENCES card(id),
    card_categorie_id INTEGER REFERENCES card_categories(id),
    PRIMARY KEY (card_id, card_categorie_id)
);

CREATE TABLE card_item (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    card_categories_id INTEGER REFERENCES card_categories(id),
    name VARCHAR[120],
    price REAL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE customer_order_line (
    customer_order_id INTEGER REFERENCES customer_order(id),
    card_item_id INTEGER REFERENCES card_item(id),
    quantity REAL,
    PRIMARY KEY (customer_order_id, card_item_id)
);

CREATE TABLE promotion_target (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    promotion_id INTEGER REFERENCES promotion(id),
    truck_id INTEGER REFERENCES truck(id),
    card_item_id INTEGER REFERENCES card_item(id)
);

CREATE TABLE history (
    id SERIAL UNIQUE NOT NULL PRIMARY KEY,
    admin_id INTEGER REFERENCES admin(id) NULL,
    admin_franchisee_id INTEGER REFERENCES admin_franchisee(id) NULL,
    created_at TIMESTAMP,
    action VARCHAR[255],
    before jsonb,
    after jsonb
);

create table migrations
(
    version INTEGER not null
);
