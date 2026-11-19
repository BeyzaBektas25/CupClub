import 'package:flutter/widgets.dart';

class Branch {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String workingHours;
  final bool isActive;

  Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.workingHours,
    required this.isActive,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    debugPrint('Gelen şube verisi: $json');

    return Branch(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: double.tryParse((json['latitude'] ?? '').toString()) ?? 0.0,
      longitude: double.tryParse((json['longitude'] ?? '').toString()) ?? 0.0,
      workingHours: json['working_hours'],
      isActive: json['is_active'],
    );
  }
}
