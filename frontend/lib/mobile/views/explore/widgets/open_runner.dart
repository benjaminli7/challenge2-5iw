import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../shared/services/config_service.dart';

class GPXMapScreen extends StatefulWidget {
  final Hike hike;
  const GPXMapScreen({super.key, required this.hike});
  @override
  _GPXMapScreenState createState() => _GPXMapScreenState();
}

class _GPXMapScreenState extends State<GPXMapScreen> {
  String baseUrl = ConfigService.baseUrl;
  List<LatLng> routePoints = [];
  bool noDataAvailable = false;

  @override
  void initState() {
    super.initState();
    loadGpxData();
  }



  Future<void> loadGpxData() async {
    if (widget.hike.gpxFile.isEmpty) {
      setState(() {
        noDataAvailable = true;
      });
      return;
    }

    final response = await http
        .get(Uri.parse('$baseUrl${widget.hike.gpxFile}'));
    if (response.statusCode == 200) {
      final gpxString = response.body;

      final points = await HikeProvider().parseGPX(gpxString);
;
      setState(() {
        routePoints = points;
        noDataAvailable = points.isEmpty;
      });
    } else {
      setState(() {
        noDataAvailable = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(AppLocalizations.of(context)!.gpxRouteViewer),
        automaticallyImplyLeading: false,
      ),
      body: noDataAvailable
          ?  Center(
              child: Text(
                AppLocalizations.of(context)!.noDataAvailable,
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            )
          : routePoints.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return FlutterMap(
                      options: MapOptions(
                        initialCenter: routePoints.isNotEmpty
                            ? routePoints.first
                            : const LatLng(0, 0),
                        initialZoom: 10.0,
                        interactionOptions: const InteractionOptions(

                            ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: routePoints,
                              strokeWidth: 4.0,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
