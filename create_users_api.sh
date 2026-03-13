#!/bin/bash

echo "🔵 Creando usuarios en https://balance.zcdigitalsolutions.com/api/register"
echo ""

# Crear usuario Michel Lopez
echo "Creando usuario: mlopez@balance.com"
curl -X POST https://balance.zcdigitalsolutions.com/api/register \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "name": "Michel Lopez",
    "email": "mlopez@balance.com",
    "password": "michel2026",
    "password_confirmation": "michel2026"
  }'
echo ""
echo ""

# Crear usuario Joel Lopez
echo "Creando usuario: jlopez@balance.com"
curl -X POST https://balance.zcdigitalsolutions.com/api/register \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "name": "Joel Lopez",
    "email": "jlopez@balance.com",
    "password": "joel2026",
    "password_confirmation": "joel2026"
  }'
echo ""
echo ""

echo "✅ Usuarios creados!"
echo "Puedes iniciar sesión con:"
echo "- mlopez@balance.com / michel2026"
echo "- jlopez@balance.com / joel2026"
