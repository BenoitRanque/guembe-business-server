BEGIN;

CREATE SCHEMA i18n;

CREATE TABLE i18n.locale (
	locale_id TEXT PRIMARY KEY,
    name TEXT
);
INSERT INTO i18n.locale (locale_id, name)
VALUES ('es', 'Español'), ('en', 'Ingles');

COMMIT;