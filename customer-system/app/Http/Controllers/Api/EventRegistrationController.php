<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\EventRegistration;

class EventRegistrationController extends Controller
{
    public function index()
    {
        return EventRegistration::all();
    }

    public function store(Request $request)
    {
        $request->validate([
            'customer_id' => 'required|exists:customers,id',
            'event_name' => 'required|string',
            'event_date' => 'required|date',
        ]);

        return EventRegistration::create($request->all());
    }

    public function show($id)
    {
        return EventRegistration::findOrFail($id);
    }

    public function update(Request $request, $id)
    {
        $event = EventRegistration::findOrFail($id);
        $event->update($request->all());

        return $event;
    }

    public function destroy($id)
    {
        return EventRegistration::destroy($id);
    }
}
