import 'package:flutter/material.dart';
import 'dart:io' show File;
import '../services/api_service.dart';
import '../main.dart';

/// Mixin para operaciones CRUD de gastos (presupuesto y reales)
/// Requiere que la clase que lo use también use DataLoaderMixin
mixin GastosMixin<T extends StatefulWidget> on State<T> {
  ApiService get apiService;
  List<GastoMensual> get gastosPresupuesto;
  List<GastoMensual> get gastosReales;
  set gastosPresupuesto(List<GastoMensual> value);
  set gastosReales(List<GastoMensual> value);

  // ========== GASTOS REALES (Operaciones) ==========

  Future<void> addGastoReal(GastoMensual gasto, {File? archivo}) async {
    try {
      final json = await apiService.createGasto(
        categoria: gasto.categoria,
        subCategoria: gasto.subCategoria,
        monto: gasto.monto,
        esFijo: gasto.esFijo,
        pagoConTarjeta: gasto.pagoConTarjeta,
        gastoHormiga: gasto.gastoHormiga,
        periodicidad: gasto.periodicidad.name,
        mes: gasto.mes,
        esPresupuesto: false,
        archivo: archivo,
      );

      final nuevoGasto = GastoMensual.fromJson(json);
      setState(() {
        gastosReales = [...gastosReales, nuevoGasto];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto agregado')),
        );
      }
    } catch (e) {
      print('❌ Error creando gasto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  Future<void> editGastoReal(int index, GastoMensual gasto, {File? archivo}) async {
    final gastoActual = gastosReales[index];
    try {
      final Map<String, dynamic> json;
      if (archivo != null) {
        // Usar multipart para subir archivo
        json = await apiService.subirArchivoGasto(gastoActual.id!, archivo,
            extraFields: gasto.toJson(esPresupuesto: false));
      } else {
        json = await apiService.updateGasto(gastoActual.id!, gasto.toJson(esPresupuesto: false));
      }

      final updated = GastoMensual.fromJson(json);
      setState(() {
        final list = [...gastosReales];
        list[index] = updated;
        gastosReales = list;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto actualizado')),
        );
      }
    } catch (e) {
      print('❌ Error actualizando gasto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  Future<void> deleteGastoReal(int index) async {
    final gasto = gastosReales[index];

    try {
      await apiService.deleteGasto(gasto.id!);
      setState(() {
        final list = [...gastosReales];
        list.removeAt(index);
        gastosReales = list;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto eliminado')),
        );
      }
    } catch (e) {
      print('❌ Error eliminando gasto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  // ========== GASTOS PRESUPUESTO ==========

  Future<void> addGastoPresupuesto(GastoMensual gasto, {File? archivo}) async {
    try {
      final json = await apiService.createGasto(
        categoria: gasto.categoria,
        subCategoria: gasto.subCategoria,
        monto: gasto.monto,
        esFijo: gasto.esFijo,
        pagoConTarjeta: gasto.pagoConTarjeta,
        gastoHormiga: gasto.gastoHormiga,
        periodicidad: gasto.periodicidad.name,
        mes: gasto.mes,
        esPresupuesto: true,
        archivo: archivo,
      );

      final nuevoGasto = GastoMensual.fromJson(json);
      setState(() {
        gastosPresupuesto = [...gastosPresupuesto, nuevoGasto];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto presupuesto agregado')),
        );
      }
    } catch (e) {
      print('❌ Error creando gasto presupuesto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  Future<void> editGastoPresupuesto(int index, GastoMensual gasto, {File? archivo}) async {
    final gastoActual = gastosPresupuesto[index];
    try {
      final Map<String, dynamic> json;
      if (archivo != null) {
        json = await apiService.subirArchivoGasto(gastoActual.id!, archivo,
            extraFields: gasto.toJson(esPresupuesto: true));
      } else {
        json = await apiService.updateGasto(gastoActual.id!, gasto.toJson(esPresupuesto: true));
      }

      final updated = GastoMensual.fromJson(json);
      setState(() {
        final list = [...gastosPresupuesto];
        list[index] = updated;
        gastosPresupuesto = list;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto presupuesto actualizado')),
        );
      }
    } catch (e) {
      print('❌ Error actualizando gasto presupuesto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  Future<void> deleteGastoPresupuesto(int index) async {
    final gasto = gastosPresupuesto[index];

    try {
      await apiService.deleteGasto(gasto.id!);
      setState(() {
        final list = [...gastosPresupuesto];
        list.removeAt(index);
        gastosPresupuesto = list;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto presupuesto eliminado')),
        );
      }
    } catch (e) {
      print('❌ Error eliminando gasto presupuesto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }
}
