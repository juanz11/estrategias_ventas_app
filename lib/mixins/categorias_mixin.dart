import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Mixin para operaciones CRUD de categorías de gastos
mixin CategoriasMixin<T extends StatefulWidget> on State<T> {
  ApiService get apiService;
  Set<String> get categoriasGasto;
  set categoriasGasto(Set<String> value);

  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(fn);
      });
    }
  }

  void _showSnack(String msg) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        }
      });
    }
  }

  // ========== CATEGORÍAS ==========

  Future<void> addCategoria(String nombre) async {
    try {
      await apiService.createCategoria(nombre);
      _safeSetState(() {
        final set = Set<String>.from(categoriasGasto);
        set.add(nombre);
        categoriasGasto = set;
      });
      _showSnack('Categoría agregada');
    } catch (e) {
      print('❌ Error creando categoría: $e');
      _showSnack('Error al guardar: $e');
    }
  }

  Future<void> editCategoria(String nombreActual, String nuevoNombre) async {
    try {
      final categoriasData = await apiService.getCategorias();
      final categoria = categoriasData.firstWhere(
        (c) => c['nombre'] == nombreActual,
        orElse: () => null,
      );

      if (categoria != null && categoria['id'] != null) {
        await apiService.updateCategoria(categoria['id'], nuevoNombre);
        _safeSetState(() {
          final set = Set<String>.from(categoriasGasto);
          set.remove(nombreActual);
          set.add(nuevoNombre);
          categoriasGasto = set;
        });
        _showSnack('Categoría renombrada');
      }
    } catch (e) {
      print('❌ Error renombrando categoría: $e');
      _showSnack('Error al renombrar: $e');
    }
  }

  Future<void> deleteCategoria(String nombre) async {
    try {
      final categoriasData = await apiService.getCategorias();
      final categoria = categoriasData.firstWhere(
        (c) => c['nombre'] == nombre,
        orElse: () => null,
      );

      if (categoria != null && categoria['id'] != null) {
        await apiService.deleteCategoria(categoria['id']);
        _safeSetState(() {
          final set = Set<String>.from(categoriasGasto);
          set.remove(nombre);
          categoriasGasto = set;
        });
        _showSnack('Categoría eliminada');
      }
    } catch (e) {
      print('❌ Error eliminando categoría: $e');
      _showSnack('Error al eliminar: $e');
    }
  }
}
