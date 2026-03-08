<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Deuda extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'concepto',
        'monto',
        'fecha',
        'tipo',
    ];

    protected $casts = [
        'monto' => 'decimal:2',
        'fecha' => 'date',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    // Scopes
    public function scopePorPagar($query)
    {
        return $query->where('tipo', 'por_pagar');
    }

    public function scopePorCobrar($query)
    {
        return $query->where('tipo', 'por_cobrar');
    }

    public function scopeVencidasHoy($query)
    {
        return $query->whereDate('fecha', today());
    }
}
