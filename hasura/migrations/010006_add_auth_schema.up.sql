BEGIN;

CREATE SCHEMA auth;

CREATE TABLE auth.oauth_provider (
    name TEXT PRIMARY KEY
);
CREATE TABLE auth.account (
    account_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT UNIQUE,
    password TEXT,
    oauth_provider_name TEXT REFERENCES auth.oauth_provider (name),
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

CREATE TABLE auth.role (
    role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE auth.account_role (
    account_id UUID REFERENCES auth.account(account_id)
        ON DELETE CASCADE,
    role_id UUID REFERENCES auth.role(role_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_account_id UUID NOT NULL REFERENCES auth.account (account_id),
    updated_by_account_id UUID NOT NULL REFERENCES auth.account (account_id)
);

COMMIT;