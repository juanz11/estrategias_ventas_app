<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Ingreso extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'etiqueta',
        'tipo',
        'monto',
        'mes',
        'es_presupuesto',
    ];

    protected $casts = [
        'monto' => 'decimal:2',
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
}
