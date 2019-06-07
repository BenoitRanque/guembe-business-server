BEGIN;
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

COMMIT;