import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:location/location.dart';
import 'package:project/models/save-presensi-response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:http/http.dart' as myHttp;

class SimpanPage extends StatefulWidget {
  const SimpanPage({Key? key}) : super(key: key);

  @override
  State<SimpanPage> createState() => _SimpanPageState();
}

class _SimpanPageState extends State<SimpanPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _token;

  @override
  void initState() {
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });
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

  Future savePresensi(latitude, longitude) async {
    SavePresensiResponseModel savePresensiResponseModel;
    Map<String, String> body = {
      "latitude": latitude.toString(),
      "longitude": longitude.toString()
    };
    Map<String, String> headers = {'Authorization': 'Bearer ' + await _token};

    var response = await myHttp.post(
        Uri.parse("https://cek-wa.com/presensi/public/api/save-presensi"),
        body: body,
        headers: headers);
    savePresensiResponseModel =
        SavePresensiResponseModel.fromJson(json.decode(response.body));
    if (savePresensiResponseModel.success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sukses simpan Presensi')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Gagal simpan Presensi')));
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
              print("KODING : " +
                  currentLocation.latitude.toString() +
                  " | " +
                  currentLocation.longitude.toString());
              return SafeArea(
                  child: Column(
                children: [
                  Expanded(
                    child: Container(
                        height: 400,
                        child: SfMaps(
                          layers: <MapLayer>[
                            MapTileLayer(
                              initialFocalLatLng: MapLatLng(
                                currentLocation.latitude!,
                                currentLocation.longitude!,
                              ),
                              initialZoomLevel: 15,
                              urlTemplate:
                                  "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            ),
                            // MapCircleLayer(
                            //   circles: Set.from([
                            //     MapCircle(
                            //       center: MapLatLng(
                            //         currentLocation.latitude!,
                            //         currentLocation.longitude!,
                            //       ),
                            //       radius: 1000, // Radius dalam meter
                            //       color: Colors.blue.withOpacity(0.3),
                            //       strokeWidth: 2,
                            //     ),
                            //   ]),
                            // ),
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
                                Icon(
                                  Icons.location_on,
                                  size: 30,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 9),
                                Column(
                                  children: [
                                    FutureBuilder<LocationData?>(
                                      future: _currenctLocation(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<LocationData?>
                                              snapshot) {
                                        if (snapshot.hasData) {
                                          final LocationData? currentLocation =
                                              snapshot.data;
                                          if (currentLocation!.latitude ==
                                                  -7.01996 &&
                                              currentLocation.longitude ==
                                                  110.3083233) {
                                            return Text(
                                              "SMK BAGIMU NEGERIKU",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          } else {
                                            return Text(
                                              "Lokasi Saat Ini:",
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
                                    ),
                                    // ...
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              savePresensi(currentLocation.latitude,
                                  currentLocation.longitude);
                            },
                            child: const Text("Simpan Presensi"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(340, 36),
                              primary: const Color(
                                  0xFF1E232C), // Atur warna latar belakang tombol
                            ),
                          )
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
