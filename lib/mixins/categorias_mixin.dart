import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Mixin para operaciones CRUD de categorías de gastos
mixin CategoriasMixin<T extends StatefulWidget> on State<T> {
  ApiService get apiService;
  Set<String> get categoriasGasto;
  set categoriasGasto(Set<String> value);

  // ========== CATEGORÍAS ==========

  Future<void> addCategoria(String nombre) async {
    try {
      await apiService.createCategoria(nombre);
      setState(() {
        final set = Set<String>.from(categoriasGasto);
        set.add(nombre);
        categoriasGasto = set;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoría agregada')),
        );
      }
    } catch (e) {
      print('❌ Error creando categoría: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
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
        setState(() {
          final set = Set<String>.from(categoriasGasto);
          set.remove(nombreActual);
          set.add(nuevoNombre);
          categoriasGasto = set;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Categoría renombrada')),
          );
        }
      }
    } catch (e) {
      print('❌ Error renombrando categoría: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al renombrar: $e')),
        );
      }
    }
  }

  Future<void> deleteCategoria(String nombre) async {
    try {
      // Primero necesitamos obtener el ID de la categoría
      final categoriasData = await apiService.getCategorias();
      final categoria = categoriasData.firstWhere(
        (c) => c['nombre'] == nombre,
        orElse: () => null,
      );

      if (categoria != null && categoria['id'] != null) {
        await apiService.deleteCategoria(categoria['id']);
        setState(() {
          final set = Set<String>.from(categoriasGasto);
          set.remove(nombre);
          categoriasGasto = set;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Categoría eliminada')),
          );
        }
      }
    } catch (e) {
      print('❌ Error eliminando categoría: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }
}
