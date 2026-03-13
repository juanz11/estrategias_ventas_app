import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main.dart';

/// Mixin para operaciones CRUD de ingresos (presupuesto y reales)
/// Requiere que la clase que lo use también use DataLoaderMixin
mixin IngresosMixin<T extends StatefulWidget> on State<T> {
  ApiService get apiService;
  List<IngresoMensual> get ingresosPresupuesto;
  List<IngresoMensual> get ingresosReales;
  set ingresosPresupuesto(List<IngresoMensual> value);
  set ingresosReales(List<IngresoMensual> value);

  // ========== INGRESOS REALES (Operaciones) ==========

  Future<void> addIngresoReal(IngresoMensual ingreso) async {
    try {
      final json = await apiService.createIngreso(
        etiqueta: ingreso.etiqueta,
        tipo: ingreso.tipo.name,
        monto: ingreso.monto,
        mes: ingreso.mes,
        esPresupuesto: false,
      );

      final nuevoIngreso = IngresoMensual.fromJson(json);
      setState(() {
        ingresosReales = [...ingresosReales, nuevoIngreso];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingreso agregado')),
        );
      }
    } catch (e) {
      print('❌ Error creando ingreso: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  Future<void> editIngresoReal(int index, IngresoMensual ingreso) async {
    final ingresoActual = ingresosReales[index];

    try {
      final json = await apiService.updateIngreso(
        ingresoActual.id!,
        ingreso.toJson(esPresupuesto: false),
      );

      final updated = IngresoMensual.fromJson(json);
      setState(() {
        final list = [...ingresosReales];
        list[index] = updated;
        ingresosReales = list;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingreso actualizado')),
        );
      }
    } catch (e) {
      print('❌ Error actualizando ingreso: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  Future<void> deleteIngresoReal(int index) async {
    final ingreso = ingresosReales[index];

    try {
      await apiService.deleteIngreso(ingreso.id!);
      setState(() {
        final list = [...ingresosReales];
        list.removeAt(index);
        ingresosReales = list;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingreso eliminado')),
        );
      }
    } catch (e) {
      print('❌ Error eliminando ingreso: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  // ========== INGRESOS PRESUPUESTO ==========

  Future<void> addIngresoPresupuesto(IngresoMensual ingreso) async {
    try {
      final json = await apiService.createIngreso(
        etiqueta: ingreso.etiqueta,
        tipo: ingreso.tipo.name,
        monto: ingreso.monto,
        mes: ingreso.mes,
        esPresupuesto: true,
      );

      final nuevoIngreso = IngresoMensual.fromJson(json);
      setState(() {
        ingresosPresupuesto = [...ingresosPresupuesto, nuevoIngreso];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingreso presupuesto agregado')),
        );
      }
    } catch (e) {
      print('❌ Error creando ingreso presupuesto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  Future<void> editIngresoPresupuesto(int index, IngresoMensual ingreso) async {
    final ingresoActual = ingresosPresupuesto[index];

    try {
      final json = await apiService.updateIngreso(
        ingresoActual.id!,
        ingreso.toJson(esPresupuesto: true),
      );

      final updated = IngresoMensual.fromJson(json);
      setState(() {
        final list = [...ingresosPresupuesto];
        list[index] = updated;
        ingresosPresupuesto = list;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingreso presupuesto actualizado')),
        );
      }
    } catch (e) {
      print('❌ Error actualizando ingreso presupuesto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  Future<void> deleteIngresoPresupuesto(int index) async {
    final ingreso = ingresosPresupuesto[index];

    try {
      await apiService.deleteIngreso(ingreso.id!);
      setState(() {
        final list = [...ingresosPresupuesto];
        list.removeAt(index);
        ingresosPresupuesto = list;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingreso presupuesto eliminado')),
        );
      }
    } catch (e) {
      print('❌ Error eliminando ingreso presupuesto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }
}
