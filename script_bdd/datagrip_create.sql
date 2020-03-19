create table franchisee
(
    id         serial not null
        constraint franchisee_pkey
            primary key,
    name       character varying[],
    qr_code    character varying[],
    created_at timestamp
);

alter table franchisee
    owner to postgres;

create table admin_franchisee
(
    id         serial not null
        constraint admin_franchisee_pkey
            primary key,
    first_name character varying[],
    last_name  character varying[],
    email      character varying[],
    password   char[],
    created_at timestamp
);

alter table admin_franchisee
    owner to postgres;

create table access_franchisee
(
    id         serial not null
        constraint access_franchisee_pkey
            primary key,
    name       character varying[],
    created_at timestamp
);

alter table access_franchisee
    owner to postgres;

create table access_franchisee_x_admin_franchisee
(
    admin_franchisee_id  integer not null
        constraint access_franchisee_x_admin_franchisee_admin_franchisee_id_fkey
            references admin_franchisee,
    access_franchisee_id integer not null
        constraint access_franchisee_x_admin_franchisee_access_franchisee_id_fkey
            references access_franchisee,
    constraint access_franchisee_x_admin_franchisee_pkey
        primary key (admin_franchisee_id, access_franchisee_id)
);

alter table access_franchisee_x_admin_franchisee
    owner to postgres;

create table franchisee_x_admin_franchisee
(
    franchisee_id       integer not null
        constraint franchisee_x_admin_franchisee_franchisee_id_fkey
            references franchisee,
    admin_franchisee_id integer not null
        constraint franchisee_x_admin_franchisee_admin_franchisee_id_fkey
            references admin_franchisee,
    constraint franchisee_x_admin_franchisee_pkey
        primary key (franchisee_id, admin_franchisee_id)
);

alter table franchisee_x_admin_franchisee
    owner to postgres;

create table truck
(
    id             serial not null
        constraint truck_pkey
            primary key,
    franchisees_id integer
        constraint truck_franchisees_id_fkey
            references franchisee,
    name           character varying[],
    location       location,
    created_at     timestamp,
    schedule       schedule
);

alter table truck
    owner to postgres;

create table promotion
(
    id         serial not null
        constraint promotion_pkey
            primary key,
    name       character varying[],
    type       type_promo,
    amount     real,
    start_at   timestamp,
    end_at     timestamp,
    created_at timestamp
);

alter table promotion
    owner to postgres;

create table promotion_x_truck
(
    promotion_id integer not null
        constraint promotion_x_truck_promotion_id_fkey
            references promotion,
    truck_id     integer not null
        constraint promotion_x_truck_truck_id_fkey
            references truck,
    constraint promotion_x_truck_pkey
        primary key (promotion_id, truck_id)
);

alter table promotion_x_truck
    owner to postgres;

create table customer
(
    id         serial not null
        constraint customer_pkey
            primary key,
    first_name character varying[],
    last_name  character varying[],
    email      character varying[],
    password   char[],
    created_at timestamp,
    status     customer_status
);

alter table customer
    owner to postgres;

create table ticket
(
    id          serial not null
        constraint ticket_pkey
            primary key,
    customer_id integer
        constraint ticket_customer_id_fkey
            references customer,
    text        text,
    created_at  timestamp,
    status      ticket_status default 'open'::ticket_status
);

alter table ticket
    owner to postgres;

create table fidelity_card
(
    id             serial not null
        constraint fidelity_card_pkey
            primary key,
    customer_id    integer
        constraint fidelity_card_customer_id_fkey
            references customer,
    perumtion_date timestamp,
    created_at     timestamp,
    point          integer
);

alter table fidelity_card
    owner to postgres;

create table address
(
    id           serial not null
        constraint address_pkey
            primary key,
    id_customer  integer
        constraint address_id_customer_fkey
            references customer,
    country      character varying[],
    city         character varying[],
    number       character varying[],
    address_line character varying[],
    type         type_address,
    created_at   timestamp
);

alter table address
    owner to postgres;

create table event
(
    id          serial not null
        constraint event_pkey
            primary key,
    name        character varying[],
    start_at    timestamp,
    end_at      timestamp,
    created_at  timestamp,
    enter_price real,
    type        type_event
);

alter table event
    owner to postgres;

create table event_x_truck
(
    event_id integer not null
        constraint event_x_truck_event_id_fkey
            references event,
    truck_id integer not null
        constraint event_x_truck_truck_id_fkey
            references truck,
    constraint event_x_truck_pkey
        primary key (event_id, truck_id)
);

alter table event_x_truck
    owner to postgres;

create table event_x_customer_id
(
    event_id    integer not null
        constraint event_x_customer_id_event_id_fkey
            references event,
    customer_id integer not null
        constraint event_x_customer_id_customer_id_fkey
            references customer,
    constraint event_x_customer_id_pkey
        primary key (event_id, customer_id)
);

alter table event_x_customer_id
    owner to postgres;

create table admin
(
    id         serial not null
        constraint admin_pkey
            primary key,
    first_name character varying[],
    last_name  character varying[],
    email      character varying[],
    password   char[],
    created_at timestamp
);

alter table admin
    owner to postgres;

create table access_admin
(
    id         serial not null
        constraint access_admin_pkey
            primary key,
    name       character varying[],
    created_at timestamp
);

alter table access_admin
    owner to postgres;

create table access_admin_x_admin
(
    admin_id        integer not null
        constraint access_admin_x_admin_admin_id_fkey
            references admin,
    access_admin_id integer not null
        constraint access_admin_x_admin_access_admin_id_fkey
            references access_admin,
    constraint access_admin_x_admin_pkey
        primary key (admin_id, access_admin_id)
);

alter table access_admin_x_admin
    owner to postgres;

create table provider
(
    id         serial not null
        constraint provider_pkey
            primary key,
    name       character varying[],
    contact    character varying[],
    country    character varying[],
    created_at timestamp
);

alter table provider
    owner to postgres;

create table categories
(
    id         serial not null
        constraint categories_pkey
            primary key,
    name       character varying[],
    created_at timestamp
);

alter table categories
    owner to postgres;

create table item
(
    id         serial not null
        constraint item_pkey
            primary key,
    name       character varying[],
    price      real,
    categories integer
        constraint item_categories_fkey
            references categories,
    created_at timestamp
);

alter table item
    owner to postgres;

create table warehouse
(
    id         serial not null
        constraint warehouse_pkey
            primary key,
    location   location,
    name       character varying[],
    created_at timestamp
);

alter table warehouse
    owner to postgres;

create table item_stock
(
    warehouses_id integer not null
        constraint item_stock_warehouses_id_fkey
            references warehouse,
    item_id       integer not null
        constraint item_stock_item_id_fkey
            references item,
    quantity      integer,
    constraint item_stock_pkey
        primary key (warehouses_id, item_id)
);

alter table item_stock
    owner to postgres;

create table order_provider
(
    id          serial not null
        constraint order_provider_pkey
            primary key,
    provider_id integer
        constraint order_provider_provider_id_fkey
            references provider,
    admin_id    integer
        constraint order_provider_admin_id_fkey
            references admin,
    created_at  timestamp
);

alter table order_provider
    owner to postgres;

create table order_provider_line
(
    order_provider_id integer not null
        constraint order_provider_line_order_provider_id_fkey
            references order_provider,
    item_id           integer not null,
    quantity          real,
    constraint order_provider_line_pkey
        primary key (order_provider_id, item_id)
);

alter table order_provider_line
    owner to postgres;

create table order_franchisee
(
    id                  serial not null
        constraint order_franchisee_pkey
            primary key,
    admin_franchisee_id integer
        constraint order_franchisee_admin_franchisee_id_fkey
            references admin_franchisee,
    created_at          timestamp
);

alter table order_franchisee
    owner to postgres;

create table order_franchisee_line
(
    order_franchisee_id integer not null
        constraint order_franchisee_line_order_franchisee_id_fkey
            references order_franchisee,
    item_id             integer not null
        constraint order_franchisee_line_item_id_fkey
            references item,
    quantity            integer,
    price               real,
    constraint order_franchisee_line_pkey
        primary key (order_franchisee_id, item_id)
);

alter table order_franchisee_line
    owner to postgres;

create table customer_order
(
    id          serial not null
        constraint customer_order_pkey
            primary key,
    customer_id integer
        constraint customer_order_customer_id_fkey
            references customer,
    created_at  timestamp,
    trucks_id   integer
        constraint customer_order_trucks_id_fkey
            references truck
);

alter table customer_order
    owner to postgres;

create table card_categories
(
    id         serial not null
        constraint card_categories_pkey
            primary key,
    name       character varying[],
    created_at timestamp,
    updated_at timestamp
);

alter table card_categories
    owner to postgres;

create table card
(
    id         serial not null
        constraint card_pkey
            primary key,
    name       character varying[],
    created_at timestamp,
    updated_at timestamp,
    truck_id   integer
        constraint card_truck_id_fkey
            references truck
);

alter table card
    owner to postgres;

create table card_categories_x_card
(
    card_id           integer not null
        constraint card_categories_x_card_card_id_fkey
            references card,
    card_categorie_id integer not null
        constraint card_categories_x_card_card_categorie_id_fkey
            references card_categories,
    constraint card_categories_x_card_pkey
        primary key (card_id, card_categorie_id)
);

alter table card_categories_x_card
    owner to postgres;

create table card_item
(
    id                 serial not null
        constraint card_item_pkey
            primary key,
    card_categories_id integer
        constraint card_item_card_categories_id_fkey
            references card_categories,
    name               character varying[],
    price              real,
    created_at         timestamp,
    updated_at         timestamp
);

alter table card_item
    owner to postgres;

create table promotion_x_card_item
(
    promotion_id integer not null
        constraint promotion_x_card_item_promotion_id_fkey
            references promotion,
    card_item_id integer not null
        constraint promotion_x_card_item_card_item_id_fkey
            references card_item,
    constraint promotion_x_card_item_pkey
        primary key (promotion_id, card_item_id)
);

alter table promotion_x_card_item
    owner to postgres;

create table customer_order_line
(
    customer_order_id integer not null
        constraint customer_order_line_customer_order_id_fkey
            references customer_order,
    card_item_id      integer not null
        constraint customer_order_line_card_item_id_fkey
            references card_item,
    quantity          real,
    constraint customer_order_line_pkey
        primary key (customer_order_id, card_item_id)
);

alter table customer_order_line
    owner to postgres;

create table history
(
    id                  serial not null
        constraint history_pkey
            primary key,
    admin_id            integer
        constraint history_admin_id_fkey
            references admin,
    admin_franchisee_id integer
        constraint history_admin_franchisee_id_fkey
            references admin_franchisee,
    created_at          timestamp,
    action              character varying[],
    before              jsonb,
    after               jsonb
);

alter table history
    owner to postgres;

create table migrations
(
    version integer not null
);

alter table migrations
    owner to postgres;


