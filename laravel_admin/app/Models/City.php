<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class City extends Model
{
    use HasFactory;
    use SoftDeletes;

    protected $fillable = ['country_id', 'name', 'vehicle_type', 'order_type', 'address', 'fixed_charges', 'cancel_charges', 'min_distance', 'min_weight', 'max_distance', 'max_weight', 'per_distance_charges', 'per_weight_charges', 'charge_per_address', 'status', 'commission_type', 'admin_commission'];


    protected $casts = [
        'country_id' => 'integer',
        'vehicle_type' => 'string',
        'order_type' => 'string',
        'fixed_charges' => 'double',
        'cancel_charges' => 'double',
        'min_distance' => 'double',
        'min_weight' => 'double',
        'max_distance' => 'double',
        'max_weight' => 'double',
        'per_distance_charges' => 'double',
        'per_weight_charges' => 'double',
        'charge_per_address' => 'double',
        'status' => 'integer',
        'admin_commission' => 'double',
    ];

    public function country()
    {
        return $this->belongsTo(Country::class, 'country_id', 'id');
    }

    public function extraCharges()
    {
        return $this->hasMany(ExtraCharge::class, 'city_id', 'id');
    }

    public function extraChargesActive()
    {
        return $this->extraCharges()->where('status', 1);
    }

    protected static function boot()
    {
        parent::boot();
        static::deleted(function ($row) {
            $row->extraCharges()->delete();
            if ($row->forceDeleting === true) {
                $row->extraCharges()->forceDelete();
            }
        });
        static::restoring(function ($row) {
            $row->extraCharges()->withTrashed()->restore();
        });
    }
}
