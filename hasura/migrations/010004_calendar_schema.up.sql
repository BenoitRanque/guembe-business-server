BEGIN;
CREATE SCHEMA calendar;

CREATE TABLE calendar.weekday (
    weekday_id INTEGER PRIMARY KEY,
    name TEXT
);
INSERT INTO calendar.weekday (weekday_id, name) VALUES
    (0, 'Domingo'),
    (1, 'Lunes'),
    (2, 'Martes'),
    (3, 'Miercoles'),
    (4, 'Jueves'),
    (5, 'Viernes'),
    (6, 'Sabado');

CREATE TABLE calendar.weekday_i18n (
    weekday_id INTEGER REFERENCES calendar.weekday (weekday_id)
        ON DELETE CASCADE,
	locale_id TEXT REFERENCES i18n.locale(locale_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
	PRIMARY KEY(weekday_id, locale_id),
    name TEXT NOT NULL
);

INSERT INTO calendar.weekday_i18n (weekday_id, locale_id, name) VALUES
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
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER calendar_holiday_set_updated_at BEFORE UPDATE ON calendar.holiday
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE calendar.holiday_i18n (
    holiday_id UUID REFERENCES calendar.holiday (holiday_id)
        ON DELETE CASCADE,
	locale_id TEXT REFERENCES i18n.locale(locale_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
	PRIMARY KEY(holiday_id, locale_id),
    name TEXT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
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
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER calendar_lifetime_set_updated_at BEFORE UPDATE ON calendar.lifetime
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE calendar.lifetime_i18n (
    lifetime_id UUID REFERENCES calendar.lifetime (lifetime_id)
        ON DELETE CASCADE,
	locale_id TEXT REFERENCES i18n.locale(locale_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
	PRIMARY KEY(lifetime_id, locale_id),
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by_user_id UUID NOT NULL REFERENCES account.user (user_id),
    updated_by_user_id UUID NOT NULL REFERENCES account.user (user_id)
);
CREATE TRIGGER calendar_lifetime_i18n_set_updated_at BEFORE UPDATE ON calendar.lifetime_i18n
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE calendar.lifetime_weekday (
    lifetime_id UUID NOT NULL REFERENCES calendar.lifetime (lifetime_id)
        ON DELETE CASCADE,
    weekday_id INTEGER NOT NULL REFERENCES calendar.weekday (weekday_id),
    PRIMARY KEY (lifetime_id, weekday_id)
);

COMMIT;