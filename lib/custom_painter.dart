import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'dart:ui';

import 'models/farm.dart';
import 'models/grid.dart';
import 'utils/config.dart';

class FarmPoly extends CustomPainter {
  late Farm farm;
  late List<Grid> grid;
  late bool update;
  double maxLat = 0;
  double maxLng = 0;
  double minLat = 1000;
  double minLng = 1000;

  FarmPoly(this.farm, this.grid, this.update);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.green
      ..isAntiAlias = true;

    maxLat = farm.markers
        .reduce((value, element) =>
            value.latitude > element.latitude ? value : element)
        .latitude;
    minLat = farm.markers
        .reduce((value, element) =>
            value.latitude < element.latitude ? value : element)
        .latitude;
    maxLng = farm.markers
        .reduce((value, element) =>
            value.longitude > element.longitude ? value : element)
        .longitude;
    minLng = farm.markers
        .reduce((value, element) =>
            value.longitude < element.longitude ? value : element)
        .longitude;
    //Log.log(Log.TAG_RENDER, "Size $size", Log.I);
    //Log.log(Log.TAG_RENDER, "Lat $minLat $maxLat", Log.I);
    //Log.log(Log.TAG_RENDER, "Lng $minLng $maxLng", Log.I);
    var path1 = Path();
    path1.moveTo(getCoordinateLat(farm.markers[0], size),
        getCoordinateLng(farm.markers[0], size));
    for (int i = 1; i < farm.markers.length; i++) {
      var e = farm.markers[i];
      path1.lineTo(getCoordinateLat(e, size), getCoordinateLng(e, size));
    }
    path1.lineTo(getCoordinateLat(farm.markers[0], size),
        getCoordinateLng(farm.markers[0], size));
    canvas.drawPath(path1, paint);
    var paintO = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Color.fromARGB(100, 255, 255, 255)
      ..isAntiAlias = true;
    var paintB = Paint()
      ..style = PaintingStyle.fill
      ..color = Color.fromARGB(90, 158, 158, 158)
      ..isAntiAlias = true;
    for (var g in grid) {
      var path2 = Path();
      path2.moveTo(
          getCoordinateLat(g.tp_l, size), getCoordinateLng(g.tp_l, size));
      path2.lineTo(
          getCoordinateLat(g.tp_r, size), getCoordinateLng(g.tp_r, size));
      path2.lineTo(
          getCoordinateLat(g.bt_r, size), getCoordinateLng(g.bt_r, size));
      path2.lineTo(
          getCoordinateLat(g.bt_l, size), getCoordinateLng(g.bt_l, size));
      path2.lineTo(
          getCoordinateLat(g.tp_l, size), getCoordinateLng(g.tp_l, size));
      switch (g.pred) {
        case 1:
          paintB.color = Color.fromARGB(206, 237, 163, 25);
          break;
        case 0:
          paintB.color = Color.fromARGB(205, 76, 175, 79);
          break;
        default:
          paintB.color = const Color.fromARGB(90, 158, 158, 158);
          break;
      }
      canvas.drawPath(path2, paintB);
      canvas.drawPath(path2, paintO);
    }
  }

  double getCoordinateLat(ll.LatLng value, Size size) {
    var d_lat = value.latitude - minLat;
    var element = maxLat - minLat;
    var percent = d_lat / element;
    return percent * size.width;
  }

  double getCoordinateLng(ll.LatLng value, Size size) {
    var d_lng = value.longitude - minLng;
    var element = maxLng - minLng;
    var percent = d_lng / element;
    return percent * size.height;
  }

  @override
  bool shouldRepaint(FarmPoly oldDelegate) {
    return farm.name != oldDelegate.farm.name ||
        grid.length != oldDelegate.grid.length ||
        update;
  }
}
