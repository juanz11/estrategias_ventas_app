<?php

namespace App\Http\Controllers;

use App\Models\Gasto;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class GastoController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Gasto::where('user_id', $request->user()->id);

        // Filtros opcionales
        if ($request->has('es_presupuesto')) {
            $query->where('es_presupuesto', $request->boolean('es_presupuesto'));
        }

        if ($request->has('categoria')) {
            $query->porCategoria($request->categoria);
        }

        if ($request->has('year') && $request->has('month')) {
            $query->delMes($request->year, $request->month);
        }

        $gastos = $query->orderBy('mes', 'desc')->get();

        return response()->json($gastos);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'categoria' => 'required|string|max:255',
            'sub_categoria' => 'required|string|max:255',
            'monto' => 'required|numeric|min:0',
            'es_fijo' => 'boolean',
            'pago_con_tarjeta' => 'boolean',
            'gasto_hormiga' => 'boolean',
            'periodicidad' => 'required|in:mensual,quincenal,semanal,diario',
            'mes' => 'required|date',
            'es_presupuesto' => 'boolean',
        ]);

        $validated['user_id'] = $request->user()->id;

        $gasto = Gasto::create($validated);

        return response()->json($gasto, 201);
    }

    public function show(Request $request, Gasto $gasto): JsonResponse
    {
        if ($gasto->user_id !== $request->user()->id) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        return response()->json($gasto);
    }

    public function update(Request $request, Gasto $gasto): JsonResponse
    {
        if ($gasto->user_id !== $request->user()->id) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        $validated = $request->validate([
            'categoria' => 'string|max:255',
            'sub_categoria' => 'string|max:255',
            'monto' => 'numeric|min:0',
            'es_fijo' => 'boolean',
            'pago_con_tarjeta' => 'boolean',
            'gasto_hormiga' => 'boolean',
            'periodicidad' => 'in:mensual,quincenal,semanal,diario',
            'mes' => 'date',
            'es_presupuesto' => 'boolean',
        ]);

        $gasto->update($validated);

        return response()->json($gasto);
    }

    public function destroy(Request $request, Gasto $gasto): JsonResponse
    {
        if ($gasto->user_id !== $request->user()->id) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        $gasto->delete();

        return response()->json(['message' => 'Gasto eliminado correctamente']);
    }
}
