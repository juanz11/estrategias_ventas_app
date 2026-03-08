<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CategoriaGasto extends Model
{
    use HasFactory;

    protected $table = 'categorias_gasto';

    protected $fillable = [
        'user_id',
        'nombre',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
