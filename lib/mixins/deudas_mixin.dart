import 'package:flutter/material.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../main.dart';

/// Mixin para operaciones CRUD de deudas
mixin DeudasMixin<T extends StatefulWidget> on State<T> {
  ApiService get apiService;
  List<Deuda> get deudas;
  set deudas(List<Deuda> value);

  Future<void> addDeuda(Deuda deuda, {File? archivo}) async {
    try {
      final json = await apiService.createDeuda(
        concepto: deuda.nombre,
        monto: deuda.monto,
        fecha: deuda.fecha,
        tipo: deuda.tipo == TipoDeuda.porPagar ? 'por_pagar' : 'por_cobrar',
      );

      var nuevaDeuda = Deuda.fromJson(json);

      // Subir archivo si se seleccionó uno
      if (archivo != null && nuevaDeuda.id != null) {
        final jsonConArchivo = await apiService.subirArchivoDeuda(nuevaDeuda.id!, archivo);
        nuevaDeuda = Deuda.fromJson(jsonConArchivo);
      }

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

  Future<void> editDeuda(int index, Deuda deuda, {File? archivo}) async {
    final deudaActual = deudas[index];

    try {
      final json = await apiService.updateDeuda(deudaActual.id!, deuda.toJson());
      var updated = Deuda.fromJson(json);

      // Subir nuevo archivo si se seleccionó uno
      if (archivo != null && updated.id != null) {
        final jsonConArchivo = await apiService.subirArchivoDeuda(updated.id!, archivo);
        updated = Deuda.fromJson(jsonConArchivo);
      }

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
