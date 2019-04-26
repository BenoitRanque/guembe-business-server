BEGIN;

CREATE SCHEMA store;

CREATE TABLE store.authentication_provider (
    provider_name TEXT PRIMARY KEY
);

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

CREATE TABLE store.taxable_activity (
    taxable_activity_id INTEGER PRIMARY KEY,
    description TEXT
);

CREATE TABLE store.product (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    public_name TEXT,
    description TEXT,
    private_name TEXT,
    internal_product_id TEXT,
    taxable_activity_id INTEGER NOT NULL REFERENCES store.taxable_activity (taxable_activity_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES staff.user (user_id)
);
CREATE TRIGGER store_product_set_updated_at BEFORE UPDATE ON store.product
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE store.listing (
    listing_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    public_name TEXT,
    description TEXT,
    private_name TEXT,
    available_from DATE NOT NULL, -- when this will be available in store
    available_to DATE NOT NULL,
    -- TODO: add trigger to validate stock
    -- might validate stock in payment creation (race condition?)
    -- validate stock in trigger before payment creation. Throw error on failure.
    available_stock INTEGER CHECK (available_stock IS NULL OR available_stock > 0),
    created_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER store_listing_set_updated_at BEFORE UPDATE ON store.listing
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- TODO: verify if it is possible to use an after trigger to check if the listing has children
CREATE TABLE store.listing_product (
    listing_id UUID NOT NULL REFERENCES store.listing (listing_id)
        ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES store.product (product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    price INT NOT NULL CHECK (price >= 0),
    lifetime_id UUID NOT NULL REFERENCES calendar.lifetime (lifetime_id),
    PRIMARY KEY (listing_id, product_id)
);

CREATE TABLE store.purchase (
    purchase_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES store.client (client_id),
    locked BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER store_purchase_set_updated_at BEFORE UPDATE ON store.purchase
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- puchase cannot be updated while a payment exists

CREATE TABLE store.purchase_listing (
    purchase_id UUID NOT NULL REFERENCES store.purchase (purchase_id)
        ON DELETE CASCADE,
    listing_id UUID NOT NULL REFERENCES store.listing (listing_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    PRIMARY KEY (purchase_id, listing_id)
);
CREATE TRIGGER store_purchase_listing_set_updated_at BEFORE UPDATE ON store.purchase_listing
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
-- puchase cannot be updated while a payment exists

CREATE TABLE store.payment (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchase_id UUID UNIQUE NOT NULL REFERENCES store.purchase (purchase_id)
        ON DELETE CASCADE,
    amount INTEGER NOT NULL,
    -- khipu payment data goes here
    khipu_payment_id TEXT UNIQUE,
    khipu_payment_url TEXT,
    khipu_app_url TEXT,
    khipu_pay_me_url TEXT,
    khipu_amount TEXT,
    khipu_subject TEXT,
    khipu_body TEXT,
    khipu_payer_name TEXT,
    khipu_payer_email TEXt,
    khipu_status TEXT,
    khipu_conciliation_date TIMESTAMP WITH TIME ZONE,
    khipu_receipt_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER store_payment_set_updated_at BEFORE UPDATE ON store.payment
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE store.payment_completion (
    payment_completion_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID UNIQUE NOT NULL REFERENCES store.payment (payment_id)
        ON DELETE CASCADE,
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
    izi_id INTEGER,
    izi_timestamp TIMESTAMP WITH TIME ZONE,
    izi_link TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER store_invoice_set_updated_at BEFORE UPDATE ON store.invoice
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- create when payment is confirmed
CREATE TABLE store.purchased_product (
    purchased_product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchase_id UUID NOT NULL REFERENCES store.purchase (purchase_id)
        ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES store.product (product_id),
    lifetime_id UUID NOT NULL REFERENCES calendar.lifetime (lifetime_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER store_puchased_product_set_updated_at BEFORE UPDATE ON store.purchased_product
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE store.purchased_product_usage (
    purchased_product_usage_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchased_product_id UUID NOT NULL REFERENCES store.purchased_product (purchased_product_id)
        ON DELETE CASCADE,
    cancelled BOOLEAN DEFAULT false,
    cancelled_motive TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES staff.user (user_id)
);
CREATE TRIGGER store_purchased_product_usage_set_updated_at BEFORE UPDATE ON store.purchased_product_usage
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- once a payment exists, a purchase cannot be modified
CREATE FUNCTION store.do_not_modify_locked_purchase()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(
        SELECT 1 FROM store.purchase
        WHERE locked = true
        AND purchase_id = OLD.purchase_id
    ) THEN
        RAISE EXCEPTION 'Modifying a locked purchase is not allowed';
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER store_purchase_do_not_modify_locked_purchase
    BEFORE DELETE ON store.purchase
    FOR EACH ROW EXECUTE FUNCTION store.do_not_modify_locked_purchase();

CREATE TRIGGER store_purchase_listing_do_not_modify_locked_purchase
    BEFORE UPDATE OR DELETE ON store.purchase_listing
    FOR EACH ROW EXECUTE FUNCTION store.do_not_modify_locked_purchase();

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
        -- Our objective here is to insert purchased products in a single insert.
        -- This is a bit tricky as we go from a (product, quantity) scheme to one record per product,
        -- as we want to record product use individually
        -- We use a join on a list of numbers to select one line per product instance
        WITH numbers_list (number) AS (
            -- Generate a list of numbers from 1 to whatever the maximum quantity is
            -- Quantity comes from two different tables, so we calculate the max from both of them
            -- This is dynamic because while it does not matter if we have extra numbers,
            -- we must have no missing numbers, else the query would silently fail to insert all required records
            SELECT *
            FROM generate_series(1, (
                SELECT MAX(quantity) FROM (
                    SELECT store.listing_product.quantity AS quantity
                    FROM store.listing_product
                    UNION ALL
                    SELECT store.purchase_listing.quantity AS quantity
                    FROM store.purchase_listing
                ) AS quantities
            )::int)
        )
        INSERT INTO store.purchased_product (purchase_id, product_id, lifetime_id)
        SELECT
            store.payment.purchase_id,
            store.listing_product.product_id,
            store.listing_product.lifetime_id
        FROM store.payment
        LEFT JOIN store.purchase_listing ON store.payment.purchase_id = store.purchase_listing.purchase_id
        -- join on numbers list to get one record per purchase listing instance
        LEFT JOIN numbers_list AS listing_numbers ON listing_numbers.number <= store.purchase_listing.quantity
        LEFT JOIN store.listing_product ON store.purchase_listing.listing_id = store.listing_product.listing_id
        -- join on numbers list to get one record per listing product instance
        LEFT JOIN numbers_list AS product_numbers ON product_numbers.number <= store.listing_product.quantity
        WHERE store.payment.payment_id = NEW.payment_id;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER store_payment_completion_create_purchased_products
    AFTER INSERT ON store.payment_completion
    FOR EACH ROW EXECUTE FUNCTION store.create_purchased_products();

CREATE FUNCTION store.validate_and_lock_purchase_before_payment()
RETURNS TRIGGER AS $$
BEGIN
    -- validate available stock
    -- we select purchsase listings where:
        -- listing avaialable stock is not null (meaning there is a limit)
        -- the purchase listing belongs to the current purchase
        -- or locked purchases where the payment is not cancelled
        -- elonging to either the current purchase, or locked purchase where the payment is not cancelled
    -- we aggregate those by listing id, and check if the sum of the quantities is more than the available stock
    IF EXISTS(
        SELECT 1
        FROM store.purchase_listing
            LEFT JOIN store.listing ON store.listing.listing_id = store.purchase_listing.listing_id
            LEFT JOIN store.purchase ON store.purchase.purchase_id = store.purchase_listing.purchase_id
            LEFT JOIN store.payment ON store.payment.purchase_id = store.purchase.purchase_id
            LEFT JOIN store.payment_completion ON store.payment_completion.payment_id = store.payment.payment_id
        WHERE NOT store.listing.available_stock = NULL
        AND (store.purchase_listing.purchase_id = NEW.purchase_id OR (store.purchase_id.locked = true AND NOT store.payment_completion.cancelled = true))
        GROUP BY store.store.purchase_listing.listing_id
        HAVING SUM(store.purchase_listing.quantity) > store.listing.available_stock
    ) THEN
        RAISE EXCEPTION 'Cannot lock current sale, insufficient stock';
    END IF;
    -- lock purchase
    UPDATE store.purchase
    SET locked = true
    WHERE purchase_id = NEW.purchase_id;
    -- calculate amount to pay
    SELECT store.purchase_listing.quantity
        * store.listing_product.quantity
        * store.listing_product.price
        AS total
    -- add total to new payment
    INTO NEW.amount
    FROM store.purchase_listing
    LEFT JOIN store.listing_product ON store.purchase_listing.listing_id = store.listing_product.listing_id
    WHERE store.purchase_listing.purchase_id = NEW.purchase_id;

    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER store_payment_validate_and_lock_purchase_before_payment
    BEFORE INSERT ON store.payment
    FOR EACH ROW EXECUTE FUNCTION store.validate_and_lock_purchase_before_payment();



INSERT INTO store.authentication_provider
    (provider_name)
VALUES
    ('google'),
    ('facebook');

INSERT INTO store.taxable_activity
    (taxable_activity_id, description)
VALUES
    (71409, 'ACTIVIDADES DEPORTIVAS Y OTRAS ACTIVIDADES DE ESPARCIMIENTO'),
    (72203, 'RESTAURANTES'),
    (72201, 'HOTELES'),
    (60202, 'VENTA AL POR MENOR DE PRODUCTOS TEXTILES, PRENDAS DE VESTIR, CALZADOS Y ARTÍCULOS DE CUERO');

COMMIT;