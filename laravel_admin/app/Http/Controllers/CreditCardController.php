<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Order;
use App\Models\Payment;

use App\Models\CreditCard;
use Illuminate\Support\Facades\Hash;

class CreditCardController extends Controller
{
  /**
   * Display a listing of the resource.
   *
   * @return \Illuminate\Http\Response
   */

  public function updatedriver($id)
  {

    User::findOrFail($id)->update($request->all());

    $result = "Driver Updated";

    return json_custom_response($result);
  }

  public function getSingleDriverData($id)
  {
    $getuserdata = User::findOrFail($id);

    return json_custom_response($getuserdata);
  }


  public function allorders($id)
  {

    $getUserOrder =  Order::where("delivery_man_id", $id)->get();




    return json_custom_response($getUserOrder);
  }




  public function getdriverbydateid($id, $date1, $date2)
  {

    $getUserFilter = Order::where("delivery_man_id", $id)->where("created_at", ">", $date1)->where("created_at", "<", $date2)->get();



    return json_custom_response($getUserFilter);
  }



  public function driverSearch($username)
  {

    $getUserFilter = User::where("user_type", "delivery_man")->where("name", 'like', '%' . $username . '%')->get();



    return json_custom_response($getUserFilter);
  }


  public function driverSearchByPlate($id_no)
  {

    $getUserFilter = User::where("user_type", "delivery_man")->where("id_no", 'like', '%' . $id_no . '%')->get();



    return json_custom_response($getUserFilter);
  }


  public function searchusers($username)
  {


    $getUserFilter = User::where("user_type", "client")->where("name", 'like', '%' . $username . '%')->get();

    return json_custom_response($getUserFilter);
  }

  public function allusers()
  {

    $getAllUsers = User::where("user_type", "client")->with('order')->get();

    return json_custom_response($getAllUsers);
  }

  public function getdriverbydate($date1, $date2)
  {

    $getUserFilter = User::where("user_type", "delivery_man")->where("created_at", ">", $date1)->where("created_at", "<", $date2)->with('order')->get();



    return json_custom_response($getUserFilter);
  }



  public function getusersbydate($date1, $date2)
  {

    $getUserFilter = User::where("user_type", "client")->where("created_at", ">", $date1)->where("created_at", "<", $date2)->with('order')->get();



    return json_custom_response($getUserFilter);
  }



  public function getdriveramount()
  {
    $getAllDriver = User::where("user_type", "delivery_man")->with('deliveryManOrder')->get();





    return json_custom_response($getAllDriver);
  }




  public function index($id)

  {
    $getUser = User::find($id);

    $getCreditCard = $getUser->creditCard;


    return  response()->json($getCreditCard);
  }




  /**
   * Show the form for creating a new resource.
   *
   * @return \Illuminate\Http\Response
   */
  public function create()
  {
    //
  }

  /**
   * Store a newly created resource in storage.
   *
   * @param  \Illuminate\Http\Request  $request
   * @return \Illuminate\Http\Response
   */
  public function store(Request $request)
  {
    $data = [
      "cardholder" => $request->cardholder,
      "expireddate" => $request->expireddate,
      "ccv" => $request->cvv,
      "number" => Hash::make($request->number),
      "user_id" => $request->user_id,
    ];

    CreditCard::create($data);


    $result = "Credit Card Saved";

    return json_custom_response($result);
  }

  /**
   * Display the specified resource.
   *
   * @param  int  $id
   * @return \Illuminate\Http\Response
   */
  public function show($id)
  {
    //
  }

  /**
   * Show the form for editing the specified resource.
   *
   * @param  int  $id
   * @return \Illuminate\Http\Response
   */
  public function edit($id)
  {
    //
  }

  /**
   * Update the specified resource in storage.
   *
   * @param  \Illuminate\Http\Request  $request
   * @param  int  $id
   * @return \Illuminate\Http\Response
   */
  public function update(Request $request, $id)
  {
    $getCreditCard =  CreditCard::findOrFail($id)->update($request->all());



    $result = "Credit Card Updated";


    return json_custom_response($result);
  }

  /**
   * Remove the specified resource from storage.
   *
   * @param  int  $id
   * @return \Illuminate\Http\Response
   */
  public function destroy($id)
  {
    CreditCard::destroy($id);


    $result = "Credit Card Deleted";

    return json_custom_response($result);
  }


  public function getuser($id)
  {
    $getUser = User::findOrFail($id);

    return json_custom_response($getUser);
  }

  public function searchdrivers($id, $search)
  {
    $getUser = Order::where("delivery_man_id", $id)->whereMonth("created_at", $search)->get();

    return json_custom_response($getUser);
  }
}
