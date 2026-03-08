<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ingresos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('etiqueta');
            $table->enum('tipo', ['fija', 'variable', 'sin_especificar'])->default('sin_especificar');
            $table->decimal('monto', 10, 2);
            $table->date('mes');
            $table->boolean('es_presupuesto')->default(false); // true = presupuesto, false = real
            $table->timestamps();

            $table->index(['user_id', 'mes']);
            $table->index(['user_id', 'es_presupuesto']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ingresos');
    }
};
