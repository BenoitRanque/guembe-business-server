BEGIN;

DELETE FROM store.listing;
DELETE FROM store.product;
DELETE FROM calendar.lifetime;

COMMIT;