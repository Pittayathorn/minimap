import 'dart:async';
import 'package:flutter/material.dart';
import 'device_page.dart';
import 'graph_page.dart';
import 'sound_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _imeiController = TextEditingController();
  String _currentImei = '';
  bool _isConnected = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _imeiController.text = '862798061921496';
    _currentImei = _imeiController.text;
  }

  void _onConnectPressed() {
    setState(() {
      _isConnected = !_isConnected;

      if (_isConnected) {
        _currentImei = _imeiController.text;
        // เริ่มโหลดทุก 1 นาที
        _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
          setState(() {
            _currentImei = _imeiController.text; // อัปเดต IMEI ทุกครั้ง
            print('Auto-refresh IMEI: $_currentImei');
          });
        });
        print('Connected with IMEI: $_currentImei');
      } else {
        _timer?.cancel();
        print('Disconnected');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ยกเลิก timer เมื่อ widget ถูกทำลาย
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PYNC'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _imeiController,
                          decoration: const InputDecoration(
                            labelText: 'Enter IMEI',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _onConnectPressed,
                        child: Text(_isConnected ? 'Disconnect' : 'Connect'),
                      ),
                    ],
                  ),
                ),
                const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.devices), text: 'Device'),
                    Tab(icon: Icon(Icons.show_chart), text: 'Graph'),
                    Tab(icon: Icon(Icons.surround_sound), text: 'Sound'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // ✅ ส่งค่า IMEI ใหม่ทุกครั้งที่ค่า _currentImei เปลี่ยน
            DevicePage(imei: _currentImei, key: ValueKey(_currentImei)),
            GraphPage(imei: _currentImei, key: ValueKey(_currentImei)),
            SoundPage(imei: _currentImei, key: ValueKey(_currentImei)),
          ],
        ),
      ),
    );
  }
}
