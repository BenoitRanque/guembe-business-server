BEGIN;

CREATE SCHEMA staff;

CREATE TABLE staff.account (
    account_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    fullname TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID REFERENCES staff.account (account_id),
    updated_by UUID REFERENCES staff.account (account_id)
);

CREATE TABLE staff.role (
    role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_name TEXT NOT NULL UNIQUE,
    description TEXT
);

-- INSERT INTO staff.role (role_name, description) VALUES
--     ('role_name', 'role description');

CREATE TABLE staff.account_role (
    account_id UUID REFERENCES staff.account(account_id),
    role_id UUID REFERENCES staff.role(role_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL REFERENCES staff.account (account_id),
    updated_by UUID NOT NULL REFERENCES staff.account (account_id)
);

COMMIT;