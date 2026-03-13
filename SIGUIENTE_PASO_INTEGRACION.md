# 🔄 Siguiente Paso: Integración Completa con Backend

## ✅ Lo que ya está hecho:

1. ✅ Login conectado y funcionando
2. ✅ Servidor Laravel configurado correctamente
3. ✅ Base de datos limpia (solo usuario admin)
4. ✅ Modelos actualizados con:
   - IDs para identificar registros
   - Métodos `fromJson()` para cargar desde API
   - Métodos `toJson()` para guardar en API

## 🎯 Lo que falta por hacer:

### 1. Modificar `DashboardScreen` para cargar datos desde la API

Actualmente, `DashboardScreen` tiene datos estáticos hardcodeados. Necesitamos:

**a) Agregar el servicio API:**
```dart
class _DashboardScreenState extends State<DashboardScreen> {
  final _apiService = ApiService();
  bool _isLoading = true;
  
  // Las listas ahora empiezan vacías
  List<_IngresoMensual> _ingresosPresupuesto = [];
  List<_IngresoMensual> _ingresosReales = [];
  List<_GastoMensual> _gastosPresupuesto = [];
  List<_GastoMensual> _gastosReales = [];
  List<_Deuda> _deudas = [];
  Set<String> _categoriasGasto = {};
```

**b) Cargar datos al iniciar:**
```dart
@override
void initState() {
  super.initState();
  _apiService.init();
  _loadData();
  _checkDeudasVencidas();
}

Future<void> _loadData() async {
  setState(() => _isLoading = true);
  
  try {
    // Cargar ingresos presupuesto
    final ingresosPresupuestoData = await _apiService.getIngresos(esPresupuesto: true);
    _ingresosPresupuesto = ingresosPresupuestoData
        .map((json) => _IngresoMensual.fromJson(json))
        .toList();
    
    // Cargar ingresos reales
    final ingresosRealesData = await _apiService.getIngresos(esPresupuesto: false);
    _ingresosReales = ingresosRealesData
        .map((json) => _IngresoMensual.fromJson(json))
        .toList();
    
    // Cargar gastos presupuesto
    final gastosPresupuestoData = await _apiService.getGastos(esPresupuesto: true);
    _gastosPresupuesto = gastosPresupuestoData
        .map((json) => _GastoMensual.fromJson(json))
        .toList();
    
    // Cargar gastos reales
    final gastosRealesData = await _apiService.getGastos(esPresupuesto: false);
    _gastosReales = gastosRealesData
        .map((json) => _GastoMensual.fromJson(json))
        .toList();
    
    // Cargar deudas
    final deudasData = await _apiService.getDeudas();
    _deudas = deudasData
        .map((json) => _Deuda.fromJson(json))
        .toList();
    
    // Cargar categorías
    final categoriasData = await _apiService.getCategorias();
    _categoriasGasto = categoriasData
        .map((json) => json['nombre'] as String)
        .toSet();
    
    setState(() => _isLoading = false);
  } catch (e) {
    print('Error cargando datos: $e');
    setState(() => _isLoading = false);
  }
}
```

### 2. Modificar métodos para guardar en la API

**a) Agregar ingreso real:**
```dart
Future<void> _addIngresoReal() async {
  final result = await _openIngresoModal(context);
  if (!mounted || result == null) return;
  
  try {
    final json = await _apiService.createIngreso(
      etiqueta: result.etiqueta,
      tipo: result.tipo.name,
      monto: result.monto,
      mes: result.mes,
      esPresupuesto: false,
    );
    
    final ingreso = _IngresoMensual.fromJson(json);
    setState(() => _ingresosReales.add(ingreso));
  } catch (e) {
    print('Error creando ingreso: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al guardar ingreso')),
    );
  }
}
```

**b) Editar ingreso real:**
```dart
Future<void> _editIngresoReal(int index) async {
  final ingreso = _ingresosReales[index];
  final result = await _openIngresoModal(context, initial: ingreso);
  if (!mounted || result == null) return;
  
  try {
    final json = await _apiService.updateIngreso(
      ingreso.id!,
      result.toJson(esPresupuesto: false),
    );
    
    final updated = _IngresoMensual.fromJson(json);
    setState(() => _ingresosReales[index] = updated);
  } catch (e) {
    print('Error actualizando ingreso: $e');
  }
}
```

**c) Eliminar ingreso real:**
```dart
Future<void> _deleteIngresoReal(int index) async {
  final ingreso = _ingresosReales[index];
  
  try {
    await _apiService.deleteIngreso(ingreso.id!);
    setState(() => _ingresosReales.removeAt(index));
  } catch (e) {
    print('Error eliminando ingreso: $e');
  }
}
```

### 3. Hacer lo mismo para:
- ✅ Ingresos presupuesto
- ✅ Gastos reales
- ✅ Gastos presupuesto
- ✅ Deudas
- ✅ Categorías

### 4. Agregar indicador de carga

```dart
@override
Widget build(BuildContext context) {
  if (_isLoading) {
    return Scaffold(
      appBar: AppBar(title: const Text('Balance Mensual')),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  // ... resto del código
}
```

### 5. Agregar botón de refresh

```dart
FloatingActionButton(
  onPressed: _loadData,
  child: const Icon(Icons.refresh),
)
```

---

## 🚀 Beneficios de la Integración Completa:

1. ✅ **Datos persistentes**: Los datos se guardan en la base de datos
2. ✅ **Sincronización**: Múltiples dispositivos pueden ver los mismos datos
3. ✅ **Backup automático**: Los datos están en el servidor
4. ✅ **Escalabilidad**: Fácil agregar más funciones
5. ✅ **Seguridad**: Datos protegidos por autenticación

---

## 📝 Resumen de Cambios Necesarios:

| Componente | Estado | Acción |
|------------|--------|--------|
| Modelos (ID, fromJson, toJson) | ✅ Hecho | - |
| Login | ✅ Hecho | - |
| Cargar datos al iniciar | ⏳ Pendiente | Agregar `_loadData()` |
| Crear ingresos/gastos | ⏳ Pendiente | Usar `_apiService.create*()` |
| Editar ingresos/gastos | ⏳ Pendiente | Usar `_apiService.update*()` |
| Eliminar ingresos/gastos | ⏳ Pendiente | Usar `_apiService.delete*()` |
| Crear deudas | ⏳ Pendiente | Usar `_apiService.createDeuda()` |
| Editar deudas | ⏳ Pendiente | Usar `_apiService.updateDeuda()` |
| Eliminar deudas | ⏳ Pendiente | Usar `_apiService.deleteDeuda()` |
| Indicador de carga | ⏳ Pendiente | Agregar `CircularProgressIndicator` |

---

## 🎯 ¿Quieres que continúe?

Puedo:

**Opción A:** Modificar todo el código automáticamente para conectar completamente la app

**Opción B:** Darte el código completo para que lo copies manualmente

**Opción C:** Ir paso a paso, conectando una sección a la vez

¿Cuál prefieres?

---

## 💡 Nota Importante:

Una vez que conectemos todo, la app:
- Empezará sin datos (base de datos vacía)
- Podrás agregar ingresos, gastos y deudas
- Todo se guardará en el backend
- Si cierras y abres la app, los datos seguirán ahí
- Puedes usar la app desde diferentes dispositivos con el mismo usuario

¡Estamos muy cerca de tener la app completamente funcional! 🎉
