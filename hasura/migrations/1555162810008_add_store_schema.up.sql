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
    available_from DATE, -- when this will be available in store
    available_to DATE,
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

CREATE TABLE store.purchase_listing (
    purchase_id UUID NOT NULL REFERENCES store.purchase (purchase_id),
    listing_id UUID NOT NULL REFERENCES store.listing (listing_id),
    listing_count INT NOT NULL CHECK (listing_count > 0),
    PRIMARY KEY (purchase_id, listing_id)
);

CREATE TABLE store.payment (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchase_id UUID NOT NULL REFERENCES store.purchase (purchase_id),
    -- pending payment data goes here
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER store_payment_set_updated_at BEFORE UPDATE ON store.payment
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- this is created in response to khipu cancellation of payment
-- payment can only be cancelled if it has not yet been confirmed
CREATE TABLE store.payment_cancellation (
    payment_cancellation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL REFERENCES store.payment (payment_id),
    -- successful payment data goes here
    -- when this is created, redeemable products should be created too
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER store_payment_cancellation_set_updated_at BEFORE UPDATE ON store.payment_cancellation
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- this is created in response to khipu confirmation of payment
CREATE TABLE store.payment_confirmation (
    payment_confirmation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL REFERENCES store.payment (payment_id),
    -- successful payment data goes here
    -- when this is created, redeemable products should be created too
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER store_payment_confirmation_set_updated_at BEFORE UPDATE ON store.payment_confirmation
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- create when payment is confirmed
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

CREATE TABLE store.used_product (
    used_product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchased_product_id UUID NOT NULL REFERENCES store.purchased_product (purchased_product_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    -- this might not be sufficient. Need checking with hasura permissions
    cancelled BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE TRIGGER store_used_product_set_updated_at BEFORE UPDATE ON store.used_product
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

COMMIT;