BEGIN;

CREATE SCHEMA calendar;

CREATE TABLE calendar.weekday (
    weekday_id INT PRIMARY KEY,
    weekday_name TEXT NOT NULL
);

INSERT INTO calendar.weekday (weekday_id, weekday_name) VALUES
    (0, 'Feriados'),
    (1, 'Lunes'),
    (2, 'Martes'),
    (3, 'Miercoles'),
    (4, 'Jueves'),
    (5, 'Viernes'),
    (6, 'Sabado'),
    (7, 'Domingo');

CREATE TABLE calendar.holiday (
    holiday_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    holiday_name TEXT NOT NULL,
    description TEXT,
    holiday_date DATE NOT NULL
);

CREATE TABLE calendar.lifetime (
    lifetime_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    private_name TEXT NOT NULL,
    public_name TEXT NOT NULL,
    description TEXT,
    "start" DATE NOT NULL,
    "end" DATE NOT NULL
);

CREATE TABLE calendar.lifetime_weekday (
    lifetime_id UUID NOT NULL REFERENCES calendar.lifetime (lifetime_id),
    weekday_id INT NOT NULL REFERENCES calendar.weekday (weekday_id),
    PRIMARY KEY (lifetime_id, weekday_id)
);

COMMIT;