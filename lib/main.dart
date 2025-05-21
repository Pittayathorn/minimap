import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'device_data.dart';

Future<DeviceData> fetchDeviceData(String imei) async {
  final response = await http
      .get(Uri.parse('https://pync.minimap.site/api/device?imei=$imei'));

  if (response.statusCode == 200) {
    return DeviceData.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load device data');
  }
}

class DeviceDataPage extends StatefulWidget {
  const DeviceDataPage({super.key});

  @override
  _DeviceDataPageState createState() => _DeviceDataPageState();
}

class _DeviceDataPageState extends State<DeviceDataPage> {
  DeviceData? _deviceData;
  bool _isLoading = false;
  String _errorMessage = '';
  String _imei = '862798061921496'; // ค่า IMEI เริ่มต้น

  TextEditingController _imeiController = TextEditingController();
  String _selectedDataType =
      'Environment'; // ค่าเริ่มต้นสำหรับเลือกประเภทข้อมูล
  List<String> _dataTypes = ['Environment', 'Motion', 'GPS', 'Energy', 'Sound'];

  void _loadDeviceData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      DeviceData data = await fetchDeviceData(_imei);
      setState(() {
        _deviceData = data;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load device data: $error';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _imeiController.text = _imei; // ตั้งค่าเริ่มต้นของ TextField
  }

  @override
//  Widget build(BuildContext context) {
//     int crossAxisCount = 2;
//     if (MediaQuery.of(context).size.width >= 600) {
//       crossAxisCount = 3;
//     }
//     if (MediaQuery.of(context).size.width >= 1200) {
//       crossAxisCount = 4;
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text('Device Data')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: _imeiController,
//               decoration: const InputDecoration(
//                 labelText: 'Enter IMEI',
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.number,
//               onChanged: (value) {
//                 setState(() {
//                   _imei = value;
//                 });
//               },
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _loadDeviceData,
//               child: const Text('Load Device Data'),
//             ),
//             const SizedBox(height: 20),
//             if (_isLoading)
//               const Center(child: CircularProgressIndicator())
//             else if (_deviceData != null)
//               Expanded(
//                 child: GridView.builder(
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: crossAxisCount,
//                     crossAxisSpacing: 16.0,
//                     mainAxisSpacing: 16.0,
//                   ),
//                   itemCount: 7, // จำนวนคอลัมน์ที่เราต้องการแสดง (เพิ่มกราฟอีก 1 ช่อง)
//                   itemBuilder: (context, index) {
//                     switch (index) {
//                       case 0:
//                         return Card(
//                           elevation: 4,
//                           margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                           child: ListTile(
//                             title: const Text('Device'),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('IMEI ID: ${_deviceData!.imeiId}'),
//                                 Text('เวอร์ชัน: ${_deviceData!.version}'),
//                               ],
//                             ),
//                           ),
//                         );
//                       case 1:
//                         return Card(
//                           elevation: 4,
//                           margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                           child: ListTile(
//                             title: const Text('Energy'),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('ระดับแบตเตอรี่: ${_deviceData!.batteryLevel}%'),
//                                 Text('ชาร์จหรือไม่: ${_deviceData!.isCharging == 1 ? "ใช่" : "ไม่ใช่"}'),
//                               ],
//                             ),
//                           ),
//                         );
//                       case 2:
//                         return Card(
//                           elevation: 4,
//                           margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                           child: ListTile(
//                             title: const Text('Environment'),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('อุณหภูมิ: ${_deviceData!.temperature}°C'),
//                                 Text('ความชื้น: ${_deviceData!.humidity}%'),
//                                 Text('ความดัน: ${_deviceData!.pressure} hPa'),
//                               ],
//                             ),
//                           ),
//                         );
//                       case 3:
//                         return Card(
//                           elevation: 4,
//                           margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                           child: ListTile(
//                             title: const Text('GPS'),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('ตำแหน่ง: ${_deviceData!.latitude}, ${_deviceData!.longitude}'),
//                                 Text('ความสูง: ${_deviceData!.altitude} m'),
//                               ],
//                             ),
//                           ),
//                         );
//                       case 4:
//                         return Card(
//                           elevation: 4,
//                           margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                           child: ListTile(
//                             title: const Text('Motion'),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('เร่งความเร็ว (X, Y, Z): ${_deviceData!.accX}, ${_deviceData!.accY}, ${_deviceData!.accZ}'),
//                                 Text('จุดหมุน (X, Y, Z): ${_deviceData!.gyroX}, ${_deviceData!.gyroY}, ${_deviceData!.gyroZ}'),
//                               ],
//                             ),
//                           ),
//                         );
//                       case 5:
//                         return Card(
//                           elevation: 4,
//                           margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                           child: ListTile(
//                             title: const Text('Sound'),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('ระดับเสียง: ${_deviceData!.decibelLevel} dB'),
//                               ],
//                             ),
//                           ),
//                         );
//                       case 6:
//                         // เพิ่มกราฟที่นี่
//                         return Card(
//                           elevation: 4,
//                           margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               children: [
//                                 const Text(
//                                   'Device Data Graph',
//                                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                                 ),
//                                 const SizedBox(height: 10),
//                                 SizedBox(
//                                   height: 200, // กำหนดความสูงของกราฟ
//                                   child: LineChart(
//                                     LineChartData(
//                                       gridData: FlGridData(show: true),
//                                       titlesData: FlTitlesData(show: true),
//                                       borderData: FlBorderData(show: true),
//                                       lineBarsData: [
//                                         LineChartBarData(
//                                           spots: [
//                                             FlSpot(0, _deviceData!.temperature), // อุณหภูมิ
//                                             FlSpot(1, _deviceData!.humidity),   // ความชื้น
//                                           ],
//                                           isCurved: true,
//                                           // colors: [Colors.blue],
//                                           dotData: FlDotData(show: false),
//                                           belowBarData: BarAreaData(show: false),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       default:
//                         return const SizedBox.shrink();
//                     }
//                   },
//                 ),
//               )
//             else if (_errorMessage.isNotEmpty)
//               Center(child: Text(_errorMessage)),
//           ],
//         ),
//       ),
//     );
//   }
// }

  Widget build(BuildContext context) {
    int crossAxisCount = 2;
    if (MediaQuery.of(context).size.width >= 600) {
      crossAxisCount = 3;
    }
    if (MediaQuery.of(context).size.width >= 1200) {
      crossAxisCount = 4;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Device Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // กราฟที่อยู่ด้านบนสุด

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _imeiController,
                    decoration: const InputDecoration(
                      labelText: 'Enter IMEI',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _imei = value;
                      });
                    },
                  ),
                ),
                const SizedBox(
                    width: 8), // เว้นระยะห่างระหว่าง TextField กับ Button
                ElevatedButton(
                  onPressed: _loadDeviceData,
                  child: const Text('Load Device Data'),
                ),
              ],
            ),

            const SizedBox(height: 20),
            // Dropdown สำหรับเลือกประเภทข้อมูล
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // ชิดขวา
              children: [
                // ปุ่ม Export ที่อยู่หน้าช่อง Start Time
                ElevatedButton(
                  onPressed: () {
                    // เพิ่มฟังก์ชันการทำงานของปุ่มนี้ เช่น ส่งข้อมูลออก หรือทำการ Export
                    print('Export pressed');
                  },
                  child: const Text('Export'), // ข้อความปุ่ม "Export"
                ),

                // ช่อง Start Time
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 8.0), // กำหนดช่องว่างระหว่าง text field
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Start Time',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.datetime,
                      onChanged: (value) {
                        // จัดการค่าของ start time ที่ถูกเปลี่ยน
                      },
                    ),
                  ),
                ),

                // ช่อง Stop Time
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 8.0), // กำหนดช่องว่างระหว่าง text field
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Stop Time',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.datetime,
                      onChanged: (value) {
                        // จัดการค่าของ stop time ที่ถูกเปลี่ยน
                      },
                    ),
                  ),
                ),

                // Dropdown Button
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedDataType,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDataType = newValue!;
                      });
                    },
                    items: _dataTypes
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            if (_deviceData != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text(
                          'Device Data Graph',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 200, // กำหนดความสูงของกราฟ
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(show: true),
                              borderData: FlBorderData(show: true),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0,
                                        _deviceData!.temperature), // อุณหภูมิ
                                    FlSpot(
                                        1, _deviceData!.humidity), // ความชื้น
                                  ],
                                  isCurved: true,
                                  dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(show: false),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            const SizedBox(height: 20),
            // ถ้ากำลังโหลดข้อมูล
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_deviceData != null)
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: 6, // จำนวนคอลัมน์ที่จะแสดง
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: const Text('Device'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('IMEI ID: ${_deviceData!.imeiId}'),
                                Text('เวอร์ชัน: ${_deviceData!.version}'),
                              ],
                            ),
                          ),
                        );
                      case 1:
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: const Text('Energy'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'ระดับแบตเตอรี่: ${_deviceData!.batteryLevel}%'),
                                Text(
                                    'ชาร์จหรือไม่: ${_deviceData!.isCharging == 1 ? "ใช่" : "ไม่ใช่"}'),
                              ],
                            ),
                          ),
                        );
                      case 2:
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: const Text('Environment'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('อุณหภูมิ: ${_deviceData!.temperature}°C'),
                                Text('ความชื้น: ${_deviceData!.humidity}%'),
                                Text('ความดัน: ${_deviceData!.pressure} hPa'),
                              ],
                            ),
                          ),
                        );
                      case 3:
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: const Text('GPS'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'ตำแหน่ง: ${_deviceData!.latitude}, ${_deviceData!.longitude}'),
                                Text('ความสูง: ${_deviceData!.altitude} m'),
                              ],
                            ),
                          ),
                        );
                      case 4:
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: const Text('Motion'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'เร่งความเร็ว (X, Y, Z): ${_deviceData!.accX}, ${_deviceData!.accY}, ${_deviceData!.accZ}'),
                                Text(
                                    'จุดหมุน (X, Y, Z): ${_deviceData!.gyroX}, ${_deviceData!.gyroY}, ${_deviceData!.gyroZ}'),
                              ],
                            ),
                          ),
                        );
                      case 5:
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: const Text('Sound'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'ระดับเสียง: ${_deviceData!.decibelLevel} dB'),
                              ],
                            ),
                          ),
                        );
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Center(child: Text(_errorMessage)),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PYNC',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DeviceDataPage(),
    );
  }
}
