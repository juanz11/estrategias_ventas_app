<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // SQLite no soporta ALTER COLUMN, así que usamos una estrategia compatible
        // Guardamos los datos, recreamos la columna y restauramos

        if (DB::getDriverName() === 'sqlite') {
            // En SQLite: recrear tabla con nueva definición
            Schema::table('gastos', function (Blueprint $table) {
                $table->string('periodicidad_new')->default('mensual');
            });

            DB::statement('UPDATE gastos SET periodicidad_new = periodicidad');

            Schema::table('gastos', function (Blueprint $table) {
                $table->dropColumn('periodicidad');
            });

            Schema::table('gastos', function (Blueprint $table) {
                $table->renameColumn('periodicidad_new', 'periodicidad');
            });
        } else {
            // MySQL: modificar directamente
            DB::statement("ALTER TABLE gastos MODIFY COLUMN periodicidad ENUM('mensual','quincenal','semanal','diario','trimestral','bimestral','semestral','anual') NOT NULL DEFAULT 'mensual'");
        }
    }

    public function down(): void
    {
        if (DB::getDriverName() === 'sqlite') {
            Schema::table('gastos', function (Blueprint $table) {
                $table->string('periodicidad_old')->default('mensual');
            });
            DB::statement('UPDATE gastos SET periodicidad_old = periodicidad');
            Schema::table('gastos', function (Blueprint $table) {
                $table->dropColumn('periodicidad');
            });
            Schema::table('gastos', function (Blueprint $table) {
                $table->renameColumn('periodicidad_old', 'periodicidad');
            });
        } else {
            DB::statement("ALTER TABLE gastos MODIFY COLUMN periodicidad ENUM('mensual','quincenal','semanal','diario') NOT NULL DEFAULT 'mensual'");
        }
    }
};
