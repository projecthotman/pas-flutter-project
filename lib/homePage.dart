import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:io/ansi.dart';
import 'package:project/models/home-response.dart';
import 'simpanPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as myHttp;
import 'package:marquee/marquee.dart';

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
    final Map<String, String> headres = {
      'Authorization': 'Bearer ${await _token}'
    };
    var response = await myHttp.get(
        Uri.parse('https://cek-wa.com/presensi/public/api/get-presensi'),
        headers: headres);
    homeResponseModel = HomeResponseModel.fromJson(json.decode(response.body));
    riwayat.clear();
    homeResponseModel!.data.forEach((element) {
      if (element.isHariIni) {
        hariIni = element;
      } else {
        riwayat.add(element);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
              20.0), // Menambah jarak vertikal di bagian bawah
          child: Container(),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          color: Colors.grey, // Icon untuk tombol menu sidebar
          onPressed: () {
            // Tambahkan fungsi untuk menampilkan menu sidebar di sini
            // Misalnya, jika Anda menggunakan Drawer, Anda dapat memanggil Scaffold.of(context).openDrawer();
          },
        ),
        actions: const [
          // Widget avatar profil di sebelah kanan
          CircleAvatar(
            backgroundImage: AssetImage(
                'assets/images/profile.jpg'), // Ganti dengan gambar profil Anda
          ),
        ],
      ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ignore: sized_box_for_whitespace
                    Container(
                      width: 500,
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: FutureBuilder(
                              future: _name,
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else {
                                  if (snapshot.hasData) {
                                    // print(snapshot.data);
                                    return Text(snapshot.data!,
                                        style: const TextStyle(fontSize: 18));
                                  } else {
                                    return const Text("-",
                                        style: TextStyle(fontSize: 18));
                                  }
                                }
                              },
                            ),
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
                      color: Colors.blue[800],
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
                                borderRadius: BorderRadius.circular(
                                    8.0), // Sudut Card dibulatkan
                              ),
                              color: Colors.blue[700],
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: FractionallySizedBox(
                                      widthFactor: 1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.blue[700],
                                          border: const Border(
                                            right: BorderSide(
                                              color: Colors
                                                  .white, // Warna border kanan
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
                                        decoration: BoxDecoration(
                                          color: Colors.blue[700],
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8.0),
                                            bottomLeft: Radius.circular(8.0),
                                          ),
                                        ),
                                        child: const Padding(
                                          padding:
                                              EdgeInsets.only(left: 12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Menggunakan SingleChildScrollView untuk teks yang panjang
                                              SizedBox(
                                                height:
                                                    15, // Atur ketinggian sesuai dengan kebutuhan Anda
                                                child: SingleChildScrollView(
                                                  scrollDirection: Axis
                                                      .horizontal, // Gulung teks secara horizontal
                                                  child: Text(
                                                    "SELAMAT PAGI HOTMAN PRIMUS, SEMANGAT KERJANYA",
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
                            const SizedBox(height: 20),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8.0), // Sudut Card dibulatkan
                              ),
                              color: Colors.blue[700],
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: FractionallySizedBox(
                                      widthFactor: 1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.blue[700],
                                          border: const Border(
                                            right: BorderSide(
                                              color: Colors
                                                  .white, // Warna border kanan
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
                                        decoration: BoxDecoration(
                                          color: Colors.blue[700],
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8.0),
                                            bottomLeft: Radius.circular(8.0),
                                          ),
                                        ),
                                        child: const Padding(
                                          padding:
                                              EdgeInsets.only(left: 12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Menggunakan SingleChildScrollView untuk teks yang panjang
                                              SizedBox(
                                                height:
                                                    15, // Atur ketinggian sesuai dengan kebutuhan Anda
                                                child: SingleChildScrollView(
                                                  scrollDirection: Axis
                                                      .horizontal, // Gulung teks secara horizontal
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
                                children: [
                                  Text(riwayat[index].masuk,
                                      style: const TextStyle(fontSize: 18)),
                                  const Text("Masuk",
                                      style: TextStyle(fontSize: 14))
                                ],
                              ),
                              const SizedBox(width: 20),
                              Column(
                                children: [
                                  Text(riwayat[index].pulang,
                                      style: const TextStyle(fontSize: 18)),
                                  const Text("Pulang",
                                      style: TextStyle(fontSize: 14))
                                ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const SimpanPage()))
              .then((value) {
            setState(() {});
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
