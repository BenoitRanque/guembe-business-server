BEGIN;
CREATE SCHEMA account;

CREATE TABLE account.user_type (
    user_type_id TEXT PRIMARY KEY
);

INSERT INTO account.user_type (user_type_id)
VALUES ('client'), ('staff');

CREATE TABLE account.oauth_provider (
    oauth_provider_id TEXT PRIMARY KEY
);

INSERT INTO account.oauth_provider (oauth_provider_id)
VALUES ('google'), ('facebook');

CREATE TABLE account.user (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_type_id TEXT NOT NULL REFERENCES account.user_type (user_type_id),
    oauth_provider_id TEXT REFERENCES account.oauth_provider (oauth_provider_id),
    oauth_id TEXT,
    email TEXT UNIQUE,
    username TEXT UNIQUE,
    password TEXT,
    UNIQUE (oauth_provider_id, oauth_id),
    CHECK(
        oauth_provider_id IS NOT NULL AND
        oauth_id IS NOT NULL AND
        email IS NULL AND
        username IS NULL AND
        password IS NULL
        OR
        oauth_provider_id IS NULL AND
        oauth_id IS NULL AND
        (email IS NOT NULL OR username IS NOT NULL)
        AND password IS NOT NULL
    ),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID REFERENCES account.user (user_id),
    updated_by_user_id UUID REFERENCES account.user (user_id)
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

COMMIT;