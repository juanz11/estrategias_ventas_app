# ⚠️ IMPORTANTE - LEE ESTO PRIMERO

## 🎯 El Problema

El login no funciona porque **el servidor Laravel debe estar corriendo**.

---

## ✅ LA SOLUCIÓN (3 Pasos Simples)

### 📍 Paso 1: Abre una Terminal y Ejecuta

```bash
cd backend-balance-mensual
php artisan serve
```

**Verás esto:**
```
INFO  Server running on [http://127.0.0.1:8000].
Press Ctrl+C to stop the server
```

⚠️ **DEJA ESTA TERMINAL ABIERTA** - No la cierres mientras uses la app.

---

### 📍 Paso 2: Abre OTRA Terminal y Ejecuta

```bash
flutter run
```

---

### 📍 Paso 3: En la App, Usa Estas Credenciales

```
Email: admin@example.com
Password: admin123
```

---

## 🎉 ¡Eso es Todo!

Si seguiste los 3 pasos, el login debe funcionar.

---

## 🔍 ¿Cómo Saber si Funciona?

En la terminal de Flutter verás mensajes como:

```
🟢 Iniciando login...
🔵 Intentando login con: admin@example.com
🔵 Status code: 200
✅ Login exitoso! Token guardado
```

Si ves ✅, ¡funcionó!

---

## ❌ ¿Qué Hacer si No Funciona?

### 1. Verifica que el servidor esté corriendo

En la terminal donde ejecutaste `php artisan serve`, debes ver:
```
Server running on [http://127.0.0.1:8000]
```

Si no lo ves, el servidor no está corriendo.

### 2. Verifica las credenciales

- Email: `admin@example.com` (con @example.com)
- Password: `admin123` (exactamente así)

### 3. Reinicia todo

```bash
# Terminal 1
cd backend-balance-mensual
php artisan migrate:fresh --seed
php artisan serve

# Terminal 2
flutter run
```

---

## 📚 Más Información

- `SOLUCION_FINAL.md` - Guía detallada con solución de problemas
- `test_connection.sh` - Script para verificar que todo funciona
- `INSTRUCCIONES_LOGIN.md` - Instrucciones completas

---

## 🆘 Ayuda Rápida

```bash
# Verificar que todo funciona
./test_connection.sh

# Si dice "✅ Todo está funcionando", entonces:
# 1. El servidor está corriendo
# 2. El usuario existe
# 3. El login funciona

# Ahora solo ejecuta:
flutter run
```

---

## ✅ Resumen Ultra Rápido

```bash
# Terminal 1 (déjala abierta)
cd backend-balance-mensual && php artisan serve

# Terminal 2
flutter run

# En la app
Email: admin@example.com
Password: admin123
```

**¡Eso es todo!** 🎉
