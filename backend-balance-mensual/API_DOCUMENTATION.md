# API Balance Mensual - Documentación

## Base URL
```
http://localhost:8000/api
```

## Autenticación

Todas las rutas protegidas requieren un token Bearer en el header:
```
Authorization: Bearer {token}
```

### Registro
**POST** `/register`

Body:
```json
{
  "name": "Juan Pérez",
  "email": "juan@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```

Response:
```json
{
  "user": {
    "id": 1,
    "name": "Juan Pérez",
    "email": "juan@example.com"
  },
  "token": "1|abc123...",
  "token_type": "Bearer"
}
```

### Login
**POST** `/login`

Body:
```json
{
  "email": "juan@example.com",
  "password": "password123"
}
```

Response:
```json
{
  "user": {
    "id": 1,
    "name": "Juan Pérez",
    "email": "juan@example.com"
  },
  "token": "2|xyz789...",
  "token_type": "Bearer"
}
```

### Logout
**POST** `/logout`

Headers: `Authorization: Bearer {token}`

Response:
```json
{
  "message": "Sesión cerrada correctamente"
}
```

### Usuario actual
**GET** `/me`

Headers: `Authorization: Bearer {token}`

Response:
```json
{
  "id": 1,
  "name": "Juan Pérez",
  "email": "juan@example.com"
}
```

---

## Ingresos

### Listar ingresos
**GET** `/ingresos`

Query params opcionales:
- `es_presupuesto`: true/false (filtrar por presupuesto o real)
- `year`: 2026 (filtrar por año)
- `month`: 3 (filtrar por mes)

Response:
```json
[
  {
    "id": 1,
    "user_id": 1,
    "etiqueta": "Salario mensual",
    "tipo": "fija",
    "monto": "5000.00",
    "mes": "2026-03-01",
    "es_presupuesto": false,
    "created_at": "2026-03-08T08:00:00.000000Z",
    "updated_at": "2026-03-08T08:00:00.000000Z"
  }
]
```

### Crear ingreso
**POST** `/ingresos`

Body:
```json
{
  "etiqueta": "Salario mensual",
  "tipo": "fija",
  "monto": 5000.00,
  "mes": "2026-03-01",
  "es_presupuesto": false
}
```

### Obtener ingreso
**GET** `/ingresos/{id}`

### Actualizar ingreso
**PUT** `/ingresos/{id}`

Body (todos los campos son opcionales):
```json
{
  "etiqueta": "Salario actualizado",
  "tipo": "variable",
  "monto": 5500.00,
  "mes": "2026-03-01",
  "es_presupuesto": true
}
```

### Eliminar ingreso
**DELETE** `/ingresos/{id}`

---

## Gastos

### Listar gastos
**GET** `/gastos`

Query params opcionales:
- `es_presupuesto`: true/false
- `categoria`: "Hogar"
- `year`: 2026
- `month`: 3

Response:
```json
[
  {
    "id": 1,
    "user_id": 1,
    "categoria": "Hogar",
    "sub_categoria": "Luz",
    "monto": "150.00",
    "es_fijo": true,
    "pago_con_tarjeta": false,
    "gasto_hormiga": false,
    "periodicidad": "mensual",
    "mes": "2026-03-01",
    "es_presupuesto": false,
    "created_at": "2026-03-08T08:00:00.000000Z",
    "updated_at": "2026-03-08T08:00:00.000000Z"
  }
]
```

### Crear gasto
**POST** `/gastos`

Body:
```json
{
  "categoria": "Hogar",
  "sub_categoria": "Luz",
  "monto": 150.00,
  "es_fijo": true,
  "pago_con_tarjeta": false,
  "gasto_hormiga": false,
  "periodicidad": "mensual",
  "mes": "2026-03-01",
  "es_presupuesto": false
}
```

### Obtener gasto
**GET** `/gastos/{id}`

### Actualizar gasto
**PUT** `/gastos/{id}`

### Eliminar gasto
**DELETE** `/gastos/{id}`

---

## Categorías de Gastos

### Listar categorías
**GET** `/categorias-gasto`

Response:
```json
[
  {
    "id": 1,
    "user_id": 1,
    "nombre": "Hogar",
    "created_at": "2026-03-08T08:00:00.000000Z",
    "updated_at": "2026-03-08T08:00:00.000000Z"
  }
]
```

### Crear categoría
**POST** `/categorias-gasto`

Body:
```json
{
  "nombre": "Transporte"
}
```

### Obtener categoría
**GET** `/categorias-gasto/{id}`

### Actualizar categoría
**PUT** `/categorias-gasto/{id}`

### Eliminar categoría
**DELETE** `/categorias-gasto/{id}`

---

## Deudas

### Listar deudas
**GET** `/deudas`

Query params opcionales:
- `tipo`: "por_pagar" o "por_cobrar"

Response:
```json
[
  {
    "id": 1,
    "user_id": 1,
    "concepto": "Préstamo personal",
    "monto": "1000.00",
    "fecha": "2026-03-15",
    "tipo": "por_pagar",
    "created_at": "2026-03-08T08:00:00.000000Z",
    "updated_at": "2026-03-08T08:00:00.000000Z"
  }
]
```

### Deudas vencidas hoy
**GET** `/deudas-vencidas-hoy`

Response: Array de deudas que vencen hoy

### Crear deuda
**POST** `/deudas`

Body:
```json
{
  "concepto": "Préstamo personal",
  "monto": 1000.00,
  "fecha": "2026-03-15",
  "tipo": "por_pagar"
}
```

### Obtener deuda
**GET** `/deudas/{id}`

### Actualizar deuda
**PUT** `/deudas/{id}`

### Eliminar deuda
**DELETE** `/deudas/{id}`

---

## Códigos de Estado HTTP

- `200 OK`: Solicitud exitosa
- `201 Created`: Recurso creado exitosamente
- `400 Bad Request`: Error en los datos enviados
- `401 Unauthorized`: No autenticado
- `403 Forbidden`: No autorizado para acceder al recurso
- `404 Not Found`: Recurso no encontrado
- `422 Unprocessable Entity`: Error de validación
- `500 Internal Server Error`: Error del servidor

---

## Tipos de Datos

### Ingreso
- `tipo`: "fija", "variable", "sin_especificar"
- `es_presupuesto`: boolean

### Gasto
- `periodicidad`: "mensual", "quincenal", "semanal", "diario"
- `es_presupuesto`: boolean
- `es_fijo`: boolean
- `pago_con_tarjeta`: boolean
- `gasto_hormiga`: boolean

### Deuda
- `tipo`: "por_pagar", "por_cobrar"

---

## Iniciar el servidor

```bash
cd backend-balance-mensual
php artisan serve
```

El servidor estará disponible en `http://localhost:8000`
