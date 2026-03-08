<?php

namespace App\Http\Controllers;

use App\Models\CategoriaGasto;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class CategoriaGastoController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $categorias = CategoriaGasto::where('user_id', $request->user()->id)
            ->orderBy('nombre')
            ->get();

        return response()->json($categorias);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'nombre' => 'required|string|max:255|unique:categorias_gasto,nombre',
        ]);

        $validated['user_id'] = $request->user()->id;

        $categoria = CategoriaGasto::create($validated);

        return response()->json($categoria, 201);
    }

    public function show(Request $request, CategoriaGasto $categoriaGasto): JsonResponse
    {
        if ($categoriaGasto->user_id !== $request->user()->id) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        return response()->json($categoriaGasto);
    }

    public function update(Request $request, CategoriaGasto $categoriaGasto): JsonResponse
    {
        if ($categoriaGasto->user_id !== $request->user()->id) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        $validated = $request->validate([
            'nombre' => 'string|max:255|unique:categorias_gasto,nombre,' . $categoriaGasto->id,
        ]);

        $categoriaGasto->update($validated);

        return response()->json($categoriaGasto);
    }

    public function destroy(Request $request, CategoriaGasto $categoriaGasto): JsonResponse
    {
        if ($categoriaGasto->user_id !== $request->user()->id) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        $categoriaGasto->delete();

        return response()->json(['message' => 'Categoría eliminada correctamente']);
    }
}
