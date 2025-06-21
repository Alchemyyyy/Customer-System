<?php

namespace App\Models;

    use Illuminate\Database\Eloquent\Factories\HasFactory;
    use Illuminate\Database\Eloquent\Model;

    class Appointment extends Model
    {
        use HasFactory;

        protected $fillable = [
            'customer_id',
            'appointment_date',
            'appointment_time',
            'service',
        ];

        public function customer()
        {
            return $this->belongsTo(Customer::class);
        }
    }

