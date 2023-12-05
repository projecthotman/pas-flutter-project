import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project/models/home_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as myHttp;
import 'package:intl/intl.dart';

class AllRiwayat extends StatefulWidget {
  const AllRiwayat({Key? key}) : super(key: key);

  @override
  State<AllRiwayat> createState() => _AllRiwayatState();
}

class _AllRiwayatState extends State<AllRiwayat> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _token;
  HomeResponseModel? homeResponseModel;
  HomeResponseModel? presensiResponModel;
  Datum? hariIni;
  List<Datum> riwayat = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  DateTime parseTanggal(String tanggalString) {
    final bulanList = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    final parts = tanggalString.split(', ');
    if (parts.length == 2) {
      final tanggalParts = parts[1].split(' ');
      if (tanggalParts.length == 3) {
        final tanggal = int.tryParse(tanggalParts[0]);
        final bulan = bulanList.indexOf(tanggalParts[1]) + 1;
        final tahun = int.tryParse(tanggalParts[2]);

        if (tanggal != null && bulan != -1 && tahun != null) {
          return DateTime(tahun, bulan, tanggal);
        }
      }
    }

    throw FormatException('Format tanggal tidak valid: $tanggalString');
  }

  String konversiKeFormatTeks(DateTime tanggal) {
    final formattedDate = DateFormat('EEEE, d MMMM y', 'id_ID').format(tanggal);
    return formattedDate;
  }

  int hitungJumlahPresensi(List<Datum> riwayat) {
    final sekarang = DateTime.now();
    final bulanIni = sekarang.month;
    final tahunIni = sekarang.year;

    int jumlahPresensi = 0;

    for (final presensi in riwayat) {
      final tanggalPresensi = parseTanggal(presensi.tanggal);

      if (tanggalPresensi.month == bulanIni &&
          tanggalPresensi.year == tahunIni) {
        jumlahPresensi++;
      }
    }

    return jumlahPresensi;
  }

  int totalPresensi = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });

    getData();
  }

  Future getData() async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer ' + await _token
    };

    // Mendapatkan data dari API
    final homeResponse = await myHttp.get(
      Uri.parse('http://10.0.2.2:8000/api/get-presensi'),
      headers: headers,
    );

    final presensiResponse = await myHttp.get(
      Uri.parse('http://10.0.2.2:8000/api/get-total-presensi'),
      headers: headers,
    );

    print("Response dari server (Home): " + homeResponse.body);
    print("Response dari server (Presensi): " + presensiResponse.body);

    final homeResponseModel =
        HomeResponseModel.fromJson(json.decode(homeResponse.body));
    final presensiResponseModel =
        PresensiResponModel.fromJson(json.decode(presensiResponse.body));

    setState(() {
      totalPresensi = presensiResponseModel.totalPresensi;
      riwayat.clear();
      homeResponseModel.data.forEach((element) {
        if (element.isHariIni) {
          hariIni = element;
        } else {
          riwayat.add(element);
        }
      });
    });
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

  Widget buildHariIniFutureBuilder(Datum? hariIni) {
    if (hariIni == null) {
      return const Text(
        "-",
        style: TextStyle(fontSize: 18, color: Colors.white),
      );
    } else {
      return Text(
        hariIni.tanggal,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }
  }

  Widget MasukWidget() {
    return Center(
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
    );
  }

  Widget PulangWidget() {
    return Center(
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
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    String greeting = '';

    if (hour < 12) {
      greeting = 'Pagi';
    } else if (hour < 15) {
      greeting = 'Siang';
    } else if (hour < 18) {
      greeting = 'Sore';
    } else {
      greeting = 'Malam';
    }

    return greeting;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Presensi'),
        backgroundColor: Color(0xFF688E4E),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: RiwayatSearch(riwayat),
              );
            },
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
                  children: [
                    Container(
                      // Widget di atas AppBar, misalnya
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      color: Colors.grey[200],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rekap Presensi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Popup Title'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text('Dari: '),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    onTap: () async {
                                                      DateTime? selectedDate =
                                                          await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            DateTime.now(),
                                                        firstDate: DateTime(
                                                            DateTime.now()
                                                                    .year -
                                                                5),
                                                        lastDate: DateTime(
                                                            DateTime.now()
                                                                    .year +
                                                                5),
                                                      );

                                                      if (selectedDate !=
                                                          null) {
                                                        // Lakukan sesuatu dengan tanggal yang dipilih
                                                        print(selectedDate);
                                                      }
                                                    },
                                                    decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      hintText: 'Pilih Tanggal',
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(height: 20),
                                            Row(
                                              children: [
                                                Text('Ke: '),
                                                SizedBox(width: 18),
                                                Expanded(
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    onTap: () async {
                                                      DateTime? selectedDate =
                                                          await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            DateTime.now(),
                                                        firstDate: DateTime(
                                                            DateTime.now()
                                                                    .year -
                                                                5),
                                                        lastDate: DateTime(
                                                            DateTime.now()
                                                                    .year +
                                                                5),
                                                      );

                                                      if (selectedDate !=
                                                          null) {
                                                        // Lakukan sesuatu dengan tanggal yang dipilih
                                                        print(selectedDate);
                                                      }
                                                    },
                                                    decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      hintText: 'Pilih Tanggal',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Tambahkan logika untuk menampilkan popup baru di sini
                                          },
                                          child: Text('Pilih'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Icon(Icons
                                .playlist_add_check), // Menggunakan ikon Rekap Presensi
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: riwayat.length,
                        itemBuilder: (context, index) => Card(
                          child: ListTile(
                            leading: Text(riwayat[index].tanggal),
                            title: Row(
                              children: [
                                Column(
                                  children: [
                                    Text(riwayat[index].masuk ?? '-',
                                        style: const TextStyle(fontSize: 18)),
                                    const Text("Masuk",
                                        style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  children: [
                                    Text(riwayat[index].pulang ?? '-',
                                        style: const TextStyle(fontSize: 18)),
                                    const Text("Pulang",
                                        style: TextStyle(fontSize: 14)),
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
              ));
            }
          }),
    );
  }
}

class RiwayatSearch extends SearchDelegate<String> {
  final List<Datum> riwayat;

  List<Datum> filteredRiwayat = [];
  RiwayatSearch(this.riwayat);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement the logic to display the search results
    return buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement the logic to display the suggestions while typing
    return buildSearchResults();
  }

  Widget buildSearchResults() {
    filteredRiwayat = riwayat.where((datum) {
      return datum.tanggal.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredRiwayat.length,
      itemBuilder: (context, index) => ListTile(
        title: ListTile(
          leading: Text(riwayat[index].tanggal),
          title: Row(
            children: [
              Column(
                children: [
                  Text(riwayat[index].masuk ?? '-',
                      style: const TextStyle(fontSize: 18)),
                  const Text("Masuk", style: TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  Text(riwayat[index].pulang ?? '-',
                      style: const TextStyle(fontSize: 18)),
                  const Text("Pulang", style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
