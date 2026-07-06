<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsOwner
{
    public function handle(Request $request, Closure $next): Response
    {
        if (!$request->user()?->isOwner()) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak. Hanya owner yang boleh melakukan aksi ini.',
            ], 403);
        }

        return $next($request);
    }
}