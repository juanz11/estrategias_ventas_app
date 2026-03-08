<?php

namespace App\Http\Controllers;

use App\Models\Ingreso;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class IngresoController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Ingreso::where('user_id', $request->user()->id);

        // Filtros opcionales
        if ($request->has('es_presupuesto')) {
            $query->where('es_presupuesto', $request->boolean('es_presupuesto'));
        }

        if ($request->has('year') && $request->has('month')) {
            $query->delMes($request->year, $request->month);
        }

        $ingresos = $query->orderBy('mes', 'desc')->get();

        return response()->json($ingresos);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'etiqueta' => 'required|string|max:255',
            'tipo' => 'required|in:fija,variable,sin_especificar',
            'monto' => 'required|numeric|min:0',
            'mes' => 'required|date',
            'es_presupuesto' => 'boolean',
        ]);

        $validated['user_id'] = $request->user()->id;

        $ingreso = Ingreso::create($validated);

        return response()->json($ingreso, 201);
    }

    public function show(Request $request, Ingreso $ingreso): JsonResponse
    {
        if ($ingreso->user_id !== $request->user()->id) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        return response()->json($ingreso);
    }

    public function update(Request $request, Ingreso $ingreso): JsonResponse
    {
        if ($ingreso->user_id !== $request->user()->id) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        $validated = $request->validate([
            'etiqueta' => 'string|max:255',
            'tipo' => 'in:fija,variable,sin_especificar',
            'monto' => 'numeric|min:0',
            'mes' => 'date',
            'es_presupuesto' => 'boolean',
        ]);

        $ingreso->update($validated);

        return response()->json($ingreso);
    }

    public function destroy(Request $request, Ingreso $ingreso): JsonResponse
    {
        if ($ingreso->user_id !== $request->user()->id) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        $ingreso->delete();

        return response()->json(['message' => 'Ingreso eliminado correctamente']);
    }
}
