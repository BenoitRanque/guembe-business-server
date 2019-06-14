BEGIN;
CREATE SCHEMA i18n;

CREATE TABLE i18n.locale (
	locale_id TEXT PRIMARY KEY,
    name TEXT
);
INSERT INTO i18n.locale (locale_id, name)
VALUES ('es', 'Español'), ('en', 'Ingles');

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

COMMIT;