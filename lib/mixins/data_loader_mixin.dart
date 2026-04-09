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
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      print('🔵 Cargando datos desde la API...');

      // Cargar todos los datos en paralelo
      final results = await Future.wait([
        apiService.getIngresos(esPresupuesto: true),
        apiService.getIngresos(esPresupuesto: false),
        apiService.getGastos(esPresupuesto: true),
        apiService.getGastos(esPresupuesto: false),
        apiService.getDeudas(),
        apiService.getCategorias(),
      ]);

      if (!mounted) return;

      ingresosPresupuesto = (results[0] as List).map((json) => IngresoMensual.fromJson(json)).toList();
      ingresosReales      = (results[1] as List).map((json) => IngresoMensual.fromJson(json)).toList();
      gastosPresupuesto   = (results[2] as List).map((json) => GastoMensual.fromJson(json)).toList();
      gastosReales        = (results[3] as List).map((json) => GastoMensual.fromJson(json)).toList();
      deudas              = (results[4] as List).map((json) => Deuda.fromJson(json)).toList();
      categoriasGasto     = (results[5] as List).map((json) => json['nombre'] as String).toSet();

      print('✅ Datos cargados: ingresos=${ingresosReales.length}, gastos=${gastosReales.length}, deudas=${deudas.length}');

      if (mounted) setState(() => isLoading = false);
    } catch (e) {
      print('❌ Error cargando datos: $e');
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }
}
