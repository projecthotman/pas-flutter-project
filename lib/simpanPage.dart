import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:location/location.dart';
import 'package:project/models/save-presensi-response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as myHttp;
import 'package:syncfusion_flutter_maps/maps.dart';

class SimpanPage extends StatefulWidget {
  const SimpanPage({Key? key}) : super(key: key);

  @override
  State<SimpanPage> createState() => _SimpanPageState();
}

class _SimpanPageState extends State<SimpanPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _token;
  late DateTime lastPresensiTime;
  int presensiCount = 0;
  bool isMasuk = true;

  @override
  void initState() {
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });
    lastPresensiTime = DateTime.now();
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

  Future savePresensiWithStatus(double latitude, double longitude, String status) async {
    DateTime currentTime = DateTime.now();

    // Memeriksa apakah sudah lewat jam 00.00, jika ya, reset hitung presensi
    if (currentTime.day != lastPresensiTime.day) {
      lastPresensiTime = currentTime;
      presensiCount = 0;
    }

    if (presensiCount == 0) {
      // Presensi pertama kali, simpan sebagai masuk
      presensiCount++;
    } else if (presensiCount == 1) {
      // Presensi kedua kali, simpan sebagai pulang
      presensiCount++;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Presensi tidak disimpan, sudah melebihi 2 kali'),
      ));
      return;
    }

    SavePresensiResponseModel savePresensiResponseModel;
    Map<String, String> body = {
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      "status": status,
    };

    Map<String, String> headers = {'Authorization': 'Bearer ' + await _token};

    var response = await myHttp.post(
      Uri.parse("https://cek-wa.com/presensi/public/api/save-presensi"),
      body: body,
      headers: headers,
    );

    savePresensiResponseModel =
        SavePresensiResponseModel.fromJson(json.decode(response.body));

    if (savePresensiResponseModel.success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sukses simpan Presensi')));
      // Reset hitung presensi jika berhasil disimpan
      presensiCount = 0;
      lastPresensiTime = currentTime;
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal simpan Presensi')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Presensi"),
      ),
      body: FutureBuilder<LocationData?>(
        future: _currenctLocation(),
        builder: (BuildContext context, AsyncSnapshot<LocationData?> snapshot) {
          if (snapshot.hasData) {
            final LocationData currentLocation = snapshot.data!;
            return SafeArea(
              child: Column(
                children: [
                  Container(
                    height: 300,
                    child: SfMaps(
                      layers: [
                        MapTileLayer(
                          initialFocalLatLng: MapLatLng(
                              currentLocation.latitude!,
                              currentLocation.longitude!),
                          initialZoomLevel: 15,
                          initialMarkersCount: 1,
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          markerBuilder: (BuildContext context, int index) {
                            return MapMarker(
                              latitude: currentLocation.latitude!,
                              longitude: currentLocation.longitude!,
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  ElevatedButton(
                    onPressed: () {
                      if (isMasuk) {
                        savePresensiWithStatus(currentLocation.latitude!, currentLocation.longitude!, "masuk");
                      } else {
                        savePresensiWithStatus(currentLocation.latitude!, currentLocation.longitude!, "pulang");
                      }

                      setState(() {
                        isMasuk = !isMasuk;
                      });
                    },
                    child: Text(isMasuk ? "Simpan Masuk" : "Simpan Pulang"),
                  )
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
