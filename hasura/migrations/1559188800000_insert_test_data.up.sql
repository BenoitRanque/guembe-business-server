DO $$
DECLARE
    admin_user_id UUID;
    lifetime_1_id UUID;
    lifetime_2_id UUID;
    lifetime_3_id UUID;
    lifetime_4_id UUID;
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
END $$;