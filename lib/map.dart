import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Map2(),
    );
  }
}

class Map2 extends StatefulWidget {
  @override
  _Map2State createState() => _Map2State();
}

class _Map2State extends State<Map2> {
  late MapZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = MapZoomPanBehavior(enableDoubleTapZooming: true);
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: Stack(
    //     children: [
    //       SfMaps(
    //         layers: [
    //           MapTileLayer(
    //            urlTemplate: 'https://stamen-tiles.a.ssl.fastly.net/toner-background/{z}/{x}/{y}.png',
    //             zoomPanBehavior: _zoomPanBehavior,
    //           ),
    //         ],
    //       ),
    //     ],
    //   ),
    // );
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child:  SfMaps(
            layers: [
              MapTileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                zoomPanBehavior: _zoomPanBehavior,
              ),
            ],
          ),
          ),
         
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Zoom In
                    if (_zoomPanBehavior.zoomLevel < _zoomPanBehavior.maxZoomLevel) {
                      _zoomPanBehavior.zoomLevel += 1;
                    }
                  },
                  child: Text("Zoom In"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Zoom Out
                    if (_zoomPanBehavior.zoomLevel > _zoomPanBehavior.minZoomLevel) {
                      _zoomPanBehavior.zoomLevel -= 1;
                    }
                  },
                  child: Text("Zoom Out"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
