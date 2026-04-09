<?php

namespace App\Http\Controllers;

use App\Models\Gasto;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;

class GastoController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Gasto::where('user_id', $request->user()->id);

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

        return response()->json($gastos->map(fn($g) => $this->formatGasto($g)));
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'categoria'       => 'required|string|max:255',
            'sub_categoria'   => 'required|string|max:255',
            'monto'           => 'required|numeric|min:0',
            'es_fijo'         => 'boolean',
            'pago_con_tarjeta'=> 'boolean',
            'gasto_hormiga'   => 'boolean',
            'periodicidad'    => 'required|in:mensual,quincenal,semanal,diario,trimestral,anual,bimestral,semestral',
            'mes'             => 'required|date',
            'es_presupuesto'  => 'boolean',
            'archivo'         => 'nullable|file|mimes:jpg,jpeg,png,pdf|max:5120',
        ]);

        $validated['user_id'] = $request->user()->id;

        if ($request->hasFile('archivo')) {
            $file = $request->file('archivo');
            $path = $file->store('gastos', 'public');
            $validated['archivo_path']   = $path;
            $validated['archivo_nombre'] = $file->getClientOriginalName();
            $validated['archivo_tipo']   = str_starts_with($file->getMimeType(), 'image') ? 'image' : 'pdf';
        }

        $gasto = Gasto::create($validated);

        return response()->json($this->formatGasto($gasto), 201);
    }

    public function show(Request $request, Gasto $gasto): JsonResponse
    {
        if ($gasto->user_id !== $request->user()->id) {
            return response()->json(['message' => 'No autorizado'], 403);
        }
        return response()->json($this->formatGasto($gasto));
    }

    public function update(Request $request, Gasto $gasto): JsonResponse
    {
        if ($gasto->user_id !== $request->user()->id) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        $validated = $request->validate([
            'categoria'       => 'string|max:255',
            'sub_categoria'   => 'string|max:255',
            'monto'           => 'numeric|min:0',
            'es_fijo'         => 'boolean',
            'pago_con_tarjeta'=> 'boolean',
            'gasto_hormiga'   => 'boolean',
            'periodicidad'    => 'in:mensual,quincenal,semanal,diario,trimestral,anual,bimestral,semestral',
            'mes'             => 'date',
            'es_presupuesto'  => 'boolean',
            'archivo'         => 'nullable|file|mimes:jpg,jpeg,png,pdf|max:5120',
        ]);

        if ($request->hasFile('archivo')) {
            if ($gasto->archivo_path) {
                Storage::disk('public')->delete($gasto->archivo_path);
            }
            $file = $request->file('archivo');
            $path = $file->store('gastos', 'public');
            $validated['archivo_path']   = $path;
            $validated['archivo_nombre'] = $file->getClientOriginalName();
            $validated['archivo_tipo']   = str_starts_with($file->getMimeType(), 'image') ? 'image' : 'pdf';
        }

        $gasto->update($validated);

        return response()->json($this->formatGasto($gasto));
    }

    public function destroy(Request $request, Gasto $gasto): JsonResponse
    {
        if ($gasto->user_id !== $request->user()->id) {
            return response()->json(['message' => 'No autorizado'], 403);
        }
        if ($gasto->archivo_path) {
            Storage::disk('public')->delete($gasto->archivo_path);
        }
        $gasto->delete();
        return response()->json(['message' => 'Gasto eliminado correctamente']);
    }

    public function eliminarArchivo(Request $request, Gasto $gasto): JsonResponse
    {
        if ($gasto->user_id !== $request->user()->id) {
            return response()->json(['message' => 'No autorizado'], 403);
        }
        if ($gasto->archivo_path) {
            Storage::disk('public')->delete($gasto->archivo_path);
        }
        $gasto->update(['archivo_path' => null, 'archivo_nombre' => null, 'archivo_tipo' => null]);
        return response()->json($this->formatGasto($gasto));
    }

    private function formatGasto(Gasto $gasto): array
    {
        $data = $gasto->toArray();
        $data['archivo_url'] = $gasto->archivo_path
            ? asset('storage/' . $gasto->archivo_path)
            : null;
        return $data;
    }
}

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
            'periodicidad' => 'required|in:mensual,quincenal,semanal,diario,trimestral,anual,bimestral,semestral',
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
            'periodicidad' => 'in:mensual,quincenal,semanal,diario,trimestral,anual,bimestral,semestral',
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
