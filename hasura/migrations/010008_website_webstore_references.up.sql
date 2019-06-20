BEGIN;

ALTER TABLE website.element
ADD COLUMN listing_link UUID REFERENCES webstore.listing (listing_id),
ADD COLUMN category_link UUID REFERENCES webstore.category (category_id);

COMMIT;