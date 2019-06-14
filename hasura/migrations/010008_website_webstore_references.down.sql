BEGIN;

ALTER TABLE website.element
DROP COLUMN listing_link;

COMMIT;