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
    -- phone TEXT,
    authentication_provider_name TEXT NOT NULL REFERENCES store.authentication_provider (name),
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

CREATE TABLE store.payment_status (
    name TEXT PRIMARY KEY,
    description TEXT
);

CREATE TABLE store.payment (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchase_id UUID UNIQUE NOT NULL REFERENCES store.purchase (purchase_id)
        ON DELETE CASCADE,
    amount INTEGER NOT NULL,
    status TEXT NOT NULL REFERENCES store.payment_status (name),
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
    khipu_custom JSON, -- (String) Campo genérico que asigna el cobrador al momento de hacer el pago
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
    -- send email invoice when this is created
    izi_emisor TEXT,
    izi_comprador TEXT,
    izi_razon_social TEXT,
    izi_lista_items JSON,
    izi_actividad_economica INTEGER NOT NULL REFERENCES store.taxable_activity (taxable_activity_id),
    -- invoice data must go here.
    izi_id INTEGER,
    izi_timestamp TIMESTAMP WITH TIME ZONE,
    izi_link TEXT,
    UNIQUE (purchase_id, izi_actividad_economica)
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
    IF NEW.status != OLD.status THEN
        IF NEW.status = 'PENDING' THEN
            RAISE EXCEPTION 'Cannot change status to PENDING from %', OLD.status;
        ELSE IF NEW.status = 'COMPLETED' THEN
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
        ELSE IF NEW.status = 'REJECTED' THEN
            -- do nothing
        ELSE IF NEW.status = 'EXPIRED' THEN
            -- do nothing
        ELSE IF NEW.status = 'REVERSED' THEN
            DELETE FROM store.purchased_product
            WHERE purchase_id = OLD.purchase_id;
        ELSE
            RAISE EXCEPTION 'Cannot update payment: invalid value for payment status %', NEW.status;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER store_payment_create_purchased_products
    BEFORE UPDATE ON store.payment
    FOR EACH ROW EXECUTE FUNCTION store.create_purchased_products();

CREATE FUNCTION store.validate_and_lock_purchase_before_payment()
RETURNS TRIGGER AS $$
BEGIN
    -- validate available stock
    -- we select purchasse listings where:
        -- listing avaialable stock is not null (meaning there is a limit)
        -- the purchase listing belongs to the current purchase or
        -- locked purchases where the payment is not cancelled (but not nescesarily present, payment may be pending)
    -- we aggregate those by listing id, and check if the sum of the quantities is more than the available stock
    IF EXISTS(
        SELECT 1
        FROM store.purchase_listing
            LEFT JOIN store.listing ON store.listing.listing_id = store.purchase_listing.listing_id
            LEFT JOIN store.purchase ON store.purchase.purchase_id = store.purchase_listing.purchase_id
            LEFT JOIN store.payment ON store.payment.purchase_id = store.purchase.purchase_id
        WHERE store.listing.available_stock IS NOT NULL
        AND (store.purchase_listing.purchase_id = NEW.purchase_id OR (store.purchase.locked = true AND store.payment.status IN ('PENDING', 'COMPLETED')))
        GROUP BY store.store.purchase_listing.listing_id
        HAVING SUM(store.purchase_listing.quantity) > store.listing.available_stock
        AND store.purchase_listing.purchase_id = NEW.purchase_id
    ) THEN
        RAISE EXCEPTION 'Cannot lock current sale, insufficient stock';
    END IF;
    -- lock purchase
    UPDATE store.purchase
    SET locked = true
    WHERE purchase_id = NEW.purchase_id;
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

INSERT INTO store.payment_status (name, description) VALUES
    ('PENDING', 'pendiente'),
    ('COMPLETED', 'completado'),
    ('REJECTED', 'rechazado'),
    ('EXPIRED', 'expirado'),
    ('REVERSED', 'revertido');

INSERT INTO store.taxable_activity
    (taxable_activity_id, description)
VALUES
    (71409, 'ACTIVIDADES DEPORTIVAS Y OTRAS ACTIVIDADES DE ESPARCIMIENTO'),
    (72203, 'RESTAURANTES'),
    (72201, 'HOTELES'),
    (60202, 'VENTA AL POR MENOR DE PRODUCTOS TEXTILES, PRENDAS DE VESTIR, CALZADOS Y ARTÍCULOS DE CUERO');

COMMIT;