BEGIN;

DO $$
DECLARE
    admin_user_id UUID;
    lifetime_1_id UUID;
    product_1_id UUID;
    product_2_id UUID;
    listing_1_id UUID;
    listing_2_id UUID;
BEGIN

SELECT user_id
INTO admin_user_id
FROM staff.user
WHERE username = 'admin';

INSERT INTO calendar.lifetime (
  private_name,
  public_name,
  description,
  "start",
  "end",
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'Hasta Fin de Gestion 2019',
  'Valido hasta fin de 2019',
  'Este producto es valido en tales y tales dias de tal a tal fecha',
  '2019-01-01',
  '2019-12-31',
  admin_user_id,
  admin_user_id
) RETURNING lifetime_id INTO lifetime_1_id;
INSERT INTO calendar.lifetime_weekday (lifetime_id, weekday_id) VALUES
  (lifetime_1_id, 0), -- Feriados
  (lifetime_1_id, 1), -- Lunes
  (lifetime_1_id, 2), -- Martes
  (lifetime_1_id, 3), -- Miercoles
  (lifetime_1_id, 4), -- Jueves
  (lifetime_1_id, 5), -- Viernes
  (lifetime_1_id, 6), -- Sabado
  (lifetime_1_id, 7); -- Domingo

INSERT INTO store.product (
  product_name,
  description,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'Ingreso',
  'Ingreso Adulto',
  admin_user_id,
  admin_user_id
) RETURNING product_id INTO product_1_id;

INSERT INTO store.product (
  product_name,
  description,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'Buffet',
  'Buffet Adulto',
  admin_user_id,
  admin_user_id
) RETURNING product_id INTO product_2_id;

INSERT INTO store.listing (
  listing_name,
  description,
  available_from,
  available_to,
  available_stock,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'Ingreso Adulto',
  'Incluye Un ingreso para adulto',
  '2019-01-01',
  '2019-12-31',
  null,
  admin_user_id,
  admin_user_id
) RETURNING listing_id INTO listing_1_id;
INSERT INTO store.listing_product (
  listing_id,
  product_id,
  quantity,
  price,
  lifetime_id
) VALUES (
  listing_1_id,
  product_1_id,
  1,
  14000,
  lifetime_1_id
);

INSERT INTO store.listing (
  listing_name,
  description,
  available_from,
  available_to,
  available_stock,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'Buffet Adulto 2x1',
  'Incluye dos Buffet para adulto',
  '2019-01-01',
  '2019-12-31',
  null,
  admin_user_id,
  admin_user_id
) RETURNING listing_id INTO listing_2_id;
INSERT INTO store.listing_product (
  listing_id,
  product_id,
  quantity,
  price,
  lifetime_id
) VALUES (
  listing_2_id,
  product_2_id,
  2,
  12000,
  lifetime_1_id
);

END $$;

COMMIT;