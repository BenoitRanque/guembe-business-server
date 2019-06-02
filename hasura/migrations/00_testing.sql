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

CREATE SCHEMA user;

CREATE TABLE user.oauth_provider (
    name TEXT PRIMARY KEY
);

CREATE TABLE user.account (
    account_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT UNIQUE,
    password TEXT,
    oauth_provider_name TEXT REFERENCES user.oauth_provider (name),
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
    created_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES staff.user (user_id)
);

CREATE TRIGGER user_account_set_updated_at BEFORE UPDATE ON user.account
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE FUNCTION user.hash_password()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.password IS NOT NULL THEN
        NEW.password = crypt(NEW.password, gen_salt('bf'));
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER user_account_hash_password BEFORE INSERT OR UPDATE ON user.account
    FOR EACH ROW EXECUTE FUNCTION user.hash_password();

CREATE TABLE user.token (
    token_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- code is a random number between 0 and 999999
    code INTEGER NOT NULL UNIQUE DEFAULT floor(random() * 1000000)::int,
    account_id UUID NOT NULL REFERENCES user.account (account_id),
    expires TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now() + INTERVAL '1 minute'
);

CREATE FUNCTION user.token_delete_expired()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM user.token
    WHERE user.token.expires < now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER user_token_delete_expired AFTER INSERT ON user.token
    EXECUTE FUNCTION user.token_delete_expired();


CREATE TABLE user.role (
    role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE user.account_role (
    account_id UUID REFERENCES user.account(account_id)
        ON DELETE CASCADE,
    role_id UUID REFERENCES user.role(role_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_account_id UUID NOT NULL REFERENCES user.account (account_id),
    updated_by_account_id UUID NOT NULL REFERENCES user.account (account_id)
);

CREATE TRIGGER user_account_role_set_updated_at BEFORE UPDATE ON user.account_role
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- possibly multiple clients per account
-- store things like nit here. This person is the titular person for any purchase
CREATE TABLE user.client (
	client_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	-- account id is nullable because some clients will be created manually byt staff (no account)
	account_id UUID REFERENCES user.account (account_id) ON DELETE CASCADE,
	created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TRIGGER user_client_set_updated_at BEFORE UPDATE ON user.client
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE SCHEMA i18n;

CREATE TABLE i18n.locale (
	locale_id TEXT PRIMARY KEY
);

INSERT INTO i18n.locale (locale_id) VALUES ('es', 'en');


CREATE TABLE i18n.message (
	message_id UUID DEFAULT gen_random_uuid(),
	locale_id TEXT REFERENCES i18n.locale(locale_id) ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY(message_id, locale_id),
	body TEXT,
	created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES staff.user (user_id)
);

CREATE TRIGGER i18n_message_set_updated_at BEFORE UPDATE ON i18n.message
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE SCHEMA calendar;

CREATE TABLE calendar.weekday (
    weekday_id INT PRIMARY KEY
);

INSERT INTO calendar.weekday (weekday_id)
VALUES (0), (1), (2), (3), (4), (5), (6);

CREATE TABLE calendar.weekday_i18n (
    weekday_id INT REFERENCES calendar.weekday (weekday_id) ON DELETE CASCADE,
	locale_id TEXT REFERENCES i18n.locale(locale_id) ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY(weekday_id, locale_id),
    name TEXT NOT NULL
);

INSERT INTO calendar.weekday_i18n (weekday_id, description) VALUES
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
    created_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES staff.user (user_id)
);

CREATE TRIGGER calendar_holiday_set_updated_at BEFORE UPDATE ON calendar.holiday
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE calendar.holiday_i18n (
    holiday_id UUID REFERENCES calendar.holiday (holiday_id) ON DELETE CASCADE,
	locale_id TEXT REFERENCES i18n.locale(locale_id) ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY(holiday_id, locale_id),
    name TEXT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES staff.user (user_id)
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
    created_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES staff.user (user_id)
);

CREATE TRIGGER calendar_lifetime_set_updated_at BEFORE UPDATE ON calendar.lifetime
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE calendar.lifetime_i18n (
    lifetime_id UUID REFERENCES calendar.lifetime (lifetime_id) ON DELETE CASCADE,
	locale_id TEXT REFERENCES i18n.locale(locale_id) ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY(lifetime_id, locale_id),
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES staff.user (user_id)
);

CREATE TRIGGER calendar_lifetime_i18n_set_updated_at BEFORE UPDATE ON calendar.lifetime_i18n
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE calendar.lifetime_weekday (
    lifetime_id UUID NOT NULL REFERENCES calendar.lifetime (lifetime_id)
        ON DELETE CASCADE,
    weekday_id INT NOT NULL REFERENCES calendar.weekday (weekday_id),
    PRIMARY KEY (lifetime_id, weekday_id)
);

CREATE SCHEMA accounting;

CREATE TABLE accounting.invoice;
CREATE TABLE accounting.economic_activity;
CREATE TABLE accounting.invoice_authorization;
CREATE TABLE accounting.izi_invoice;
CREATE TABLE accounting.khipu_payment;

CREATE TABLE accounting.payment;
-- completion and cancellation could potentially be a single record, with type.
CREATE TABLE accounting.payment_refund;
CREATE TABLE accounting.payment_completion;
CREATE TABLE accounting.payment_cancellation;

CREATE TABLE accounting.sale; -- join point for diferent types of sale.

CREATE SCHEMA website;

CREATE TABLE website.image (
    image_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    image_format_id TEXT NOT NULL,
    name TEXT,
    placeholder TEXT,
	created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES staff.user (user_id)
);

CREATE TRIGGER website_image_set_updated_at BEFORE UPDATE ON website_image
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE website.image_format (
    image_format_id TEXT PRIMARY KEY,
);
CREATE TABLE website.image_format_size (
    image_format_id TEXT REFERENCES website.image_format (image_format_id) ON UPDATE CASCADE ON DELETE CASCADE,
    name TEXT,
	PRIMARY KEY (image_format_id, name),
    width INTEGER CHECK (width >= 0),
    height INTEGER CHECK (height >= 0)
);

CREATE TABLE website.page (
    page_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	name TEXT NOT NULL
);

CREATE TABLE website.page_i18n (
	page_id UUID REFERENCES website.page (page_id) ON DELETE CASCADE,
	locale_id TEXT REFERENCES i18n.locale(locale_id) ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY (page_id, locale_id),
    background_image_id UUID REFERENCES website.image (image_id) ON DELETE RESTRICT,
    banner_image_id UUID REFERENCES website.image (image_id) ON DELETE RESTRICT,
    title TEXT,
    subtitle TEXT,
	body TEXT
);


CREATE SCHEMA webstore;

CREATE TABLE webstore.product;
CREATE TABLE webstore.product_i18n;
CREATE TABLE webstore.listing;
CREATE TABLE webstore.listing_i18n;
CREATE TABLE webstore.listing_product;
CREATE TABLE webstore.sale_listing; -- references accounting.sale
CREATE TABLE webstore.aquired_product;
CREATE TABLE webstore.aquired_product_use;
CREATE TABLE webstore.cart_listing;

CREATE SCHEMA hotel;

CREATE TABLE hotel.room_type;
CREATE TABLE hotel.room;
CREATE TABLE hotel.room_i18n;
-- reference room type, calendar lifetime. set price
-- like webstore listing, define availability of this price
-- consider percentage price that must be paid upfront, percentage that can be refunded
CREATE TABLE hotel.listing;
CREATE TABLE hotel.reservation;
CREATE TABLE hotel.cancellation; -- link to partial payment cancellation here
CREATE TABLE hotel.booking; -- link to partial payment cancellation here
CREATE TABLE hotel.reservation_guest;
CREATE TABLE hotel.guest;
CREATE TABLE hotel.guest_room;
CREATE TABLE hotel.checkin;
CREATE TABLE hotel.checkin_client;
CREATE TABLE hotel.checkout;
CREATE TABLE hotel.checkout_client;
-- ask management: do we want fixed products for additial charges, or just manually fill
CREATE TABLE hotel.additional;

COMMIT;