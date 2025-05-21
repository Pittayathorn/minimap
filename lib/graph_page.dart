import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> exportDataAsCSV(List<Map<String, dynamic>> data) async {
  final csvBuffer = StringBuffer();
  csvBuffer.writeln('timestamp,temperature,humidity,pressure');

  for (var item in data) {
    csvBuffer.writeln(
        '${item['ts']},${item['temperature']},${item['humidity']},${item['pressure']}');
  }

  final status = await Permission.storage.request();
  if (status.isGranted) {
    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/environment_data.csv';
    final file = File(path);
    await file.writeAsString(csvBuffer.toString());

    print('CSV saved to $path');
  } else {
    print('Permission denied');
  }
}

Future<List<Map<String, dynamic>>> fetchEnvironmentData(
    String imei, String startTime, String endTime) async {
  final response = await http.get(Uri.parse(
      'https://pync.mini-map.shop/api/environment?imei=$imei&start=$startTime&end=$endTime'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data
        .map((e) => {
              'temperature': e['temperature'],
              'humidity': e['humidity'],
              'pressure': e['pressure'],
              'ts': e['ts'],
            })
        .toList();
  } else {
    throw Exception('Failed to load data');
  }
}

class GraphPage extends StatefulWidget {
  final String imei;

  const GraphPage({super.key, required this.imei});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  String _selectedDataType = 'Temperature'; // ตั้งค่าเริ่มต้นเป็น 'Temperature'
  final List<String> _dataTypes = ['Temperature', 'Humidity', 'Pressure'];
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  List<Map<String, dynamic>> _data = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startTimeController.text =
        _formatDateTime(now.subtract(Duration(minutes: 10)));
    _endTimeController.text = _formatDateTime(now);
    _loadData();
  }

  Future<void> _selectDateTime(TextEditingController controller) async {
    DateTime now = DateTime.now();

    DateTime? date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );

    if (date != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );

      if (time != null) {
        final selected =
            DateTime(date.year, date.month, date.day, time.hour, time.minute);
        controller.text = _formatDateTime(selected);
      }
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> _loadData() async {
    if (_isLoading) return; // ป้องกันการโหลดข้อมูลซ้อนกัน
    setState(() => _isLoading = true);

    try {
      List<Map<String, dynamic>> data = await fetchEnvironmentData(
        widget.imei, // ใช้ IMEI จาก widget
        _startTimeController.text,
        _endTimeController.text,
      );

      setState(() {
        _data = data;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error fetching data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<FlSpot> _getChartData() {
    List<FlSpot> spots = [];
    for (int i = 0; i < _data.length; i++) {
      double x = i.toDouble();
      double y = _selectedDataType == 'Temperature'
          ? _data[i]['temperature']
          : _selectedDataType == 'Humidity'
              ? _data[i]['humidity']
              : _data[i]['pressure'];
      spots.add(FlSpot(x, y));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Graph')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await exportDataAsCSV(_data); // ส่งข้อมูลออกเป็น CSV
                  },
                  child: const Text('Export'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _startTimeController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Start Time',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _selectDateTime(_startTimeController),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _endTimeController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'End Time',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _selectDateTime(_endTimeController),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedDataType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDataType = newValue!;
                      _loadData(); // รีเฟรชข้อมูลทันทีที่เปลี่ยนชนิดข้อมูล
                    });
                  },
                  items:
                      _dataTypes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _data.isEmpty
                          ? const Text('No data available')
                          : LineChart(
                              LineChartData(
                                gridData: FlGridData(show: true),
                                titlesData: FlTitlesData(show: true),
                                borderData: FlBorderData(show: true),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _getChartData(),
                                    isCurved: true,
                                    dotData: FlDotData(show: false),
                                    belowBarData: BarAreaData(show: false),
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
