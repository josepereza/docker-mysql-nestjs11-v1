# docker-mysql-nestjs11-v1
## 📦 Instalar Docker en tu VPS Ubuntu
Sigue estos pasos para una instalación manual y segura desde los repositorios oficiales de Docker.

Conectarse y Actualizar el Sistema: Conéctate a tu VPS vía SSH y actualiza la lista de paquetes.

bash
```bash
ssh usuario@ip_de_tu_vps
sudo apt update && sudo apt upgrade -y
```
### Instalar Paquetes Necesarios: Instala las herramientas que permiten a apt usar repositorios HTTPS.

bash
```bash
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
```
### Agregar el Repositorio Oficial de Docker:

Importar la clave GPG:

bash
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg 
--dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```
### Añadir el repositorio:

bash
```bash
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
### Actualizar de nuevo la lista de paquetes:

bash
```bash
sudo apt update
```
### Instalar Docker Engine: Procede con la instalación.

bash
```bash
sudo apt install docker-ce docker-ce-cli containerd.io -y
```
### Verificar la Instalación:

Comprueba que el servicio esté activo:

bash
```bash
sudo systemctl status docker
```
### Ejecuta el contenedor de prueba hello-world:

bash
```bash
sudo docker run hello-world
```
### Ejecutar Docker sin sudo (Opcional pero Recomendado): Para no tener que prefijar siempre sudo, añade tu usuario al grupo docker.

bash
```bash
sudo usermod -aG docker $USER
```
Cierra la sesión en el VPS y vuelve a conectarte para que el cambio surta efecto.

# 🐳 Crear y Ejecutar tu Primer Contenedor
Ahora crearás un contenedor personalizado usando un Dockerfile.

Crear un Dockerfile: En tu máquina local, crea un directorio y un archivo llamado Dockerfile.

dockerfile
```
## Usa una imagen base oficial de Node.js
FROM node:18
## Establece el directorio de trabajo dentro del contenedor
WORKDIR /app
## Copia los archivos de dependencias primero (aprovecha la cache de Docker)
COPY package*.json ./
## Instala las dependencias
RUN npm install
## Copia el resto del código de la aplicación
COPY . .
## Informa que el contenedor escuchará en el puerto 3000
EXPOSE 3000
## Comando para ejecutar la aplicación
CMD ["node", "server.js"]
```
* Construir la Imagen Docker: En el mismo directorio que tu Dockerfile, ejecuta:

bash
```bash
docker build -t mi-aplicacion .
```
* Ejecutar el Contenedor en tu VPS:

* Sube la carpeta de tu proyecto (con el Dockerfile) a tu VPS usando scp o git clone.

* Navega hasta la carpeta del proyecto en tu VPS y construye la imagen (paso 2) si no lo hiciste localmente.

* Ejecuta el contenedor, mapeando un puerto de tu VPS al puerto interno del contenedor. Esto es clave para el acceso exterior.

bash
```bash
docker run -d -p 8080:3000 --name mi-contenedor mi-aplicacion
```
Este comando vincula el puerto 8080 de tu VPS al puerto 3000 del contenedor y se ejecuta en segundo plano (-d).

# 🌍 Acceder al Contenedor desde el Exterior
Para que tu aplicación sea accesible desde internet, necesitas configurar el acceso.

## Método	Descripción	Comando / Configuración
* Mapeo de Puertos	Expone un puerto del contenedor a un puerto de tu VPS.
```bash
	docker run -p 
```    
    [Puerto_VPS]:[Puerto_Contenedor] ...
* Firewall (UFW)	Permite tráfico en el puerto mapeado.
```bash
	sudo ufw allow 8080/tcp
    ```
* Mapeo de Puertos: Como se mostró en el comando docker run anterior, el flag -p 8080:3000 hace que la aplicación que corre dentro del contenedor en el puerto 3000, sea accesible desde cualquier conexión externa a través del puerto 8080 de la IP de tu VPS. La URL sería: http://ip_de_tu_vps:8080.

Configurar el Firewall: Si tienes el firewall UFW activado en tu VPS, debes abrir el puerto que mapeaste.

bash
```bash
sudo ufw allow 8080/tcp
sudo ufw reload
```
# 💡 Comandos Esenciales para la Gestión
Aquí tienes una referencia rápida de comandos útiles para gestionar tus contenedores:

* docker ps: Lista los contenedores en ejecución.

* docker stop mi-contenedor: Detiene un contenedor.

* docker start mi-contenedor: Inicia un contenedor detenido.

* docker logs mi-contenedor: Muestra los logs del contenedor (útil para depuración).

* docker exec -it mi-contenedor bash: Abre una terminal interactiva dentro del contenedor en ejecución.

# 2. Configuración de TypeORM para Docker
📄 .env.docker (variables para Docker)
env
## Database
```
DB_HOST=mysql
DB_PORT=3306
DB_USERNAME=root
DB_PASSWORD=mysql_password
DB_DATABASE=nestapp
```
## App
NODE_ENV=production
PORT=3000
📄 src/app.module.ts (configuración TypeORM)
typescript
```bash
@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'mysql',
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT) || 3306,
      username: process.env.DB_USERNAME || 'root',
      password: process.env.DB_PASSWORD || '',
      database: process.env.DB_DATABASE || 'nestapp',
      entities: [__dirname + '/**/*.entity{.ts,.js}'],
      synchronize: process.env.NODE_ENV !== 'production', // ¡CUIDADO en producción!
      logging: true,
    }),
    // ... otros módulos
  ],
})
export class AppModule {}
```
# 5. Configuración en el VPS
Subir archivos al VPS:
bash
## Desde tu máquina local
```bash
scp -r mi-app-nest/ usuario@tu_vps_ip:/home/usuario/apps/
```
## En el VPS - Ejecutar la aplicación:
bash
## Navegar al directorio
```bash
cd /home/usuario/apps/mi-app-nest
```
## Construir y ejecutar los contenedores
```bash
docker-compose up -d
```

## Verificar que todo esté funcionando
```bash
docker-compose ps
docker-compose logs -f app
```
# 🔧 6. Configuración de TypeORM para Producción
📄 ormconfig.js (configuración adicional)
javascript
```
module.exports = {
  type: 'mysql',
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT),
  username: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE,
  entities: ['dist/**/*.entity{.ts,.js}'],
  synchronize: false, // IMPORTANTE: false en producción
  logging: true,
  migrations: ['dist/migrations/*.js'],
  cli: {
    migrationsDir: 'src/migrations',
  },
};
```



# 7. Script de Inicialización de Base de Datos
📄 init.sql (opcional - para datos iniciales)
sql
-- Crear usuario específico para la aplicación
```
CREATE USER IF NOT EXISTS 'nestuser'@'%' IDENTIFIED BY 'nestpassword';
GRANT ALL PRIVILEGES ON nestapp.* TO 'nestuser'@'%';
FLUSH PRIVILEGES;
```
# 🌐 8. Acceso desde el Exterior
Configurar puertos en el VPS:
bash
## Abrir puertos en el firewall
```bash
sudo ufw allow 3000/tcp  # API NestJS
sudo ufw allow 3306/tcp  # MySQL (solo si necesitas acceso externo)
sudo ufw allow 8080/tcp  # PHPMyAdmin
sudo ufw reload
```
## URLs de acceso:
API NestJS: http://tu_vps_ip:3000

PHPMyAdmin: http://tu_vps_ip:8080

MySQL directamente: mysql -h tu_vps_ip -P 3306 -u root -p

# 🐛 9. Comandos Útiles para Troubleshooting
bash
## Ver logs de la aplicación
```bash
docker-compose logs -f app
```
## Ver logs de MySQL
```bash
docker-compose logs -f mysql
```
## Conectar a la base de datos desde el VPS
```bash
docker exec -it mi-app-nest-mysql-1 mysql -u root -p
```
## Ejecutar migraciones (si las tienes)
```bash
docker-compose exec app npx typeorm migration:run
```
## Backup de la base de datos
```bash
docker-compose exec mysql mysqldump -u root -p mysql_password nestapp 
> backup.sql
```
# 🔒 10. Consideraciones de Seguridad
Variables de entorno seguras:
bash
## Crear archivo .env en el VPS (NO subirlo a git)
```bash
echo "DB_PASSWORD=tu_password_super_seguro" > .env
echo "JWT_SECRET=tu_jwt_secret" >> .env
docker-compose.prod.yml (para producción):
yaml
```
## Sobrescribe configuraciones para producción
```
version: '3.8'

services:
  app:
    environment:
      - NODE_ENV=production
      - DB_HOST=mysql
      - DB_PORT=3306
    restart: always

  mysql:
    ports:
      - "3306:3306"  # Considera remover esto y usar red interna solo
```
# 🚀 Comandos Finales de Despliegue
bash
## En tu VPS - despliegue completo
```bash
cd /ruta/de/tu/app
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```
## Verificar que todo funcione
```bash
curl http://localhost:3000/health
```

## Cómo se comunican?
```
text
+------------------------------------------------+
|                  DOCKER COMPOSE                |
|                                                |
|  +-------------+        +------------------+   |
|  |  Contenedor |        |  Contenedor      |   |
|  |  NestJS     |------->|  MySQL           |   |
|  |  (app)      | Puerto |  (mysql)         |   |
|  +-------------+  3306  +------------------+   |
+------------------------------------------------+

```
## En tu código NestJS, la conexión sería:

typescript
```
// .env o configuración
DB_HOST=mysql    // ← Nombre del servicio en docker-compose
DB_PORT=3306
```
🚀 Comandos para ejecutar
bash
## Esto levanta AMBOS servicios
```bash
docker-compose up -d
```
## Ver ambos contenedores ejecutándose
```
docker-compose ps
text
Name                    Command              State           Ports         
----------------------------------------------------------------------------
mi-app-app-1    node dist/main               Up      0.0.0.0:3000->3000/tcp
mi-app-mysql-1  docker-entrypoint.sh mysqld  Up      0.0.0.0:3306->3306/tcp
```
# 🛠 Ejemplo de Conexión
Tu app.module.ts se conecta al servicio mysql:

typescript
```
@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'mysql',
      host: 'mysql',  // ← Nombre del servicio en docker-compose
      port: 3306,
      username: 'root',
      password: 'password123',
      database: 'nestapp',
      // ...
    }),
  ],
})

```

# 🔧 2. Configurar MySQL para Conexiones Externas
## 📄 my-custom.cnf (configuración personalizada)
```
[mysqld]
bind-address = 0.0.0.0
skip-name-resolve
max_connections = 1000
```
## docker-compose.yml con configuración personalizada:
```
mysql:
  image: mysql:8.0
  environment:
    MYSQL_ROOT_PASSWORD: mysql_password
    MYSQL_DATABASE: nestapp
  ports:
    - "3306:3306"
  volumes:
    - mysql_data:/var/lib/mysql
    - ./my-custom.cnf:/etc/mysql/conf.d/custom.cnf  # ← Config personalizada
  command: 
    - --bind-address=0.0.0.0
    - --max_connections=1000

   ``` 
# 🌐 3. Conectar desde el Exterior
Desde tu máquina local:
bash
## Con MySQL Client
mysql -h TU_VPS_IP -P 3306 -u root -p

## Con herramienta gráfica (DBeaver, MySQL Workbench, etc.)
* Host: TU_VPS_IP
* Port: 3306
* User: root
* Password: mysql_password
## Desde otra aplicación:
javascript
// Ejemplo en Node.js
```
const connection = mysql.createConnection({
  host: 'TU_VPS_IP',
  port: 3306,
  user: 'root',
  password: 'mysql_password',
  database: 'nestapp'
});
```
# 🛡️ 4. Configuración de Seguridad (IMPORTANTE)
## crear usuario con permisos específicos:
sql
-- Conectarse al contenedor MySQL
```
docker exec -it nombre_contenedor_mysql mysql -u root -p
```
-- Ejecutar estos comandos:
```
CREATE USER 'usuario_externo'@'%' IDENTIFIED BY 'password_seguro';
GRANT SELECT, INSERT, UPDATE, DELETE ON nestapp.* TO 'usuario_externo'@'%';
FLUSH PRIVILEGES;
```
-- O más restrictivo (solo desde IP específica)
```
CREATE USER 'usuario_seguro'@'192.168.1.100' IDENTIFIED BY 'password_seguro';
GRANT SELECT ON nestapp.* TO 'usuario_seguro'@'192.168.1.100';
📄 init.sql (para crear usuarios automáticamente)
```
sql
-- Crear usuario para acceso externo
```
CREATE USER IF NOT EXISTS 'externo'@'%' IDENTIFIED BY 'PasswordExterno123';
GRANT SELECT, INSERT, UPDATE, DELETE ON nestapp.* TO 'externo'@'%';
```
-- Crear usuario solo para aplicación
```

CREATE USER IF NOT EXISTS 'app_user'@'%' IDENTIFIED BY 'PasswordApp123';
GRANT ALL PRIVILEGES ON nestapp.* TO 'app_user'@'%';

FLUSH PRIVILEGES;
```
## docker-compose.yml con init script:
yaml
```
mysql:
  image: mysql:8.0
  environment:
    MYSQL_ROOT_PASSWORD: mysql_password
    MYSQL_DATABASE: nestapp
  ports:
    - "3306:3306"
  volumes:
    - mysql_data:/var/lib/mysql
    - ./init.sql:/docker-entrypoint-initdb.d/init.sql  # ← Script inicial
 ```   
#  🔥 5. Configurar Firewall en el VPS
bash
## Permitir conexiones MySQL desde cualquier IP
```
sudo ufw allow 3306/tcp
```
## O solo desde tu IP específica (MÁS SEGURO)
```
sudo ufw allow from TU_IP_PERSONAL to any port 3306
```

## Recargar firewall
sudo ufw reload

## Verificar reglas
```
sudo ufw status numbered
```
# 🚀 6. Probar la Conexión Externa
Desde tu máquina local:
bash
## Test de conexión básica
```
telnet TU_VPS_IP 3306
```

## Conectar con cliente MySQL
```
mysql -h TU_VPS_IP -P 3306 -u externo -p
```

## Ver bases de datos
```
SHOW DATABASES;
```

## Usar la base de datos
```
USE nestapp;
SHOW TABLES;
```
# ⚠️ 7. Consideraciones de Seguridad CRÍTICAS
NO hacer esto (inseguro):
yaml
## ❌ MUY PELIGROSO
```
mysql:
  environment:
    MYSQL_ROOT_PASSWORD: admin123  # Password débil
  ports:
    - "3306:3306"  # Expuesto sin restricciones

```    
SÍ hacer esto (seguro):
yaml
## ✅ CONFIGURACIÓN SEGURA
```
mysql:
  environment:
    MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}  # Desde variable de entorno
  ports:
    - "3306:3306"
  volumes:
    - ./init.sql:/docker-entrypoint-initdb.d/init.sql  # Crear usuarios seguros
 ```
Variables de entorno seguras (.env):
env
## Archivo .env (NO subir a Git)
```
DB_ROOT_PASSWORD=TuPasswordSuperSeguro123!
DB_APP_PASSWORD=OtroPasswordSeguro456!
```
🛠️ 8. Comandos Útiles para Administración
bash
## Ver logs de MySQL
```
docker-compose logs -f mysql
```
## Conectar al contenedor MySQL
```
docker exec -it mi-app-mysql-1 mysql -u root -p
```
## Backup de la base de datos
```
docker exec mi-app-mysql-1 mysqldump -u root -p nestapp > backup.sql
```
## Restaurar backup
```
docker exec -i mi-app-mysql-1 mysql -u root -p nestapp < backup.sql
```
## Ver conexiones activas
```
docker exec -it mi-app-mysql-1 mysql -u root -p -e "SHOW PROCESSLIST;"
```
# 🔄 9. Alternativa: Usar SSH Tunnel (Más Seguro)
Si no quieres exponer MySQL directamente:

bash
## Crear túnel SSH desde tu local
ssh -L 3307:localhost:3306 usuario@TU_VPS_IP

## Ahora puedes conectar localmente
```
mysql -h 127.0.0.1 -P 3307 -u root -p
```
### URLs de acceso:

MySQL Directo: mysql -h TU_VPS_IP -P 3306 -u root -p

PHPMyAdmin: http://TU_VPS_IP:8080 (si lo incluyes en docker-compose)

Tu API NestJS: http://TU_VPS_IP:3000