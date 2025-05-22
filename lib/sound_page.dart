import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

class SoundPage extends StatefulWidget {
  final String imei;

  const SoundPage({super.key, required this.imei});

  @override
  _SoundPageState createState() => _SoundPageState();
}

class _SoundPageState extends State<SoundPage> {
  final AudioPlayer _player = AudioPlayer();

  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  String? _selectedPath;
  List<String> _pathOptions = [];

  // ฟังก์ชันสำหรับเลือกวันเวลา
  Future<void> _selectDateTime(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        final DateTime fullDateTime = DateTime(
            picked.year, picked.month, picked.day, time.hour, time.minute);
        controller.text = fullDateTime.toString().split('.').first;
      }
    }
  }

  // ฟังก์ชันสำหรับดึงรายชื่อเสียง
  Future<void> _fetchAvailablePaths() async {
    final imei = widget.imei.trim();
    final startTime = _startTimeController.text.trim();
    final endTime = _endTimeController.text.trim();

    if (imei.isEmpty || startTime.isEmpty || endTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter IMEI, start time, and end time')),
      );
      return;
    }

    final url = Uri.parse(
        'https://pync.minimap.site/api/sound/list?imei=$imei&start=$startTime&end=$endTime');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _pathOptions = data.map<String>((e) => e['path'].toString()).toList();
          _selectedPath = _pathOptions.isNotEmpty ? _pathOptions.first : null;
        });
      } else {
        throw Exception('Failed to fetch sound list');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // ฟังก์ชันสำหรับเล่นเสียงที่เลือก
  // void _playSelectedPath() async {
  //   if (_selectedPath != null) {
  //     final url = 'https://pync.minimap.site/api/sound/load?$path';
  //     await _player.play(UrlSource(url));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sound')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // เลือกวันและเวลา
            Row(
              children: [
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
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Load Sounds'),
                  onPressed: _fetchAvailablePaths,
                ),
              ],
            ),
            // แสดงเสียงทั้งหมดในรูปแบบการ์ด
            Expanded(
              child: ListView.builder(
                itemCount: _pathOptions.length,
                itemBuilder: (context, index) {
                  final path = _pathOptions[index];
                  return Card(
                    child: ListTile(
                      leading: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () {
                          final url =
                              'https://pync.minimap.site/api/sound?$path';
                          _player.play(UrlSource(url));
                        },
                      ),
                      title: Text(path),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
