<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;//
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\CustomerController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\AppointmentController;
use App\Http\Controllers\Api\EventRegistrationController;





Route::get('/test', function (Request $request) {
    return response()->json(['message' => 'API is working']);
});

Route::apiResource('customers', CustomerController::class);

Route::apiResource('orders', OrderController::class);

//Route::apiResource('appointments', AppointmentController::class);
Route::get('/appointments', [AppointmentController::class, 'index']);
Route::post('/appointments', [AppointmentController::class, 'store']);
Route::put('/appointments/{id}', [AppointmentController::class, 'update']);
Route::delete('/appointments/{id}', [AppointmentController::class, 'destroy']);
Route::get('/customers/{customerId}/appointments', [AppointmentController::class, 'getByCustomer']);


Route::apiResource('event-registrations', EventRegistrationController::class);

Route::post('/login', function (Request $request) {
    $credentials = $request->only('email', 'password');

    if (Auth::attempt($credentials)) {
        $user = Auth::user();
        return response()->json([
            'message' => 'Login successful',
            'user' => $user
        ]);
    }

    return response()->json([
        'message' => 'Invalid credentials'
    ], 401);
});


