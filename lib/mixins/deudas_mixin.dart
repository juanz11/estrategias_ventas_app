import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main.dart';

/// Mixin para operaciones CRUD de deudas
/// Requiere que la clase que lo use también use DataLoaderMixin
mixin DeudasMixin<T extends StatefulWidget> on State<T> {
  ApiService get apiService;
  List<Deuda> get deudas;
  set deudas(List<Deuda> value);

  // ========== DEUDAS ==========

  Future<void> addDeuda(Deuda deuda) async {
    try {
      final json = await apiService.createDeuda(
        concepto: deuda.nombre,
        monto: deuda.monto,
        fecha: deuda.fecha,
        tipo: deuda.tipo == TipoDeuda.porPagar ? 'por_pagar' : 'por_cobrar',
      );

      final nuevaDeuda = Deuda.fromJson(json);
      setState(() {
        deudas = [...deudas, nuevaDeuda];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deuda agregada')),
        );
      }
    } catch (e) {
      print('❌ Error creando deuda: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  Future<void> editDeuda(int index, Deuda deuda) async {
    final deudaActual = deudas[index];

    try {
      final json = await apiService.updateDeuda(
        deudaActual.id!,
        deuda.toJson(),
      );

      final updated = Deuda.fromJson(json);
      setState(() {
        final list = [...deudas];
        list[index] = updated;
        deudas = list;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deuda actualizada')),
        );
      }
    } catch (e) {
      print('❌ Error actualizando deuda: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  Future<void> deleteDeuda(int index) async {
    final deuda = deudas[index];

    try {
      await apiService.deleteDeuda(deuda.id!);
      setState(() {
        final list = [...deudas];
        list.removeAt(index);
        deudas = list;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deuda eliminada')),
        );
      }
    } catch (e) {
      print('❌ Error eliminando deuda: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  // ========== OBTENER DEUDAS VENCIDAS ==========
  
  /// Obtiene las deudas vencidas hoy desde la API
  /// Retorna una lista de deudas para que la clase que use el mixin
  /// pueda mostrar la UI como prefiera
  Future<List<Deuda>> obtenerDeudasVencidasHoy() async {
    try {
      final deudasVencidas = await apiService.getDeudasVencidasHoy();
      return deudasVencidas.map((json) => Deuda.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error obteniendo deudas vencidas: $e');
      return [];
    }
  }
}
