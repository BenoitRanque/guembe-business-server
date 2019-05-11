BEGIN;

DO $$
DECLARE
    admin_user_id UUID;
    lifetime_1_id UUID;
    lifetime_2_id UUID;
    lifetime_3_id UUID;
    product_1_id UUID;
    product_2_id UUID;
    product_3_id UUID;
    product_4_id UUID;
    product_5_id UUID;
    product_6_id UUID;
    listing_1_id UUID;
    listing_2_id UUID;
    listing_3_id UUID;
    listing_4_id UUID;
    listing_5_id UUID;
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
  'Este producto es valido de Lunes a Domingo, incluyendo feriados, hasta el 31 de diciembre 2019',
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

INSERT INTO calendar.lifetime (
  private_name,
  public_name,
  description,
  "start",
  "end",
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'Valido Viernes a Domingo, y Feriados, hasta fin de Septiembre 2019',
  'Valido Viernes-Domingo, y Feriados, hasta fin de Septiembre 2019',
  'Este producto es valido de Viernes a Domingo, mas Feriados, desde el 01 de mayo hasta el 30 de septiembre 2019',
  '2019-05-01',
  '2019-09-30',
  admin_user_id,
  admin_user_id
) RETURNING lifetime_id INTO lifetime_2_id;
INSERT INTO calendar.lifetime_weekday (lifetime_id, weekday_id) VALUES
  (lifetime_2_id, 0), -- Feriados
  (lifetime_2_id, 5), -- Viernes
  (lifetime_2_id, 6), -- Sabado
  (lifetime_2_id, 7); -- Domingo

INSERT INTO calendar.lifetime (
  private_name,
  public_name,
  description,
  "start",
  "end",
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'Lunes a Viernes, sin Feriados, hasta fin de 2019',
  'Lunes a Viernes, hasta finales de 2019',
  'Este producto es valido de lunes a viernes, excluyendo feriados, hasta el 31 de diciembre 2019',
  '2019-01-01',
  '2019-12-31',
  admin_user_id,
  admin_user_id
) RETURNING lifetime_id INTO lifetime_3_id;
INSERT INTO calendar.lifetime_weekday (lifetime_id, weekday_id) VALUES
  (lifetime_3_id, 1), -- Lunes
  (lifetime_3_id, 2), -- Martes
  (lifetime_3_id, 3), -- Miercoles
  (lifetime_3_id, 4), -- Jueves
  (lifetime_3_id, 5); -- Viernes

INSERT INTO store.product (
  public_name,
  description,
  economic_activity_id,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'Ingreso',
  'Accesso al parque y todos sus atractivos para 1 adulto entre 18 y 69 años de edad. No incluye alimentos ni bebidas.',
  71409,
  admin_user_id,
  admin_user_id
) RETURNING product_id INTO product_1_id;

INSERT INTO store.product (
  public_name,
  description,
  economic_activity_id,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'Ingreso Adolecente',
  'Accesso al parque y todos sus atractivos para 1 adolecente entre 12 y 17 años de edad. No incluye alimentos ni bebidas.',
  71409,
  admin_user_id,
  admin_user_id
) RETURNING product_id INTO product_2_id;

INSERT INTO store.product (
  public_name,
  description,
  economic_activity_id,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'Ingreso Niño',
  'Accesso al parque y todos sus atractivos para 1 niño entre 3 y 11 años de edad. No incluye alimentos ni bebidas.',
  71409,
  admin_user_id,
  admin_user_id
) RETURNING product_id INTO product_3_id;

INSERT INTO store.product (
  public_name,
  description,
  economic_activity_id,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'Buffet Adulto',
  'Buffet de cubierto libre para almuerzo. Disponible desde las 12:00 hasta las 15:00 horas.',
  72203,
  admin_user_id,
  admin_user_id
) RETURNING product_id INTO product_4_id;

INSERT INTO store.product (
  public_name,
  description,
  economic_activity_id,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'Coctail de bienvenida',
  'Coctail promocional, disponible en cualquiera de nuestros bares. Mescla de fernet, ron, wisky, cerveza, azucar y yo que se...',
  72203,
  admin_user_id,
  admin_user_id
) RETURNING product_id INTO product_5_id;

INSERT INTO store.product (
  public_name,
  description,
  economic_activity_id,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'Chop de Cerveza',
  'Chop de Cerveza Prost, disponible en nuestro beergarden',
  72203,
  admin_user_id,
  admin_user_id
) RETURNING product_id INTO product_6_id;

INSERT INTO store.listing (
  public_name,
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
  public_name,
  description,
  available_from,
  available_to,
  available_stock,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'Paquete Full Day adulto',
  'Llevate el buffet a solo 100 bs comprando este paquete. Para 1 adulto, ingreso & buffet. No inlcuye bebidas.',
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
  product_1_id,
  1,
  14000,
  lifetime_1_id
), (
  listing_2_id,
  product_4_id,
  1,
  10000,
  lifetime_1_id
);

INSERT INTO store.listing (
  public_name,
  description,
  available_from,
  available_to,
  available_stock,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'CUPO LIMITADO: Ingreso con coctail de bienvenida gratis',
  'Incluye 1 ingreso para adultos, mas un coctail de bienvenida completamente gratis',
  '2019-01-01',
  '2019-06-30',
  5,
  admin_user_id,
  admin_user_id
) RETURNING listing_id INTO listing_3_id;
INSERT INTO store.listing_product (
  listing_id,
  product_id,
  quantity,
  price,
  lifetime_id
) VALUES (
  listing_3_id,
  product_1_id,
  1,
  14000,
  lifetime_1_id
), (
  listing_3_id,
  product_5_id,
  1,
  0,
  lifetime_1_id
);

INSERT INTO store.listing (
  public_name,
  description,
  available_from,
  available_to,
  available_stock,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'CUPO LIMITADO: Por la compra de 3 ingresos, llevate 1 gratis',
  'Incluye 3 ingresos mas uno completamente gratis!. Solo valido para uso los dias de semana, excluyendo feriados',
  '2019-01-01',
  '2019-06-30',
  10,
  admin_user_id,
  admin_user_id
) RETURNING listing_id INTO listing_4_id;
INSERT INTO store.listing_product (
  listing_id,
  product_id,
  quantity,
  price,
  lifetime_id
) VALUES (
  listing_4_id,
  product_1_id,
  3,
  14000,
  lifetime_3_id
), (
  listing_4_id,
  product_1_id,
  1,
  0,
  lifetime_3_id
);

INSERT INTO store.listing (
  public_name,
  description,
  available_from,
  available_to,
  available_stock,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'CUPO LIMITADO: Por la compra de un ingreso y un chop de cerveza, llevate otro chop gratis!',
  'Incluye un ingreso para adulto, y 2 chop de cerveza',
  '2019-01-01',
  '2019-06-30',
  10,
  admin_user_id,
  admin_user_id
) RETURNING listing_id INTO listing_5_id;
INSERT INTO store.listing_product (
  listing_id,
  product_id,
  quantity,
  price,
  lifetime_id
) VALUES (
  listing_5_id,
  product_1_id,
  1,
  14000,
  lifetime_1_id
), (
  listing_5_id,
  product_6_id,
  1,
  2500,
  lifetime_2_id
), (
  listing_5_id,
  product_6_id,
  1,
  0,
  lifetime_2_id
);

END $$;

COMMIT;