# Guía Rápida - Backend Balance Mensual

## 🚀 Inicio Rápido

### 1. Iniciar el servidor
```bash
cd backend-balance-mensual
php artisan serve
```

El servidor estará en: `http://localhost:8000`

### 2. Datos de prueba

Ya existe un usuario creado con datos de ejemplo:
- **Email:** admin@example.com
- **Password:** admin123

### 3. Probar la API

#### Opción A: Con cURL

**1. Login:**
```bash
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}'
```

Guarda el token que recibes en la respuesta.

**2. Obtener ingresos:**
```bash
curl -X GET "http://localhost:8000/api/ingresos" \
  -H "Authorization: Bearer TU_TOKEN_AQUI"
```

**3. Obtener gastos:**
```bash
curl -X GET "http://localhost:8000/api/gastos" \
  -H "Authorization: Bearer TU_TOKEN_AQUI"
```

**4. Obtener deudas:**
```bash
curl -X GET "http://localhost:8000/api/deudas" \
  -H "Authorization: Bearer TU_TOKEN_AQUI"
```

#### Opción B: Con Postman

1. Importa la colección desde el archivo `postman_collection.json` (si lo creas)
2. Configura la variable `base_url` como `http://localhost:8000/api`
3. Haz login y copia el token
4. Usa el token en el header `Authorization: Bearer {token}`

#### Opción C: Desde Flutter

Ver la sección "Integración con Flutter" más abajo.

---

## 📊 Datos de Ejemplo Incluidos

El seeder crea automáticamente:

### Usuario
- Email: admin@example.com
- Password: admin123

### Categorías de Gastos
- Hogar
- Transporte
- Alimentación
- Entretenimiento
- Salud

### Ingresos (Presupuesto)
- Salario mensual: $5,000
- Freelance: $1,500

### Ingresos (Reales)
- Salario mensual: $5,000
- Proyecto freelance: $2,080

### Gastos (Presupuesto)
- Renta: $1,500
- Gasolina: $500

### Gastos (Reales)
- Renta: $1,500
- Supermercado: $800
- Gasolina: $450

### Deudas
- Préstamo personal (por pagar): $5,000
- Pago de cliente (por cobrar): $2,000
- Tarjeta de crédito (vence hoy): $1,200

---

## 🔄 Reiniciar Base de Datos

Si quieres empezar de cero:

```bash
php artisan migrate:fresh --seed
```

Esto eliminará todos los datos y volverá a crear las tablas con los datos de ejemplo.

---

## 🧪 Probar Endpoints

### Filtrar ingresos por mes
```bash
curl -X GET "http://localhost:8000/api/ingresos?year=2026&month=3" \
  -H "Authorization: Bearer TU_TOKEN"
```

### Filtrar solo presupuesto
```bash
curl -X GET "http://localhost:8000/api/ingresos?es_presupuesto=true" \
  -H "Authorization: Bearer TU_TOKEN"
```

### Filtrar solo reales
```bash
curl -X GET "http://localhost:8000/api/gastos?es_presupuesto=false" \
  -H "Authorization: Bearer TU_TOKEN"
```

### Deudas vencidas hoy
```bash
curl -X GET "http://localhost:8000/api/deudas-vencidas-hoy" \
  -H "Authorization: Bearer TU_TOKEN"
```

### Crear un nuevo ingreso
```bash
curl -X POST http://localhost:8000/api/ingresos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TU_TOKEN" \
  -d '{
    "etiqueta": "Bono",
    "tipo": "variable",
    "monto": 1000.00,
    "mes": "2026-03-01",
    "es_presupuesto": false
  }'
```

---

## 📱 Integración con Flutter

### 1. Agregar dependencias en pubspec.yaml

```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

### 2. Crear servicio API (ejemplo básico)

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  String? _token;

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      return data;
    } else {
      throw Exception('Error en login');
    }
  }

  // Obtener ingresos
  Future<List<dynamic>> getIngresos({bool? esPresupuesto}) async {
    String url = '$baseUrl/ingresos';
    if (esPresupuesto != null) {
      url += '?es_presupuesto=$esPresupuesto';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener ingresos');
    }
  }

  // Crear ingreso
  Future<Map<String, dynamic>> createIngreso(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ingresos'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear ingreso');
    }
  }
}
```

### 3. Usar en Flutter

```dart
final apiService = ApiService();

// Login
try {
  final result = await apiService.login('admin@example.com', 'admin123');
  print('Token: ${result['token']}');
} catch (e) {
  print('Error: $e');
}

// Obtener ingresos
try {
  final ingresos = await apiService.getIngresos(esPresupuesto: false);
  print('Ingresos: $ingresos');
} catch (e) {
  print('Error: $e');
}
```

---

## 🐛 Solución de Problemas

### Error: "SQLSTATE[HY000]: General error: 1 no such table"
```bash
php artisan migrate:fresh --seed
```

### Error: "Unauthenticated"
Verifica que estés enviando el token en el header:
```
Authorization: Bearer {tu_token}
```

### Error de CORS desde Flutter
El CORS ya está configurado para aceptar todas las peticiones. Si tienes problemas, verifica que estés usando la URL correcta.

### Ver logs del servidor
```bash
tail -f storage/logs/laravel.log
```

---

## 📚 Recursos Adicionales

- [Documentación completa de la API](./API_DOCUMENTATION.md)
- [README del Backend](./README_BACKEND.md)
- [Documentación de Laravel](https://laravel.com/docs/11.x)
- [Documentación de Sanctum](https://laravel.com/docs/11.x/sanctum)
