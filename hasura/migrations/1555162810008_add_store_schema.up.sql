BEGIN;

CREATE SCHEMA store;

CREATE TABLE store.authentication_provider (
    provider_name TEXT PRIMARY KEY
);

INSERT INTO store.authentication_provider
    (provider_name)
VALUES
    ('google'),
    ('facebook');

CREATE TABLE store.client (
    client_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT,
    first_name TEXT,
    middle_name TEXT,
    last_name TEXT,
    email TEXT,
    -- phone TEXT,
    authentication_provider_name TEXT NOT NULL REFERENCES store.authentication_provider (provider_name),
    authentication_account_id TEXT NOT NULL,
    UNIQUE (authentication_provider_name, authentication_account_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER store_client_set_updated_at BEFORE UPDATE ON store.client
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE store.product (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_name TEXT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES staff.user (user_id)
);
CREATE TRIGGER store_product_set_updated_at BEFORE UPDATE ON store.product
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE store.listing (
    listing_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_name TEXT,
    description TEXT,
    available_from DATE NOT NULL, -- when this will be available in store
    available_to DATE NOT NULL,
    available_stock INTEGER CHECK (available_stock IS NULL OR available_stock > 0),
    created_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER store_listing_set_updated_at BEFORE UPDATE ON store.listing
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE store.listing_product (
    listing_id UUID NOT NULL REFERENCES store.listing (listing_id),
    product_id UUID NOT NULL REFERENCES store.product (product_id),
    product_count INT NOT NULL CHECK (product_count > 0),
    product_price INT NOT NULL CHECK (product_price >= 0),
    lifetime_id UUID NOT NULL REFERENCES calendar.lifetime (lifetime_id),
    PRIMARY KEY (listing_id, product_id)
);

CREATE TABLE store.purchase (
    purchase_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES store.client (client_id),
    cancelled BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER store_purchase_set_updated_at BEFORE UPDATE ON store.purchase
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- puchase cannot be updated while a payment exists

CREATE TABLE store.purchase_listing (
    purchase_id UUID NOT NULL REFERENCES store.purchase (purchase_id),
    listing_id UUID NOT NULL REFERENCES store.listing (listing_id),
    listing_count INT NOT NULL CHECK (listing_count > 0),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    PRIMARY KEY (purchase_id, listing_id)
);
CREATE TRIGGER store_purchase_listing_set_updated_at BEFORE UPDATE ON store.purchase_listing
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- puchase cannot be updated while a payment exists

CREATE TABLE store.payment (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchase_id UUID UNIQUE NOT NULL REFERENCES store.purchase (purchase_id),
    -- pending payment data goes here
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER store_payment_set_updated_at BEFORE UPDATE ON store.payment
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE store.payment_completion (
    payment_completion_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID UNIQUE NOT NULL REFERENCES store.payment (payment_id),
    cancelled BOOLEAN NOT NULL DEFAULT FALSE,
    -- successful payment data goes here
    -- when this is created, redeemable products should be created too
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER store_payment_completion_set_updated_at BEFORE UPDATE ON store.payment_completion
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- this is created in response to khipu cancellation of payment
-- payment can only be cancelled if it has not yet been confirmed

-- create when payment is completed successfully
-- this should be created after invoice is created, with the invoice response data such as invoice number
CREATE TABLE store.invoice (
    invoice_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchase_id UUID NOT NULL REFERENCES store.purchase (purchase_id),
    -- send email invoice when this is created
    -- invoice data must go here.
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER store_invoice_set_updated_at BEFORE UPDATE ON store.invoice
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- create when payment is confirmed
CREATE TABLE store.purchased_product (
    purchased_product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchase_id UUID NOT NULL REFERENCES store.purchase (purchase_id),
    product_id UUID NOT NULL REFERENCES store.product (product_id),
    lifetime_id UUID NOT NULL REFERENCES calendar.lifetime (lifetime_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER store_puchased_product_set_updated_at BEFORE UPDATE ON store.purchased_product
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE store.purchased_product_usage (
    purchased_product_usage_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchased_product_id UUID NOT NULL REFERENCES store.purchased_product (purchased_product_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    -- this might not be sufficient. Need checking with hasura permissions
    cancelled BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE TRIGGER store_purchased_product_usage_set_updated_at BEFORE UPDATE ON store.purchased_product_usage
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- once a payment exists, a purchase cannot be modified
CREATE FUNCTION store.do_not_modify_paid_purchase()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(SELECT 1 FROM store.payment WHERE purchase_id = OLD.purchase_id) THEN
        RAISE EXCEPTION 'Modifying a paid purchase is not allowed';
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER store_purchase_do_not_modify_paid_purchase
    BEFORE UPDATE OR DELETE ON store.purchase
    FOR EACH ROW EXECUTE FUNCTION store.do_not_modify_paid_purchase();

CREATE TRIGGER store_purchase_listing_do_not_modify_paid_purchase
    BEFORE UPDATE OR DELETE ON store.purchase_listing
    FOR EACH ROW EXECUTE FUNCTION store.do_not_modify_paid_purchase();

-- Each client can only have a single purchase without payment. Do not allow insert of another
-- note unpaid means payment not created, no nescesarily completed.
CREATE FUNCTION store.allow_one_unpaid_purchase_per_client()
RETURNS TRIGGER AS $$
BEGIN
    -- if unpaid purchase exists
    IF EXISTS (
        SELECT 1 FROM store.purchase
        LEFT JOIN store.payment ON store.purchase.purchase_id = store.payment.purchase_id
        WHERE store.purchase.client_id = NEW.client_id
        AND store.payment.payment_id = NULL
    ) THEN
        RAISE EXCEPTION 'Cannot create more than one unpaid purchase. Please update or delete any unpaid purchases';
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER store_purchase_allow_one_unpaid_purchase_per_client
    BEFORE INSERT ON store.purchase
    FOR EACH ROW EXECUTE FUNCTION store.allow_one_unpaid_purchase_per_client();

-- created purchased products if payment confirmation is properly received

CREATE FUNCTION store.create_purchased_products()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.cancelled = FALSE THEN

        -- INSERT INTO store.purchased_product (purchase_id, product_id, lifetime_id)
        -- SELECT
        --     store.payment.purchase_id,
        --     store.listing_product.product_id,
        --     store.listing_product.lifetime_id,
        --     store.purchase_listing.listing_count,
        --     store.listing_product.product_count
        -- FROM store.payment
        -- LEFT JOIN store.purchase_listing ON store.payment.purchase_id = store.purchase_listing.purchase_id
        -- LEFT JOIN store.listing_product ON store.purchase_listing.listing_id = store.listing_product.listing_id
        -- WHERE store.payment.payment_id = NEW.payment_id

        WITH listings AS (
            SELECT
                store.payment.purchase_id,
                store.listing_product.product_id,
                store.listing_product.lifetime_id,
                store.purchase_listing.listing_count,
                store.listing_product.product_count,
                2
            FROM store.payment
            LEFT JOIN store.purchase_listing ON store.payment.purchase_id = store.purchase_listing.purchase_id
            LEFT JOIN store.listing_product ON store.purchase_listing.listing_id = store.listing_product.listing_id
            WHERE store.payment.payment_id = '0e3df8f3-2225-46e2-b660-a4f3332891ed'
        ) FOR listing IN listings LOOP

        END LOOP;

        FOR listing (purchase_id) IN
            SELECT
                store.payment.purchase_id,
                store.listing_product.product_id,
                store.listing_product.lifetime_id,
                store.purchase_listing.listing_count,
                store.listing_product.product_count,
                2
            FROM store.payment
            LEFT JOIN store.purchase_listing ON store.payment.purchase_id = store.purchase_listing.purchase_id
            LEFT JOIN store.listing_product ON store.purchase_listing.listing_id = store.listing_product.listing_id
            WHERE store.payment.payment_id = '0e3df8f3-2225-46e2-b660-a4f3332891ed'
        LOOP

        END LOOP;



        -- BEGIN;

        -- WITH purchased_products (purchase_id, product_id, lifetime_id, listing_count, product_count) AS (
        --     SELECT
        --         store.payment.purchase_id,
        --         store.listing_product.product_id,
        --         store.listing_product.lifetime_id,
        --         store.purchase_listing.listing_count,
        --         store.listing_product.product_count
        --     FROM store.payment
        --     LEFT JOIN store.purchase_listing ON store.payment.purchase_id = store.purchase_listing.purchase_id
        --     LEFT JOIN store.listing_product ON store.purchase_listing.listing_id = store.listing_product.listing_id
        --     WHERE store.payment.payment_id = NEW.payment_id
        -- )
        -- total product count is row * listing count * product count


        -- INSERT INTO store.purchased_product (purchase_id, product_id, lifetime_id)
        -- VALUES ()


        -- COMMIT;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER store_payment_completion_create_purchased_products
    AFTER INSERT ON store.payment_completion
    FOR EACH ROW EXECUTE FUNCTION store.create_purchased_products();

COMMIT;