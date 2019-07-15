BEGIN;

DO $$
DECLARE
    admin_user_id UUID;
BEGIN

SELECT user_id
INTO admin_user_id
FROM account.user
WHERE username = 'admin';

INSERT INTO website.page (
  path,
  name,
  editable,
  protected,
  created_by_user_id,
  updated_by_user_id
) VALUES
  ('', 'Inicio', true, true, admin_user_id, admin_user_id);

INSERT INTO website.format (format_id, name) VALUES
    ('background', 'Fondo de pagina'),
    ('6x4', '6x4'),
    ('4x3', '4x3'),
    ('21x9', '21x9');
INSERT INTO website.format_size (format_id, size_id, width, height) VALUES
    ('background', 'xl', 1920, 1080),
    ('background', 'lg', 1366, 768),
    ('background', 'md', 768, 1024),
    ('background', 'sm', 360, 640),
    ('background', 'xs', 320, 480),
    ('4x3', 'xl', 800, 600),
    ('4x3', 'lg', 640, 480),
    ('4x3', 'md', 480, 360),
    ('4x3', 'sm', 320, 240),
    ('4x3', 'xs', 160, 120),
    ('6x4', 'xl', 900, 600),
    ('6x4', 'lg', 720, 480),
    ('6x4', 'md', 540, 360),
    ('6x4', 'sm', 360, 240),
    ('6x4', 'xs', 180, 120),
    ('21x9', 'xl', 2520, 1080),
    ('21x9', 'lg', 1680, 720),
    ('21x9', 'md', 980, 420),
    ('21x9', 'sm', 840, 360),
    ('21x9', 'xs', 560, 240);

WITH inserted_user (user_id) AS (
  INSERT INTO account.user (user_type_id, username, password, created_by_user_id, updated_by_user_id)
  VALUES ('staff', 'ffernandez', 'fernanda', admin_user_id, admin_user_id)
  RETURNING user_id
)
INSERT INTO account.user_role (user_id, role_id, created_by_user_id, updated_by_user_id)
SELECT inserted_user.user_id, 'administrator', admin_user_id, admin_user_id
FROM inserted_user;

END $$;

COMMIT;