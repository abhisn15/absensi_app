import 'dart:convert';

class Absensi {
  final DateTime date;
  final bool locationValid;
  final String photoPath;

  Absensi({
    required this.date,
    required this.locationValid,
    required this.photoPath,
  });

  String toJson() {
    return jsonEncode({
      'date': date.toIso8601String(),
      'locationValid': locationValid,
      'photoPath': photoPath,
    });
  }

  factory Absensi.fromJson(String json) {
    final map = jsonDecode(json);
    return Absensi(
      date: DateTime.parse(map['date']),
      locationValid: map['locationValid'],
      photoPath: map['photoPath'],
    );
  }
}