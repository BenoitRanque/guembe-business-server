CREATE TABLE BEGIN;

CREATE SCHEMA client;
CREATE TABLE client.account;
CREATE TABLE client.authentication_provider;
CREATE TABLE client.authentication;
CREATE TABLE client.;
CREATE SCHEMA staff;
CREATE TABLE staff.account (
    account_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

);
CREATE TABLE staff.role (
    role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_name TEXT NOT NULL UNIQUE,
    description TEXT
);
CREATE TABLE staff.account_role (
    account_id UUID REFERENCES staff.account(account_id),
    role_id UUID REFERENCES staff.account(role_id)
);

CREATE SCHEMA shop;
CREATE TABLE shop.article (
    article_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    article_name TEXT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL REFERENCES staff.account (account_id),
    updated_by UUID NOT NULL REFERENCES staff.account (account_id)
);
CREATE TABLE shop.listing (
    listing_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_name TEXT,
    description TEXT,
    available_from DATE WITH TIME ZONE, -- when this will be available in store
    available_to DATE WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL REFERENCES staff.account (account_id),
    updated_by UUID NOT NULL REFERENCES staff.account (account_id)
);
CREATE TABLE shop.listing_article (
    listing_id UUID NOT NULL REFERENCES shop.listing (listing_id),
    article_id UUID NOT NULL REFERENCES shop.article (article_id),
    unit_count INT CHECK (unit_count > 0),
    unit_price INT CHECK (unit_price >= 0),
    lifetime_id UUID NOT NULL REFERENCES shop.lifetime (lifetime_id)
    PRIMARY KEY (listing_id, article_id)
);

CREATE TABLE shop.lifetime {
    lifetime_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    private_name TEXT NOT NULL,
    public_name TEXT NOT NULL,
    description TEXT,
    "start" DATE NOT NULL,
    "end" DATE NOT NULL
}

CREATE TABLE shop.lifetime_day {
    lifetime_id UUID NOT NULL REFERENCES shop.lifetime (lifetime_id),
    day_id TEXT NOT NULL REFERENCES calendar.day (day_id)
        ON UPDATE CASCADE,
    PRIMARY (lifetime_id, day_id)
}

CREATE SCHEMA calendar;

CREATE TABLE calendar.day (
    day_id INT PRIMARY KEY,
    day_name TEXT NOT NULL
);

INSERT INTO calendar.day (day_id, day_name) VALUES
    (0, 'Lunes'),
    (1, 'Martes'),
    (2, 'Miercoles'),
    (3, 'Jueves'),
    (4, 'Viernes'),
    (5, 'Sabado'),
    (6, 'Domingo');
    (7, 'Feriados'),

CREATE TABLE calendar.holiday (
    holiday_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    holiday_name TEXT NOT NULL,
    description TEXT,
    holiday_date DATE NOY NULL
);









CREATE SCHEMA product;
                listing -- a listing is a combo of 1 or more products. It has display limits, by date or stock
                        -- todo: how does a listing react if a product is updated/replaced?
CREATE TABLE product.listing (name, description, price);
CREATE TABLE sale_listing_item (); -- all listings are combos.
CREATE TABLE product.sale_range (listing, use_range, display_from, display_to, use_range, stock)
CREATE TABLE product.use_range (listing, strategy);

CREATE TABLE product.combo (name)
CREATE TABLE product.combo_listing (listing)

CREATE TABLE sale ()
CREATE TABLE sale_item (item, amount)

CREATE SCHEMA metadata;
CREATE TABLE metadata.holidays (id, name, description, date)
CREATE TABLE metadata.weekdays (id, name, description)

CREATE SCHEMA product;
CREATE TABLE transaction.sale;
CREATE TABLE transaction.;

sale {
    items: {
        listings {
            product
        }
    }
}
product_pending_use (client_id, product_id, sale_id, pending)
product_pending_use (client_id, product_id, sale_id, pending)
sale
sale_item
sale_item_use
listing (listing_item, available_from, available_to, stock)
listing_product (product, price)
product (name, description)
listing_use (from, to) -- link this to product or listing? thinking listing. Should price be a part of listing?

sale (client_id)
sale_listing (listing)

-- define how listing reacts to product change
--

CREATE TABLE listing (listing_id, available_from, available_to, created_at, updated_at, created_by, updated_by)
CREATE TABLE available_days (listing_id, day, PRIMARY KEY (listing_id, day))
CREATE TABLE listing_product (listing_id, product_id, unit_count, unit_price, PRIMARY KEY (listing_id, product_id))
CREATE TABLE product (product_id, product_name, description, created_at, updated_at, created_by, updated_by)

CREATE SCHEMA metadata;
CREATE TABLE metadata.holidays (id, name, description, date)
CREATE TABLE metadata.weekdays (id, name, description)

weekdays (id, name, description)

CREATE TABLE sales.product (
    product_id
    name
    description
    price INT
    created_at
    updated_at
    created_by
    updated_by
);
CREATE TABLE product_activation {
    activation_id
    product_id
-- link to validity table
-- limited stock
-- validate during specific time period
-- sale_validity
-- use_valid period
-- validation period
-- validation strategies: product valid on specific weekdays (plus days 8 = holidays)
-- validation strategies: product valid during specific date range
-- validation strategies: product valid specific time (from purchase date)

    created_at
    updated_at
    created_by
    updated_by
}
product
    item
    activation
    activation days -- 7 days of the week plus holidays

holiday table


CREATE TABLE sales.product_version;

CREATE TABLE client.account(
    account_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name TEXT,
    middle_name TEXT,
    last_name TEXT,
    email TEXT,
    phone TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TRIGGER client_account_set_updated_at BEFORE UPDATE ON client.account
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE client.authentication_provider (
    name TEXT PRIMARY KEY
);

CREATE TABLE client.authentication (
	account_id UUID NOT NULL REFERENCES client.account (account_id),
    authentication_provider_name TEXT NOT NULL REFERENCES client.authentication_provider (name),
	authentication_id TEXT NOT NULL,
	PRIMARY (provider_name, authentication_id)
);

CREATE TABLE client.billing (
	account_id
	nit
	razon social

);
payment table
payment
sale
INSERT INTO client.auth_provider
    (name)
VALUES
    ('google'),
    ('facebook');

COMMIT;