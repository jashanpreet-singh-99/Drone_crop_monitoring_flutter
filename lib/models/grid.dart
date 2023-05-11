import 'dart:convert';

import 'package:latlong2/latlong.dart';

import '../utils/config.dart';

class Grid {
  int id = -1;
  String grid;
  LatLng tp_l;
  LatLng tp_r;
  LatLng bt_r;
  LatLng bt_l;
  int pred;

  Grid._(
      {required this.id,
      required this.grid,
      required this.tp_l,
      required this.tp_r,
      required this.bt_r,
      required this.bt_l,
      required this.pred});
  Grid(this.id, this.grid, this.tp_l, this.tp_r, this.bt_r, this.bt_l,
      this.pred);

  static LatLng getLatLng(String val) {
    val = val.substring(1, val.length - 1);
    var tmp = val.split(',');
    //Log.log(Log.TAG_RENDER, "E : " + val, Log.E);
    return LatLng(double.tryParse(tmp[0])!, double.tryParse(tmp[1])!);
  }

  factory Grid.fromJson(Map<String, dynamic> json_d) {
    LatLng tp_l = getLatLng(json_d['tp_l']);
    LatLng tp_r = getLatLng(json_d['tp_r']);
    LatLng bt_r = getLatLng(json_d['bt_r']);
    LatLng bt_l = getLatLng(json_d['bt_l']);
    return Grid._(
        id: json_d['farm_id'],
        grid: json_d['grid_id'],
        tp_l: tp_l,
        tp_r: tp_r,
        bt_r: bt_r,
        bt_l: bt_l,
        pred: json_d['pred']);
  }
}
