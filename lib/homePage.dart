import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:project/models/home-response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as myHttp;
import 'package:percent_indicator/percent_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _name, _token;
  HomeResponseModel? homeResponseModel;
  Datum? hariIni;
  List<Datum> riwayat = [];

  @override
  void initState() {
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });

    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });
  }

  Future getData() async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer ${await _token}'
    };
    var response = await myHttp.get(
        Uri.parse('https://cek-wa.com/presensi/public/api/get-presensi'),
        headers: headers);
    homeResponseModel = HomeResponseModel.fromJson(json.decode(response.body));
    riwayat.clear();
    homeResponseModel!.data.forEach((element) {
      if (element.isHariIni) {
        hariIni = element;
      } else {
        riwayat.add(element);
      }
    });

    // Panggil setState untuk memperbarui tampilan
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String _getGreeting() {
      final hour = DateTime.now().hour;
      String greeting = '';

      if (hour < 12) {
        greeting = 'Pagi';
      } else if (hour < 17) {
        greeting = 'Siang';
      } else if (hour < 20) {
        greeting = 'Sore';
      } else {
        greeting = 'Malam';
      }

      return greeting;
    }

    Widget buildNameFutureBuilder(Future<String> future) {
      return FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.hasData) {
              return Text(
                snapshot.data!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            } else {
              return const Text(
                "-",
                style: TextStyle(fontSize: 18),
              );
            }
          }
        },
      );
    }

    return Scaffold(
      body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return SafeArea(
                  child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 16,
                    ),
                    Container(
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Agar teks sejajar kiri
                            children: <Widget>[
                              Row(
                                children: [
                                  Text(
                                    "Selamat ${_getGreeting()} !",
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.waving_hand,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              buildNameFutureBuilder(_name),
                            ],
                          ),
                          const Spacer(),
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.notifications,
                                color: Colors
                                    .black, // Ubah warna ikon notifikasi sesuai preferensi Anda
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Container(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              CircularPercentIndicator(
                                radius: 30,
                                lineWidth: 8,
                                percent: 0.4,
                                progressColor: Color(0xFF688E4E),
                                backgroundColor: Colors.blue.shade100,
                                circularStrokeCap: CircularStrokeCap.round,
                                center: const Text('40%', style: TextStyle(fontSize: 16)),
                              ),
                              const SizedBox(width: 16),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Kehadiranmu sebulan ini",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.keyboard_arrow_up,
                                        size: 18,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "meningkat 5% dari bulan lalu",
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text("Presensi"),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      color: const Color(0xFF688E4E),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hariIni?.tanggal ?? '-',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0), // Sudut Card dibulatkan
                              ),
                              color:const Color(0xFF688E4E),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: FractionallySizedBox(
                                      widthFactor: 1,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF688E4E),
                                          border: Border(
                                            right: BorderSide(
                                              color: Colors.white, // Warna border kanan
                                              width: 2.0, // Lebar border kanan
                                            ),
                                          ),
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              hariIni?.masuk ?? '-',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF688E4E),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8.0),
                                            bottomLeft: Radius.circular(8.0),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Menggunakan SingleChildScrollView untuk teks yang panjang
                                              Container(
                                                  width: double.infinity,
                                                  height: 15, // Atur ketinggian sesuai dengan kebutuhan Anda
                                                  child: Marquee(
                                                    text: "SELAMAT PAGI HOTMAN, SEMANGAT KERJANYA | ",
                                                    startAfter: const Duration(seconds: 3),
                                                    velocity: 25,
                                                    style: const TextStyle(color: Colors.white),
                                                  )),
                                              const Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(right: 5),
                                                    child: Card(
                                                      color: Colors.green,
                                                      child: Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    "BERHASIL",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0), // Sudut Card dibulatkan
                              ),
                              color: const Color(0xFF688E4E),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: FractionallySizedBox(
                                      widthFactor: 1,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF688E4E),
                                          border: Border(
                                            right: BorderSide(
                                              color: Colors.white, // Warna border kanan
                                              width: 2.0, // Lebar border kanan
                                            ),
                                          ),
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              hariIni?.pulang ?? '-',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF688E4E),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8.0),
                                            bottomLeft: Radius.circular(8.0),
                                          ),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.only(left: 12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Menggunakan SingleChildScrollView untuk teks yang panjang
                                              SizedBox(
                                                height: 15, // Atur ketinggian sesuai dengan kebutuhan Anda
                                                child: SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal, // Gulung teks secara horizontal
                                                  child: Text(
                                                    "SELAMAT SORE HOTMAN PRIMUS, SAMPAI JUMPA BESOK`",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(right: 5),
                                                    child: Card(
                                                      color: Colors.green,
                                                      child: Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    "BERHASIL",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Riwayat Presensi"),
                    Expanded(
                      child: ListView.builder(
                        itemCount: riwayat.length,
                        itemBuilder: (context, index) => Card(
                          child: ListTile(
                            leading: Text(riwayat[index].tanggal),
                            title: Row(children: [
                              Column(
                                children: [Text(riwayat[index].masuk, style: const TextStyle(fontSize: 18)), const Text("Masuk", style: TextStyle(fontSize: 14))],
                              ),
                              const SizedBox(width: 20),
                              Column(
                                children: [Text(riwayat[index].pulang, style: const TextStyle(fontSize: 18)), const Text("Pulang", style: TextStyle(fontSize: 14))],
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
            }
          }),
      
    );
  }
}
