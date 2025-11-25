# Despliegue en Dokploy - GrinTic

## Variables de Entorno Requeridas

Al crear la aplicación en Dokploy, configura las siguientes variables de entorno:

```bash
# Database (PostgreSQL será creado automáticamente por Dokploy)
DATABASE_URL=postgresql://usuario:password@postgres:5432/grintic_prod
POSTGRES_USER=grintic_user
POSTGRES_PASSWORD=CAMBIAR_PASSWORD_SEGURO
POSTGRES_DB=grintic_prod

# Secret Key (generar con: mix phx.gen.secret)
SECRET_KEY_BASE=GENERAR_CON_MIX_PHX_GEN_SECRET_64_CARACTERES_MINIMO

# Host y Puerto
PHX_HOST=grintic.com
PORT=4000
PHX_SERVER=true

# Ambiente
MIX_ENV=prod
```

## Pasos en Dokploy

### 1. Crear Nueva Aplicación
- **Tipo**: Docker Compose
- **Repositorio**: `https://github.com/diegmero/grintic-social`
- **Rama**: `main`
- **Ruta del proyecto**: `grintic`
- **Archivo Compose**: `docker-compose.yml`

### 2. Configurar Dominio
- **Dominio**: `grintic.com`
- **Habilitar HTTPS**: ✅ (Let's Encrypt automático)
- **Redirect HTTP → HTTPS**: ✅

### 3. Variables de Entorno
Copiar y pegar las variables de arriba, reemplazando:
- `CAMBIAR_PASSWORD_SEGURO` con password seguro
- `GENERAR_CON_MIX_PHX_GEN_SECRET_...` ejecutando localmente:
  ```bash
  mix phx.gen.secret
  ```

### 4. Desplegar
1. Click en "Deploy"
2. Esperar a que construya la imagen (2-3 minutos)
3. Una vez corriendo, ejecutar migraciones:
   - Ir a "Terminal" en Dokploy
   - Ejecutar:
     ```bash
     docker compose exec web /app/bin/grintic eval "Grintic.Release.migrate()"
     ```

### 5. Verificar
- Abrir `https://grintic.com`
- Debería cargar la página de inicio con SSL válido

## Troubleshooting

### Error de Base de Datos
```bash
# Ver logs
docker compose logs web

# Verificar que PostgreSQL esté corriendo
docker compose ps
```

### Regenerar Secret Key
```bash
# Localmente
cd grintic
mix phx.gen.secret
```

### Certificado SSL No Genera
- Verificar que el dominio apunte correctamente a la IP del servidor
- Esperar hasta 5 minutos para que Let's Encrypt valide
- Revisar logs de Traefik en Dokploy
