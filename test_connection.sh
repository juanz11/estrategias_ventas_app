#!/bin/bash

echo "🔍 Verificando conexión al backend..."
echo ""

# Test 1: Verificar que el servidor esté corriendo
echo "1️⃣ Verificando servidor en puerto 8000..."
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null ; then
    echo "✅ Servidor corriendo en puerto 8000"
else
    echo "❌ No hay servidor en puerto 8000"
    echo "   Ejecuta: cd backend-balance-mensual && php artisan serve"
    exit 1
fi

echo ""

# Test 2: Verificar que el endpoint responda
echo "2️⃣ Probando endpoint de login..."
RESPONSE=$(curl -s -w "\n%{http_code}" http://127.0.0.1:8000/api/login \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Login exitoso (HTTP 200)"
    echo "   Token recibido: $(echo $BODY | grep -o '"token":"[^"]*"' | cut -d'"' -f4 | cut -c1-20)..."
else
    echo "❌ Login falló (HTTP $HTTP_CODE)"
    echo "   Respuesta: $BODY"
    exit 1
fi

echo ""

# Test 3: Verificar usuario en base de datos
echo "3️⃣ Verificando usuario en base de datos..."
cd backend-balance-mensual
USER_EXISTS=$(php artisan tinker --execute="echo App\Models\User::where('email', 'admin@example.com')->exists() ? 'yes' : 'no';" 2>/dev/null)

if [ "$USER_EXISTS" = "yes" ]; then
    echo "✅ Usuario existe en la base de datos"
else
    echo "❌ Usuario NO existe en la base de datos"
    echo "   Ejecuta: php artisan migrate:fresh --seed"
    exit 1
fi

echo ""
echo "🎉 ¡Todo está funcionando correctamente!"
echo ""
echo "📱 Ahora puedes ejecutar la app Flutter:"
echo "   flutter run"
echo ""
echo "🔐 Credenciales:"
echo "   Email: admin@example.com"
echo "   Password: admin123"
