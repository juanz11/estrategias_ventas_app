<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('gastos', function (Blueprint $table) {
            $table->string('archivo_path')->nullable()->after('es_presupuesto');
            $table->string('archivo_nombre')->nullable()->after('archivo_path');
            $table->string('archivo_tipo')->nullable()->after('archivo_nombre');
        });
    }

    public function down(): void
    {
        Schema::table('gastos', function (Blueprint $table) {
            $table->dropColumn(['archivo_path', 'archivo_nombre', 'archivo_tipo']);
        });
    }
};
