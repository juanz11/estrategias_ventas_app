# 🔄 Código para Integración Completa

## Instrucciones

Debido a la longitud del archivo `lib/main.dart`, voy a darte el código que necesitas agregar/modificar en secciones específicas.

## 1. Modificar la clase `_DashboardScreenState`

Busca la línea `class _DashboardScreenState extends State<DashboardScreen> {` (alrededor de la línea 760) y reemplaza TODO el contenido hasta donde empiezan los métodos `get` (alrededor de línea 1070) con esto:

```dart
class _DashboardScreenState extends State<DashboardScreen> {
  final _apiService = ApiService();
  int _tab = 0;
  bool _isLoading = true;

  // Datos de PRESUPUESTO (estimaciones mensuales)
  List<_IngresoMensual> _ingresosPresupuesto = [];
  List<_GastoMensual> _gastosPresupuesto = [];

  // Datos REALES de OPERACIONES (ingresos y gastos reales por mes)
  List<_IngresoMensual> _ingresosReales = [];
  List<_GastoMensual> _gastosReales = [];

  Set<String> _categoriasGasto = {};
  List<_Deuda> _deudas = [];

  @override
  void initState() {
    super.initState();
    _apiService.init();
    _loadData();
  }

  // Cargar todos los datos desde la API
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      print('🔵 Cargando datos desde la API...');
      
      // Cargar ingresos presupuesto
      final ingresosPresupuestoData = await _apiService.getIngresos(esPresupuesto: true);
      _ingresosPresupuesto = ingresosPresupuestoData
          .map((json) => _IngresoMensual.fromJson(json))
          .toList();
      print('✅ Ingresos presupuesto: ${_ingresosPresupuesto.length}');
      
      // Cargar ingresos reales
      final ingresosRealesData = await _apiService.getIngresos(esPresupuesto: false);
      _ingresosReales = ingresosRealesData
          .map((json) => _IngresoMensual.fromJson(json))
          .toList();
      print('✅ Ingresos reales: ${_ingresosReales.length}');
      
      // Cargar gastos presupuesto
      final gastosPresupuestoData = await _apiService.getGastos(esPresupuesto: true);
      _gastosPresupuesto = gastosPresupuestoData
          .map((json) => _GastoMensual.fromJson(json))
          .toList();
      print('✅ Gastos presupuesto: ${_gastosPresupuesto.length}');
      
      // Cargar gastos reales
      final gastosRealesData = await _apiService.getGastos(esPresupuesto: false);
      _gastosReales = gastosRealesData
          .map((json) => _GastoMensual.fromJson(json))
          .toList();
      print('✅ Gastos reales: ${_gastosReales.length}');
      
      // Cargar deudas
      final deudasData = await _apiService.getDeudas();
      _deudas = deudasData
          .map((json) => _Deuda.fromJson(json))
          .toList();
      print('✅ Deudas: ${_deudas.length}');
      
      // Cargar categorías
      final categoriasData = await _apiService.getCategorias();
      _categoriasGasto = categoriasData
          .map((json) => json['nombre'] as String)
          .toSet();
      print('✅ Categorías: ${_categoriasGasto.length}');
      
      setState(() => _isLoading = false);
      
      // Verificar deudas vencidas después de cargar
      _verificarDeudasHoy();
    } catch (e) {
      print('❌ Error cargando datos: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }
```

## 2. Agregar método para verificar deudas vencidas

Busca el método `_verificarDeudasHoy()` y reemplázalo con:

```dart
  Future<void> _verificarDeudasHoy() async {
    try {
      final deudasVencidas = await _apiService.getDeudasVencidasHoy();
      
      if (deudasVencidas.isEmpty || !mounted) return;
      
      final deudas = deudasVencidas.map((json) => _Deuda.fromJson(json)).toList();
      
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Text('Deudas Vencidas Hoy'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tienes deudas que vencen hoy:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...deudas.map((d) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          d.tipo == _TipoDeuda.porPagar
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: d.tipo == _TipoDeuda.porPagar
                              ? Colors.red
                              : Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d.nombre,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                _money(d.monto),
                                style: TextStyle(
                                  color: d.tipo == _TipoDeuda.porPagar
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Entendido'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error verificando deudas vencidas: $e');
    }
  }
```

## 3. Modificar métodos de INGRESOS REALES para usar la API

Busca los métodos `_addIngresoReal`, `_editIngresoReal`, `_deleteIngresoReal` y reemplázalos con:

```dart
  // ========== FUNCIONES PARA OPERACIONES (REALES) ==========
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
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingreso agregado')),
        );
      }
    } catch (e) {
      print('Error creando ingreso: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

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
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingreso actualizado')),
        );
      }
    } catch (e) {
      print('Error actualizando ingreso: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  Future<void> _deleteIngresoReal(int index) async {
    final ingreso = _ingresosReales[index];
    
    try {
      await _apiService.deleteIngreso(ingreso.id!);
      setState(() => _ingresosReales.removeAt(index));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingreso eliminado')),
        );
      }
    } catch (e) {
      print('Error eliminando ingreso: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }
```

## 4. Modificar métodos de GASTOS REALES para usar la API

Busca los métodos `_addGastoReal`, `_editGastoReal`, `_deleteGastoReal` y reemplázalos con:

```dart
  Future<void> _addGastoReal() async {
    final result = await _openGastoModal(context);
    if (!mounted || result == null) return;
    
    try {
      final json = await _apiService.createGasto(
        categoria: result.categoria,
        subCategoria: result.subCategoria,
        monto: result.monto,
        esFijo: result.esFijo,
        pagoConTarjeta: result.pagoConTarjeta,
        gastoHormiga: result.gastoHormiga,
        periodicidad: result.periodicidad.name,
        mes: result.mes,
        esPresupuesto: false,
      );
      
      final gasto = _GastoMensual.fromJson(json);
      setState(() => _gastosReales.add(gasto));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto agregado')),
        );
      }
    } catch (e) {
      print('Error creando gasto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  Future<void> _editGastoReal(int index) async {
    final gasto = _gastosReales[index];
    final result = await _openGastoModal(context, initial: gasto);
    if (!mounted || result == null) return;
    
    try {
      final json = await _apiService.updateGasto(
        gasto.id!,
        result.toJson(esPresupuesto: false),
      );
      
      final updated = _GastoMensual.fromJson(json);
      setState(() => _gastosReales[index] = updated);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto actualizado')),
        );
      }
    } catch (e) {
      print('Error actualizando gasto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  Future<void> _deleteGastoReal(int index) async {
    final gasto = _gastosReales[index];
    
    try {
      await _apiService.deleteGasto(gasto.id!);
      setState(() => _gastosReales.removeAt(index));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto eliminado')),
        );
      }
    } catch (e) {
      print('Error eliminando gasto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }
```

## 5. Hacer lo mismo para PRESUPUESTO

Aplica el mismo patrón para:
- `_addIngresoPresupuesto` (usa `esPresupuesto: true`)
- `_editIngresoPresupuesto`
- `_deleteIngresoPresupuesto`
- `_addGastoPresupuesto`
- `_editGastoPresupuesto`
- `_deleteGastoPresupuesto`

## 6. Modificar métodos de DEUDAS

```dart
  Future<void> _addDeuda() async {
    final result = await _openDeudaModal(context);
    if (!mounted || result == null) return;
    
    try {
      final json = await _apiService.createDeuda(
        concepto: result.nombre,
        monto: result.monto,
        fecha: result.fecha,
        tipo: result.tipo == _TipoDeuda.porPagar ? 'por_pagar' : 'por_cobrar',
      );
      
      final deuda = _Deuda.fromJson(json);
      setState(() => _deudas.add(deuda));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deuda agregada')),
        );
      }
    } catch (e) {
      print('Error creando deuda: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  Future<void> _editDeuda(int index) async {
    final deuda = _deudas[index];
    final result = await _openDeudaModal(context, initial: deuda);
    if (!mounted || result == null) return;
    
    try {
      final json = await _apiService.updateDeuda(
        deuda.id!,
        result.toJson(),
      );
      
      final updated = _Deuda.fromJson(json);
      setState(() => _deudas[index] = updated);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deuda actualizada')),
        );
      }
    } catch (e) {
      print('Error actualizando deuda: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  Future<void> _deleteDeuda(int index) async {
    final deuda = _deudas[index];
    
    try {
      await _apiService.deleteDeuda(deuda.id!);
      setState(() => _deudas.removeAt(index));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deuda eliminada')),
        );
      }
    } catch (e) {
      print('Error eliminando deuda: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }
```

## 7. Agregar indicador de carga en el build

Busca el método `build` de `_DashboardScreenState` y agrega al inicio:

```dart
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Balance Mensual'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando datos...'),
            ],
          ),
        ),
      );
    }
    
    // ... resto del código existente
  }
```

---

## ⚠️ IMPORTANTE

Este código es muy extenso para aplicarlo manualmente. Te recomiendo que:

1. **Haz un backup de tu `lib/main.dart` actual**
2. **Aplica los cambios sección por sección**
3. **Prueba después de cada sección**

O si prefieres, puedo crear un script que haga todos los cambios automáticamente.

¿Quieres que cree el script automático o prefieres aplicar los cambios manualmente?
