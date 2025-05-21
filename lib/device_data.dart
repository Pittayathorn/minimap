class DeviceData {
  final String imeiId;
  final String version;
  final double temperature;
  final double humidity;
  final double pressure;
  final double accX;
  final double accY;
  final double accZ;
  final double gyroX;
  final double gyroY;
  final double gyroZ;
  final double decibelLevel;
  final double latitude;
  final double longitude;
  final double altitude;
  final double batteryLevel;
  final bool isCharging;

  DeviceData({
    required this.imeiId,
    required this.version,
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.accX,
    required this.accY,
    required this.accZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.decibelLevel,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.batteryLevel,
    required this.isCharging,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) {
    return DeviceData(
      imeiId: json['imei_id'],
      version: json['version'],
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      pressure: (json['pressure'] ?? 0).toDouble(),
      accX: (json['acc_x'] ?? 0).toDouble(),
      accY: (json['acc_y'] ?? 0).toDouble(),
      accZ: (json['acc_z'] ?? 0).toDouble(),
      gyroX: (json['gyro_x'] ?? 0).toDouble(),
      gyroY: (json['gyro_y'] ?? 0).toDouble(),
      gyroZ: (json['gyro_z'] ?? 0).toDouble(),
      decibelLevel: (json['decibel_level'] ?? 0).toDouble(),
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      altitude: (json['altitude'] ?? 0).toDouble(),
      batteryLevel: (json['battery_level'] ?? 0).toDouble(),
      isCharging: (json['is_charging'] ?? 0) == 1,
    );
  }
}
