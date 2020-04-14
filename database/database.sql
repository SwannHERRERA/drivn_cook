create type location as
(
    longitude double precision,
    latitude  double precision
);

create type maintenance_status as enum ('waiting', 'processing', 'finish');

create type invoice_recipient as enum ('drivncook', 'customer', 'user');

create type type_address as enum ('delivery', 'invoice');

create table if not exists admin
(
    id         serial not null
        constraint admin_pkey
            primary key,
    first_name character varying[],
    last_name  character varying[],
    email      character varying[],
    password   char[],
    created_at timestamp with time zone default CURRENT_TIMESTAMP
);

create table if not exists truck
(
    id            serial not null
        constraint truck_pkey
            primary key,
    matriculation character varying[],
    location      location,
    created_at    timestamp with time zone default CURRENT_TIMESTAMP
);

create table if not exists warehouse
(
    id         serial not null
        constraint warehouse_pkey
            primary key,
    location   location,
    name       character varying[],
    created_at timestamp with time zone default CURRENT_TIMESTAMP
);

create table if not exists warehouse_category
(
    id         serial not null
        constraint warehouse_category_pkey
            primary key,
    name       character varying[],
    parent_id  integer
        constraint warehouse_category_parent_id_fkey
            references warehouse_category,
    created_at timestamp with time zone default CURRENT_TIMESTAMP
);

create table if not exists warehouse_item
(
    id         serial not null
        constraint warehouse_item_pkey
            primary key,
    name       character varying[],
    price      double precision,
    tva        double precision,
    category   integer
        constraint warehouse_item_category_fkey
            references warehouse_category,
    created_at timestamp with time zone default CURRENT_TIMESTAMP
);

create table if not exists warehouse_stock_item
(
    item      integer
        constraint warehouse_stock_item_item_fkey
            references warehouse_item,
    warehouse integer
        constraint warehouse_stock_item_warehouse_fkey
            references warehouse,
    quantity  integer
);

create table if not exists "user"
(
    id         serial not null
        constraint user_pkey
            primary key,
    truck_id   integer
        constraint user_truck_id_fkey
            references truck,
    first_name character varying[],
    last_name  character varying[],
    email      character varying[],
    password   char[],
    created_at timestamp with time zone default CURRENT_TIMESTAMP
);

create table if not exists customer
(
    id         serial not null
        constraint customer_pkey
            primary key,
    first_name character varying[],
    last_name  character varying[],
    email      character varying[],
    password   char[],
    created_at timestamp with time zone default CURRENT_TIMESTAMP
);

create table if not exists invoice
(
    id          serial not null
        constraint invoice_pkey
            primary key,
    recipient   invoice_recipient,
    "from"      character varying[],
    user_id     integer
        constraint invoice_user_id_fkey
            references "user",
    customer_id integer
        constraint invoice_customer_id_fkey
            references customer,
    status      boolean                  default false,
    created_at  timestamp with time zone default CURRENT_TIMESTAMP
);

create table if not exists invoice_line
(
    invoice_id integer
        constraint invoice_line_invoice_id_fkey
            references invoice,
    text       character varying[],
    quantity   integer,
    price      double precision
);

create table if not exists maintenance
(
    id         serial                                                         not null
        constraint maintenance_pkey
            primary key,
    truck_id   integer
        constraint maintenance_truck_id_fkey
            references truck,
    status     maintenance_status       default 'waiting'::maintenance_status not null,
    invoice    integer
        constraint maintenance_invoice_fkey
            references invoice,
    created_at timestamp with time zone default CURRENT_TIMESTAMP
);

create table if not exists maintenance_info
(
    id             serial not null
        constraint maintenance_info_pkey
            primary key,
    maintenance_id integer
        constraint maintenance_info_maintenance_id_fkey
            references maintenance,
    info           text,
    created_at     timestamp with time zone default CURRENT_TIMESTAMP
);

create table if not exists card
(
    id      serial not null
        constraint card_pkey
            primary key,
    name    character varying[],
    user_id integer
        constraint card_user_id_fkey
            references "user"
);

create table if not exists card_category
(
    id         serial not null
        constraint card_category_pkey
            primary key,
    name       character varying[],
    card       integer
        constraint card_category_card_fkey
            references card,
    created_at timestamp with time zone default CURRENT_TIMESTAMP
);

create table if not exists card_item
(
    id          serial not null
        constraint card_item_pkey
            primary key,
    category_id integer
        constraint card_item_category_id_fkey
            references card_category,
    name        character varying[],
    price       double precision,
    created_at  timestamp with time zone default CURRENT_TIMESTAMP
);

create table if not exists event
(
    id                serial not null
        constraint event_pkey
            primary key,
    name              character varying[],
    start_at          timestamp,
    end_at            timestamp,
    begin_register_at timestamp,
    description       text,
    created_at        timestamp with time zone default CURRENT_TIMESTAMP
);

create table if not exists event_user
(
    event_id integer not null
        constraint event_user_event_id_fkey
            references event,
    user_id  integer not null
        constraint event_user_user_id_fkey
            references "user",
    constraint event_user_pkey
        primary key (event_id, user_id)
);

create table if not exists promotion
(
    id         serial not null
        constraint promotion_pkey
            primary key,
    user_id    integer
        constraint promotion_user_id_fkey
            references "user",
    name       character varying[],
    code       character varying[],
    start_at   timestamp,
    end_at     timestamp,
    created_at timestamp with time zone default CURRENT_TIMESTAMP
);

create table if not exists promotion_target
(
    promotion_id  integer not null
        constraint promotion_target_pkey
            primary key
        constraint promotion_target_promotion_id_fkey
            references promotion,
    card_item_id  integer
        constraint promotion_target_card_item_id_fkey
            references card_item,
    card_category integer
        constraint promotion_target_card_category_fkey
            references card_category
);

create table if not exists address
(
    id             serial not null
        constraint address_pkey
            primary key,
    country        character varying[],
    city           character varying[],
    address_line_1 character varying[],
    address_line_2 character varying[],
    type           type_address,
    created_at     timestamp with time zone default CURRENT_TIMESTAMP
);

create table if not exists address_customer
(
    address_id  integer not null
        constraint address_customer_address_id_fkey
            references address,
    customer_id integer not null
        constraint address_customer_customer_id_fkey
            references customer,
    constraint address_customer_pkey
        primary key (customer_id, address_id)
);

create table if not exists fidelity_card
(
    customer_id integer not null
        constraint fidelity_card_pkey
            primary key
        constraint fidelity_card_customer_id_fkey
            references customer,
    nb_point    integer,
    end_at      timestamp,
    created_at  timestamp with time zone default CURRENT_TIMESTAMP
);

create table if not exists "order"
(
    id          serial not null
        constraint order_pkey
            primary key,
    customer_id integer
        constraint order_customer_id_fkey
            references customer,
    user_id     integer
        constraint order_user_id_fkey
            references "user",
    created_at  timestamp with time zone default CURRENT_TIMESTAMP
);

create table if not exists order_line
(
    order_id integer
        constraint order_line_order_id_fkey
            references "order",
    text     character varying[],
    quantity integer,
    price    double precision
);

