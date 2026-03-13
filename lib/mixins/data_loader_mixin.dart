import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main.dart';

/// Mixin para cargar todos los datos desde la API
mixin DataLoaderMixin<T extends StatefulWidget> on State<T> {
  final apiService = ApiService();
  bool isLoading = true;

  // Getters y setters que deben ser implementados por la clase que use este mixin
  List<IngresoMensual> get ingresosPresupuesto;
  List<GastoMensual> get gastosPresupuesto;
  List<IngresoMensual> get ingresosReales;
  List<GastoMensual> get gastosReales;
  Set<String> get categoriasGasto;
  List<Deuda> get deudas;

  set ingresosPresupuesto(List<IngresoMensual> value);
  set gastosPresupuesto(List<GastoMensual> value);
  set ingresosReales(List<IngresoMensual> value);
  set gastosReales(List<GastoMensual> value);
  set categoriasGasto(Set<String> value);
  set deudas(List<Deuda> value);

  /// Inicializar API y cargar todos los datos
  Future<void> initializeData() async {
    await apiService.init();
    await loadAllData();
  }

  /// Cargar todos los datos desde la API
  Future<void> loadAllData() async {
    setState(() => isLoading = true);

    try {
      print('🔵 Cargando datos desde la API...');

      // Cargar ingresos presupuesto
      final ingresosPresupuestoData = await apiService.getIngresos(esPresupuesto: true);
      ingresosPresupuesto = ingresosPresupuestoData
          .map((json) => IngresoMensual.fromJson(json))
          .toList();
      print('✅ Ingresos presupuesto: ${ingresosPresupuesto.length}');

      // Cargar ingresos reales
      final ingresosRealesData = await apiService.getIngresos(esPresupuesto: false);
      ingresosReales = ingresosRealesData
          .map((json) => IngresoMensual.fromJson(json))
          .toList();
      print('✅ Ingresos reales: ${ingresosReales.length}');

      // Cargar gastos presupuesto
      final gastosPresupuestoData = await apiService.getGastos(esPresupuesto: true);
      gastosPresupuesto = gastosPresupuestoData
          .map((json) => GastoMensual.fromJson(json))
          .toList();
      print('✅ Gastos presupuesto: ${gastosPresupuesto.length}');

      // Cargar gastos reales
      final gastosRealesData = await apiService.getGastos(esPresupuesto: false);
      gastosReales = gastosRealesData
          .map((json) => GastoMensual.fromJson(json))
          .toList();
      print('✅ Gastos reales: ${gastosReales.length}');

      // Cargar deudas
      final deudasData = await apiService.getDeudas();
      deudas = deudasData
          .map((json) => Deuda.fromJson(json))
          .toList();
      print('✅ Deudas: ${deudas.length}');

      // Cargar categorías
      final categoriasData = await apiService.getCategorias();
      categoriasGasto = categoriasData
          .map((json) => json['nombre'] as String)
          .toSet();
      print('✅ Categorías: ${categoriasGasto.length}');

      setState(() => isLoading = false);
    } catch (e) {
      print('❌ Error cargando datos: $e');
      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }
}
