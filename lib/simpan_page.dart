import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:project/models/save_presensi_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:http/http.dart' as my_http;
import 'tabbar/master.dart';

import 'dart:math' as math;

import 'map.dart';

class SimpanPage extends StatefulWidget {
  // ignore: use_super_parameters
  const SimpanPage({Key? key}) : super(key: key);

  @override
  State<SimpanPage> createState() => _SimpanPageState();
}

class _SimpanPageState extends State<SimpanPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _token;

  late MapZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });
    _zoomPanBehavior = MapZoomPanBehavior(
      enableDoubleTapZooming: true,
      zoomLevel: 15, // Sesuaikan dengan level yang diinginkan
    );
  }

  Future<LocationData?> _currenctLocation() async {
    bool serviceEnable;
    PermissionStatus permissionGranted;

    Location location = Location();

    serviceEnable = await location.serviceEnabled();

    if (!serviceEnable) {
      serviceEnable = await location.requestService();
      if (!serviceEnable) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    return await location.getLocation();
  }

  // Fungsi untuk menghitung jarak antara dua titik menggunakan Haversine formula
  double _calculateHaversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Radius bumi dalam kilometer

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) + math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

// Fungsi bantu untuk mengonversi derajat ke radian
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  Future savePresensi(latitude, longitude) async {
    SavePresensiResponseModel savePresensiResponseModel;
    Map<String, String> body = {"latitude": latitude.toString(), "longitude": longitude.toString()};
    Map<String, String> headers = {'Authorization': 'Bearer ${await _token}'};

    var response = await my_http.post(Uri.parse("http://10.0.2.2:8000/api/save-presensi"), body: body, headers: headers);
    // print('Response from server: ${response.body}');
    savePresensiResponseModel = SavePresensiResponseModel.fromJson(json.decode(response.body));
    if (savePresensiResponseModel.success) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sukses simpan Presensi')));
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MasterTabbar()));
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal simpan Presensi')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<LocationData?>(
          future: _currenctLocation(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              final LocationData currentLocation = snapshot.data;
              MapLatLng location = MapLatLng(
                currentLocation.latitude!,
                currentLocation.longitude!,
              );
              // ignore: avoid_print
              print("Lokasi Anda : ${currentLocation.latitude} | ${currentLocation.longitude}");
              return SafeArea(
                  child: Column(
                children: [
                  Expanded(
                    child: SizedBox(
                        height: 400,
                        child: SfMaps(
                          layers: <MapLayer>[
                            MapTileLayer(
                              initialFocalLatLng: location,
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              zoomPanBehavior: _zoomPanBehavior,
                              markerBuilder: (BuildContext context, int index) {
                                return MapMarker(
                                  latitude: location.latitude,
                                  longitude: location.longitude,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 100,
                                  ),
                                );
                              },
                            ),
                          ],
                        )),
                  ),
                  Container(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 2,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Icon(
                                  Icons.location_on,
                                  size: 30,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 9),
                                Column(
                                  children: [
                                    FutureBuilder<LocationData?>(
                                      future: _currenctLocation(),
                                      builder: (BuildContext context, AsyncSnapshot<LocationData?> snapshot) {
                                        if (snapshot.hasData) {
                                          final LocationData? currentLocation = snapshot.data;

                                          // Koordinat 1 di wilayah SMK BN
                                          double centerLatitude1 = -7.019950742580668;
                                          double centerLongitude1 = 110.30832545032034;

                                          // Koordinat 2 di wilayah Asrama Putra BN
                                          double centerLatitude2 = -7.019471;
                                          double centerLongitude2 = 110.3112571;

                                          // Koordinat 3 di wilayah Asrama Putri BN
                                          double centerLatitude3 = -7.0195361;
                                          double centerLongitude3 = 110.3084811;

                                          double threshold = 0.1; // Nilai ambang batas dalam kilometer, misalnya 0.1 km (100 meter)

                                          // Menghitung jarak antara dua titik menggunakan Haversine formula untuk lokasi pertama
                                          double distance1 = _calculateHaversineDistance(
                                            currentLocation!.latitude!,
                                            currentLocation.longitude!,
                                            centerLatitude1,
                                            centerLongitude1,
                                          );

                                          // Menghitung jarak antara dua titik menggunakan Haversine formula untuk lokasi kedua
                                          double distance2 = _calculateHaversineDistance(
                                            currentLocation.latitude!,
                                            currentLocation.longitude!,
                                            centerLatitude2,
                                            centerLongitude2,
                                          );

                                          // Menghitung jarak antara dua titik menggunakan Haversine formula untuk lokasi kedua
                                          double distance3 = _calculateHaversineDistance(
                                            currentLocation.latitude!,
                                            currentLocation.longitude!,
                                            centerLatitude3,
                                            centerLongitude3,
                                          );

                                          print("Distance 1: $distance1");
                                          print("Distance 2: $distance2");
                                          print("Distance 3: $distance3");
                                          print("Current Location: ${currentLocation?.latitude}, ${currentLocation?.longitude}");

                                          if (distance1 <= threshold) {
                                            return const Text(
                                              "SMK BAGIMU NEGERIKU",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          } else if (distance2 <= threshold) {
                                            return const Text(
                                              "Aspa BN",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          } else if (distance3 <= threshold) {
                                            return const Text(
                                              "Aspi BN",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          } else {
                                            return const Text(
                                              "Bukan titik lokasi ",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          }
                                        } else {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                      },
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              savePresensi(currentLocation.latitude, currentLocation.longitude);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(340, 36),
                              backgroundColor: const Color(0xFF1E232C), // Atur warna latar belakang tombol
                            ),
                            child: const Text("Simpan Presensi"),
                          ),
                          // const SizedBox(height: 10),
                          // ElevatedButton(onPressed: (){ToMap2(context);}, child: const Text("Peta2"))
                        ],
                      ),
                    ),
                  ),
                ],
              ));
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}

// void ToMap2(BuildContext context) {
//   // Gunakan Navigator untuk berpindah ke halaman Map2
//   Navigator.push(
//     context,
//     MaterialPageRoute(builder: (context) => Map2()),
//   );
// }