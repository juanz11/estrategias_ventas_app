<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\IngresoController;
use App\Http\Controllers\GastoController;
use App\Http\Controllers\CategoriaGastoController;
use App\Http\Controllers\DeudaController;

// Rutas públicas de autenticación
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Rutas protegidas con autenticación
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    // Ingresos
    Route::apiResource('ingresos', IngresoController::class);

    // Gastos
    Route::apiResource('gastos', GastoController::class);
    Route::delete('/gastos/{gasto}/archivo', [GastoController::class, 'eliminarArchivo']);

    // Categorías de gastos
    Route::apiResource('categorias-gasto', CategoriaGastoController::class);

    // Deudas
    Route::apiResource('deudas', DeudaController::class);
    Route::get('/deudas-vencidas-hoy', [DeudaController::class, 'vencidasHoy']);
    Route::delete('/deudas/{deuda}/archivo', [DeudaController::class, 'eliminarArchivo']);
});
