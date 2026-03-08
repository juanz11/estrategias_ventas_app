<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Ingreso;
use App\Models\Gasto;
use App\Models\CategoriaGasto;
use App\Models\Deuda;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Crear usuario de prueba
        $user = User::create([
            'name' => 'Admin',
            'email' => 'admin@example.com',
            'password' => Hash::make('admin123'),
        ]);

        // Crear categorías de gastos
        $categorias = ['Hogar', 'Transporte', 'Alimentación', 'Entretenimiento', 'Salud'];
        foreach ($categorias as $categoria) {
            CategoriaGasto::create([
                'user_id' => $user->id,
                'nombre' => $categoria,
            ]);
        }

        // Crear ingresos de presupuesto
        Ingreso::create([
            'user_id' => $user->id,
            'etiqueta' => 'Salario mensual',
            'tipo' => 'fija',
            'monto' => 5000.00,
            'mes' => '2026-03-01',
            'es_presupuesto' => true,
        ]);

        Ingreso::create([
            'user_id' => $user->id,
            'etiqueta' => 'Freelance',
            'tipo' => 'variable',
            'monto' => 1500.00,
            'mes' => '2026-03-01',
            'es_presupuesto' => true,
        ]);

        // Crear ingresos reales
        Ingreso::create([
            'user_id' => $user->id,
            'etiqueta' => 'Salario mensual',
            'tipo' => 'fija',
            'monto' => 5000.00,
            'mes' => '2026-03-01',
            'es_presupuesto' => false,
        ]);

        Ingreso::create([
            'user_id' => $user->id,
            'etiqueta' => 'Proyecto freelance',
            'tipo' => 'variable',
            'monto' => 2080.00,
            'mes' => '2026-03-01',
            'es_presupuesto' => false,
        ]);

        // Crear gastos de presupuesto
        Gasto::create([
            'user_id' => $user->id,
            'categoria' => 'Hogar',
            'sub_categoria' => 'Renta',
            'monto' => 1500.00,
            'es_fijo' => true,
            'pago_con_tarjeta' => false,
            'gasto_hormiga' => false,
            'periodicidad' => 'mensual',
            'mes' => '2026-03-01',
            'es_presupuesto' => true,
        ]);

        Gasto::create([
            'user_id' => $user->id,
            'categoria' => 'Transporte',
            'sub_categoria' => 'Gasolina',
            'monto' => 500.00,
            'es_fijo' => false,
            'pago_con_tarjeta' => true,
            'gasto_hormiga' => false,
            'periodicidad' => 'mensual',
            'mes' => '2026-03-01',
            'es_presupuesto' => true,
        ]);

        // Crear gastos reales
        Gasto::create([
            'user_id' => $user->id,
            'categoria' => 'Hogar',
            'sub_categoria' => 'Renta',
            'monto' => 1500.00,
            'es_fijo' => true,
            'pago_con_tarjeta' => false,
            'gasto_hormiga' => false,
            'periodicidad' => 'mensual',
            'mes' => '2026-03-01',
            'es_presupuesto' => false,
        ]);

        Gasto::create([
            'user_id' => $user->id,
            'categoria' => 'Alimentación',
            'sub_categoria' => 'Supermercado',
            'monto' => 800.00,
            'es_fijo' => false,
            'pago_con_tarjeta' => true,
            'gasto_hormiga' => false,
            'periodicidad' => 'mensual',
            'mes' => '2026-03-01',
            'es_presupuesto' => false,
        ]);

        Gasto::create([
            'user_id' => $user->id,
            'categoria' => 'Transporte',
            'sub_categoria' => 'Gasolina',
            'monto' => 450.00,
            'es_fijo' => false,
            'pago_con_tarjeta' => true,
            'gasto_hormiga' => false,
            'periodicidad' => 'mensual',
            'mes' => '2026-03-01',
            'es_presupuesto' => false,
        ]);

        // Crear deudas
        Deuda::create([
            'user_id' => $user->id,
            'concepto' => 'Préstamo personal',
            'monto' => 5000.00,
            'fecha' => '2026-03-15',
            'tipo' => 'por_pagar',
        ]);

        Deuda::create([
            'user_id' => $user->id,
            'concepto' => 'Pago de cliente',
            'monto' => 2000.00,
            'fecha' => '2026-03-20',
            'tipo' => 'por_cobrar',
        ]);

        Deuda::create([
            'user_id' => $user->id,
            'concepto' => 'Tarjeta de crédito',
            'monto' => 1200.00,
            'fecha' => today(),
            'tipo' => 'por_pagar',
        ]);
    }
}
