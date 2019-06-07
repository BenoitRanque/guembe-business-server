BEGIN;

CREATE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    -- NEW.updated_at = now();
    -- RETURN NEW;
    -- the below is not compatible with JSON columns, as the must be type cast before comparison
    IF row(NEW.*) IS DISTINCT FROM row(OLD.*) THEN
        NEW.updated_at = now();
        RETURN NEW;
    ELSE
        RETURN OLD;
    END IF;
END;
$$ language 'plpgsql';

CREATE SCHEMA account;

CREATE TABLE account.oauth_provider (
    name TEXT PRIMARY KEY
);

INSERT INTO account.oauth_provider (name)
VALUES ('google'), ('facebook');

CREATE TABLE account.user (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT UNIQUE,
    password TEXT,
    oauth_provider_name TEXT REFERENCES account.oauth_provider (name),
    oauth_id TEXT,
    UNIQUE (oauth_provider_name, oauth_id),
    CHECK(
        username IS NOT NULL AND
        password IS NOT NULL AND
        oauth_provider_name IS NULL AND
        oauth_id IS NULL
        OR
        username IS NULL AND
        password IS NULL AND
        oauth_provider_name IS NOT NULL AND
        oauth_id IS NOT NULL
    ),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER account_user_set_updated_at BEFORE UPDATE ON account.user
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE FUNCTION account.hash_password()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.password IS NOT NULL THEN
        NEW.password = crypt(NEW.password, gen_salt('bf'));
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER account_user_hash_password BEFORE INSERT OR UPDATE ON account.user
    FOR EACH ROW EXECUTE FUNCTION account.hash_password();

CREATE TABLE account.token (
    token_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- code is a random number between 0 and 999999
    code INTEGER NOT NULL UNIQUE DEFAULT floor(random() * 1000000)::int,
    user_id UUID NOT NULL REFERENCES account.user (user_id),
    expires TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now() + INTERVAL '1 minute'
);

CREATE FUNCTION account.token_delete_expired()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM account.token
    WHERE account.token.expires < now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER account_token_delete_expired AFTER INSERT ON account.token
    EXECUTE FUNCTION account.token_delete_expired();


CREATE TABLE account.role (
    role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE account.user_role (
    user_id UUID REFERENCES account.user(user_id)
        ON DELETE CASCADE,
    role_id UUID REFERENCES account.role(role_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER account_user_role_set_updated_at BEFORE UPDATE ON account.user_role
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- possibly multiple clients per user
-- webstore things like nit here. This person is the titular person for any sale
CREATE TABLE account.client (
	client_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	-- user id is nullable because some clients will be created manually by account (no user)
	user_id UUID REFERENCES account.user (user_id) ON DELETE CASCADE,
    business_name TEXT, -- razon social
    tax_identification_number TEXT, -- nit
	created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER account_client_set_updated_at BEFORE UPDATE ON account.client
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE SCHEMA i18n;

CREATE TABLE i18n.locale (
	locale_id TEXT PRIMARY KEY
);
INSERT INTO i18n.locale (locale_id)
VALUES ('es'), ('en');

CREATE TABLE i18n.message (
	message_id UUID DEFAULT gen_random_uuid(),
	locale_id TEXT REFERENCES i18n.locale(locale_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
	PRIMARY KEY(message_id, locale_id),
	body TEXT,
	created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER i18n_message_set_updated_at BEFORE UPDATE ON i18n.message
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE SCHEMA calendar;

CREATE TABLE calendar.weekday (
    weekday_id INTEGER PRIMARY KEY
);
INSERT INTO calendar.weekday (weekday_id)
VALUES (0), (1), (2), (3), (4), (5), (6);

CREATE TABLE calendar.weekday_i18n (
    weekday_id INTEGER REFERENCES calendar.weekday (weekday_id)
        ON DELETE CASCADE,
	locale_id TEXT REFERENCES i18n.locale(locale_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
	PRIMARY KEY(weekday_id, locale_id),
    name TEXT NOT NULL
);

INSERT INTO calendar.weekday_i18n (weekday_id, locale_id, name) VALUES
    (0, 'es', 'Domingo'),
    (1, 'es', 'Lunes'),
    (2, 'es', 'Martes'),
    (3, 'es', 'Miercoles'),
    (4, 'es', 'Jueves'),
    (5, 'es', 'Viernes'),
    (6, 'es', 'Sabado'),
    (0, 'en', 'Sunday'),
    (1, 'en', 'Monday'),
    (2, 'en', 'Tuesday'),
    (3, 'en', 'Wednesday'),
    (4, 'en', 'Thursday'),
    (5, 'en', 'Friday'),
    (6, 'en', 'Saturday');

CREATE TABLE calendar.holiday (
    holiday_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT,
    date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER calendar_holiday_set_updated_at BEFORE UPDATE ON calendar.holiday
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE calendar.holiday_i18n (
    holiday_id UUID REFERENCES calendar.holiday (holiday_id)
        ON DELETE CASCADE,
	locale_id TEXT REFERENCES i18n.locale(locale_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
	PRIMARY KEY(holiday_id, locale_id),
    name TEXT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER calendar_holiday_i18n_set_updated_at BEFORE UPDATE ON calendar.holiday_i18n
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE calendar.lifetime (
    lifetime_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    include_holidays BOOLEAN NOT NULL,
    "start" DATE NOT NULL,
    "end" DATE NOT NULL,
    CHECK ("start" <= "end"),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER calendar_lifetime_set_updated_at BEFORE UPDATE ON calendar.lifetime
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE calendar.lifetime_i18n (
    lifetime_id UUID REFERENCES calendar.lifetime (lifetime_id)
        ON DELETE CASCADE,
	locale_id TEXT REFERENCES i18n.locale(locale_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
	PRIMARY KEY(lifetime_id, locale_id),
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER calendar_lifetime_i18n_set_updated_at BEFORE UPDATE ON calendar.lifetime_i18n
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE calendar.lifetime_weekday (
    lifetime_id UUID NOT NULL REFERENCES calendar.lifetime (lifetime_id)
        ON DELETE CASCADE,
    weekday_id INTEGER NOT NULL REFERENCES calendar.weekday (weekday_id),
    PRIMARY KEY (lifetime_id, weekday_id)
);

CREATE SCHEMA accounting;

CREATE TABLE accounting.economic_activity (
    economic_activity_id INTEGER PRIMARY KEY,
    name TEXT
);
INSERT INTO accounting.economic_activity
    (economic_activity_id, name)
VALUES
    (71409, 'ACTIVIDADES DEPORTIVAS Y OTRAS ACTIVIDADES DE ESPARCIMIENTO'),
    (72203, 'RESTAURANTES'),
    (72201, 'HOTELES'),
    (60202, 'VENTA AL POR MENOR DE PRODUCTOS TEXTILES, PRENDAS DE VESTIR, CALZADOS Y ARTÍCULOS DE CUERO');

CREATE TABLE accounting.invoice (
    invoice_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    economic_activity_id INTEGER NOT NULL
        REFERENCES accounting.economic_activity (economic_activity_id),
    amount INTEGER NOT NULL CHECK (amount > 0),
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
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER accounting_invoice_set_updated_at BEFORE UPDATE ON accounting.invoice
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE accounting.invoice_item (
    invoice_id UUID REFERENCES accounting.invoice (invoice_id),
    index INTEGER CHECK (index >= 0),
    PRIMARY KEY (invoice_id, index),
    name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price INTEGER NOT NULL CHECK (price > 0),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER accounting_invoice_item_set_updated_at BEFORE UPDATE ON accounting.invoice_item
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE accounting.payment_status (
    payment_status_id TEXT PRIMARY KEY,
    name TEXT,
    description TEXT
);
INSERT INTO accounting.payment_status (payment_status_id, name, description) VALUES
    ('PENDING', 'Pendiente', 'Aun no ingreso el dinero'),
    ('COMPLETED', 'Completado', 'El pago se completo satisfactoriamente'),
    ('REJECTED', 'Rechazado', 'El pago fue rechazado por el pagador'),
    ('EXPIRED', 'Expirado', 'Expiro la ventana de pago, el pago ya no se puede completar'),
    ('REVERSED', 'Revertido', 'Se realizo una devolucion del pago');

CREATE TABLE accounting.payment (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    amount INTEGER NOT NULL CHECK (amount > 0),
    status TEXT NOT NULL REFERENCES accounting.payment_status (payment_status_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
        DEFAULT 'PENDING',
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
    khipu_bank_user_number TEXT, -- (String) Número de cuenta bancaria del pagador
    khipu_out_of_date_conciliation BOOLEAN, -- (Boolean) Es 'true' si la conciliación del pago fue hecha luego de la fecha de expiración
    khipu_transaction_id TEXT, -- (String) Identificador del pago asignado por el cobrador
    khipu_custom JSONB, -- (String) Campo genérico que asigna el cobrador al momento de hacer el pago
    khipu_responsible_account_email TEXT, -- (String) Correo electrónico de la persona responsable del pago
    khipu_send_reminders BOOLEAN, -- (Boolean) Es 'true' cuando este es un cobro por correo electrónico y khipu enviará recordatorios
    khipu_send_email BOOLEAN, -- (Boolean) Es 'true' cuando khipu enviará el cobro por correo electrónico
    khipu_payment_method TEXT, -- (String) Método de pago usado por el pagador, puede ser 'regular_transfer' (transferencia normal), 'simplified_transfer' (transferencia simplificada) o 'not_available' (para un pago marcado como realizado por otro medio por el cobrador).
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER accounting_payment_set_updated_at BEFORE UPDATE ON accounting.payment
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE accounting.payment_update (
    payment_id UUID REFERENCES accounting.payment (payment_id),
    status TEXT REFERENCES accounting.payment_status (payment_status_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    PRIMARY KEY (payment_id, status),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE TRIGGER accounting_payment_update_set_updated_at BEFORE UPDATE ON accounting.payment_update
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE FUNCTION accounting.payment_update_status()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE accounting.payment
    SET status = NEW.status
    WHERE accounting.payment.payment_id = NEW.payment_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER accounting_payment_update_status AFTER INSERT ON accounting.payment_update
    EXECUTE FUNCTION accounting.payment_update_status();

-- idea for refund table
-- CREATE TABLE accounting.refund (
--     refund_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--     payment_id UUID NOT NULL REFERENCES accounting.payment (payment_id),
--     amount INTEGER NOT NULL CHECK (amount > 0),
--     created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
--     updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
-- );
-- CREATE TRIGGER accounting_refund_set_updated_at BEFORE UPDATE ON accounting.refund
--     FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE SCHEMA website;

CREATE TABLE website.size (
    size_id TEXT PRIMARY KEY
);
INSERT INTO website.size (size_id)
VALUES ('xl'), ('lg'), ('md'), ('sm'), ('xs');

CREATE TABLE website.image (
    image_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    image_format_id TEXT NOT NULL,
    name TEXT,
    placeholder TEXT,
	created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER website_image_set_updated_at BEFORE UPDATE ON website.image
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE website.image_format (
    image_format_id TEXT PRIMARY KEY
);

CREATE TABLE website.image_format_size (
    image_format_id TEXT REFERENCES website.image_format (image_format_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    size_id TEXT REFERENCES website.size (size_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
	PRIMARY KEY (image_format_id, size_id),
    width INTEGER CHECK (width >= 0),
    height INTEGER CHECK (height >= 0)
);

CREATE TABLE website.page (
    page_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    path TEXT UNIQUE NOT NULL,
	name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER website_page_set_updated_at BEFORE UPDATE ON website.page
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE website.page_i18n (
    page_id UUID REFERENCES website.page (page_id)
        ON DELETE CASCADE,
	locale_id TEXT REFERENCES i18n.locale(locale_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    PRIMARY KEY (page_id, locale_id),
	name TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER website_page_i18n_set_updated_at BEFORE UPDATE ON website.page_i18n
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE website.slide (
    slide_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    page_id UUID NOT NULL REFERENCES website.page (page_id)
        ON DELETE CASCADE,
    index INTEGER NOT NULL CHECK (index >= 0),
    UNIQUE (page_id, index),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER website_slide_set_updated_at BEFORE UPDATE ON website.slide
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE website.slide_i18n (
    slide_id UUID REFERENCES website.slide (slide_id)
        ON DELETE CASCADE,
	locale_id TEXT REFERENCES i18n.locale(locale_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
	PRIMARY KEY (slide_id, locale_id),
    image_id UUID NOT NULL REFERENCES website.image (image_id)
        ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER website_slide_i18n_set_updated_at BEFORE UPDATE ON website.slide_i18n
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE website.section (
    section_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	page_id UUID NOT NULL REFERENCES website.page (page_id)
        ON DELETE CASCADE,
    index INTEGER NOT NULL CHECK (index >= 0),
    UNIQUE(page_id, index),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER website_section_set_updated_at BEFORE UPDATE ON website.section
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE website.element (
    element_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    section_id UUID NOT NULL REFERENCES website.section (section_id)
        ON DELETE CASCADE,
    index INTEGER NOT NULL CHECK (index >= 0),
    UNIQUE (section_id, index),
    size_id TEXT NOT NULL REFERENCES website.size (size_id),
    image_id UUID REFERENCES website.image (image_id) ON DELETE RESTRICT,
    target TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER website_element_set_updated_at BEFORE UPDATE ON website.element
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE website.element_i18n (
	element_id UUID REFERENCES website.element (element_id)
        ON DELETE CASCADE,
	locale_id TEXT REFERENCES i18n.locale(locale_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
	PRIMARY KEY (element_id, locale_id),
    caption TEXT,
    title TEXT,
    subtitle TEXT,
	body TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER website_element_i18n_set_updated_at BEFORE UPDATE ON website.element_i18n
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

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
    sale_id UUID NOT NULL REFERENCES webstore.listing (listing_id)
        ON DELETE CASCADE,
    listing_id UUID NOT NULL REFERENCES webstore.product (product_id)
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
