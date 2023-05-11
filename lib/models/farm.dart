import 'dart:convert';

import 'package:latlong2/latlong.dart';

class Farm {
  int id = -1;
  String name;
  int no_markers;
  List<LatLng> markers;

  Farm._(
      {required this.id,
      required this.name,
      required this.no_markers,
      required this.markers});
  Farm(this.id, this.name, this.no_markers, this.markers);

  factory Farm.fromJson(Map<String, dynamic> json_d) {
    List<String> list = json.decode(json_d['marker']).cast<String>().toList();
    List<LatLng> val = [];
    for (var element in list) {
      var tmp = element.split(',');
      val.add(LatLng(double.tryParse(tmp[0])!, double.tryParse(tmp[1])!));
    }
    return Farm._(
      id: json_d['farm_id'],
      name: json_d['name'],
      no_markers: json_d['no_markers'],
      markers: val,
    );
  }
}
