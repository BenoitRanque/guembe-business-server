BEGIN;

CREATE SCHEMA store;

CREATE TABLE store.authentication_provider (
    name TEXT PRIMARY KEY
);

CREATE TABLE store.client (
    client_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT,
    first_name TEXT,
    middle_name TEXT,
    last_name TEXT,
    email TEXT,
    authentication_provider_name TEXT REFERENCES store.authentication_provider (name),
    authentication_provider_account_id TEXT,
    UNIQUE (authentication_provider_name, authentication_provider_account_id),
    authentication_username TEXT UNIQUE,
    authentication_password TEXT,
    CHECK(
        authentication_username IS NOT NULL AND
        authentication_password IS NOT NULL AND
        authentication_provider_name IS NULL AND
        authentication_provider_account_id IS NULL
        OR
        authentication_username IS NULL AND
        authentication_password IS NULL AND
        authentication_provider_name IS NOT NULL AND
        authentication_provider_account_id IS NOT NULL
    ),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER store_client_set_updated_at BEFORE UPDATE ON store.client
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE FUNCTION store.hash_password()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.authentication_password IS NOT NULL THEN
        NEW.authentication_password = crypt(NEW.authentication_password, gen_salt('bf'));
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER store_client_hash_password BEFORE INSERT OR UPDATE ON store.client
    FOR EACH ROW EXECUTE FUNCTION store.hash_password();

CREATE TABLE store.client_token (
    token_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES store.client (client_id),
    expires TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now() + INTERVAL '1 minute'
);

CREATE FUNCTION store.client_token_delete_expired()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM store.client_token
    WHERE store.client_token.expires < now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER store_client_token_delete_expired AFTER INSERT ON store.client_token
    EXECUTE FUNCTION store.client_token_delete_expired();

CREATE TABLE store.economic_activity (
    economic_activity_id INTEGER PRIMARY KEY,
    description TEXT
);

CREATE TABLE store.product (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    public_name TEXT,
    description TEXT,
    private_name TEXT,
    internal_product_id TEXT,
    economic_activity_id INTEGER NOT NULL REFERENCES store.economic_activity (economic_activity_id),
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
    CHECK (available_from <= available_to),
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
    PRIMARY KEY (listing_id, product_id, price, lifetime_id)
);

CREATE TABLE store.listing_image (
    image_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    placeholder TEXT NOT NULL,
    highlighted BOOLEAN NOT NULL DEFAULT false,
    listing_id UUID REFERENCES store.listing(listing_id)
        ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES staff.user (user_id)
);

CREATE TRIGGER store_listing_image_set_updated_at BEFORE UPDATE ON store.listing_image
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE store.cart_listing (
    client_id UUID NOT NULL REFERENCES store.client (client_id)
        ON DELETE CASCADE,
    listing_id UUID NOT NULL REFERENCES store.listing (listing_id)
        ON DELETE CASCADE,
    quantity INT NOT NULL CHECK (quantity > 0),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    PRIMARY KEY (client_id, listing_id)
);
CREATE TRIGGER store_cart_listing_set_updated_at BEFORE UPDATE ON store.cart_listing
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE store.purchase (
    purchase_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES store.client (client_id),
    -- locked BOOLEAN NOT NULL DEFAULT false,
    buyer_business_name TEXT,
    buyer_tax_identification_number TEXT,
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

CREATE TABLE store.payment_status (
    name TEXT PRIMARY KEY,
    description TEXT
);

CREATE TABLE store.payment (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchase_id UUID UNIQUE NOT NULL REFERENCES store.purchase (purchase_id)
        ON DELETE CASCADE,
    amount INTEGER NOT NULL,
    status TEXT NOT NULL REFERENCES store.payment_status (name) DEFAULT 'PENDING',
    -- khipu payment data goes here
    khipu_payment_id TEXT, -- (String) Identificador único del pago, es una cadena alfanumérica de 12 caracteres
    khipu_payment_url TEXT, -- (String) URL principal del pago, si el usuario no ha elegido previamente un método de pago se le muestran las opciones
    khipu_simplified_transfer_url TEXT, -- (String) URL de pago simplificado
    khipu_transfer_url TEXT, -- (String) URL de pago normal
    khipu_webpay_url TEXT, -- (String) URL de webpay
    khipu_app_url TEXT, -- (String) URL para invocar el pago desde un dispositivo móvil usando la APP de khipu
    khipu_ready_for_terminal BOOLEAN, -- (Boolean) Es 'true' si el pago ya cuenta con todos los datos necesarios para abrir directamente la aplicación de pagos khipu
    khipu_notification_token TEXT, -- (String) Cadena de caracteres alfanuméricos que identifican unicamente al pago, es el identificador que el servidor de khipu enviará al servidor del comercio cuando notifique que un pago está conciliado
    khipu_receiver_id TEXT, -- (Long) Identificador único de una cuenta de cobro
    khipu_conciliation_date TIMESTAMP WITH TIME ZONE, -- (Date) Fecha y hora de conciliación del pago. Formato ISO-8601. Ej: 2017-03-01T13:00:00Z
    khipu_subject TEXT, -- (String) Motivo del pago
    khipu_amount TEXT, -- (Double)
    khipu_currency TEXT, -- (String) El código de moneda en formato ISO-4217
    khipu_status TEXT, -- (String) Estado del pago, puede ser 'pending' (el pagador aún no comienza a pagar), 'verifying' (se está verificando el pago) o 'done', cuando el pago ya está confirmado
    khipu_status_detail TEXT, -- (String) Detalle del estado del pago, 'pending' (el pagadon aún no comienza a pagar), 'normal' (el pago fue verificado y fue cancelado por algún medio de pago estandar), 'marked-paid-by-receiver' (el cobrador marco el cobro como pagado por otro medio), 'rejected-by-payer' (el pagador declaró que no pagará), 'marked-as-abuse' (el pagador declaró que no pagará y que el cobro fue no solicitado) y 'reversed' (el pago fue anulado por el comercio, el dinero fue devuelto al pagador).
    khipu_body TEXT, -- (String) Detalle del cobro
    khipu_picture_url TEXT, -- (String) URL de cobro
    khipu_receipt_url TEXT, -- (String) URL del comprobante de pago
    khipu_return_url TEXT, -- (String) URL donde se redirige al pagador luego que termina el pago
    khipu_cancel_url TEXT, -- (String) URL donde se redirige al pagador luego de que desiste hacer el pago
    khipu_notify_url TEXT, -- (String) URL del webservice donde se notificará el pago
    khipu_notify_api_version TEXT, -- (String) Versión de la api de notificación
    khipu_expires_date TIMESTAMP WITH TIME ZONE, -- (Date) Fecha de expiración del pago. En formato ISO-8601
    khipu_attachment_urls TEXT, -- (array[String]) URLs de archivos adjuntos al pago
    khipu_bank TEXT, -- (String) Nombre del banco seleccionado por el pagador
    khipu_bank_id TEXT, -- (String) Identificador del banco seleccionado por el pagador
    khipu_payer_name TEXT, -- (String) Nombre del pagador
    khipu_payer_email TEXT, -- (String) Correo electrónico del pagador
    khipu_personal_identifier TEXT, -- (String) Identificador personal del pagador
    khipu_bank_account_number TEXT, -- (String) Número de cuenta bancaria del pagador
    khipu_out_of_date_conciliation BOOLEAN, -- (Boolean) Es 'true' si la conciliación del pago fue hecha luego de la fecha de expiración
    khipu_transaction_id TEXT, -- (String) Identificador del pago asignado por el cobrador
    khipu_custom JSONB, -- (String) Campo genérico que asigna el cobrador al momento de hacer el pago
    khipu_responsible_user_email TEXT, -- (String) Correo electrónico de la persona responsable del pago
    khipu_send_reminders BOOLEAN, -- (Boolean) Es 'true' cuando este es un cobro por correo electrónico y khipu enviará recordatorios
    khipu_send_email BOOLEAN, -- (Boolean) Es 'true' cuando khipu enviará el cobro por correo electrónico
    khipu_payment_method TEXT, -- (String) Método de pago usado por el pagador, puede ser 'regular_transfer' (transferencia normal), 'simplified_transfer' (transferencia simplificada) o 'not_available' (para un pago marcado como realizado por otro medio por el cobrador).
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER store_payment_set_updated_at BEFORE UPDATE ON store.payment
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- this is created in response to khipu cancellation of payment
-- payment can only be cancelled if it has not yet been confirmed

-- create when payment is completed successfully
-- this should be created after invoice is created, with the invoice response data such as invoice number
CREATE TABLE store.invoice (
    invoice_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchase_id UUID NOT NULL REFERENCES store.purchase (purchase_id),
    economic_activity_id INTEGER NOT NULL REFERENCES store.economic_activity (economic_activity_id),
    -- invoice data must go here.
    izi_id INTEGER,
    izi_timestamp TIMESTAMP WITH TIME ZONE,
    izi_link TEXT,
    izi_numero INTEGER,
    izi_comprador TEXT,
    izi_razon_social TEXT,
    izi_lista_items JSONB,
    izi_autorizacion TEXT,
    izi_monto_total DOUBLE PRECISION,
    izi_descuentos DOUBLE PRECISION,
    izi_sin_credito DOUBLE PRECISION,
    izi_control TEXT,
    izi_tipo_compra INTEGER,
    izi_terminos_pago TEXT,
    UNIQUE (purchase_id, economic_activity_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER store_invoice_set_updated_at BEFORE UPDATE ON store.invoice
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- create when payment is completed
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
        ON DELETE RESTRICT, -- once a usage exists, the product cannot be deleted
    cancelled BOOLEAN DEFAULT false,
    cancelled_motive TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES staff.user (user_id)
);
CREATE TRIGGER store_purchased_product_usage_set_updated_at BEFORE UPDATE ON store.purchased_product_usage
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE VIEW store.listing_stock AS
SELECT
    store.listing.listing_id AS listing_id,
    store.listing.available_stock AS available_stock,
    COALESCE(SUM(store.purchase_listing.quantity), 0) AS used_stock,
    available_stock - COALESCE(SUM(store.purchase_listing.quantity), 0) AS remaining_stock
FROM store.listing
LEFT JOIN store.purchase_listing ON store.listing.listing_id = store.purchase_listing.listing_id
    AND store.purchase_listing.purchase_id NOT IN
        (SELECT store.payment.purchase_id FROM store.payment WHERE store.payment.status NOT IN ('PENDING', 'COMPLETED'))
WHERE store.listing.available_stock IS NOT NULL
GROUP BY store.listing.listing_id, store.listing.available_stock;

CREATE VIEW store.available_listing AS
SELECT
    store.listing.listing_id,
    store.listing.public_name,
    store.listing.description
FROM store.listing
WHERE store.listing.available_from <= NOW() AND store.listing.available_to >= NOW()
AND (store.listing.available_stock IS NULL
    OR store.listing.listing_id IN (SELECT store.listing_stock.listing_id FROM store.listing_stock WHERE store.listing_stock.remaining_stock > 0))
ORDER BY store.listing.created_at DESC;

-- CREATE VIEW store.usable_purchased_product AS
-- SELECT
--     store.purchase.client_id,
--     store.purchased_product.purchase_product_id
-- FROM store.purchased_product
-- LEFT JOIN store.purchase ON store.purchase.purchase_id = store.purchased_product.purchase_id
-- WHERE NOT store.purchased_product.purchase_product_id IN (SELECT purchase_product_id FROM store.purchased_product_usage WHERE store.purchased_product_usage.cancelled = false)
-- DAYOFWEEK(now()) IN (SELECT weekday_id FROM )
-- AND ()

-- SELECT calendar.weekday_id FROM calendar.lifetime_weekday WHERE calendar.lifetime_weekday.lifetime_id = store.

-- 1 check if lifetime range inside dates
-- 2 check if day of week inside permited days of week
-- or day is holiday

-- once a purchase exists, a listing cannot be modified cannot be modified
CREATE FUNCTION store.protect_purchased_listing()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(
        SELECT 1 FROM store.purchase_listing
        WHERE store.purchase_listing.listing_id = COALESCE(NEW.listing_id, OLD.listing_id)
    ) THEN
        RAISE EXCEPTION 'Modifying a listing already in a purchase is not allowed';
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

CREATE TRIGGER store_listing_protect_purchased_listing
    BEFORE UPDATE OR DELETE ON store.listing
    FOR EACH ROW EXECUTE FUNCTION store.protect_purchased_listing();

CREATE TRIGGER store_listing_product_protect_purchased_listing
    BEFORE INSERT OR UPDATE OR DELETE ON store.listing_product
    FOR EACH ROW EXECUTE FUNCTION store.protect_purchased_listing();

-- once a payment exists, a purchase cannot be modified
CREATE FUNCTION store.protect_paid_purchase()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(
        SELECT 1 FROM store.payment
        WHERE store.payment.purchase_id = COALESCE(NEW.purchase_id, OLD.purchase_id)
    ) THEN
        RAISE EXCEPTION 'Modifying a paid purchase is not allowed';
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

CREATE TRIGGER store_purchase_protect_paid_purchase
    BEFORE UPDATE OR DELETE ON store.purchase
    FOR EACH ROW EXECUTE FUNCTION store.protect_paid_purchase();

CREATE TRIGGER store_purchase_listing_protect_paid_purchase
    BEFORE INSERT OR UPDATE OR DELETE ON store.purchase_listing
    FOR EACH ROW EXECUTE FUNCTION store.protect_paid_purchase();

-- created purchased products if payment confirmation is properly received

CREATE FUNCTION store.create_purchased_products()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status != OLD.status THEN
        IF OLD.status = 'PENDING' AND NEW.status = 'COMPLETED' THEN
            -- 1 create invoices
            INSERT INTO store.invoice (purchase_id, economic_activity_id)
            SELECT
                store.payment.purchase_id AS purchase_id,
                store.product.economic_activity_id AS economic_activity_id
            FROM store.payment
            LEFT JOIN store.purchase_listing ON store.purchase_listing.purchase_id = store.payment.purchase_id
            LEFT JOIN store.listing_product ON store.purchase_listing.listing_id = store.listing_product.listing_id
            LEFT JOIN store.product ON store.listing_product.product_id = store.product.product_id
            WHERE store.payment.payment_id = OLD.payment_id AND store.listing_product.price > 0
            GROUP BY store.product.economic_activity_id, store.payment.purchase_id;

            -- 2 create purchased products

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
            WHERE store.payment.payment_id = OLD.payment_id;
        ELSIF OLD.status = 'PENDING' AND NEW.status IN ('REJECTED', 'EXPIRED', 'REVERSED') THEN
            -- do nothing
        ELSE
            RAISE EXCEPTION 'Cannot change payment status from % to %', OLD.status, NEW.status;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER store_payment_create_purchased_products
    BEFORE UPDATE ON store.payment
    FOR EACH ROW EXECUTE FUNCTION store.create_purchased_products();

CREATE FUNCTION store.calculate_payment_amount()
RETURNS TRIGGER AS $$
BEGIN
    -- calculate amount to pay
    -- TODO: verify how many rows this query returns. I have doubts
    SELECT store.purchase_listing.quantity
        * store.listing_product.quantity
        * store.listing_product.price
        AS total
    -- add total to new payment
    INTO NEW.amount
    FROM store.purchase_listing
    LEFT JOIN store.listing_product ON store.purchase_listing.listing_id = store.listing_product.listing_id
    WHERE store.purchase_listing.purchase_id = NEW.purchase_id;

    IF NEW.amount = 0 THEN
        RAISE EXCEPTION 'Cannot create payment for 0';
    END IF;

    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER store_payment_calculate_payment_amount
    BEFORE INSERT ON store.payment
    FOR EACH ROW EXECUTE FUNCTION store.calculate_payment_amount();

CREATE FUNCTION store.purchase_listing_verify_stock_and_availability()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM store.listing_stock
        WHERE store.listing_stock.listing_id = NEW.listing_id
        AND store.listing_stock.remaining_stock < NEW.quantity
    )
    THEN
        RAISE EXCEPTION 'Insuficient remaining stock for listing %', NEW.listing_id;
    END IF;
    IF NEW.listing_id NOT IN (SELECT listing_id FROM store.available_listing)
    THEN
        RAISE EXCEPTION 'Listing no longer available %', NEW.listing_id;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER store_purchase_listing_verify_stock_and_availability
    BEFORE INSERT OR UPDATE ON store.purchase_listing
    FOR EACH ROW EXECUTE FUNCTION store.purchase_listing_verify_stock_and_availability();


INSERT INTO store.authentication_provider
    (name)
VALUES
    ('google'),
    ('facebook');

INSERT INTO store.payment_status (name, description) VALUES
    ('PENDING', 'pendiente'),
    ('COMPLETED', 'completado'),
    ('REJECTED', 'rechazado'),
    ('EXPIRED', 'expirado'),
    ('REVERSED', 'revertido');

INSERT INTO store.economic_activity
    (economic_activity_id, description)
VALUES
    (71409, 'ACTIVIDADES DEPORTIVAS Y OTRAS ACTIVIDADES DE ESPARCIMIENTO'),
    (72203, 'RESTAURANTES'),
    (72201, 'HOTELES'),
    (60202, 'VENTA AL POR MENOR DE PRODUCTOS TEXTILES, PRENDAS DE VESTIR, CALZADOS Y ARTÍCULOS DE CUERO');

COMMIT;