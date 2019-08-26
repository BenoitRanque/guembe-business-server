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
    locale_id TEXT NOT NULL DEFAULT 'es'
        REFERENCES i18n.locale(locale_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    username TEXT UNIQUE,
    password TEXT,
    oauth_id TEXT,
    oauth_provider_id TEXT REFERENCES account.oauth_provider (oauth_provider_id),
    UNIQUE (oauth_provider_id, oauth_id),
    CHECK(
        username IS NULL AND
        password IS NULL AND
        oauth_id IS NOT NULL AND
        oauth_provider_id IS NOT NULL
        OR
        username IS NOT NULL AND
        password IS NOT NULL AND
        oauth_id IS NULL AND
        oauth_provider_id IS NULL
    ),
    name TEXT,
    email TEXT,
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
    IF NEW.password IS NOT NULL AND (OLD IS NULL OR OLD.password != NEW.password) THEN
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
    role_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
);

CREATE TABLE account.user_role (
    user_id UUID REFERENCES account.user(user_id)
        ON DELETE CASCADE,
    role_id TEXT REFERENCES account.role(role_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
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

DO $$
DECLARE
    admin_user_id UUID;
BEGIN

INSERT INTO account.user
    (user_type_id, username, password)
VALUES ('staff', 'admin', 'admin')
RETURNING user_id INTO admin_user_id;

WITH admin_user (user_id) AS (
	VALUES (admin_user_id)
), account_roles (role_id) AS (
    INSERT INTO account.role
        (role_id, name, description)
    VALUES
        ('administrator', 'Administrador', 'Usuario administrador maximo.')
    RETURNING role_id
)
INSERT INTO account.user_role
    (user_id, role_id, created_by_user_id, updated_by_user_id)
SELECT user_id, role_id, user_id, user_id
FROM account_roles CROSS JOIN admin_user;

END $$;

COMMIT;