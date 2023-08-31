<?php

namespace App\Http\Resources\API;

use Illuminate\Http\Resources\Json\JsonResource;

class CityResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array|\Illuminate\Contracts\Support\Arrayable|\JsonSerializable
     */
    public function toArray($request)
    {
        return [
            'id'                => $this->id,
            'name'              => $this->name,
            'address'           => $this->address,
            'vehicle_type'      => $this->vehicle_type,
            'order_type'        => $this->order_type,
            'country_id'        => $this->country_id,
            'country_name'      => optional($this->country)->name,
            'country'           => $this->country,
            'status'            => $this->status,
            'fixed_charges'     => $this->fixed_charges,
            'extra_charges'     => $this->extraChargesActive,
            'cancel_charges'    => $this->cancel_charges,
            'min_distance'      => $this->min_distance,
            'min_weight'        => $this->min_weight,
            'max_distance'      => $this->max_distance,
            'max_weight'        => $this->max_weight,
            'per_distance_charges' => $this->per_distance_charges,
            'per_weight_charges' => $this->per_weight_charges,
            'charge_per_address' => $this->charge_per_address,
            'created_at'         => $this->created_at,
            'updated_at'         => $this->updated_at,
            'deleted_at'         => $this->deleted_at,
            'commission_type'    => $this->commission_type,
            'admin_commission'   => $this->admin_commission,
        ];
    }
}
