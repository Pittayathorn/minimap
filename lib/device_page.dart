import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

class DevicePage extends StatefulWidget {
  final String imei;

  const DevicePage({super.key, required this.imei});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  DeviceData? _deviceData;
  bool _isLoading = false;
  String _errorMessage = '';
  late String _imei;

  @override
  void initState() {
    super.initState();
    _imei = widget.imei; // รับค่า IMEI จาก constructor
    _loadDeviceData();
  }

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
  void didUpdateWidget(covariant DevicePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imei != widget.imei) {
      // รีเฟรชข้อมูลใหม่เมื่อ IMEI เปลี่ยน
      _imei = widget.imei;
      _loadDeviceData();
    }
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = MediaQuery.of(context).size.width >= 1200
        ? 4
        : MediaQuery.of(context).size.width >= 600
            ? 3
            : 2;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (_isLoading)
            const CircularProgressIndicator()
          else if (_deviceData != null)
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return _buildCard('Device', [
                        'IMEI ID: ${_deviceData!.imeiId}',
                        'เวอร์ชัน: ${_deviceData!.version}',
                      ]);
                    case 1:
                      return _buildCard('Energy', [
                        'ระดับแบตเตอรี่: ${_deviceData!.batteryLevel}%',
                        'ชาร์จหรือไม่: ${_deviceData!.isCharging == 1 ? "ใช่" : "ไม่ใช่"}',
                      ]);
                    case 2:
                      return _buildCard('Environment', [
                        'อุณหภูมิ: ${_deviceData!.temperature}°C',
                        'ความชื้น: ${_deviceData!.humidity}%',
                        'ความดัน: ${_deviceData!.pressure} hPa',
                      ]);
                    case 3:
                      return _buildCard('GPS', [
                        'ตำแหน่ง: ${_deviceData!.latitude}, ${_deviceData!.longitude}',
                        'ความสูง: ${_deviceData!.altitude} m',
                      ]);
                    case 4:
                      return _buildCard('Motion', [
                        'เร่งความเร็ว (X,Y,Z): ${_deviceData!.accX}, ${_deviceData!.accY}, ${_deviceData!.accZ}',
                        'จุดหมุน (X,Y,Z): ${_deviceData!.gyroX}, ${_deviceData!.gyroY}, ${_deviceData!.gyroZ}',
                      ]);
                    case 5:
                      return _buildCard('Sound', [
                        'ระดับเสียง: ${_deviceData!.decibelLevel} dB',
                      ]);
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
    );
  }

  Widget _buildCard(String title, List<String> lines) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lines.map((e) => Text(e)).toList(),
        ),
      ),
    );
  }
}
