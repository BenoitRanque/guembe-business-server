BEGIN;

CREATE SCHEMA calendar;

CREATE TABLE calendar.weekday (
    weekday_id INT PRIMARY KEY,
    description TEXT NOT NULL
);

INSERT INTO calendar.weekday (weekday_id, description) VALUES
    (0, 'Domingo'),
    (1, 'Lunes'),
    (2, 'Martes'),
    (3, 'Miercoles'),
    (4, 'Jueves'),
    (5, 'Viernes'),
    (6, 'Sabado');

CREATE TABLE calendar.holiday (
    holiday_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    private_name TEXT,
    public_name TEXT,
    description TEXT,
    date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES staff.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES staff.user (user_id)
);

CREATE TRIGGER calendar_holiday_set_updated_at BEFORE UPDATE ON calendar.holiday
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE calendar.lifetime (
    lifetime_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    private_name TEXT NOT NULL,
    public_name TEXT NOT NULL,
    description TEXT,
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

CREATE TABLE calendar.lifetime_weekday (
    lifetime_id UUID NOT NULL REFERENCES calendar.lifetime (lifetime_id)
        ON DELETE CASCADE,
    weekday_id INT NOT NULL REFERENCES calendar.weekday (weekday_id),
    PRIMARY KEY (lifetime_id, weekday_id)
);

COMMIT;