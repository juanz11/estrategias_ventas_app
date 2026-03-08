<?php

namespace App\Http\Controllers;

use App\Models\Deuda;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class DeudaController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Deuda::where('user_id', $request->user()->id);

        // Filtros opcionales
        if ($request->has('tipo')) {
            $query->where('tipo', $request->tipo);
        }

        $deudas = $query->orderBy('fecha', 'asc')->get();

        return response()->json($deudas);
    }

    public function vencidasHoy(Request $request): JsonResponse
    {
        $deudas = Deuda::where('user_id', $request->user()->id)
            ->vencidasHoy()
            ->get();

        return response()->json($deudas);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'concepto' => 'required|string|max:255',
            'monto' => 'required|numeric|min:0',
            'fecha' => 'required|date',
            'tipo' => 'required|in:por_pagar,por_cobrar',
        ]);

        $validated['user_id'] = $request->user()->id;

        $deuda = Deuda::create($validated);

        return response()->json($deuda, 201);
    }

    public function show(Request $request, Deuda $deuda): JsonResponse
    {
        if ($deuda->user_id !== $request->user()->id) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        return response()->json($deuda);
    }

    public function update(Request $request, Deuda $deuda): JsonResponse
    {
        if ($deuda->user_id !== $request->user()->id) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        $validated = $request->validate([
            'concepto' => 'string|max:255',
            'monto' => 'numeric|min:0',
            'fecha' => 'date',
            'tipo' => 'in:por_pagar,por_cobrar',
        ]);

        $deuda->update($validated);

        return response()->json($deuda);
    }

    public function destroy(Request $request, Deuda $deuda): JsonResponse
    {
        if ($deuda->user_id !== $request->user()->id) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        $deuda->delete();

        return response()->json(['message' => 'Deuda eliminada correctamente']);
    }
}
