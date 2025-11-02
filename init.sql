-- Crear usuario para acceso externo
CREATE USER IF NOT EXISTS 'externo'@'%' IDENTIFIED BY 'PasswordExterno123';
GRANT SELECT, INSERT, UPDATE, DELETE ON nestapp.* TO 'externo'@'%';

-- Crear usuario solo para aplicación
CREATE USER IF NOT EXISTS 'app_user'@'%' IDENTIFIED BY 'PasswordApp123';
GRANT ALL PRIVILEGES ON nestapp.* TO 'app_user'@'%';

FLUSH PRIVILEGES;