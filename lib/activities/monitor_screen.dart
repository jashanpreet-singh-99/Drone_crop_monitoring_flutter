import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:web_farm/activities/add_farm_screen.dart';
import 'package:web_farm/models/farm.dart';
import 'package:web_farm/models/grid.dart';
import 'package:web_farm/utils/config.dart';

import 'package:http/http.dart' as http;

import '../custom_painter.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<MonitorScreen> createState() {
    return _MonitorScreenState();
  }
}

class _MonitorScreenState extends State<MonitorScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this);
    getFarms();
    const oneSec = Duration(seconds: 1);
    Timer.periodic(oneSec, (Timer t) => getDroneStat());

    const fiveSec = Duration(seconds: 5);
    Timer.periodic(fiveSec, (Timer t) => updateInfection());
  }

  MaterialColor deployBtnColor = Colors.grey;
  MaterialColor stallBtnColor = Colors.grey;
  MaterialColor abortBtnColor = Colors.grey;

  late AnimationController animationController;

  Farm selected = Farm(-1, '', 0, []);
  List<MaterialColor> cardColors = [];

  List<Farm> farms = [];
  List<Grid> farmGrid = [];
  bool update = true;

  int rpm = 0;
  double coverage = 0;
  double infected = 0;
  int altitude = 0;
  String grid_cur = '';

  Future<void> getDroneStat() async {
    final uri = Config.urlDroneStat;
    final headers = {'Content-Type': 'application/json'};

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    int statusCode = response.statusCode;
    String responseBody = response.body;
    Log.log(Log.TAG_REQUEST, "$statusCode", Log.I);
    Log.log(Log.TAG_REQUEST, responseBody, Log.I);
    if (statusCode == 200) {
      setState(() {
        var obj = jsonDecode(responseBody)['valid'];
        rpm = obj['rpm'];
        grid_cur = obj['grid_id'];
        altitude = obj['altitude'];
        var pred = obj['pred'];
        int index = int.parse(grid_cur.split('_')[1].split('.')[0]);
        if (index < farmGrid.length) {
          Log.log(Log.TAG_REQUEST, "INDEX ${index + 1}", Log.I);
          farmGrid[index].pred = pred;
        }
        deployDrone(obj['state'], false);
        int cov = int.parse(grid_cur.split("_")[1]);
        if (farmGrid.isNotEmpty) {
          var tmp = cov / farmGrid.length * 100;
          coverage = tmp;
        }
      });
    }
  }

  Future<void> getFarms() async {
    final uri = Config.urlFarms;
    final headers = {'Content-Type': 'application/json'};

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    int statusCode = response.statusCode;
    String responseBody = response.body;
    Log.log(Log.TAG_REQUEST, "$statusCode", Log.I);
    Log.log(Log.TAG_REQUEST, responseBody, Log.I);
    if (statusCode == 200) {
      farms.clear();
      setState(() {
        farms = List<Farm>.from(json
            .decode(responseBody)['valid']
            .map((model) => Farm.fromJson(model)));
        selected = farms[0];
        getFarmGrid(selected);
      });
      Log.log(Log.TAG_REQUEST, "Value ${farms.length}", Log.I);
    }
  }

  Future<void> getFarmGrid(Farm farm) async {
    final uri = Config.urlFarmGrid;
    final headers = {'Content-Type': 'application/json'};

    Map bData = {'farm_id': farm.id};
    final body = json.encode(bData);

    http.Response response = await http.post(uri, headers: headers, body: body);

    int statusCode = response.statusCode;
    String responseBody = response.body;
    Log.log(Log.TAG_REQUEST, "$statusCode", Log.I);
    //Log.log(Log.TAG_REQUEST, responseBody, Log.I);
    if (statusCode == 200) {
      farmGrid.clear();
      setState(() {
        farmGrid = List<Grid>.from(json
            .decode(responseBody)['grid']
            .map((model) => Grid.fromJson(model)));
      });
      Log.log(Log.TAG_REQUEST, "Value ${farmGrid.length}", Log.I);
    }
  }

  void updateInfection() {
    var tmp = 0;
    for (var element in farmGrid) {
      if (element.pred > 0) {
        tmp += element.pred;
      }
    }
    infected = (tmp / farmGrid.length) * 100;
  }

  Future<bool> sendDeleteFarm(Farm farm) async {
    final uri = Config.urlDeleteFarm;
    final headers = {'Content-Type': 'application/json'};

    Map bData = {'farm_id': farm.id};
    final body = json.encode(bData);

    http.Response response = await http.post(uri, headers: headers, body: body);

    int statusCode = response.statusCode;
    String responseBody = response.body;
    Log.log(Log.TAG_REQUEST, "$statusCode", Log.I);
    Log.log(Log.TAG_REQUEST, responseBody, Log.I);
    if (statusCode == 200) {
      if (json.decode(responseBody)['valid'] == 1) {
        Log.log(Log.TAG_REQUEST, "Farm deleted.", Log.I);
        setState(() {
          farms.remove(farm);
          if (farms.isNotEmpty) {
            selected = farms[0];
            update = true;
          }
        });
        return true;
      } else {
        Log.log(Log.TAG_REQUEST, "Farm delete Error.", Log.E);
      }
    }
    return false;
  }

  Future<bool> sendRenameFarm(Farm farm) async {
    final uri = Config.urlDeleteFarm;
    final headers = {'Content-Type': 'application/json'};

    Map bData = {'farm_id': farm.id};
    final body = json.encode(bData);

    http.Response response = await http.post(uri, headers: headers, body: body);

    int statusCode = response.statusCode;
    String responseBody = response.body;
    Log.log(Log.TAG_REQUEST, "$statusCode", Log.I);
    Log.log(Log.TAG_REQUEST, responseBody, Log.I);
    if (statusCode == 200) {
      if (json.decode(responseBody)['valid'] == 1) {
        Log.log(Log.TAG_REQUEST, "Farm deleted.", Log.I);
        setState(() {
          farms.remove(farm);
          if (farms.isNotEmpty) {
            selected = farms[0];
          }
        });
        return true;
      } else {
        Log.log(Log.TAG_REQUEST, "Farm delete Error.", Log.E);
      }
    }
    return false;
  }

  void switchToAddFarm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddFarmScreen()),
    );
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

  void deleteFarm() {
    if (selected.id == -1 && farms.length <= 1) {
      return;
    }
    sendDeleteFarm(selected);
  }

  deployDrone(int state, bool update) {
    setState(() {
      switch (state) {
        case Config.STATE_DEPLOY:
          deployBtnColor = Colors.green;
          stallBtnColor = Colors.grey;
          abortBtnColor = Colors.grey;
          animationController.forward();
          animationController.repeat();
          break;
        case Config.STATE_STALL:
          stallBtnColor = Colors.blue;
          deployBtnColor = Colors.grey;
          abortBtnColor = Colors.grey;
          animationController.forward();
          animationController.repeat();

          break;
        case Config.STATE_ABORT:
          abortBtnColor = Colors.red;
          deployBtnColor = Colors.grey;
          stallBtnColor = Colors.grey;
          animationController.stop();
          break;
        default:
          return;
      }
      if (update) {
        updateDroneState(state);
      }
    });
  }

  Future<void> updateDroneState(int state) async {
    final uri = Config.urlDroneState;
    final headers = {'Content-Type': 'application/json'};

    Map bData = {'state': state};
    final body = json.encode(bData);

    http.Response response = await http.post(uri, headers: headers, body: body);

    int statusCode = response.statusCode;
    String responseBody = response.body;
    Log.log(Log.TAG_REQUEST, "$statusCode", Log.I);
    Log.log(Log.TAG_REQUEST, responseBody, Log.I);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 230, 10),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: Row(
                        children: [
                          // Drone Visual
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                            child: SizedBox(
                              width: 260,
                              height: 200,
                              child: Card(
                                elevation: 2,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Lottie.asset(
                                    'assets/drone.json',
                                    repeat: true,
                                    animate: true,
                                    controller: animationController,
                                    onLoaded: (composition) {
                                      animationController.duration =
                                          composition.duration;
                                      animationController.forward();
                                      animationController.repeat();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Drone controls
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                            child: SizedBox(
                                width: 260,
                                height: 200,
                                child: Column(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => {
                                        deployDrone(Config.STATE_DEPLOY, true),
                                      },
                                      icon: const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 10, 0, 10),
                                        child: Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ButtonStyle(
                                        overlayColor: MaterialStateProperty
                                            .resolveWith<Color?>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.hovered)) {
                                              return Colors.green;
                                            }
                                            return null;
                                          },
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                deployBtnColor),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        )),
                                      ),
                                      label: const Padding(
                                        padding: EdgeInsets.all(14.0),
                                        child: Text('Deploy Drone ',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16)),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(10),
                                    ),
                                    // Drone stall
                                    ElevatedButton.icon(
                                      onPressed: () => {
                                        deployDrone(Config.STATE_STALL, true),
                                      },
                                      icon: const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 10, 0, 10),
                                        child: Icon(
                                          Icons.pause,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ButtonStyle(
                                        overlayColor: MaterialStateProperty
                                            .resolveWith<Color?>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.hovered)) {
                                              return Colors.blue;
                                            }
                                            return null;
                                          },
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                stallBtnColor),
                                        // const Color.fromARGB(
                                        //     183, 175, 175, 175)),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        )),
                                      ),
                                      label: const Padding(
                                        padding: EdgeInsets.all(14.0),
                                        child: Text('Stall Drone     ',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16)),
                                      ),
                                    ),
                                    // Abort deployment
                                    const Padding(
                                      padding: EdgeInsets.all(10),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => {
                                        deployDrone(Config.STATE_ABORT, true),
                                      },
                                      icon: const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 10, 0, 10),
                                        child: Icon(
                                          Icons.back_hand,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ButtonStyle(
                                        overlayColor: MaterialStateProperty
                                            .resolveWith<Color?>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.hovered)) {
                                              return Colors.red;
                                            }
                                            return null;
                                          },
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                abortBtnColor
                                                // const Color.fromARGB(
                                                //     183, 244, 67, 54),
                                                ),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                      ),
                                      label: const Padding(
                                        padding: EdgeInsets.all(14.0),
                                        child: Text('Abort Drone    ',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16)),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          // Drone information
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 36,
                                            child: Image.asset(
                                                'assets/altitude.png'),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                16, 10, 10, 10),
                                            child: Text(
                                              'Altitude    ',
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 18),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 10, 16, 10),
                                            child: Text(
                                              '$altitude m',
                                              style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(14),
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 36,
                                            child:
                                                Image.asset('assets/rotor.png'),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                16, 10, 2, 10),
                                            child: Text(
                                              'Speed (RPM)',
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 18),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 10, 16, 10),
                                            child: Text(
                                              '$rpm',
                                              style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(14),
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 36,
                                            child: Image.asset(
                                                'assets/battery.png'),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                16, 10, 10, 10),
                                            child: Text(
                                              'Battery     ',
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 18),
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                20, 10, 16, 10),
                                            child: Text(
                                              '100 %',
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 36,
                                            child:
                                                Image.asset('assets/grid.png'),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                16, 10, 10, 10),
                                            child: Text(
                                              'Grid Value',
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 18),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 10, 10, 10),
                                            child: Text(
                                              grid_cur,
                                              style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(14),
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 36,
                                            child: Image.asset(
                                                'assets/disease.png'),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                16, 10, 10, 10),
                                            child: Text(
                                              'Diseased',
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 18),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 10, 10, 10),
                                            child: Text(
                                              '${infected.toStringAsFixed(1)} %',
                                              style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(14),
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 36,
                                            child: Image.asset(
                                                'assets/coverage.png'),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                16, 10, 10, 10),
                                            child: Text(
                                              'Coverage',
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 18),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 10, 10, 10),
                                            child: Text(
                                              '${coverage.toStringAsFixed(1)} %',
                                              style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          // Farm options
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                            child: SizedBox(
                              child: Column(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: deleteFarm,
                                    icon: const Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 10, 0, 10),
                                      child: Icon(
                                        Icons.delete_forever,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ButtonStyle(
                                      overlayColor: MaterialStateProperty
                                          .resolveWith<Color?>(
                                        (Set<MaterialState> states) {
                                          if (states.contains(
                                              MaterialState.hovered)) {
                                            return Colors.red;
                                          }
                                          return null;
                                        },
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.grey),
                                      // const Color.fromARGB(
                                      //     183, 175, 175, 175)),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      )),
                                    ),
                                    label: const Padding(
                                      padding: EdgeInsets.all(14.0),
                                      child: Text('Delete Farm   ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16)),
                                    ),
                                  ),
                                  // Abort deployment
                                  const Padding(
                                    padding: EdgeInsets.all(8),
                                  ),
                                  // Drone stall
                                  ElevatedButton.icon(
                                    onPressed: () => {
                                      showErrorDialog(
                                          "Permission not available, Please check with the Admin.")
                                    },
                                    icon: const Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 10, 0, 10),
                                      child: Icon(
                                        Icons.change_circle,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ButtonStyle(
                                      overlayColor: MaterialStateProperty
                                          .resolveWith<Color?>(
                                        (Set<MaterialState> states) {
                                          if (states.contains(
                                              MaterialState.hovered)) {
                                            return Colors.red;
                                          }
                                          return null;
                                        },
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.grey
                                              // const Color.fromARGB(
                                              //     183, 244, 67, 54),
                                              ),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                      ),
                                    ),
                                    label: const Padding(
                                      padding: EdgeInsets.all(14.0),
                                      child: Text('Rename Farm  ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 30, 10, 20),
                                    child: Text(
                                      'CUR: ${selected.name}',
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                              child: Card(
                                elevation: 2,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: SizedBox(
                                    height: double.infinity,
                                    width: double.infinity,
                                    child: GestureDetector(
                                      onTapDown: (details) {
                                        if (selected.id == 1) {
                                          Log.log(
                                              Log.TAG_RENDER,
                                              "${details.globalPosition.dx}",
                                              Log.I);
                                          Log.log(
                                              Log.TAG_RENDER,
                                              "${details.globalPosition.dy}",
                                              Log.I);
                                        }
                                      },
                                      child: RepaintBoundary(
                                        child: CustomPaint(
                                          painter: (FarmPoly(
                                              selected, farmGrid, update)),
                                          isComplex: true,
                                          willChange: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Side Right Panel
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 240,
                child: Column(
                  children: [
                    // Switch screens buttons
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 200,
                            child: ElevatedButton.icon(
                              onPressed: switchToAddFarm,
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
                                    if (states
                                        .contains(MaterialState.hovered)) {
                                      return Colors.black38;
                                    }
                                    return null;
                                  },
                                ),
                                backgroundColor: MaterialStateProperty.all<
                                        Color>(
                                    const Color.fromARGB(220, 120, 120, 120)),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                )),
                              ),
                              label: const Padding(
                                padding: EdgeInsets.all(14.0),
                                child: Text('Add Farms       ',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              ),
                            ),
                          ),
                          const Padding(padding: EdgeInsets.all(10)),
                          ElevatedButton.icon(
                            onPressed: null,
                            icon: const Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                              child: Icon(
                                Icons.monitor,
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
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              )),
                            ),
                            label: const Padding(
                              padding: EdgeInsets.all(14.0),
                              child: Text('Monitor Farms',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(5)),
                    // Show the stored farms
                    Expanded(
                      child: SizedBox(
                        width: 210,
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: farms.length,
                            itemBuilder: (context, index) {
                              if (farms.isEmpty) {
                                return const Center(
                                  child: Text('No Farm Added Yet.',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 16)),
                                );
                              }
                              return SizedBox(
                                width: 210,
                                child: Card(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 20),
                                  elevation: 2,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 10, 10, 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 8, 8, 8),
                                          child: Text(
                                              farms[index].name.toLowerCase(),
                                              style: const TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 20)),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () => {
                                            setState(() {
                                              Log.log(
                                                  Log.TAG_RENDER,
                                                  "Render next field $index",
                                                  Log.E);
                                              selected = farms[index];
                                              getFarmGrid(selected);
                                            })
                                          },
                                          icon: const Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(2, 6, 0, 6),
                                            child: Icon(
                                              Icons.agriculture,
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
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                        Color>(
                                                    const Color.fromARGB(
                                                        220, 120, 120, 120)),
                                            shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            )),
                                          ),
                                          label: const Padding(
                                            padding: EdgeInsets.all(4.0),
                                            child: Text('Switch',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
