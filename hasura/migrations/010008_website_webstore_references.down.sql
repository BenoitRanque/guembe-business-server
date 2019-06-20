BEGIN;

ALTER TABLE website.element
DROP COLUMN category_link;
DROP COLUMN listing_link;

COMMIT;