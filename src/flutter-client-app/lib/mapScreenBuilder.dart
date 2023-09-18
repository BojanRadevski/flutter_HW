// ignore_for_file: sized_box_for_whitespace

import 'dart:ui' as ui;
import 'package:demo/models/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:demo/directions_repository.dart';
import 'package:demo/models/directions_model.dart';

// ignore: must_be_immutable
class MapScreen extends StatefulWidget {
  MapScreen({Key? key, required this.locs, this.markerIcons}) : super(key: key);
  List<Location> locs;
  // ignore: prefer_typing_uninitialized_variables
  final markerIcons;
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Marker> _markers = <Marker>[];
  List<Marker> _currentMarkers = <Marker>[];
  List<Location> _currentLocations = <Location>[];
  BitmapDescriptor myIcon = BitmapDescriptor.defaultMarker;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Location locationDetails = Location(-1, "a", 1, 1, "a", "a");
  Location selectedLocation = Location(-1, "a", 1, 1, "a", "a");
  late GoogleMapController _googleMapController;
  final _initialCameraPosition =
      const CameraPosition(target: LatLng(41.997345, 21.427996), zoom: 11.5);
  final String fillerDescription =
      "Mnogu ubavo mesto za poseta. Posetete go ova mesto. Neizmerna ubavina ve ochekuva na ova mesto.";
  LatLng currentLocation = const LatLng(0, 0);
  Location destination = Location(-1, "a", 1, 1, "a", "a");
  Directions _directions = Directions(
      bounds: null,
      polylinePoins: null,
      totalDistance: null,
      totalDuration: null);

  Position? currentPosition;
  var geoLocator = Geolocator();

  void showPath(Location destinationLocation) async {
    LatLng destinationLatLng =
        LatLng(destinationLocation.lat, destinationLocation.lon);
    final directions = await DirectionsRepository()
        .getDirections(origin: currentLocation, destination: destinationLatLng);
    setState(() {
      _directions = directions;
      destination = destinationLocation;
    });
  }

  void removePath() {
    setState(() {
      destination = Location(-1, "a", 1, 1, "a", "a");
      _directions = Directions(
          bounds: null,
          polylinePoins: null,
          totalDistance: null,
          totalDuration: null);
    });
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    currentLocation = LatLng(position.latitude, position.longitude);
  }

  @override
  // ignore: must_call_super
  void initState() {
    _markers = List<Location>.from(widget.locs)
        .map((e) => Marker(
              icon: widget.markerIcons[e.type] == null
                  ? BitmapDescriptor.defaultMarker
                  : widget.markerIcons[e.type]!,
              markerId: MarkerId(e.id.toString()),
              position: LatLng(e.lat, e.lon),
              infoWindow: InfoWindow(
                  title: e.name,
                  snippet: e.type,
                  onTap: () => {showDetails(e.id)}),
            ))
        .toList();
    _currentMarkers = _markers.map((e) => e).toList();
    _currentLocations = widget.locs;
  }

  void filterLocations(String type) {
    final currentLocations =
        widget.locs.where((element) => element.type == type);

    if (!currentLocations.contains(destination)) {
      removePath();
    }
    setState(() {
      _currentMarkers = currentLocations
          .map((e) => Marker(
              icon: widget.markerIcons[e.type] == null
                  ? BitmapDescriptor.defaultMarker
                  : widget.markerIcons[e.type]!,
              markerId: MarkerId(e.id.toString()),
              position: LatLng(e.lat, e.lon),
              infoWindow: InfoWindow(
                  title: e.name,
                  snippet: e.type,
                  onTap: () => {showDetails(e.id)})))
          .toList();
      _currentLocations = currentLocations.toList();
    });
  }

  void showDetails(int id) {
    setState(() {
      locationDetails = widget.locs.firstWhere((location) => location.id == id);
    });
    _scaffoldKey.currentState!.openDrawer();
  }

  void showAll() {
    setState(() {
      _currentMarkers = _markers.map((e) => e).toList();
      _currentLocations = widget.locs;
    });
  }

  List<Location> filter(String value) {
    return _currentLocations
        .where((element) =>
            element.name.toLowerCase().contains(value.toLowerCase()))
        .take(5)
        .toList();
  }

  AssetImage getImageByType(String type) {
    switch (type) {
      case "CAVE":
        return const AssetImage("assets/bgImages/cave.jfif");
      case "LAKE":
        return const AssetImage("assets/bgImages/lake.jfif");
      case "LODGE":
        return const AssetImage("assets/bgImages/lodge.jfif");
      case "PEAK":
        return const AssetImage("assets/bgImages/peak.jfif");
      case "SPRING":
        return const AssetImage("assets/bgImages/spring.jfif");
      default:
        return const AssetImage("assets/bgImages/waterfall.jfif");
    }
  }

  void focusOnLocation(Location location) {
    _googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(location.lat, location.lon),
      zoom: 14.5,
      tilt: 50.0,
    )));
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color.fromARGB(255, 45, 71, 74);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: mainColor,
          automaticallyImplyLeading: false,
          title: Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: TypeAheadField(
                    noItemsFoundBuilder: (context) => const SizedBox(
                      height: 50,
                      child: Center(
                        child: Text('No Items Found'),
                      ),
                    ),
                    suggestionsBoxDecoration: const SuggestionsBoxDecoration(
                        color: Colors.white,
                        elevation: 4.0,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15.0),
                          bottomRight: Radius.circular(15.0),
                        )),
                    debounceDuration: const Duration(milliseconds: 400),
                    textFieldConfiguration: TextFieldConfiguration(
                        decoration: InputDecoration(
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                              15.0,
                            )),
                            enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15.0),
                                ),
                                borderSide: BorderSide(color: Colors.black)),
                            hintText: "Search",
                            contentPadding:
                                const EdgeInsets.only(top: 4, left: 10),
                            hintStyle: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                            suffixIcon: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.search,
                                    color: Colors.grey)),
                            fillColor: Colors.white,
                            filled: true)),
                    suggestionsCallback: (value) {
                      return filter(value);
                    },
                    itemBuilder: (context, Location suggestion) {
                      return Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          const Icon(
                            Icons.refresh,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                suggestion.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                        ],
                      );
                    },
                    onSuggestionSelected: (Location suggestion) {
                      focusOnLocation(suggestion);
                    },
                  )),
            ),
          )),
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: false,
      drawer: Container(
        width: MediaQuery.of(context).size.width - 50,
        child: Drawer(
          backgroundColor: mainColor,
          child: ListView(
            children: [
              Container(
                  height: 190,
                  child: DrawerHeader(
                    child: const Text(""),
                    decoration: BoxDecoration(
                        color: Colors.green,
                        image: DecorationImage(
                            image: getImageByType(locationDetails.type),
                            fit: BoxFit.cover)),
                  )),
              ListBody(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                    child: Container(
                      height: 370,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromARGB(200, 132, 136, 132)),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 10, 0),
                            child: Row(children: [
                              const Expanded(
                                flex: 1,
                                child: Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(0, 0, 10, 0),
                                  child: Text(
                                    "Name:",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 7, 10, 10),
                                    child: Text(
                                      locationDetails.name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ))
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
                            child: Row(children: [
                              const Expanded(
                                flex: 1,
                                child: Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Text(
                                    "Longitude:",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      locationDetails.lon.toString(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ))
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
                            child: Row(children: [
                              const Expanded(
                                flex: 1,
                                child: Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Text(
                                    "Latitude:",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      locationDetails.lat.toString(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ))
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 10, 0),
                            child: Row(
                              // ignore: prefer_const_literals_to_create_immutables
                              children: [
                                 const Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: Text(
                                        "Description:",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 5, 10, 0),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: Expanded(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Text(
                                            locationDetails.description +
                                                fillerDescription,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                    ))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.amber,
                                fixedSize: const ui.Size(125, 40)),
                            onPressed: () {
                              showPath(locationDetails);
                              Navigator.pop(context);
                            },
                            child: Row(
                              // ignore: prefer_const_literals_to_create_immutables
                              children: [
                                const Text(
                                  "Directions",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const Icon(
                                  Icons.directions,
                                  color: Colors.white,
                                )
                              ],
                            ))
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
      body: Stack(children: <Widget>[
        GoogleMap(
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          polylines: {
            if (_directions.bounds != null)
              Polyline(
                polylineId: const PolylineId('overview_polyline'),
                color: Colors.red,
                width: 5,
                points: _directions.polylinePoins!
                    .map((e) => LatLng(e.latitude, e.longitude))
                    .toList(),
              ),
          },
          markers: _currentMarkers.toSet(),
          initialCameraPosition: _initialCameraPosition,
          onMapCreated: (GoogleMapController controller) {
            _googleMapController = controller;
            locatePosition();
          },
        ),
        if (_directions.totalDistance != null)
          Positioned(
              //top: 0.0,
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  margin: const EdgeInsets.only(top: 25.0),
                  child: IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.black,
                      iconSize: 40,
                      splashRadius: 40,
                      splashColor: Colors.greenAccent,
                      tooltip: 'remove path',
                      onPressed: removePath)),
              Container(
                margin: const EdgeInsets.only(top: 25.0),
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.yellowAccent,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    )
                  ],
                ),
                child: Text(
                  '${_directions.totalDistance}, ${_directions.totalDuration}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          )),
      ]),
      floatingActionButton: SpeedDial(
        //backgroundColor: Colors.white,
        backgroundColor: mainColor,
        animatedIcon: AnimatedIcons.menu_close,
        overlayColor: Colors.white,
        overlayOpacity: 0.25,
        spacing: 12,
        spaceBetweenChildren: 12,
        //openCloseDial: isDialOpen,
        closeManually: false,
        children: [
          SpeedDialChild(
              //backgroundColor: Colors.green,
              label: 'Caves',
              onTap: () => {filterLocations("CAVE")},
              child: Image.asset("assets/cave_icon.png")
              //ImageIcon(AssetImage("assets/cave_icon.png"),size: 30,)
              ),
          SpeedDialChild(
              backgroundColor: Colors.green,
              onTap: () => {filterLocations("LAKE")} /*samo springs */,
              child: Image.asset("assets/lake_icon.png"),
              labelWidget: Container(
                child: const Text("Lakes"),
                color: Colors.white,
                margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
              )
              // label: 'Lakes',
              ),
          SpeedDialChild(
            backgroundColor: Colors.green,
            label: 'Peaks',
            child: Image.asset("assets/mountain_icon.png"),
            onTap: () => {filterLocations("PEAK")},
          ),
          SpeedDialChild(
            backgroundColor: Colors.green,
            label: 'Waterfalls',
            child: Image.asset("assets/waterfall_icon.png"),
            onTap: () => {filterLocations("WATERFALL")},
          ),
          SpeedDialChild(
            backgroundColor: Colors.green,
            label: 'Springs',
            child: Image.asset("assets/river_icon.png"),
            onTap: () => {filterLocations("SPRING")},
          ),
          SpeedDialChild(
            backgroundColor: Colors.green,
            label: 'Lodges',
            child: Image.asset("assets/lodge_icon.png"),
            onTap: () => {filterLocations("LODGE")},
          ),
          SpeedDialChild(
            backgroundColor: mainColor,
            label: 'ALL',
            onTap: () => {showAll()},
            child: const Icon(
              Icons.all_out,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }
}
