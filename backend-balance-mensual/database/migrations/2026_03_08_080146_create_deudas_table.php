<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('deudas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('concepto');
            $table->decimal('monto', 10, 2);
            $table->date('fecha');
            $table->enum('tipo', ['por_pagar', 'por_cobrar']);
            $table->timestamps();

            $table->index(['user_id', 'tipo']);
            $table->index(['user_id', 'fecha']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('deudas');
    }
};
