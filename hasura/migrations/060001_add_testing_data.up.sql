BEGIN;

DO $$
DECLARE
    admin_user_id UUID;
    locale_1_id TEXT := 'es';
    locale_2_id TEXT := 'en';
    lifetime_1_id UUID := gen_random_uuid();
    lifetime_2_id UUID := gen_random_uuid();
    lifetime_3_id UUID := gen_random_uuid();
    product_1_id UUID := gen_random_uuid();
    product_2_id UUID := gen_random_uuid();
    product_3_id UUID := gen_random_uuid();
    product_4_id UUID := gen_random_uuid();
    product_5_id UUID := gen_random_uuid();
    product_6_id UUID := gen_random_uuid();
    listing_1_id UUID := gen_random_uuid();
    listing_2_id UUID := gen_random_uuid();
    listing_3_id UUID := gen_random_uuid();
    listing_4_id UUID := gen_random_uuid();
BEGIN

SELECT user_id
INTO admin_user_id
FROM account.user
WHERE username = 'admin';

INSERT INTO calendar.lifetime (
  lifetime_id,
  name,
  "start",
  "end",
  include_holidays,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  lifetime_1_id,
  'Hasta Fin de Gestion 2019',
  '2019-01-01',
  '2019-12-31',
  true,
  admin_user_id,
  admin_user_id
);
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
  lifetime_id,
  name,
  "start",
  "end",
  include_holidays,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  lifetime_2_id,
  'Valido Viernes a Domingo, y Feriados, hasta fin de Septiembre 2019',
  '2019-05-01',
  '2019-09-30',
  true,
  admin_user_id,
  admin_user_id
);
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
  lifetime_id,
  name,
  "start",
  "end",
  include_holidays,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  lifetime_3_id,
  'Lunes a Viernes, sin Feriados, hasta fin de 2019',
  '2019-01-01',
  '2019-12-31',
  false,
  admin_user_id,
  admin_user_id
);
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
  product_id,
  name,
  economic_activity_id,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  product_1_id,
  'Ingreso Adulto',
  71409,
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.product_i18n (product_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  product_1_id,
  locale_1_id,
  'Ingreso',
  'Accesso al parque y todos sus atractivos para 1 adulto entre 18 y 69 años de edad. No incluye alimentos ni bebidas.',
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.product_i18n (product_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  product_1_id,
  locale_2_id,
  'Entry',
  'Basic access to the park and all attractions. Valid for one adult between 18 y 69 years old. Does not include food or beverages.',
  admin_user_id,
  admin_user_id
);

INSERT INTO webstore.product (
  product_id,
  name,
  economic_activity_id,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  product_2_id,
  'Ingreso Adolecente',
  71409,
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.product_i18n (product_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  product_2_id,
  locale_1_id,
  'Ingreso',
  'Accesso al parque y todos sus atractivos para 1 adulto entre 18 y 69 años de edad. No incluye alimentos ni bebidas.',
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.product_i18n (product_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  product_2_id,
  locale_2_id,
  'Entry',
  'Basic access to the park and all attractions. Valid for one adult between 18 and 69 years old. Does not include food or beverages.',
  admin_user_id,
  admin_user_id
);

INSERT INTO webstore.product (
  product_id,
  name,
  economic_activity_id,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  product_3_id,
  'Ingreso Niño',
  71409,
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.product_i18n (product_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  product_3_id,
  locale_1_id,
  'Ingreso Niño',
  'Accesso al parque y todos sus atractivos para 1 niño entre 3 y 11 años de edad. No incluye alimentos ni bebidas.',
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.product_i18n (product_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  product_3_id,
  locale_2_id,
  'Children Entry',
  'Basic access to the park and all attractions. Valid for one child between 3 and 11 years old. Does not include food or beverages.',
  admin_user_id,
  admin_user_id
);

INSERT INTO webstore.product (
  product_id,
  name,
  economic_activity_id,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  product_4_id,
  'Buffet Adulto',
  72203,
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.product_i18n (product_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  product_4_id,
  locale_1_id,
  'Buffet Adulto',
  'Buffet de cubierto libre para almuerzo. Disponible desde las 12:00 hasta las 15:00 horas.',
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.product_i18n (product_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  product_4_id,
  locale_2_id,
  'Buffet (Adult)',
  'Lunch Buffet for adults. Available from 12:00 until 15:00',
  admin_user_id,
  admin_user_id
);

INSERT INTO webstore.product (
  product_id,
  name,
  economic_activity_id,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  product_5_id,
  'Coctail Promocional Bajo Costo',
  72203,
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.product_i18n (product_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  product_5_id,
  locale_1_id,
  'Coctail de bienvenida',
  'Coctail de bienvenida, disponible en cualquiera de nuestros bares. Mescla de fernet, ron, wisky, cerveza, azucar y yo que se...',
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.product_i18n (product_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  product_5_id,
  locale_2_id,
  'Welcome Drink',
  'Welcome Drink, available in any of our bars.',
  admin_user_id,
  admin_user_id
);

INSERT INTO webstore.product (
  product_id,
  name,
  economic_activity_id,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  product_6_id,
  'Chop de Cerveza Prost',
  72203,
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.product_i18n (product_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  product_6_id,
  locale_1_id,
  'Chop de Cerveza',
  'Chop de Cerveza Prost, disponible en nuestro beergarden',
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.product_i18n (product_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  product_6_id,
  locale_2_id,
  'Beer Mug',
  'An ice cold beer served in a mug in our beergarden.',
  admin_user_id,
  admin_user_id
);

INSERT INTO webstore.listing (
  listing_id,
  name,
  available_from,
  available_to,
  supply,
  lifetime_id,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  listing_1_id,
  'Paquete de ingreso adulto 2019',
  '2019-01-01',
  '2019-12-31',
  null,
  lifetime_1_id,
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.listing_product (
  listing_id,
  product_id,
  quantity,
  price,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  listing_1_id,
  product_1_id,
  1,
  14000,
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
INSERT INTO webstore.listing_i18n (listing_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  listing_1_id,
  locale_2_id,
  'Adult Entry',
  'Entrance for 1 adult',
  admin_user_id,
  admin_user_id
);

INSERT INTO webstore.listing (
  listing_id,
  name,
  available_from,
  available_to,
  supply,
  emit_multiple_vouchers,
  lifetime_id,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  listing_2_id,
  'Paquete full day 2019',
  '2019-01-01',
  '2019-12-31',
  null,
  false,
  lifetime_1_id,
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.listing_product (
  listing_id,
  product_id,
  quantity,
  price,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  listing_2_id,
  product_1_id,
  1,
  14000,
  admin_user_id,
  admin_user_id
), (
  listing_2_id,
  product_4_id,
  1,
  10000,
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.listing_i18n (listing_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  listing_2_id,
  locale_1_id,
  'Paquete Full Day adulto',
  'Llevate el buffet a solo 100 bs comprando este paquete. Para 1 adulto, ingreso & buffet. No incluye bebidas.',
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.listing_i18n (listing_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  listing_2_id,
  locale_2_id,
  'Fullday Package',
  'Fullday package for 1 adult. Includes entrance and buffet. Does not include beverages',
  admin_user_id,
  admin_user_id
);

INSERT INTO webstore.listing (
  listing_id,
  name,
  available_from,
  available_to,
  supply,
  emit_multiple_vouchers,
  lifetime_id,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  listing_3_id,
  'Promo por cada 3 ingresos te regalamos uno gratis',
  '2019-01-01',
  '2019-12-31',
  null,
  true,
  lifetime_1_id,
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.listing_product (
  listing_id,
  product_id,
  quantity,
  price,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  listing_3_id,
  product_1_id,
  3,
  14000,
  admin_user_id,
  admin_user_id
), (
  listing_3_id,
  product_1_id,
  1,
  0,
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.listing_i18n (listing_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  listing_3_id,
  locale_1_id,
  'Promo 4 entradas a precio de 3',
  'Por la compra de 3 entradas te regalamos una entrada addicional. Estas entradas pueden utilizarse por separado',
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.listing_i18n (listing_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  listing_3_id,
  locale_2_id,
  '4 entrances for the price of 3',
  '4 entrances for the price of 3. Those can be used separately',
  admin_user_id,
  admin_user_id
);

INSERT INTO webstore.listing (
  listing_id,
  name,
  available_from,
  available_to,
  supply,
  emit_multiple_vouchers,
  lifetime_id,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  listing_4_id,
  'Ingreso con cotail de bienvenida',
  '2019-01-01',
  '2019-12-31',
  null,
  false,
  lifetime_1_id,
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.listing_product (
  listing_id,
  product_id,
  quantity,
  price,
  created_by_user_id,
  updated_by_user_id
) VALUES (
  listing_4_id,
  product_1_id,
  1,
  14000,
  admin_user_id,
  admin_user_id
), (
  listing_4_id,
  product_5_id,
  1,
  0,
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.listing_i18n (listing_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  listing_4_id,
  locale_1_id,
  'Ingreso con cotail de bienvenida',
  'Ingreso con cotail de bienvenida. Vale para un adulto.',
  admin_user_id,
  admin_user_id
);
INSERT INTO webstore.listing_i18n (listing_id, locale_id, name, description, created_by_user_id, updated_by_user_id)
VALUES (
  listing_4_id,
  locale_2_id,
  'Entry with welcome drink',
  'Entry with welcome drink. Valid for one adult',
  admin_user_id,
  admin_user_id
);

END $$;

COMMIT;