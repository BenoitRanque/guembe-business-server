BEGIN;

CREATE SCHEMA staff;

-- Password Hashing trigger Function
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE OR REPLACE FUNCTION staff.hash_password()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.password IS NOT NULL THEN
        NEW.password = crypt(NEW.password, gen_salt('bf'));
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TABLE staff.user (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    fullname TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES staff.user (user_id)
);

CREATE TRIGGER staf_user_hash_password BEFORE INSERT OR UPDATE ON staff.user
    FOR EACH ROW EXECUTE FUNCTION staff.hash_password();

CREATE TRIGGER staf_user_set_updated_at BEFORE UPDATE ON staff.user
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE staff.role (
    role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_name TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE staff.user_role (
    user_id UUID REFERENCES staff.user(user_id),
    role_id UUID REFERENCES staff.role(role_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES staff.user (user_id)
);

CREATE TRIGGER staf_role_set_updated_at BEFORE UPDATE ON staff.role
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DO $$
DECLARE
    admin_user_id UUID := gen_random_uuid();
BEGIN

INSERT INTO staff.user
    (user_id, username, password, created_by_user_id, updated_by_user_id)
VALUES (admin_user_id, 'admin', 'admin', admin_user_id, admin_user_id);

WITH admin_user (user_id) AS (
	VALUES (admin_user_id)
), staff_roles (role_id) AS (
    INSERT INTO staff.role
        (role_name, description)
    VALUES
        ('administrator', 'Usuario administrador maximo. No utilizar en productivo')
    RETURNING role_id
)
INSERT INTO staff.user_role
    (user_id, role_id, created_by_user_id, updated_by_user_id)
SELECT user_id, role_id, user_id, user_id FROM staff_roles CROSS JOIN admin_user;

END $$;

COMMIT;