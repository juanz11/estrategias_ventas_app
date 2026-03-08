# Backend Balance Mensual - Laravel API

Backend API REST para la aplicación de Balance Mensual desarrollado con Laravel 11 y Laravel Sanctum para autenticación.

## Características

- ✅ Autenticación con Laravel Sanctum (tokens API)
- ✅ CRUD completo para Ingresos (presupuesto y reales)
- ✅ CRUD completo para Gastos (presupuesto y reales)
- ✅ CRUD completo para Categorías de Gastos
- ✅ CRUD completo para Deudas (por pagar y por cobrar)
- ✅ Filtros por mes, año, tipo, categoría
- ✅ Endpoint para deudas vencidas hoy
- ✅ Validaciones de datos
- ✅ Autorización por usuario
- ✅ CORS configurado para Flutter

## Requisitos

- PHP >= 8.2
- Composer
- SQLite (incluido por defecto)

## Instalación

1. **Instalar dependencias:**
```bash
cd backend-balance-mensual
composer install
```

2. **Configurar el archivo .env:**
El archivo `.env` ya está configurado con SQLite. Si deseas usar MySQL u otra base de datos, modifica las variables:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=balance_mensual
DB_USERNAME=root
DB_PASSWORD=
```

3. **Las migraciones ya están ejecutadas**, pero si necesitas volver a ejecutarlas:
```bash
php artisan migrate:fresh
```

4. **Iniciar el servidor:**
```bash
php artisan serve
```

El servidor estará disponible en `http://localhost:8000`

## Estructura de la Base de Datos

### Tabla: users
- id
- name
- email
- password
- timestamps

### Tabla: ingresos
- id
- user_id (FK)
- etiqueta
- tipo (fija, variable, sin_especificar)
- monto
- mes (date)
- es_presupuesto (boolean)
- timestamps

### Tabla: gastos
- id
- user_id (FK)
- categoria
- sub_categoria
- monto
- es_fijo (boolean)
- pago_con_tarjeta (boolean)
- gasto_hormiga (boolean)
- periodicidad (mensual, quincenal, semanal, diario)
- mes (date)
- es_presupuesto (boolean)
- timestamps

### Tabla: categorias_gasto
- id
- user_id (FK)
- nombre
- timestamps

### Tabla: deudas
- id
- user_id (FK)
- concepto
- monto
- fecha (date)
- tipo (por_pagar, por_cobrar)
- timestamps

## Endpoints API

Ver documentación completa en [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)

### Resumen de endpoints:

**Autenticación:**
- POST `/api/register` - Registrar usuario
- POST `/api/login` - Iniciar sesión
- POST `/api/logout` - Cerrar sesión
- GET `/api/me` - Obtener usuario actual

**Ingresos:**
- GET `/api/ingresos` - Listar ingresos
- POST `/api/ingresos` - Crear ingreso
- GET `/api/ingresos/{id}` - Obtener ingreso
- PUT `/api/ingresos/{id}` - Actualizar ingreso
- DELETE `/api/ingresos/{id}` - Eliminar ingreso

**Gastos:**
- GET `/api/gastos` - Listar gastos
- POST `/api/gastos` - Crear gasto
- GET `/api/gastos/{id}` - Obtener gasto
- PUT `/api/gastos/{id}` - Actualizar gasto
- DELETE `/api/gastos/{id}` - Eliminar gasto

**Categorías:**
- GET `/api/categorias-gasto` - Listar categorías
- POST `/api/categorias-gasto` - Crear categoría
- GET `/api/categorias-gasto/{id}` - Obtener categoría
- PUT `/api/categorias-gasto/{id}` - Actualizar categoría
- DELETE `/api/categorias-gasto/{id}` - Eliminar categoría

**Deudas:**
- GET `/api/deudas` - Listar deudas
- GET `/api/deudas-vencidas-hoy` - Deudas vencidas hoy
- POST `/api/deudas` - Crear deuda
- GET `/api/deudas/{id}` - Obtener deuda
- PUT `/api/deudas/{id}` - Actualizar deuda
- DELETE `/api/deudas/{id}` - Eliminar deuda

## Ejemplo de uso con cURL

### Registrar usuario:
```bash
curl -X POST http://localhost:8000/api/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Juan Pérez",
    "email": "juan@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }'
```

### Login:
```bash
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "juan@example.com",
    "password": "password123"
  }'
```

### Crear ingreso (requiere token):
```bash
curl -X POST http://localhost:8000/api/ingresos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {tu_token}" \
  -d '{
    "etiqueta": "Salario mensual",
    "tipo": "fija",
    "monto": 5000.00,
    "mes": "2026-03-01",
    "es_presupuesto": false
  }'
```

## Seguridad

- Todas las rutas (excepto register y login) están protegidas con autenticación Sanctum
- Los usuarios solo pueden acceder a sus propios datos
- Las contraseñas se hashean con bcrypt
- Validación de datos en todos los endpoints

## Testing

Para ejecutar las pruebas (cuando las crees):
```bash
php artisan test
```

## Comandos útiles

```bash
# Limpiar caché
php artisan cache:clear
php artisan config:clear
php artisan route:clear

# Ver rutas
php artisan route:list

# Crear un nuevo usuario desde consola
php artisan tinker
>>> User::create(['name' => 'Admin', 'email' => 'admin@example.com', 'password' => Hash::make('admin123')])
```

## Próximos pasos para integrar con Flutter

1. Agregar el paquete `http` o `dio` en Flutter
2. Crear servicios API en Flutter para cada endpoint
3. Implementar almacenamiento del token (SharedPreferences o secure_storage)
4. Crear interceptores para agregar el token en cada petición
5. Manejar errores y respuestas de la API

## Soporte

Para más información, consulta la documentación de:
- [Laravel 11](https://laravel.com/docs/11.x)
- [Laravel Sanctum](https://laravel.com/docs/11.x/sanctum)
