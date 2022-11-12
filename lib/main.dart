import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'package:node_auth_with_flutter/providers/user_provider.dart';
import 'package:node_auth_with_flutter/screens/home_screen.dart';
import 'package:node_auth_with_flutter/screens/signup_screen.dart';
import 'package:node_auth_with_flutter/services/auth_services.dart';
import 'package:node_auth_with_flutter/services/location_services.dart';
import 'package:provider/provider.dart';
import 'dart:async';

void main() {
  runApp(
    // ChangeNotifierProvider(
    //   create: (_) => UserProvider(),
    //   child: const MyApp(),
    // ),
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();

  // @override
  // void initState() {
  //   super.initState();
  //   authService.getUserData(context);
  // }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Node Auth',
      home: MapSample(),
      // home: context.read<UserProvider>().user.token.isEmpty
      //     ?
      //     : const HomeScreen(),
    );
  }
}

class Homwpage extends StatelessWidget {
  const Homwpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.withOpacity(0.2),
        title: const Text(
          'Map',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: const SizedBox(child: MapSample()),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final Set<Marker> _markers = <Marker>{};
  final Set<Polygon> _polygons = <Polygon>{};
  final Set<Polyline> _polylines = <Polyline>{};

  List<LatLng> polygonLatLng = <LatLng>[];
  int polygonIdCounter = 1;
  int polygonlineIdCounter = 1;

  LocationData? currentLocation;
  Location location = Location();

  // static const LatLng sourceLocation = LatLng(
  //   37.33500926,
  //   -122.03272188,
  // );

  // static const LatLng destination = LatLng(
  //   37.33429383,
  //   -122.06600055,
  // );

  // static const CameraPosition _kGooglePlex = CameraPosition(
  //   target: LatLng(37.42796133580664, -122.085749655962),
  //   zoom: 14.00,
  // );

  void getCurrentLocation() async {
    location.getLocation().then((location) {
      currentLocation = location;
      setState(() {});
    });

    // //   // setState(() {});
    // GoogleMapController googleMapController = await _controller.future;
    // location.onLocationChanged.listen((newloc) {
    //   currentLocation = newloc;

    //   googleMapController.animateCamera(CameraUpdate.newCameraPosition(
    //     CameraPosition(
    //       target: LatLng(
    //         newloc.latitude!,
    //         newloc.longitude!,
    //       ),
    //       zoom: 19.00,
    //     ),
    //   ));
    //   setState(() {});
    // });
  }

  @override
  void initState() {
    getCurrentLocation();

    super.initState();
  }

  void _setMarker(LatLng point) {
    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('marker'),
        position: point,
      ));
    });
  }

  void _setPolygon() {
    final String polygonValId = 'polygon $polygonIdCounter';
    polygonIdCounter++;
    _polygons.add(
      Polygon(
        polygonId: PolygonId(polygonValId),
        points: polygonLatLng,
        strokeWidth: 2,
        fillColor: Colors.transparent,
      ),
    );
  }

  void _setPolylines(List<PointLatLng> points) {
    final String polygonLinesId = 'polygon $polygonlineIdCounter';
    polygonlineIdCounter++;
    _polylines.add(
      Polyline(
        polylineId: PolylineId(polygonLinesId),
        width: 2,
        color: Colors.blue,
        points: points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Map',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.pink,
        centerTitle: true,
      ),
      body: currentLocation == null
          ? const Text('Loading')
          : Column(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _originController,
                                decoration: const InputDecoration(
                                  hintText: 'Origin',
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),
                              TextFormField(
                                controller: _destinationController,
                                decoration: const InputDecoration(
                                  hintText: 'Destination',
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            // print(textController.text);
                            final directions = await LocationService()
                                .getDirection(_originController.text,
                                    _destinationController.text);
                            // final place = await LocationService()
                            //     .getPlace(_originController.text);
                            _goToPlace(
                              directions['start_location']['lat'],
                              directions['start_location']['lng'],
                              directions['bounds_ne'],
                              directions['bounds_sw'],
                            );
                            _setPolylines(directions['polyline_decoded']);
                          },
                          icon: const Icon(
                            Icons.search,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: GoogleMap(
                    mapType: MapType.hybrid,
                    markers: _markers,
                    polygons: _polygons,
                    polylines: _polylines,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        currentLocation!.latitude!,
                        currentLocation!.longitude!,
                      ),
                      zoom: 19.00,
                    ),
                    // polylines: {
                    //   const Polyline(
                    //     polylineId: PolylineId("route"),
                    //     points: [
                    //       LatLng(
                    //         37.32500926,
                    //         -122.03272188,
                    //       ),
                    //       LatLng(
                    //         37.33429383,
                    //         -122.06600055,
                    //       )
                    //     ],
                    //     width: 6,
                    //     color: Colors.purple,
                    //   ),
                    // },
                    // markers: {
                    //   const Marker(
                    //     markerId: MarkerId('source'),
                    //     infoWindow: InfoWindow(title: 'White house'),
                    //     position: sourceLocation,
                    //   ),
                    //   Marker(
                    //     markerId: const MarkerId('currentLocation'),
                    //     infoWindow:
                    //         const InfoWindow(title: 'percious location'),
                    //     position: LatLng(
                    //       currentLocation!.latitude!,
                    //       currentLocation!.longitude!,
                    //     ),
                    //   ),
                    //   const Marker(
                    //     markerId: MarkerId('destination'),
                    //     infoWindow: InfoWindow(title: 'Yellow house'),
                    //     position: destination,
                    //   )
                    // },
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    onTap: (point) {
                      _setMarker(point);
                      setState(() {
                        polygonLatLng.add(point);
                        _setPolygon();
                      });
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _goToCurrentLocation();
        },
        label: const Text('Go to my Location!'),
        icon: const Icon(Icons.location_on_rounded),
      ),
    );
  }

  Future<void> _goToPlace(double lat, double lng, Map<String, dynamic> boundNE,
      Map<String, dynamic> boundSW) async {
    // final double lat = place['geometry']['location']['lat'];
    // final double lng = place['geometry']['location']['lng'];
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(
          lat,
          lng,
        ),
        zoom: 18.00,
      ),
    ));


    googleMapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            boundSW['lat'],
            boundSW['lng'],
          ),
          northeast: LatLng(
            boundNE['lat'],
            boundNE['lng'],
          ),
        ),
        25,
      ),
    );

    _setMarker(LatLng(lat, lng));
  }

  Future<void> _goToCurrentLocation() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(
          currentLocation!.latitude!,
          currentLocation!.longitude!,
        ),
        zoom: 10.00,
      ),
    ));
  }
}
