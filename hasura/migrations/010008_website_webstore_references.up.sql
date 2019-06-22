BEGIN;

ALTER TABLE website.element
-- create webstore.categoy table
-- ADD COLUMN category_link UUID REFERENCES webstore.category (category_id),
ADD COLUMN listing_link UUID REFERENCES webstore.listing (listing_id);

COMMIT;