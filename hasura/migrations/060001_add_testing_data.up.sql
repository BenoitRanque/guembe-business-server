BEGIN;

DO $$
DECLARE
    admin_user_id UUID;
    locale_1_id TEXT := 'es';
    lifetime_1_id UUID;
    lifetime_2_id UUID;
    lifetime_3_id UUID;
    product_1_id UUID;
    -- product_2_id UUID;
    -- product_3_id UUID;
    -- product_4_id UUID;
    -- product_5_id UUID;
    -- product_6_id UUID;
    -- product_7_id UUID;
    listing_1_id UUID;
    -- listing_2_id UUID;
    -- listing_3_id UUID;
    -- listing_4_id UUID;
    -- listing_5_id UUID;
    -- listing_6_id UUID;
    -- listing_7_id UUID;
BEGIN

SELECT user_id
INTO admin_user_id
FROM account.user
WHERE username = 'admin';

INSERT INTO calendar.lifetime (
  name,
  "start",
  "end",
  include_holidays,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'Hasta Fin de Gestion 2019',
  '2019-01-01',
  '2019-12-31',
  true,
  admin_user_id,
  admin_user_id
) RETURNING lifetime_id INTO lifetime_1_id;
INSERT INTO calendar.lifetime_i18n (lifetime_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  lifetime_1_id,
  locale_1_id,
  'Valido hasta fin de 2019',
  'Este producto es valido de Lunes a Domingo, incluyendo feriados, hasta el 31 de diciembre 2019',
  admin_user_id,
  admin_user_id
);
INSERT INTO calendar.lifetime_weekday (lifetime_id, weekday_id) VALUES
  (lifetime_1_id, 0), -- Domingo
  (lifetime_1_id, 1), -- Lunes
  (lifetime_1_id, 2), -- Martes
  (lifetime_1_id, 3), -- Miercoles
  (lifetime_1_id, 4), -- Jueves
  (lifetime_1_id, 5), -- Viernes
  (lifetime_1_id, 6); -- Sabado

INSERT INTO calendar.lifetime (
  name,
  "start",
  "end",
  include_holidays,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'Valido Viernes a Domingo, y Feriados, hasta fin de Septiembre 2019',
  '2019-05-01',
  '2019-09-30',
  true,
  admin_user_id,
  admin_user_id
) RETURNING lifetime_id INTO lifetime_2_id;
INSERT INTO calendar.lifetime_i18n (lifetime_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  lifetime_2_id,
  locale_1_id,
  'Valido Viernes-Domingo, y Feriados, hasta fin de Septiembre 2019',
  'Este producto es valido de Viernes a Domingo, mas Feriados, desde el 01 de mayo hasta el 30 de septiembre 2019',
  admin_user_id,
  admin_user_id
);
INSERT INTO calendar.lifetime_weekday (lifetime_id, weekday_id) VALUES
  (lifetime_2_id, 0), -- Domingo
  (lifetime_2_id, 5), -- Viernes
  (lifetime_2_id, 6); -- Sabado

INSERT INTO calendar.lifetime (
  name,
  "start",
  "end",
  include_holidays,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'Lunes a Viernes, sin Feriados, hasta fin de 2019',
  '2019-01-01',
  '2019-12-31',
  false,
  admin_user_id,
  admin_user_id
) RETURNING lifetime_id INTO lifetime_3_id;
INSERT INTO calendar.lifetime_i18n (lifetime_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  lifetime_3_id,
  locale_1_id,
  'Lunes a Viernes, hasta finales de 2019',
  'Este producto es valido de lunes a viernes, excluyendo feriados, hasta el 31 de diciembre 2019',
  admin_user_id,
  admin_user_id
);
INSERT INTO calendar.lifetime_weekday (lifetime_id, weekday_id) VALUES
  (lifetime_3_id, 1), -- Lunes
  (lifetime_3_id, 2), -- Martes
  (lifetime_3_id, 3), -- Miercoles
  (lifetime_3_id, 4), -- Jueves
  (lifetime_3_id, 5); -- Viernes

INSERT INTO webstore.product (
  name,
  economic_activity_id,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'Ingreso Adulto',
  71409,
  admin_user_id,
  admin_user_id
) RETURNING product_id INTO product_1_id;
INSERT INTO webstore.product_i18n (product_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  product_1_id,
  locale_1_id,
  'Ingreso',
  'Accesso al parque y todos sus atractivos para 1 adulto entre 18 y 69 años de edad. No incluye alimentos ni bebidas.',
  admin_user_id,
  admin_user_id
);

-- INSERT INTO webstore.product (
--   private_name,
--   public_name,
--   description,
--   economic_activity_id,
--   created_by_user_id,
--   updated_by_user_id
-- ) VALUES (
--   'Ingreso Adolecente',
--   'Ingreso Adolecente',
--   'Accesso al parque y todos sus atractivos para 1 adolecente entre 12 y 17 años de edad. No incluye alimentos ni bebidas.',
--   71409,
--   admin_user_id,
--   admin_user_id
-- ) RETURNING product_id INTO product_2_id;

-- INSERT INTO webstore.product (
--   private_name,
--   public_name,
--   description,
--   economic_activity_id,
--   created_by_user_id,
--   updated_by_user_id
-- ) VALUES (
--   'Ingreso Niño',
--   'Ingreso Niño',
--   'Accesso al parque y todos sus atractivos para 1 niño entre 3 y 11 años de edad. No incluye alimentos ni bebidas.',
--   71409,
--   admin_user_id,
--   admin_user_id
-- ) RETURNING product_id INTO product_3_id;

-- INSERT INTO webstore.product (
--   private_name,
--   public_name,
--   description,
--   economic_activity_id,
--   created_by_user_id,
--   updated_by_user_id
-- ) VALUES (
--   'Buffet Adulto',
--   'Buffet Adulto',
--   'Buffet de cubierto libre para almuerzo. Disponible desde las 12:00 hasta las 15:00 horas.',
--   72203,
--   admin_user_id,
--   admin_user_id
-- ) RETURNING product_id INTO product_4_id;

-- INSERT INTO webstore.product (
--   private_name,
--   public_name,
--   description,
--   economic_activity_id,
--   created_by_user_id,
--   updated_by_user_id
-- ) VALUES (
--   'Coctail Promocional Bajo Costo',
--   'Coctail de bienvenida',
--   'Coctail promocional, disponible en cualquiera de nuestros bares. Mescla de fernet, ron, wisky, cerveza, azucar y yo que se...',
--   72203,
--   admin_user_id,
--   admin_user_id
-- ) RETURNING product_id INTO product_5_id;

-- INSERT INTO webstore.product (
--   private_name,
--   public_name,
--   description,
--   economic_activity_id,
--   created_by_user_id,
--   updated_by_user_id
-- ) VALUES (
--   'Chop de Cerveza Prost',
--   'Chop de Cerveza',
--   'Chop de Cerveza Prost, disponible en nuestro beergarden',
--   72203,
--   admin_user_id,
--   admin_user_id
-- ) RETURNING product_id INTO product_6_id;

-- INSERT INTO webstore.product (
--   private_name,
--   public_name,
--   description,
--   economic_activity_id,
--   created_by_user_id,
--   updated_by_user_id
-- ) VALUES (
--   'Ingreso Adulto 2 por 1',
--   'Ingreso Adulto 2x1',
--   'Ingreso 2 por 1. Al ser un solo producto, ambos ingresos deben utilizarse al mismo tiempo',
--   72203,
--   admin_user_id,
--   admin_user_id
-- ) RETURNING product_id INTO product_7_id;

INSERT INTO webstore.listing (
  name,
  available_from,
  available_to,
  supply,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  'Paquete de ingreso adulto 2019',
  '2019-01-01',
  '2019-12-31',
  null,
  admin_user_id,
  admin_user_id
) RETURNING listing_id INTO listing_1_id;
INSERT INTO webstore.listing_product (
  listing_id,
  product_id,
  quantity,
  price,
  lifetime_id,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  listing_1_id,
  product_1_id,
  1,
  14000,
  lifetime_1_id,
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.listing_i18n (listing_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  listing_1_id,
  locale_1_id,
  'Ingreso Adulto',
  'Incluye Un ingreso para adulto',
  admin_user_id,
  admin_user_id
);

-- INSERT INTO webstore.listing (
--   private_name,
--   public_name,
--   description,
--   available_from,
--   available_to,
--   supply,
--   created_by_user_id,
--   updated_by_user_id
-- ) VALUES (
--   'Paquete full day 2019',
--   'Paquete Full Day adulto',
--   'Llevate el buffet a solo 100 bs comprando este paquete. Para 1 adulto, ingreso & buffet. No inlcuye bebidas.',
--   '2019-01-01',
--   '2019-12-31',
--   null,
--   admin_user_id,
--   admin_user_id
-- ) RETURNING listing_id INTO listing_2_id;
-- INSERT INTO webstore.listing_product (
--   listing_id,
--   product_id,
--   quantity,
--   price,
--   lifetime_id
-- ) VALUES (
--   listing_2_id,
--   product_1_id,
--   1,
--   14000,
--   lifetime_1_id
-- ), (
--   listing_2_id,
--   product_4_id,
--   1,
--   10000,
--   lifetime_1_id
-- );

-- INSERT INTO webstore.listing (
--   private_name,
--   public_name,
--   description,
--   available_from,
--   available_to,
--   supply,
--   created_by_user_id,
--   updated_by_user_id
-- ) VALUES (
--   'Paquete de ingreso con coctail promocional enero - junio 2019 (cupo limitado)',
--   'CUPO LIMITADO: Ingreso con coctail de bienvenida gratis',
--   'Incluye 1 ingreso para adultos, mas un coctail de bienvenida completamente gratis',
--   '2019-01-01',
--   '2019-06-30',
--   5,
--   admin_user_id,
--   admin_user_id
-- ) RETURNING listing_id INTO listing_3_id;
-- INSERT INTO webstore.listing_product (
--   listing_id,
--   product_id,
--   quantity,
--   price,
--   lifetime_id
-- ) VALUES (
--   listing_3_id,
--   product_1_id,
--   1,
--   14000,
--   lifetime_1_id
-- ), (
--   listing_3_id,
--   product_5_id,
--   1,
--   0,
--   lifetime_1_id
-- );

-- INSERT INTO webstore.listing (
--   private_name,
--   public_name,
--   description,
--   available_from,
--   available_to,
--   supply,
--   created_by_user_id,
--   updated_by_user_id
-- ) VALUES (
--   'Paquete de 1 ingreso gratis por la compra de 3 ingresos',
--   'CUPO LIMITADO: Por la compra de 3 ingresos, llevate 1 gratis',
--   'Incluye 3 ingresos mas uno completamente gratis!. Solo valido para uso los dias de semana, excluyendo feriados',
--   '2019-01-01',
--   '2019-06-30',
--   10,
--   admin_user_id,
--   admin_user_id
-- ) RETURNING listing_id INTO listing_4_id;
-- INSERT INTO webstore.listing_product (
--   listing_id,
--   product_id,
--   quantity,
--   price,
--   lifetime_id
-- ) VALUES (
--   listing_4_id,
--   product_1_id,
--   3,
--   14000,
--   lifetime_3_id
-- ), (
--   listing_4_id,
--   product_1_id,
--   1,
--   0,
--   lifetime_3_id
-- );

-- INSERT INTO webstore.listing (
--   private_name,
--   public_name,
--   description,
--   available_from,
--   available_to,
--   supply,
--   created_by_user_id,
--   updated_by_user_id
-- ) VALUES (
--   'Paquete de ingreso & chop de cerveza con un chop gratis (cupo 10)',
--   'CUPO LIMITADO: Por la compra de un ingreso y un chop de cerveza, llevate otro chop gratis!',
--   'Incluye un ingreso para adulto, y 2 chop de cerveza',
--   '2019-01-01',
--   '2019-06-30',
--   10,
--   admin_user_id,
--   admin_user_id
-- ) RETURNING listing_id INTO listing_5_id;
-- INSERT INTO webstore.listing_product (
--   listing_id,
--   product_id,
--   quantity,
--   price,
--   lifetime_id
-- ) VALUES (
--   listing_5_id,
--   product_1_id,
--   1,
--   14000,
--   lifetime_1_id
-- ), (
--   listing_5_id,
--   product_6_id,
--   1,
--   2500,
--   lifetime_2_id
-- ), (
--   listing_5_id,
--   product_6_id,
--   1,
--   0,
--   lifetime_2_id
-- );

-- INSERT INTO webstore.listing (
--   private_name,
--   public_name,
--   description,
--   available_from,
--   available_to,
--   supply,
--   created_by_user_id,
--   updated_by_user_id
-- ) VALUES (
--   'Paquete comprate un ingreso llevate 2 (cupo 10)',
--   'CUPO LIMITADO: Por la compra de 1 ingreso, llevate otro gratis',
--   'Incluye dos ingresos para adulto',
--   '2019-01-01',
--   '2019-06-30',
--   10,
--   admin_user_id,
--   admin_user_id
-- ) RETURNING listing_id INTO listing_6_id;
-- INSERT INTO webstore.listing_product (
--   listing_id,
--   product_id,
--   quantity,
--   price,
--   lifetime_id
-- ) VALUES (
--   listing_6_id,
--   product_1_id,
--   1,
--   14000,
--   lifetime_1_id
-- ), (
--   listing_6_id,
--   product_1_id,
--   1,
--   0,
--   lifetime_1_id
-- );

-- INSERT INTO webstore.listing (
--   private_name,
--   public_name,
--   description,
--   available_from,
--   available_to,
--   supply,
--   created_by_user_id,
--   updated_by_user_id
-- ) VALUES (
--   'Paquete 2 por 1',
--   'Paquete 2 por 1!',
--   'Con este paquete ingresan 2 personas a precio de 1. Solo valido de lunes a viernes',
--   '2019-01-01',
--   '2019-06-30',
--   10,
--   admin_user_id,
--   admin_user_id
-- ) RETURNING listing_id INTO listing_7_id;
-- INSERT INTO webstore.listing_product (
--   listing_id,
--   product_id,
--   quantity,
--   price,
--   lifetime_id
-- ) VALUES (
--   listing_7_id,
--   product_7_id,
--   1,
--   14000,
--   lifetime_2_id
-- );

END $$;

COMMIT;