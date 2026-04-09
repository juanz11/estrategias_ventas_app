<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Gasto extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'categoria',
        'sub_categoria',
        'monto',
        'es_fijo',
        'pago_con_tarjeta',
        'gasto_hormiga',
        'periodicidad',
        'mes',
        'es_presupuesto',
        'archivo_path',
        'archivo_nombre',
        'archivo_tipo',
    ];

    protected $casts = [
        'monto' => 'decimal:2',
        'es_fijo' => 'boolean',
        'pago_con_tarjeta' => 'boolean',
        'gasto_hormiga' => 'boolean',
        'mes' => 'date',
        'es_presupuesto' => 'boolean',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    // Scopes
    public function scopePresupuesto($query)
    {
        return $query->where('es_presupuesto', true);
    }

    public function scopeReal($query)
    {
        return $query->where('es_presupuesto', false);
    }

    public function scopeDelMes($query, $year, $month)
    {
        return $query->whereYear('mes', $year)
                     ->whereMonth('mes', $month);
    }

    public function scopePorCategoria($query, $categoria)
    {
        return $query->where('categoria', $categoria);
    }
}
