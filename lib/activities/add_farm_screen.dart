import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_farm/activities/monitor_screen.dart';
import 'package:web_farm/utils/config.dart';

import 'package:http/http.dart' as http;

class AddFarmScreen extends StatefulWidget {
  const AddFarmScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AddFarmScreen> createState() {
    return _AddFarmScreenState();
  }
}

class _AddFarmScreenState extends State<AddFarmScreen> {
  final mapController = MapController();
  var marker = <Marker>[];
  var farmNameController;

  var polyline = <Polyline>[];

  var polygon = Polygon(points: []);

  var saveColor = Colors.cyan;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  Future<bool> uploadFarmData(String name, List<Marker> mks) async {
    final uri = Config.urlAddFarm;
    final headers = {'Content-Type': 'application/json'};

    var marks = jsonEncode(
        mks.map((e) => ('${e.point.latitude},${e.point.longitude}')).toList());
    Map bData = {'f_name': name, 'points': marks};
    final body = json.encode(bData);

    http.Response response = await http.post(uri, headers: headers, body: body);

    int statusCode = response.statusCode;
    String responseBody = response.body;
    Log.log(Log.TAG_REQUEST, "$statusCode", Log.I);
    Log.log(Log.TAG_REQUEST, responseBody, Log.I);
    if (statusCode == 200) {
      Log.log(Log.TAG_REQUEST, "Farm successfully updated.", Log.I);
      return true;
    }
    return false;
  }

  void handleTap(TapPosition tapPosition, LatLng point) {
    Log.log(Log.TAG_MAP, 'Point $point', Log.I);
    setState(() {
      marker.add(
        Marker(
          point: point,
          builder: (ctx) => Image.asset('assets/marker.png'),
        ),
      );
    });
  }

  void drawLines() {
    polyline.clear();
    if (marker.length < 2) {
      return;
    }
    setState(() {
      for (var i = 1; i < marker.length; i++) {
        polyline.add(Polyline(
          points: [marker[i - 1].point, marker[i].point],
          color: Colors.cyanAccent,
          strokeWidth: 3,
        ));
      }
      polyline.add(Polyline(
        points: [marker[marker.length - 1].point, marker[0].point],
        color: Colors.cyanAccent,
        strokeWidth: 3,
      ));
    });
  }

  void clearLines() {
    setState(() {
      polyline.clear();
      marker.clear();
    });
  }

  void switchToMonitor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MonitorScreen()),
    );
  }

  void saveFarmBtn() {
    Log.log(Log.TAG_MAP, 'Save farm ${farmNameController.text}', Log.I);
    if (farmNameController.text.toString().isEmpty) {
      showErrorDialog('No name provided to the Marker configuration.');
    } else if (marker.length < 3) {
      showErrorDialog(
          'The selected marker doesn\'t form a polygon. Please select at least 3 markers on map.');
    } else {
      uploadFarmData(farmNameController.text.toString(), marker);
      clearLines();
    }
  }

  void showErrorDialog(var text) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            content: Text(text,
                style: const TextStyle(color: Colors.cyan, fontSize: 16)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          );
        });
  }

  Widget buildTextField(String hint, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 15, 0, 10),
      height: 45,
      child: TextField(
        decoration: InputDecoration(
          labelText: hint,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(
              color: Colors.cyan,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(
              color: Colors.black38,
            ),
          ),
        ),
        controller: controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    farmNameController = TextEditingController();
    return Scaffold(
      body: SizedBox(
        child: Stack(
          children: <Widget>[
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                minZoom: 5,
                maxZoom: 18,
                zoom: 18,
                center: Config.myLocation,
                onTap: handleTap,
              ),
              nonRotatedChildren: [
                AttributionWidget.defaultWidget(
                  source: '© Mapbox © OpenStreetMap',
                  onSourceTapped: () async {
                    if (!await launchUrl(Uri.parse(
                        "https://docs.mapbox.com/help/getting-started/attribution/"))) {}
                  },
                ),
              ],
              children: [
                TileLayer(
                  urlTemplate:
                      "https://api.mapbox.com/styles/v1/jashanpreet99/{mapStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}",
                  additionalOptions: const {
                    'mapStyleId': Config.mapBoxStyleId,
                    'accessToken': Config.mapBoxAccessToken,
                  },
                ),
                MarkerLayer(
                  markers: marker,
                ),
                PolylineLayer(
                  polylines: polyline,
                ),
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  children: [
                    SizedBox(
                      width: 200,
                      child: ElevatedButton.icon(
                        onPressed: null,
                        icon: const Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                        style: ButtonStyle(
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.hovered)) {
                                return Colors.black38;
                              }
                              return null;
                            },
                          ),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.cyan),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          )),
                        ),
                        label: const Padding(
                          padding: EdgeInsets.all(14.0),
                          child: Text('Add Farms       ',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(10)),
                    ElevatedButton.icon(
                      onPressed: switchToMonitor,
                      icon: const Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                        child: Icon(
                          Icons.monitor,
                          color: Colors.white,
                        ),
                      ),
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.hovered)) {
                              return Colors.black38;
                            }
                            return null;
                          },
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(220, 120, 120, 120)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        )),
                      ),
                      label: const Padding(
                        padding: EdgeInsets.all(14.0),
                        child: Text('Monitor Farms',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Card(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: SizedBox(
                  height: 360,
                  width: 360,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Marker Boundaries',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: drawLines,
                                    icon: const Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 10, 0, 10),
                                      child: Icon(
                                        Icons.draw,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ButtonStyle(
                                      overlayColor: MaterialStateProperty
                                          .resolveWith<Color?>(
                                        (Set<MaterialState> states) {
                                          if (states.contains(
                                              MaterialState.hovered)) {
                                            return Colors.cyan;
                                          }
                                          return null;
                                        },
                                      ),
                                      shadowColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.transparent),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.blueGrey),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      )),
                                    ),
                                    label: const Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Text('Draw',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16)),
                                    ),
                                  ),
                                ],
                              ),
                              buildTextField("Farm Name", farmNameController),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: saveFarmBtn,
                                      style: ButtonStyle(
                                        overlayColor: MaterialStateProperty
                                            .resolveWith<Color?>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.hovered)) {
                                              return Colors.cyan;
                                            }
                                            return null;
                                          },
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.grey),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        )),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            10, 14.0, 10, 14),
                                        child: Text('Save Farm',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16)),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: clearLines,
                                      style: ButtonStyle(
                                        overlayColor: MaterialStateProperty
                                            .resolveWith<Color?>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.hovered)) {
                                              return Colors.cyan;
                                            }
                                            return null;
                                          },
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.grey),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        )),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            10, 14.0, 10, 14),
                                        child: Text('Clear Marker',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            reverse: true,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: marker.length,
                            itemBuilder: (context, index) {
                              if (marker.isEmpty) {
                                return const Center(
                                  child: Text('No Marker Added Yet.',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 16)),
                                );
                              }
                              return Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 14, 20, 14),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_history,
                                            color: Colors.grey,
                                          ),
                                          const Padding(
                                              padding: EdgeInsets.all(10)),
                                          Text('Marker $index',
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16)),
                                        ],
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () => {
                                          setState(() {
                                            marker.removeAt(index);
                                          })
                                        },
                                        icon: const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 8, 0, 8),
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ButtonStyle(
                                          overlayColor: MaterialStateProperty
                                              .resolveWith<Color?>(
                                            (Set<MaterialState> states) {
                                              if (states.contains(
                                                  MaterialState.hovered)) {
                                                return Colors.redAccent;
                                              }
                                              return null;
                                            },
                                          ),
                                          shadowColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.transparent),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.red),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          )),
                                        ),
                                        label: const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 8, 0, 8),
                                          child: Text('Remove',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
