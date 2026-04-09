<?php

namespace App\Http\Controllers;

use App\Models\Deuda;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;

class DeudaController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Deuda::where('user_id', $request->user()->id);

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
            'monto'    => 'required|numeric|min:0',
            'fecha'    => 'required|date',
            'tipo'     => 'required|in:por_pagar,por_cobrar',
            'archivo'  => 'nullable|file|mimes:jpg,jpeg,png,pdf|max:5120', // 5MB max
        ]);

        $validated['user_id'] = $request->user()->id;

        if ($request->hasFile('archivo')) {
            $file = $request->file('archivo');
            $path = $file->store('deudas/' . $request->user()->id, 'public');
            $validated['archivo_path']   = $path;
            $validated['archivo_nombre'] = $file->getClientOriginalName();
            $validated['archivo_tipo']   = str_contains($file->getMimeType(), 'pdf') ? 'pdf' : 'image';
        }

        unset($validated['archivo']);
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
            'monto'    => 'numeric|min:0',
            'fecha'    => 'date',
            'tipo'     => 'in:por_pagar,por_cobrar',
            'archivo'  => 'nullable|file|mimes:jpg,jpeg,png,pdf|max:5120',
        ]);

        if ($request->hasFile('archivo')) {
            // Eliminar archivo anterior si existe
            if ($deuda->archivo_path) {
                Storage::disk('public')->delete($deuda->archivo_path);
            }
            $file = $request->file('archivo');
            $path = $file->store('deudas/' . $request->user()->id, 'public');
            $validated['archivo_path']   = $path;
            $validated['archivo_nombre'] = $file->getClientOriginalName();
            $validated['archivo_tipo']   = str_contains($file->getMimeType(), 'pdf') ? 'pdf' : 'image';
        }

        unset($validated['archivo']);
        $deuda->update($validated);

        return response()->json($deuda);
    }

    public function destroy(Request $request, Deuda $deuda): JsonResponse
    {
        if ($deuda->user_id !== $request->user()->id) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        // Eliminar archivo si existe
        if ($deuda->archivo_path) {
            Storage::disk('public')->delete($deuda->archivo_path);
        }

        $deuda->delete();

        return response()->json(['message' => 'Deuda eliminada correctamente']);
    }

    public function eliminarArchivo(Request $request, Deuda $deuda): JsonResponse
    {
        if ($deuda->user_id !== $request->user()->id) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        if ($deuda->archivo_path) {
            Storage::disk('public')->delete($deuda->archivo_path);
            $deuda->update([
                'archivo_path'   => null,
                'archivo_nombre' => null,
                'archivo_tipo'   => null,
            ]);
        }

        return response()->json($deuda);
    }
}
