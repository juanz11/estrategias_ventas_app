# 🔌 Cómo Probar la Conexión Flutter + Laravel

## ✅ Estado Actual

La aplicación Flutter ya está conectada al backend Laravel. Aquí está lo que se ha configurado:

### 1. Backend Laravel
- ✅ Servidor API REST funcionando
- ✅ Base de datos con datos de prueba
- ✅ Autenticación con Sanctum
- ✅ Endpoints CRUD completos

### 2. Flutter App
- ✅ Dependencias HTTP instaladas (`http`, `shared_preferences`)
- ✅ Servicio API creado (`lib/services/api_service.dart`)
- ✅ Login conectado a la API real
- ✅ Token de autenticación guardado automáticamente

---

## 🚀 Pasos para Probar

### 1. Iniciar el Servidor Laravel

```bash
cd backend-balance-mensual
php artisan serve
```

Deberías ver:
```
INFO  Server running on [http://127.0.0.1:8000].
```

**⚠️ IMPORTANTE:** Deja esta terminal abierta mientras pruebas la app.

### 2. Ejecutar la App Flutter

En otra terminal:

```bash
flutter run
```

O si usas un dispositivo específico:
```bash
flutter run -d chrome        # Para web
flutter run -d macos         # Para macOS
flutter run -d <device-id>   # Para tu dispositivo
```

### 3. Probar el Login

En la pantalla de login, usa estas credenciales:

- **Email:** `admin@example.com`
- **Password:** `admin123`

Si todo funciona correctamente:
- ✅ El login se conectará al backend
- ✅ Recibirás un token de autenticación
- ✅ Serás redirigido a la pantalla principal

---

## 🔍 Verificar la Conexión

### Opción A: Ver logs del servidor Laravel

En la terminal donde corre el servidor Laravel, deberías ver las peticiones:

```
[2026-03-08 08:30:15] local.INFO: POST /api/login
[2026-03-08 08:30:15] local.INFO: Response: 200
```

### Opción B: Probar manualmente con cURL

```bash
# Login
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}'

# Deberías recibir un token
```

---

## ⚠️ Solución de Problemas

### Error: "Connection refused" o "Failed to connect"

**Causa:** El servidor Laravel no está corriendo o la URL es incorrecta.

**Solución:**
1. Verifica que el servidor Laravel esté corriendo: `cd backend-balance-mensual && php artisan serve`
2. Verifica que la URL en `lib/services/api_service.dart` sea correcta:
   ```dart
   static const String baseUrl = 'http://localhost:8000/api';
   ```

### Error: "Usuario o clave incorrectos" (pero las credenciales son correctas)

**Causa:** El servidor no está respondiendo o hay un error en la API.

**Solución:**
1. Verifica los logs del servidor Laravel
2. Prueba el login con cURL para confirmar que la API funciona
3. Verifica que la base de datos tenga el usuario de prueba:
   ```bash
   cd backend-balance-mensual
   php artisan tinker
   >>> User::where('email', 'admin@example.com')->first()
   ```

### Error: "CORS" o "Access-Control-Allow-Origin"

**Causa:** Problema de CORS (solo en web).

**Solución:**
El CORS ya está configurado en `backend-balance-mensual/config/cors.php`. Si aún tienes problemas:
1. Limpia la caché de Laravel:
   ```bash
   cd backend-balance-mensual
   php artisan config:clear
   php artisan cache:clear
   ```
2. Reinicia el servidor

### La app se queda cargando indefinidamente

**Causa:** Timeout o error de red.

**Solución:**
1. Verifica tu conexión de red
2. Asegúrate de que no haya firewall bloqueando el puerto 8000
3. Revisa los logs de Flutter en la consola

---

## 📊 Datos de Prueba Disponibles

El backend ya tiene datos de ejemplo:

### Usuario
- Email: `admin@example.com`
- Password: `admin123`

### Ingresos (4 registros)
- 2 de presupuesto
- 2 reales (operaciones)

### Gastos (5 registros)
- 2 de presupuesto
- 3 reales (operaciones)

### Categorías (5)
- Hogar, Transporte, Alimentación, Entretenimiento, Salud

### Deudas (3)
- 2 por pagar
- 1 por cobrar

---

## 🎯 Próximos Pasos

Actualmente, solo el LOGIN está conectado a la API. Los datos de ingresos, gastos y deudas aún son estáticos.

Para conectar el resto de la app:

1. **Cargar datos reales al iniciar:**
   - Modificar `DashboardScreen` para cargar datos desde la API
   - Usar `_apiService.getIngresos()`, `_apiService.getGastos()`, etc.

2. **Guardar datos en la API:**
   - Modificar los métodos `_addIngresoReal()`, `_addGastoReal()`, etc.
   - Llamar a `_apiService.createIngreso()`, `_apiService.createGasto()`, etc.

3. **Actualizar y eliminar:**
   - Conectar los botones de editar y eliminar con la API

¿Quieres que continúe conectando el resto de la aplicación?

---

## 📱 Comandos Útiles

```bash
# Ver logs de Laravel en tiempo real
cd backend-balance-mensual
tail -f storage/logs/laravel.log

# Reiniciar base de datos con datos frescos
cd backend-balance-mensual
php artisan migrate:fresh --seed

# Ver todas las rutas de la API
cd backend-balance-mensual
php artisan route:list

# Limpiar caché de Flutter
flutter clean
flutter pub get

# Ver dispositivos disponibles
flutter devices
```

---

## ✅ Checklist de Verificación

- [ ] Servidor Laravel corriendo en http://localhost:8000
- [ ] App Flutter ejecutándose
- [ ] Login exitoso con admin@example.com / admin123
- [ ] Token guardado (verificar con SharedPreferences)
- [ ] Redirección a pantalla principal después del login

Si todos los puntos están marcados, ¡la conexión está funcionando! 🎉
