BEGIN;

CREATE SCHEMA client;

CREATE TABLE client.account(
    account_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name TEXT,
    middle_name TEXT,
    last_name TEXT,
    email TEXT,
    phone TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TRIGGER client_account_set_updated_at BEFORE UPDATE ON client.account
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE client.authentication_provider (
    name TEXT PRIMARY KEY
);

CREATE TABLE client.authentication (
	account_id UUID NOT NULL REFERENCES client.account (account_id),
    authentication_provider_name TEXT NOT NULL REFERENCES client.authentication_provider (name),
	authentication_id TEXT NOT NULL,
	PRIMARY (provider_name, authentication_id)
);

CREATE TABLE client.billing (
	account_id
	nit
	razon social

);


INSERT INTO client.auth_provider
    (name)
VALUES
    ('google'),
    ('facebook');

COMMIT;