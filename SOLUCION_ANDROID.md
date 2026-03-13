# 🤖 Solución para Android - Connection Refused

## ✅ Problema Identificado

Estás ejecutando la app en **Android Emulator**, y en Android no puedes usar `127.0.0.1` o `localhost` para conectarte a tu computadora.

## 🔧 Solución Aplicada

Ya actualicé el código para que use automáticamente:
- **Android:** `http://10.0.2.2:8000/api`
- **iOS/macOS/Web:** `http://127.0.0.1:8000/api`

`10.0.2.2` es la IP especial del emulador de Android que apunta a tu computadora (localhost).

---

## 🚀 Ahora Sí Debe Funcionar

### 1. Asegúrate de que el servidor Laravel esté corriendo

```bash
cd backend-balance-mensual
php artisan serve
```

Debe mostrar:
```
INFO  Server running on [http://127.0.0.1:8000].
```

### 2. Reinicia la app Flutter

Como cambié el código, necesitas reiniciar la app:

```bash
# Detén la app (Ctrl+C en la terminal donde corre)
# Luego ejecuta de nuevo:
flutter run
```

O si ya está corriendo, usa hot restart:
- Presiona `R` (mayúscula) en la terminal de Flutter
- O presiona el botón de restart en tu IDE

### 3. Intenta el login de nuevo

- Email: `admin@example.com`
- Password: `admin123`

---

## 🔍 Verificar la Conexión

Ahora deberías ver en los logs:

```
🟢 Iniciando login...
🔵 Intentando login con: admin@example.com
🔵 URL: http://10.0.2.2:8000/api/login  ← Nota la IP diferente
🔵 Status code: 200
✅ Login exitoso! Token guardado
```

---

## 📱 Explicación Técnica

### ¿Por qué 10.0.2.2?

En el emulador de Android:
- `127.0.0.1` o `localhost` apunta al PROPIO emulador (no a tu computadora)
- `10.0.2.2` es una IP especial que apunta a tu computadora host

### Tabla de IPs según plataforma:

| Plataforma | IP para conectar al host |
|------------|-------------------------|
| Android Emulator | `10.0.2.2` |
| iOS Simulator | `127.0.0.1` o `localhost` |
| macOS App | `127.0.0.1` o `localhost` |
| Web (Chrome) | `127.0.0.1` o `localhost` |
| Dispositivo físico | IP de tu computadora en la red (ej: `192.168.1.100`) |

---

## 🔥 Si Usas un Dispositivo Android Físico

Si estás usando un teléfono Android real (no emulador), necesitas:

1. **Conectar el teléfono y la computadora a la misma red WiFi**

2. **Obtener la IP de tu computadora:**
   ```bash
   # En macOS/Linux
   ifconfig | grep "inet " | grep -v 127.0.0.1
   
   # O más simple en macOS
   ipconfig getifaddr en0
   ```

3. **Actualizar la URL en `lib/services/api_service.dart`:**
   ```dart
   static String get baseUrl {
     if (Platform.isAndroid) {
       return 'http://TU_IP_AQUI:8000/api'; // Ej: http://192.168.1.100:8000/api
     } else {
       return 'http://127.0.0.1:8000/api';
     }
   }
   ```

4. **Iniciar el servidor Laravel en todas las interfaces:**
   ```bash
   cd backend-balance-mensual
   php artisan serve --host=0.0.0.0 --port=8000
   ```

---

## ✅ Checklist

- [ ] Servidor Laravel corriendo en puerto 8000
- [ ] App Flutter reiniciada (hot restart o `flutter run`)
- [ ] Usando Android Emulator (no dispositivo físico)
- [ ] Credenciales correctas: `admin@example.com` / `admin123`

Si todos los puntos están marcados, el login DEBE funcionar ahora.

---

## 🆘 Si Aún No Funciona

### Error: "Connection refused" todavía

**Verifica que el servidor esté corriendo:**
```bash
# En otra terminal
curl http://127.0.0.1:8000/api/login \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}'
```

Si esto funciona pero la app no, entonces:

1. Asegúrate de haber reiniciado la app Flutter
2. Verifica que estés usando el emulador de Android (no dispositivo físico)
3. Verifica los logs de Flutter para ver qué URL está usando

### Error: "Timeout" o se queda cargando

**Causa:** El firewall puede estar bloqueando la conexión.

**Solución en macOS:**
```bash
# Permitir conexiones entrantes en el puerto 8000
sudo pfctl -d  # Deshabilitar firewall temporalmente para probar
```

---

## 📝 Resumen

**El problema era:** Android Emulator no puede usar `127.0.0.1`

**La solución:** Usar `10.0.2.2` en Android

**Ya está aplicado:** El código ahora detecta automáticamente la plataforma

**Siguiente paso:** Reinicia la app Flutter y prueba el login

---

## 🎉 Después del Login

Una vez que el login funcione, verás que la app aún muestra datos estáticos (no los del backend). Esto es normal, solo el login está conectado por ahora.

Para conectar el resto de la app (ingresos, gastos, deudas), avísame y continúo con la integración.
