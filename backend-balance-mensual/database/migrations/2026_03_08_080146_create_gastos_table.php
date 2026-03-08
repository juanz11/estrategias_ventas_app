<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('gastos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('categoria');
            $table->string('sub_categoria');
            $table->decimal('monto', 10, 2);
            $table->boolean('es_fijo')->default(false);
            $table->boolean('pago_con_tarjeta')->default(false);
            $table->boolean('gasto_hormiga')->default(false);
            $table->enum('periodicidad', ['mensual', 'quincenal', 'semanal', 'diario'])->default('mensual');
            $table->date('mes');
            $table->boolean('es_presupuesto')->default(false); // true = presupuesto, false = real
            $table->timestamps();

            $table->index(['user_id', 'mes']);
            $table->index(['user_id', 'categoria']);
            $table->index(['user_id', 'es_presupuesto']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('gastos');
    }
};
