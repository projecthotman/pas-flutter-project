// To parse this JSON data, do
//
//     final PresensiResponModel = PresensiResponModelFromJson(jsonString);

import 'dart:convert';

PresensiResponModel PresensiResponModelFromJson(String str) => PresensiResponModel.fromJson(json.decode(str));

String PresensiResponModelToJson(PresensiResponModel data) => json.encode(data.toJson());

class PresensiResponModel {
    bool success;
    int totalPresensi;
    String message;

    PresensiResponModel({
        required this.success,
        required this.totalPresensi,
        required this.message,
    });

    factory PresensiResponModel.fromJson(Map<String, dynamic> json) => PresensiResponModel(
        success: json["success"],
        totalPresensi: json["total_presensi"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "total_presensi": totalPresensi,
        "message": message,
    };
}
