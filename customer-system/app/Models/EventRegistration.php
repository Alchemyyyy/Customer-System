<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EventRegistration extends Model
{
    protected $fillable = ['customer_id', 'event_name', 'event_date'];

    public function customer() {
        return $this->belongsTo(Customer::class);
    }
}
