BEGIN;

ALTER TABLE website.element
ADD COLUMN listing_link UUID REFERENCES webstore.listing (listing_id);

COMMIT;