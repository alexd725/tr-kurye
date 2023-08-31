<?php

namespace App\Http\Resources\API;

use Illuminate\Http\Resources\Json\JsonResource;

class DeliveryManEarningResource extends JsonResource
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
            'wallet_balance'    => $this->wallet_balance,
            'total_withdrawn'   => $this->total_withdrawn,
            'admin_commission'  => $this->admin_commission,
            'delivery_man_commission' => $this->delivery_man_commission,
            'total_order'       => $this->total_order,
            'paid_order'        => $this->paid_order,
        ];
    }
}