BEGIN;

CREATE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
    -- the below is not compatible with JSON columns, as the must be type cast before comparison
    -- IF row(NEW.*) IS DISTINCT FROM row(OLD.*) THEN
    --     NEW.updated_at = now();
    --     RETURN NEW;
    -- ELSE
    --     RETURN OLD;
    -- END IF;
END;
$$ language 'plpgsql';

COMMIT;
