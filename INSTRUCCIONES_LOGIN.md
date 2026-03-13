# 🔐 Instrucciones de Login - ACTUALIZADO

## ✅ Problema Resuelto

El usuario no existía en la base de datos. Ya se ha ejecutado el seeder y ahora todo funciona correctamente.

## 🚀 Pasos para Usar la App

### 1. Asegúrate de que el servidor Laravel esté corriendo

```bash
cd backend-balance-mensual
php artisan serve
```

Deberías ver:
```
INFO  Server running on [http://127.0.0.1:8000].
```

### 2. Ejecuta la app Flutter

```bash
flutter run
```

### 3. Usa estas credenciales en el login

- **Email:** `admin@example.com`
- **Password:** `admin123`

⚠️ **IMPORTANTE:** Usa el EMAIL completo, no solo "admin"

---

## ✅ Verificación

El backend ya tiene:
- ✅ Usuario creado: admin@example.com / admin123
- ✅ 4 ingresos de ejemplo
- ✅ 5 gastos de ejemplo
- ✅ 5 categorías
- ✅ 3 deudas

---

## 🔧 Si Aún No Funciona

### Problema: "Usuario o clave incorrectos"

**Solución 1: Verifica que el servidor esté corriendo**
```bash
curl http://localhost:8000/api/login \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}'
```

Si recibes un token, el backend funciona correctamente.

**Solución 2: Reinicia la base de datos**
```bash
cd backend-balance-mensual
php artisan migrate:fresh --seed
```

**Solución 3: Verifica que el usuario exista**
```bash
cd backend-balance-mensual
php artisan tinker --execute="echo App\Models\User::where('email', 'admin@example.com')->first();"
```

Deberías ver los datos del usuario.

### Problema: "Connection refused" o error de red

**Causa:** El servidor no está corriendo o la URL es incorrecta.

**Solución:**
1. Verifica que el servidor Laravel esté corriendo en el puerto 8000
2. Si está en otro puerto, actualiza `lib/services/api_service.dart`:
   ```dart
   static const String baseUrl = 'http://localhost:8000/api';
   ```

### Problema: La app se queda cargando

**Causa:** Timeout o problema de red.

**Solución:**
1. Verifica los logs de Flutter en la consola
2. Verifica los logs del servidor Laravel
3. Asegúrate de que no haya firewall bloqueando el puerto 8000

---

## 📱 Probar en Diferentes Plataformas

### macOS
```bash
flutter run -d macos
```
URL: `http://localhost:8000/api`

### iOS Simulator
```bash
flutter run -d ios
```
URL: `http://localhost:8000/api`

### Android Emulator
```bash
flutter run -d android
```
⚠️ **IMPORTANTE:** En Android, usa `http://10.0.2.2:8000/api` en lugar de `localhost`

Para cambiar la URL en Android, modifica `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

### Web (Chrome)
```bash
flutter run -d chrome
```
URL: `http://localhost:8000/api`

---

## 🎯 Resumen

**Credenciales correctas:**
- Email: `admin@example.com` ✅
- Password: `admin123` ✅

**NO uses:**
- Usuario: `admin` ❌ (debe ser el email completo)

**Servidor debe estar en:**
- `http://localhost:8000` ✅

---

## 📞 Comandos Útiles

```bash
# Ver si el servidor está corriendo
lsof -i :8000

# Detener proceso en puerto 8000
kill -9 $(lsof -ti:8000)

# Reiniciar servidor Laravel
cd backend-balance-mensual
php artisan serve

# Ver logs del servidor en tiempo real
cd backend-balance-mensual
tail -f storage/logs/laravel.log

# Limpiar todo y empezar de nuevo
cd backend-balance-mensual
php artisan migrate:fresh --seed
php artisan serve
```

---

## ✅ Checklist

Antes de reportar un problema, verifica:

- [ ] Servidor Laravel corriendo en puerto 8000
- [ ] Usuario existe en la base de datos
- [ ] Usas el email completo: `admin@example.com`
- [ ] Password correcto: `admin123`
- [ ] App Flutter ejecutándose
- [ ] No hay errores en la consola de Flutter
- [ ] No hay errores en los logs de Laravel

Si todos los puntos están marcados y aún no funciona, revisa los logs detallados.
