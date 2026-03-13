# 🚀 Integración Flutter + Laravel - Balance Mensual

## ✅ Backend Laravel Completado

Se ha creado un backend completo en Laravel 11 con las siguientes características:

### 📦 Estructura del Proyecto

```
backend-balance-mensual/
├── app/
│   ├── Http/Controllers/
│   │   ├── AuthController.php          # Autenticación (login, register, logout)
│   │   ├── IngresoController.php       # CRUD de ingresos
│   │   ├── GastoController.php         # CRUD de gastos
│   │   ├── CategoriaGastoController.php # CRUD de categorías
│   │   └── DeudaController.php         # CRUD de deudas
│   └── Models/
│       ├── User.php                    # Usuario con Sanctum
│       ├── Ingreso.php                 # Modelo de ingresos
│       ├── Gasto.php                   # Modelo de gastos
│       ├── CategoriaGasto.php          # Modelo de categorías
│       └── Deuda.php                   # Modelo de deudas
├── database/
│   ├── migrations/                     # Migraciones de tablas
│   └── seeders/
│       └── DatabaseSeeder.php          # Datos de prueba
├── routes/
│   └── api.php                         # Rutas de la API
├── API_DOCUMENTATION.md                # Documentación completa de la API
├── README_BACKEND.md                   # README del backend
└── QUICK_START.md                      # Guía rápida de inicio
```

### 🗄️ Base de Datos

**Tablas creadas:**
- `users` - Usuarios del sistema
- `ingresos` - Ingresos (presupuesto y reales)
- `gastos` - Gastos (presupuesto y reales)
- `categorias_gasto` - Categorías de gastos
- `deudas` - Deudas por pagar y por cobrar
- `personal_access_tokens` - Tokens de autenticación Sanctum

### 🔐 Autenticación

- Sistema de autenticación con Laravel Sanctum
- Tokens API para peticiones desde Flutter
- Rutas protegidas por middleware `auth:sanctum`
- Usuario de prueba: `admin@example.com` / `admin123`

### 🌐 Endpoints API

**Autenticación:**
- `POST /api/register` - Registrar usuario
- `POST /api/login` - Iniciar sesión
- `POST /api/logout` - Cerrar sesión
- `GET /api/me` - Usuario actual

**Ingresos:**
- `GET /api/ingresos` - Listar (con filtros: es_presupuesto, year, month)
- `POST /api/ingresos` - Crear
- `GET /api/ingresos/{id}` - Obtener
- `PUT /api/ingresos/{id}` - Actualizar
- `DELETE /api/ingresos/{id}` - Eliminar

**Gastos:**
- `GET /api/gastos` - Listar (con filtros: es_presupuesto, categoria, year, month)
- `POST /api/gastos` - Crear
- `GET /api/gastos/{id}` - Obtener
- `PUT /api/gastos/{id}` - Actualizar
- `DELETE /api/gastos/{id}` - Eliminar

**Categorías:**
- `GET /api/categorias-gasto` - Listar
- `POST /api/categorias-gasto` - Crear
- `GET /api/categorias-gasto/{id}` - Obtener
- `PUT /api/categorias-gasto/{id}` - Actualizar
- `DELETE /api/categorias-gasto/{id}` - Eliminar

**Deudas:**
- `GET /api/deudas` - Listar (con filtro: tipo)
- `GET /api/deudas-vencidas-hoy` - Deudas que vencen hoy
- `POST /api/deudas` - Crear
- `GET /api/deudas/{id}` - Obtener
- `PUT /api/deudas/{id}` - Actualizar
- `DELETE /api/deudas/{id}` - Eliminar

---

## 📱 Próximos Pasos: Integrar con Flutter

### 1. Agregar Dependencias HTTP

En `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  
  cupertino_icons: ^1.0.8
  fl_chart: ^0.66.2
  
  # Nuevas dependencias para API
  http: ^1.1.0                    # Cliente HTTP
  shared_preferences: ^2.2.2      # Almacenar token
  provider: ^6.1.1                # Gestión de estado (opcional)
```

### 2. Crear Servicio API

Crear archivo `lib/services/api_service.dart`:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  String? _token;

  // Inicializar y cargar token guardado
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Guardar token
  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Eliminar token
  Future<void> _removeToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Headers con autenticación
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // LOGIN
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token']);
      return data;
    } else {
      throw Exception('Error en login: ${response.body}');
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: _headers,
    );
    await _removeToken();
  }

  // OBTENER INGRESOS
  Future<List<dynamic>> getIngresos({
    bool? esPresupuesto,
    int? year,
    int? month,
  }) async {
    String url = '$baseUrl/ingresos';
    List<String> params = [];
    
    if (esPresupuesto != null) params.add('es_presupuesto=$esPresupuesto');
    if (year != null) params.add('year=$year');
    if (month != null) params.add('month=$month');
    
    if (params.isNotEmpty) url += '?${params.join('&')}';

    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener ingresos');
    }
  }

  // CREAR INGRESO
  Future<Map<String, dynamic>> createIngreso({
    required String etiqueta,
    required String tipo,
    required double monto,
    required DateTime mes,
    required bool esPresupuesto,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ingresos'),
      headers: _headers,
      body: jsonEncode({
        'etiqueta': etiqueta,
        'tipo': tipo,
        'monto': monto,
        'mes': mes.toIso8601String().split('T')[0],
        'es_presupuesto': esPresupuesto,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear ingreso: ${response.body}');
    }
  }

  // ACTUALIZAR INGRESO
  Future<Map<String, dynamic>> updateIngreso(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/ingresos/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar ingreso');
    }
  }

  // ELIMINAR INGRESO
  Future<void> deleteIngreso(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/ingresos/$id'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar ingreso');
    }
  }

  // OBTENER GASTOS
  Future<List<dynamic>> getGastos({
    bool? esPresupuesto,
    String? categoria,
    int? year,
    int? month,
  }) async {
    String url = '$baseUrl/gastos';
    List<String> params = [];
    
    if (esPresupuesto != null) params.add('es_presupuesto=$esPresupuesto');
    if (categoria != null) params.add('categoria=$categoria');
    if (year != null) params.add('year=$year');
    if (month != null) params.add('month=$month');
    
    if (params.isNotEmpty) url += '?${params.join('&')}';

    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener gastos');
    }
  }

  // CREAR GASTO
  Future<Map<String, dynamic>> createGasto({
    required String categoria,
    required String subCategoria,
    required double monto,
    required bool esFijo,
    required bool pagoConTarjeta,
    required bool gastoHormiga,
    required String periodicidad,
    required DateTime mes,
    required bool esPresupuesto,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/gastos'),
      headers: _headers,
      body: jsonEncode({
        'categoria': categoria,
        'sub_categoria': subCategoria,
        'monto': monto,
        'es_fijo': esFijo,
        'pago_con_tarjeta': pagoConTarjeta,
        'gasto_hormiga': gastoHormiga,
        'periodicidad': periodicidad,
        'mes': mes.toIso8601String().split('T')[0],
        'es_presupuesto': esPresupuesto,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear gasto: ${response.body}');
    }
  }

  // ELIMINAR GASTO
  Future<void> deleteGasto(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/gastos/$id'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar gasto');
    }
  }

  // OBTENER DEUDAS
  Future<List<dynamic>> getDeudas({String? tipo}) async {
    String url = '$baseUrl/deudas';
    if (tipo != null) url += '?tipo=$tipo';

    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener deudas');
    }
  }

  // DEUDAS VENCIDAS HOY
  Future<List<dynamic>> getDeudasVencidasHoy() async {
    final response = await http.get(
      Uri.parse('$baseUrl/deudas-vencidas-hoy'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener deudas vencidas');
    }
  }

  // CREAR DEUDA
  Future<Map<String, dynamic>> createDeuda({
    required String concepto,
    required double monto,
    required DateTime fecha,
    required String tipo,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/deudas'),
      headers: _headers,
      body: jsonEncode({
        'concepto': concepto,
        'monto': monto,
        'fecha': fecha.toIso8601String().split('T')[0],
        'tipo': tipo,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear deuda: ${response.body}');
    }
  }

  // ELIMINAR DEUDA
  Future<void> deleteDeuda(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/deudas/$id'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar deuda');
    }
  }
}
```

### 3. Modificar el Login en Flutter

Actualizar `lib/main.dart` para usar la API real:

```dart
// En _LoginScreenState
final _apiService = ApiService();

@override
void initState() {
  super.initState();
  _apiService.init();
}

void _login() async {
  final user = _userController.text.trim();
  final pass = _passController.text.trim();

  try {
    final result = await _apiService.login(user, pass);
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  } catch (e) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}
```

### 4. Cargar Datos Reales

En `HomeScreen`, reemplazar los datos estáticos con llamadas a la API:

```dart
class _HomeScreenState extends State<HomeScreen> {
  final _apiService = ApiService();
  
  List<_IngresoMensual> _ingresosReales = [];
  List<_GastoMensual> _gastosReales = [];
  List<_Deuda> _deudas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Cargar ingresos reales
      final ingresosData = await _apiService.getIngresos(esPresupuesto: false);
      _ingresosReales = ingresosData.map((json) => _IngresoMensual.fromJson(json)).toList();
      
      // Cargar gastos reales
      final gastosData = await _apiService.getGastos(esPresupuesto: false);
      _gastosReales = gastosData.map((json) => _GastoMensual.fromJson(json)).toList();
      
      // Cargar deudas
      final deudasData = await _apiService.getDeudas();
      _deudas = deudasData.map((json) => _Deuda.fromJson(json)).toList();
      
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error cargando datos: $e');
      setState(() => _isLoading = false);
    }
  }
}
```

### 5. Agregar Métodos fromJson a los Modelos

```dart
class _IngresoMensual {
  // ... campos existentes ...
  int? id; // Agregar ID de la base de datos

  factory _IngresoMensual.fromJson(Map<String, dynamic> json) {
    return _IngresoMensual(
      id: json['id'],
      etiqueta: json['etiqueta'],
      tipo: _IngresoTipo.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => _IngresoTipo.sinEspecificar,
      ),
      monto: double.parse(json['monto'].toString()),
      mes: DateTime.parse(json['mes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'etiqueta': etiqueta,
      'tipo': tipo.name,
      'monto': monto,
      'mes': mes.toIso8601String().split('T')[0],
    };
  }
}
```

---

## 🎯 Resumen

### ✅ Completado

1. **Backend Laravel completo** con:
   - Autenticación con Sanctum
   - CRUD de ingresos, gastos, categorías y deudas
   - Filtros y búsquedas
   - Validaciones
   - Datos de prueba

2. **Documentación completa**:
   - API_DOCUMENTATION.md
   - README_BACKEND.md
   - QUICK_START.md

3. **Base de datos** con datos de ejemplo

4. **Servidor funcionando** en `http://localhost:8000`

### 📋 Pendiente (Integración Flutter)

1. Agregar dependencias HTTP en Flutter
2. Crear servicio API en Flutter
3. Modificar login para usar API real
4. Cargar datos desde API en lugar de datos estáticos
5. Implementar creación/edición/eliminación con API
6. Manejar errores y estados de carga

---

## 🚀 Comandos Útiles

### Backend
```bash
# Iniciar servidor
cd backend-balance-mensual
php artisan serve

# Reiniciar base de datos
php artisan migrate:fresh --seed

# Ver rutas
php artisan route:list
```

### Flutter
```bash
# Instalar dependencias
flutter pub get

# Ejecutar app
flutter run
```

---

## 📞 Soporte

- Documentación Laravel: https://laravel.com/docs/11.x
- Documentación Sanctum: https://laravel.com/docs/11.x/sanctum
- Paquete HTTP Flutter: https://pub.dev/packages/http
