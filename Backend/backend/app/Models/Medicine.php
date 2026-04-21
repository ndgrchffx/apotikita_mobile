<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Medicine extends Model
{
    use HasFactory;

    // Tambahkan baris ini supaya Laravel izinkan input data
    protected $fillable = ['name', 'category', 'price'];
}
