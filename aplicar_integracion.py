#!/usr/bin/env python3
"""
Script para aplicar la integración completa con el backend Laravel.
Este script modifica lib/main.dart para conectar toda la app con la API.
"""

import re
import sys

def main():
    print("🔄 Aplicando integración completa con backend...")
    print("")
    
    # Leer el archivo
    try:
        with open('lib/main.dart', 'r', encoding='utf-8') as f:
            content = f.content()
    except FileNotFoundError:
        print("❌ Error: No se encontró lib/main.dart")
        print("   Asegúrate de ejecutar este script desde la raíz del proyecto Flutter")
        sys.exit(1)
    
    print("✅ Archivo leído correctamente")
    print("")
    
    # Hacer backup
    with open('lib/main.dart.backup', 'w', encoding='utf-8') as f:
        f.write(content)
    print("✅ Backup creado: lib/main.dart.backup")
    print("")
    
    # Aplicar cambios
    print("🔧 Aplicando cambios...")
    
    # 1. Agregar import del servicio API si no existe
    if 'import \'services/api_service.dart\';' not in content:
        content = content.replace(
            "import 'package:fl_chart/fl_chart.dart';",
            "import 'package:fl_chart/fl_chart.dart';\nimport 'services/api_service.dart';"
        )
        print("  ✅ Import de ApiService agregado")
    
    # 2. Modificar la clase _DashboardScreenState
    # Buscar el patrón y reemplazar
    pattern = r'class _DashboardScreenState extends State<DashboardScreen> \{[\s\S]*?(?=  // Totales de ingresos)'
    
    replacement = '''class _DashboardScreenState extends State<DashboardScreen> {
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
      print('✅ Ingresos presupuesto: \${_ingresosPresupuesto.length}');
      
      // Cargar ingresos reales
      final ingresosRealesData = await _apiService.getIngresos(esPresupuesto: false);
      _ingresosReales = ingresosRealesData
          .map((json) => _IngresoMensual.fromJson(json))
          .toList();
      print('✅ Ingresos reales: \${_ingresosReales.length}');
      
      // Cargar gastos presupuesto
      final gastosPresupuestoData = await _apiService.getGastos(esPresupuesto: true);
      _gastosPresupuesto = gastosPresupuestoData
          .map((json) => _GastoMensual.fromJson(json))
          .toList();
      print('✅ Gastos presupuesto: \${_gastosPresupuesto.length}');
      
      // Cargar gastos reales
      final gastosRealesData = await _apiService.getGastos(esPresupuesto: false);
      _gastosReales = gastosRealesData
          .map((json) => _GastoMensual.fromJson(json))
          .toList();
      print('✅ Gastos reales: \${_gastosReales.length}');
      
      // Cargar deudas
      final deudasData = await _apiService.getDeudas();
      _deudas = deudasData
          .map((json) => _Deuda.fromJson(json))
          .toList();
      print('✅ Deudas: \${_deudas.length}');
      
      // Cargar categorías
      final categoriasData = await _apiService.getCategorias();
      _categoriasGasto = categoriasData
          .map((json) => json['nombre'] as String)
          .toSet();
      print('✅ Categorías: \${_categoriasGasto.length}');
      
      setState(() => _isLoading = false);
      
      // Verificar deudas vencidas después de cargar
      _verificarDeudasHoy();
    } catch (e) {
      print('❌ Error cargando datos: \$e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: \$e')),
        );
      }
    }
  }

  '''
    
    content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
    print("  ✅ Clase _DashboardScreenState modificada")
    
    # Guardar cambios
    with open('lib/main.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("")
    print("🎉 ¡Integración aplicada exitosamente!")
    print("")
    print("📝 Próximos pasos:")
    print("  1. Revisa los cambios en lib/main.dart")
    print("  2. Si algo salió mal, restaura desde lib/main.dart.backup")
    print("  3. Ejecuta: flutter run")
    print("")
    print("⚠️  NOTA: Este script solo aplicó parte de los cambios.")
    print("   Revisa CODIGO_INTEGRACION_COMPLETA.md para los métodos restantes.")

if __name__ == '__main__':
    main()
