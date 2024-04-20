import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readair/BLE/ble_setup.dart';
import 'package:readair/data/packet.dart';
import 'package:readair/settings/settings.dart';
import 'package:readair/stats/aqi.dart';
import 'package:readair/stats/co.dart';
import 'package:readair/stats/co2.dart';
import 'package:readair/stats/humid.dart';
import 'package:readair/stats/methane.dart';
import 'package:readair/stats/nox.dart';
import 'package:readair/stats/ppm10p0.dart';
import 'package:readair/stats/ppm2p5.dart';
import 'package:readair/stats/stats.dart';
import 'package:readair/stats/temp.dart';
import 'package:readair/stats/voc.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double? temp;
  double? aqi; //test
  double? co2;
  double? humid;
  double? ppm1_0;
  double? ppm2_5;
  double? ppm4_0;
  double? ppm10_0;
  double? voc;
  double? nox;
  double? ng;
  double? co;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchLatestData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _onPullToRefresh() async {
    final BluetoothController bluetoothController =
        Get.find<BluetoothController>();

    // Send the UPDAT command if subscribed and a device is connected
    if (bluetoothController.isSubscribed.value &&
        bluetoothController.connectedDevice != null) {
      await bluetoothController.sendData(
          bluetoothController.connectedDevice!, "UPDAT");
      //await Future.delayed(Duration(seconds: 1)); // Wait for the command to take effect
    }

    // Fetch the latest data after sending the UPDAT command
    await _fetchLatestData();
  }

  Future<void> _fetchLatestData() async {
    DataPacket? latestPacket = await DatabaseService.instance.getLastPacket();
    if (latestPacket != null) {
      setState(() {
        temp = latestPacket.temp;
        aqi = latestPacket.aqi;
        co2 = latestPacket.co2;
        co = latestPacket.co;
        humid = latestPacket.humid;
        voc = latestPacket.voc;
        nox = latestPacket.nox;
        ng = latestPacket.ng;
        ppm2_5 = latestPacket.ppm2_5;
        ppm10_0 = latestPacket.ppm10_0;
      });
    }
    _showRefreshedMessage();
  }

  void _showRefreshedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Refreshed"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel(); // Cancel any existing timer
    _autoRefreshTimer = Timer.periodic(Duration(seconds: 40), (timer) {
      _fetchLatestData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final BluetoothController bluetoothController =
        Get.find<BluetoothController>();
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onPullToRefresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      'Welcome v1.1',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Obx(() => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.bluetooth_connected,
                            color: bluetoothController.isSubscribed.value
                                ? Colors.green
                                : Colors.red,
                          ),
                        )),
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StatsPage()),
                          );
                        },
                        icon: Icon(Icons.auto_graph)),
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingsPage()),
                          );
                        },
                        icon: Icon(Icons.settings)),
                  ],
                ),
              ),
              Divider(
                thickness: 3,
                indent: 20,
                endIndent: 20,
              ),
              SizedBox(height: 10),
                            GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AQIPage()),
                  );
                },
                child: Card(
                  child: ListTile(
                    title: Text(
                        'Air Quality Index: ${aqi?.toStringAsFixed(1) ?? 'N/A'}',
                        style: TextStyle(fontSize: 20)),
                    trailing: Icon(Icons.air, size: 40),
                  ),
                ),
              ),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => AQIPage()),
              //     );
              //   },
              //   child: Card(
              //     child: Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: ListTile(
              //         title: Text(
              //             'Air Quality Index: ${aqi?.toStringAsFixed(1) ?? 'N/A'}',
              //             style: TextStyle(
              //                 fontSize: 20, fontWeight: FontWeight.bold)),
              //         subtitle: Text('The Air Quality is Normal'),
              //         trailing: Container(
              //           width: 80,
              //           child: Row(
              //             children: [
              //               Expanded(
              //                 child: LinearProgressIndicator(
              //                   value: 0.6, // Example value
              //                   valueColor: AlwaysStoppedAnimation<Color>(
              //                       Colors.orange),
              //                   backgroundColor: Colors.grey[300],
              //                 ),
              //               ),
              //               SizedBox(width: 5),
              //               Text('medium', style: TextStyle(fontSize: 10)),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TempPage()),
                  );
                },
                child: Card(
                  child: ListTile(
                    title: Text(
                        'Temperature: ${temp?.toStringAsFixed(1) ?? 'N/A'}°C',
                        style: TextStyle(fontSize: 20)),
                    trailing: Icon(Icons.wb_sunny, size: 40),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CO2Page()),
                  );
                },
                child: Card(
                  child: ListTile(
                    title: Text(
                        'Carbon Dioxide: ${co2?.toStringAsFixed(1) ?? 'N/A'}',
                        style: TextStyle(fontSize: 20)),
                    trailing: Icon(Icons.cloud, size: 40),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HumidPage()),
                  );
                },
                child: Card(
                  child: ListTile(
                    title: Text(
                        'Humidity: ${humid?.toStringAsFixed(1) ?? 'N/A'}% ',
                        style: TextStyle(fontSize: 20)),
                    trailing: Icon(Icons.water_drop, size: 40),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => COPage()),
                  );
                },
                child: Card(
                  child: ListTile(
                    title: Text(
                        'Carbon Monoxide: ${co?.toStringAsFixed(1) ?? 'N/A'}',
                        style: TextStyle(fontSize: 20)),
                    trailing: Icon(Icons.cloud_circle, size: 40),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VOCPage()),
                  );
                },
                child: Card(
                  child: ListTile(
                    title: Text('Volatile Organic Compounds: ${voc?.toStringAsFixed(1) ?? 'N/A'}',
                        style: TextStyle(fontSize: 16)),
                    trailing: Icon(Icons.heat_pump_rounded, size: 40),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NOxPage()),
                  );
                },
                child: Card(
                  child: ListTile(
                    title: Text('Nitorgen Oxides: ${nox?.toStringAsFixed(1) ?? 'N/A'}',
                        style: TextStyle(fontSize: 20)),
                    trailing: Icon(Icons.gas_meter, size: 40),
                  ),
                ),
              ),
                            SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MethanePage()),
                  );
                },
                child: Card(
                  child: ListTile(
                    title: Text('Methane: ${ng?.toStringAsFixed(1) ?? 'N/A'}',
                        style: TextStyle(fontSize: 20)),
                    trailing: Icon(Icons.mail_lock, size: 40),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ppm2p5Page()),
                  );
                },
                child: Card(
                  child: ListTile(
                    title: Text('Particulate Matter: ${ppm2_5?.toStringAsFixed(1) ?? 'N/A'}', style: TextStyle(fontSize: 20)),
                    trailing: Icon(Icons.circle, size: 40),
                  ),
                ),
              ),
                            SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StatsPage()),
                  );
                },
                child: Card(
                  child: ListTile(
                    title: Text('Graphs', style: TextStyle(fontSize: 20)),
                    trailing: Icon(Icons.auto_graph, size: 40),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20), // Adjust padding as needed
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        "Pull to refresh",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Icon(
                        Icons.arrow_downward,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _fetchLatestData, // Refreshes and updates the data
      //   child: Icon(Icons.refresh),
      //   tooltip: 'Refresh Data',
      // ),
    );
  }
}
