BEGIN;
CREATE SCHEMA webstore;

CREATE TABLE webstore.product (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT,
    internal_product_id TEXT,
    economic_activity_id INTEGER NOT NULL REFERENCES accounting.economic_activity (economic_activity_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER webstore_product_set_updated_at BEFORE UPDATE ON webstore.product
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE webstore.product_i18n (
    product_id UUID REFERENCES webstore.product (product_id)
        ON DELETE CASCADE,
	locale_id TEXT REFERENCES i18n.locale(locale_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
	PRIMARY KEY(product_id, locale_id),
    name TEXT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER webstore_product_i18n_set_updated_at BEFORE UPDATE ON webstore.product_i18n
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();


CREATE TABLE webstore.listing (
    listing_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT,
    available_from DATE NOT NULL, -- when this will be available in webstore
    available_to DATE NOT NULL,
    CHECK (available_from <= available_to),
    supply INTEGER CHECK (supply IS NULL OR supply > 0),
    total INTEGER NOT NULL CHECK (total >= 0),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER webstore_listing_set_updated_at BEFORE UPDATE ON webstore.listing
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE webstore.listing_i18n (
    listing_id UUID REFERENCES webstore.listing (listing_id)
        ON DELETE CASCADE,
	locale_id TEXT REFERENCES i18n.locale(locale_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
	PRIMARY KEY(listing_id, locale_id),
    name TEXT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER webstore_listing_i18n_set_updated_at BEFORE UPDATE ON webstore.listing_i18n
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE webstore.listing_product (
    listing_id UUID NOT NULL REFERENCES webstore.listing (listing_id)
        ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES webstore.product (product_id)
        ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price INTEGER NOT NULL CHECK (price >= 0),
    lifetime_id UUID NOT NULL REFERENCES calendar.lifetime (lifetime_id),
    PRIMARY KEY (listing_id, product_id, price, lifetime_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER webstore_listing_product_set_updated_at BEFORE UPDATE ON webstore.listing_product
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE webstore.sale (
    sale_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES account.user (user_id),
    client_id UUID NOT NULL REFERENCES account.client (client_id),
    total INTEGER NOT NULL CHECK (total > 0),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER webstore_sale_set_updated_at BEFORE UPDATE ON webstore.sale
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE webstore.sale_listing (
    sale_id UUID NOT NULL REFERENCES webstore.sale (sale_id)
        ON DELETE CASCADE,
    listing_id UUID NOT NULL REFERENCES webstore.listing (listing_id)
        ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER webstore_sale_listing_set_updated_at BEFORE UPDATE ON webstore.sale_listing
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE webstore.sale_payment (
    sale_id UUID REFERENCES webstore.sale (sale_id),
    payment_id UUID UNIQUE REFERENCES accounting.payment (payment_id),
    PRIMARY KEY (sale_id, payment_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER webstore_sale_payment_set_updated_at BEFORE UPDATE ON webstore.sale_payment
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE webstore.sale_invoice (
    sale_id UUID REFERENCES webstore.sale (sale_id),
    invoice_id UUID UNIQUE REFERENCES accounting.invoice (invoice_id),
    PRIMARY KEY (sale_id, invoice_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER webstore_sale_invoice_set_updated_at BEFORE UPDATE ON webstore.sale_invoice
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE webstore.aquired_product (
    aquired_product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id UUID NOT NULL REFERENCES webstore.sale (sale_id)
        ON DELETE RESTRICT,
    user_id UUID NOT NULL REFERENCES account.user (user_id),
    product_id UUID NOT NULL REFERENCES webstore.product (product_id),
    listing_id UUID NOT NULL REFERENCES webstore.listing (listing_id),
    lifetime_id UUID NOT NULL REFERENCES calendar.lifetime (lifetime_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER webstore_aquired_product_set_updated_at BEFORE UPDATE ON webstore.aquired_product
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE webstore.aquired_product_use (
    aquired_product_use_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    aquired_product_id UUID NOT NULL
        REFERENCES webstore.aquired_product (aquired_product_id)
        ON DELETE RESTRICT, -- once a usage exists, the product cannot be deleted
    cancelled BOOLEAN DEFAULT false,
    cancelled_motive TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER webstore_aquired_product_use_set_updated_at BEFORE UPDATE ON webstore.aquired_product_use
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE webstore.cart_listing (
    user_id UUID NOT NULL REFERENCES account.user (user_id)
        ON DELETE CASCADE,
    listing_id UUID NOT NULL REFERENCES webstore.listing (listing_id)
        ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (user_id, listing_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER webstore_cart_listing_set_updated_at BEFORE UPDATE ON webstore.cart_listing
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE VIEW webstore.inventory AS
SELECT
    webstore.listing.listing_id AS listing_id,
    webstore.listing.supply AS supply,
    COALESCE(SUM(webstore.sale_listing.quantity), 0) AS used,
    webstore.listing.supply - COALESCE(SUM(webstore.sale_listing.quantity), 0) AS remaining,
    ((webstore.listing.supply - COALESCE(SUM(webstore.sale_listing.quantity), 0)) > 0)::text AS available
FROM webstore.listing
LEFT JOIN webstore.sale_listing
    ON webstore.listing.listing_id = webstore.sale_listing.listing_id
    AND webstore.sale_listing.sale_id IN (
        SELECT webstore.sale_payment.sale_id
        FROM webstore.sale_payment
        LEFT JOIN accounting.payment
            ON webstore.sale_payment.payment_id = accounting.payment.payment_id
        WHERE accounting.payment.status IN ('PENDING', 'COMPLETED')
    )
WHERE webstore.listing.supply IS NOT NULL
GROUP BY webstore.listing.listing_id, webstore.listing.supply;

CREATE VIEW webstore.aquired_product_usable AS
SELECT
    webstore.aquired_product.aquired_product_id
FROM webstore.aquired_product
LEFT JOIN calendar.lifetime ON webstore.aquired_product.lifetime_id = calendar.lifetime.lifetime_id
LEFT JOIN calendar.lifetime_weekday ON calendar.lifetime.lifetime_id = calendar.lifetime_weekday.lifetime_id AND calendar.lifetime_weekday.weekday_id = EXTRACT(DOW FROM now())::int
LEFT JOIN calendar.holiday ON calendar.holiday.date = CURRENT_DATE
WHERE now() >= calendar.lifetime.start AND now() <= calendar.lifetime.end
AND webstore.aquired_product.aquired_product_id NOT IN (SELECT webstore.aquired_product_use.aquired_product_id FROM webstore.aquired_product_use WHERE webstore.aquired_product_use.cancelled = false)
AND ((
    calendar.holiday.date IS NULL AND calendar.lifetime_weekday.weekday_id IS NOT NULL
) OR (
    calendar.holiday.date IS NOT NULL AND calendar.lifetime.include_holidays = true
));

CREATE FUNCTION webstore.protect_sale_listing()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(
        SELECT 1 FROM webstore.sale_listing
        WHERE webstore.sale_listing.listing_id = COALESCE(NEW.listing_id, OLD.listing_id)
    ) THEN
        RAISE EXCEPTION 'Modifying a listing already in a sale is not allowed';
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

CREATE TRIGGER webstore_listing_protect_sale_listing
    BEFORE UPDATE OR DELETE ON webstore.listing
    FOR EACH ROW EXECUTE FUNCTION webstore.protect_sale_listing();

CREATE TRIGGER webstore_listing_product_protect_sale_listing
    BEFORE INSERT OR UPDATE OR DELETE ON webstore.listing_product
    FOR EACH ROW EXECUTE FUNCTION webstore.protect_sale_listing();

CREATE FUNCTION webstore.protect_paid_sale()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(
        SELECT 1 FROM webstore.sale_payment
        WHERE webstore.sale_payment.sale_id = COALESCE(NEW.sale_id, OLD.sale_id)
    ) THEN
        RAISE EXCEPTION 'Modifying a paid sale is not allowed';
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

CREATE TRIGGER webstore_sale_protect_paid_sale
    BEFORE UPDATE OR DELETE ON webstore.sale
    FOR EACH ROW EXECUTE FUNCTION webstore.protect_paid_sale();

CREATE TRIGGER webstore_sale_listing_protect_paid_sale
    BEFORE INSERT OR UPDATE OR DELETE ON webstore.sale_listing
    FOR EACH ROW EXECUTE FUNCTION webstore.protect_paid_sale();

CREATE FUNCTION webstore.update_listing_total()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE webstore.listing
    SET webstore.listing.total = (
        SELECT SUM(webstore.listing_product.quantity * webstore.listing_product.price) AS total
        FROM webstore.listing_product
        WHERE webstore.listing_product.listing_id = COALESCE(NEW.listing_id, OLD.listing_id)
    ) WHERE webstore.listing.listing_id = COALESCE(NEW.listing_id, OLD.listing_id);
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

CREATE TRIGGER update_webstore_listing_total
    AFTER INSERT OR UPDATE OR DELETE ON webstore.listing_product
    FOR EACH ROW EXECUTE FUNCTION webstore.update_listing_total();

CREATE FUNCTION webstore.update_sale_total()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE webstore.sale
    SET webstore.sale.total = (
        SELECT SUM(webstore.sale_listing.quantity * webstore.listing_product.quantity * webstore.listing_product.price) AS total
        FROM webstore.sale_listing
        LEFT JOIN webstore.listing_product ON webstore.sale_listing.listing_id = webstore.listing_product.listing_id
        WHERE webstore.sale_listing.sale_id = COALESCE(NEW.sale_id, OLD.sale_id)
    ) WHERE webstore.sale.sale_id = COALESCE(NEW.sale_id, OLD.sale_id);
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

CREATE TRIGGER update_webstore_sale_total
    AFTER INSERT OR UPDATE OR DELETE ON webstore.sale_listing
    FOR EACH ROW EXECUTE FUNCTION webstore.update_sale_total();

CREATE FUNCTION webstore.sale_listing_verify_availability()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM webstore.inventory
        WHERE webstore.inventory.listing_id = NEW.listing_id
        AND webstore.inventory.remaining < NEW.quantity
    )
    THEN
        RAISE EXCEPTION 'Insuficient remaining stock for listing %', NEW.listing_id;
    END IF;
    IF NEW.listing_id NOT IN (
        SELECT listing_id
        FROM webstore.listing
        WHERE webstore.listing.available_from <= NOW()
        AND webstore.listing.available_to >= NOW()
    ) THEN
        RAISE EXCEPTION 'Listing no longer available %', NEW.listing_id;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER webstore_sale_listing_verify_availability
    BEFORE INSERT ON webstore.sale_listing
    FOR EACH ROW EXECUTE FUNCTION webstore.sale_listing_verify_availability();

CREATE FUNCTION webstore.validate_aquired_product_use()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.aquired_product_id) NOT IN (SELECT webstore.aquired_product_usable.aquired_product_id FROM webstore.aquired_product_usable) THEN
        RAISE EXCEPTION 'Cannot use this product.';
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER validate_webstore_aquired_product_use
    BEFORE INSERT ON webstore.aquired_product_use
    FOR EACH ROW EXECUTE FUNCTION webstore.validate_aquired_product_use();

COMMIT;