<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckRole
{
    public function handle($request, Closure $next, $role)
    {
        // Cek apakah user yang login punya role yang sesuai
        if ($request->user() && $request->user()->role !== $role) {
            return response()->json(['message' => 'Akses ditolak! Khusus Admin.'], 403);
        }

        return $next($request);
    }
}
