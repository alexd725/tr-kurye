class CalculateDistanceModel {
  List<String>? destinationAddresses;
  List<String>? originAddresses;
  List<Row>? rows;
  String? status;
  String? errorMsg;

  CalculateDistanceModel(
      {this.destinationAddresses,
      this.originAddresses,
      this.rows,
      this.status,
      this.errorMsg});

  factory CalculateDistanceModel.fromJson(Map<String, dynamic> json) {
    return CalculateDistanceModel(
      destinationAddresses: json['destination_addresses'] != null
          ? new List<String>.from(json['destination_addresses'])
          : null,
      originAddresses: json['origin_addresses'] != null
          ? new List<String>.from(json['origin_addresses'])
          : null,
      rows: json['rows'] != null
          ? (json['rows'] as List).map((i) => Row.fromJson(i)).toList()
          : null,
      status: json['status'],
      errorMsg: json['error_message'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.destinationAddresses != null) {
      data['destination_addresses'] = this.destinationAddresses;
    }
    if (this.originAddresses != null) {
      data['origin_addresses'] = this.originAddresses;
    }
    if (this.rows != null) {
      data['rows'] = this.rows!.map((v) => v.toJson()).toList();
    }
    if (this.errorMsg != null) {
      data['error_message'] = this.errorMsg;
    }
    return data;
  }
}

class Row {
  List<Element>? elements;

  Row({this.elements});

  factory Row.fromJson(Map<String, dynamic> json) {
    return Row(
      elements: json['elements'] != null
          ? (json['elements'] as List).map((i) => Element.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.elements != null) {
      data['elements'] = this.elements!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


class Element {
  Distance? distance;
  Duration? duration;
  String? status;

  Element({this.distance, this.duration, this.status});

  factory Element.fromJson(Map<String, dynamic> json) {
    return Element(
      distance:
          json['distance'] != null ? Distance.fromJson(json['distance']) : null,
      duration:
          json['duration'] != null ? Duration.fromJson(json['duration']) : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.distance != null) {
      data['distance'] = this.distance!.toJson();
    }
    if (this.duration != null) {
      data['duration'] = this.duration!.toJson();
    }
    return data;
  }
}

class Duration {
  String? text;
  int? value;

  Duration({this.text, this.value});

  factory Duration.fromJson(Map<String, dynamic> json) {
    return Duration(
      text: json['text'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    data['value'] = this.value;
    return data;
  }
}

class Distance {
  String? text;
  int? value;

  Distance({this.text, this.value});

  factory Distance.fromJson(Map<String, dynamic> json) {
    return Distance(
      text: json['text'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    data['value'] = this.value;
    return data;
  }
}
