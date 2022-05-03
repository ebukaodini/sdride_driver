import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sdride_driver/models/driver.model.dart';
import 'package:sdride_driver/models/order.model.dart';
import 'package:sdride_driver/pages/directions_model.dart';
import 'package:sdride_driver/pages/directions_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sdride_driver/providers/Driver.dart';
import 'package:sdride_driver/providers/Order.dart';
import 'package:sdride_driver/providers/Rider.dart';
import 'package:sdride_driver/utils/functions.dart';
import 'package:sdride_driver/widgets/error.dart';
import 'package:sdride_driver/widgets/notice.dart';
import 'package:sdride_driver/widgets/success.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static CameraPosition? initialCameraPosition;

  GoogleMapController? _googleMapController;

  Location location = new Location();
  Directions? travelInfo;

  BitmapDescriptor? riderMarker;
  BitmapDescriptor? driverMarker;
  BitmapDescriptor? originMarker;
  BitmapDescriptor? destinationMarker;
  BitmapDescriptor? travelDriverMarker;
  Marker? travelRiderMarker;
  bool isPageReady = false;

  @override
  initState() {
    super.initState();
    initPage();
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  Future initPage() async {
    loadMarkers();
    await getCurrentLocation();
    setInitialCameraLocation();
    await getChangingLocation();
    // showRidersRequestingMyRideOnMap();
    setState(() => isPageReady = true);
    await fetchOrders();
  }

  Future fetchOrders() async {
    Order pOrder = context.read<Order>();
    Driver pDriver = context.read<Driver>();
    if (pOrder.orders!.isEmpty == true && pDriver.driver!.isOnline! == true) {
      await pOrder.getOrders();
    }
  }

  void setInitialCameraLocation() {
    setState(() {
      initialCameraPosition = CameraPosition(
        target: myLocation!,
        zoom: zoomLevel!,
      );
    });
  }

  Future getChangingLocation() async {
    Driver pDriver = context.read<Driver>();
    location.onLocationChanged.listen((LocationData currentLocation) async {
      setState(() {
        myLocation =
            LatLng(currentLocation.latitude!, currentLocation.longitude!);
      });
      await pDriver.updateLocation(myLocation!);
      Rider pRider = context.read<Rider>();
      if (selectedOrder!.riderId != null) {
        LatLng pos = await pRider.getLocation(selectedOrder!.riderId!);
        // update the marker
        setState(() {
          riderLocation = pos;
          travelRiderMarker = Marker(
            markerId: MarkerId("rider_${selectedOrder!.riderId!}"),
            infoWindow: const InfoWindow(title: 'Rider'),
            icon: riderMarker!,
            position: pos,
            zIndex: 999,
          );
        });

        // get travel details
        Directions directions = await getDirection(pos, myLocation);
        setState(() {
          pickupDirectionInfo =
              "Rider is ${directions.totalDistance} away. You should get to rider in ${directions.totalDuration}.";
        });
      }
    });
  }

  updateMarker() {}

  Future getCurrentLocation() async {
    try {
      // enable background mode
      location.enableBackgroundMode(enable: true);

      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      LocationData _locationData;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      _locationData = await location.getLocation();

      setState(
        () {
          myLocation =
              LatLng(_locationData.latitude!, _locationData.longitude!);
        },
      );

      Driver pDriver = context.read<Driver>();
      await pDriver.updateLocation(myLocation!);
    } catch (e) {
      error(context, "Get Location Error: " + e.toString());
    }
  }

  void loadMarkers() {
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      'assets/markers/rider.png',
    ).then(
      (value) => setState(() {
        riderMarker = value;
      }),
    );
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      'assets/markers/driver.png',
    ).then(
      (value) => setState(() {
        driverMarker = value;
      }),
    );
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      'assets/markers/travelDriver.png',
    ).then(
      (value) => setState(() {
        travelDriverMarker = value;
      }),
    );
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      'assets/markers/origin.png',
    ).then(
      (value) => setState(() {
        originMarker = value;
      }),
    );
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      'assets/markers/destination.png',
    ).then(
      (value) => setState(() {
        destinationMarker = value;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Driver>(builder: (BuildContext context, pDriver, child) {
      return Consumer<Order>(builder: (BuildContext context, pOrder, child) {
        return Consumer<Rider>(builder: (BuildContext context, pRider, child) {
          return Scaffold(
            body: Stack(
              alignment: Alignment.center,
              children: [
                if (isPageReady == true)
                  GoogleMap(
                    myLocationEnabled: true,
                    indoorViewEnabled: true,
                    zoomControlsEnabled: false,
                    initialCameraPosition: initialCameraPosition!,
                    onMapCreated: (controller) =>
                        _googleMapController = controller,
                    markers: {
                      if (travelRiderMarker != null) travelRiderMarker!,
                      if (travelInfo != null && showTravelDirection == true)
                        if (travelOriginMarker != null) travelOriginMarker!,
                      if (travelInfo != null && showTravelDirection == true)
                        if (travelDestinationMarker != null)
                          travelDestinationMarker!,
                    },
                    polylines: {
                      // travel polyline
                      if (travelInfo != null && showTravelDirection == true)
                        Polyline(
                          polylineId: const PolylineId('travel_polyline'),
                          color: Colors.blue.shade900,
                          width: 10,
                          startCap: Cap.roundCap,
                          endCap: Cap.roundCap,
                          jointType: JointType.round,
                          points: travelInfo!.polylinePoints!
                              .map((e) => LatLng(e.latitude, e.longitude))
                              .toList(),
                        ),

                      if (pickupInfo != null && showPickupDirection == true)
                        Polyline(
                          polylineId: const PolylineId('pickup_polyline'),
                          color: Colors.green,
                          width: 15,
                          patterns: [
                            PatternItem.dot,
                            PatternItem.gap(20),
                          ],
                          startCap: Cap.roundCap,
                          endCap: Cap.roundCap,
                          jointType: JointType.round,
                          points: pickupInfo!.polylinePoints!
                              .map((e) => LatLng(e.latitude, e.longitude))
                              .toList(),
                        ),
                    },
                  ),

                // show loading while page is loading
                if (isPageReady == false)
                  Center(
                    child: CircularProgressIndicator(),
                  ),

                if (isPageReady == true)
                  Positioned(
                    top: 50,
                    left: 20,
                    child: FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.black,
                      onPressed: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back_rounded),
                    ),
                  ),

                if (isPageReady == true)
                  Positioned(
                    top: 120,
                    left: 20,
                    child: FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.black,
                      onPressed: () => toggleDriverOnlineOffline(),
                      child: Icon(
                        CupertinoIcons.dot_radiowaves_left_right,
                        color: pDriver.driver!.isOnline!
                            ? Colors.green
                            : Colors.black54,
                        size: 35,
                      ),
                    ),
                  ),

                if (isPageReady == true)
                  // display the info distance and time estimation info
                  if (travelInfo != null && showTravelDirection == true)
                    Positioned(
                      top: 50,
                      right: 20,
                      height: 55,
                      width: screen(context).width * 0.6,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 6.0,
                            )
                          ],
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '${travelInfo!.totalDistance}, ${travelInfo!.totalDuration}',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                DraggableScrollableSheet(
                  initialChildSize: 0.30,
                  minChildSize: 0.30,
                  maxChildSize: 0.40,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return SingleChildScrollView(
                      controller: scrollController,
                      child: Container(
                        margin: EdgeInsets.only(top: 10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 5.0,
                              spreadRadius: 5,
                              offset: Offset.zero,
                            ),
                          ],
                          color: Colors.white,
                        ),
                        child: bottomSheetPage == BottomSheetPage.SELECT_ORDER
                            ? showSelectOrder()
                            : bottomSheetPage == BottomSheetPage.CONFIRM_RIDE
                                ? showConfirmRide()
                                : bottomSheetPage ==
                                        BottomSheetPage.PICKUP_RIDER
                                    ? showPickupRider()
                                    : showStartRide(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        });
      });
    });
  }

  void addRiderMarker(LatLng pos, riderId) {
    try {
      setState(() {
        travelRiderMarker = Marker(
          markerId: MarkerId("rider_$riderId"),
          infoWindow: const InfoWindow(title: 'Rider'),
          icon: riderMarker!,
          position: pos,
          zIndex: 999,
        );
      });
    } catch (e) {
      error(context, e.toString());
    }
  }

  void removeRiderMarker() {
    try {
      setState(() {
        travelRiderMarker = null;
      });
    } catch (e) {
      error(context, e.toString());
    }
  }

  void addTravelMarker() {
    setState(() {
      travelOriginMarker = Marker(
        markerId: const MarkerId('origin'),
        infoWindow: const InfoWindow(title: 'Origin'),
        icon: originMarker!,
        position: travelOrigin!,
        zIndex: 99,
      );
      travelDestinationMarker = Marker(
        markerId: const MarkerId('destination'),
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: destinationMarker!,
        position: travelDestination!,
        zIndex: 99,
      );
    });
  }

  Future setTravelDirection() async {
    // Get travel directions
    if (travelOrigin != null && travelDestination != null) {
      final directions = await getDirection(travelOrigin, travelDestination);

      setState(() {
        travelInfo = directions;
        showTravelDirection = true;
      });

      _googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: travelDestination!,
            zoom: 12,
          ),
        ),
      );
    }
  }

  Future setPickupDirection() async {
    // Get travel directions
    if (myLocation != null && riderLocation != null) {
      final directions = await getDirection(myLocation, riderLocation);

      setState(() {
        pickupInfo = directions;
        pickupDirectionInfo =
            "Rider is ${directions.totalDistance} away. You should get to rider in ${directions.totalDuration}.";
        showPickupDirection = true;
      });

      _googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: riderLocation!,
            zoom: 16,
          ),
        ),
      );
    }
  }

  Future<Directions> getDirection(LatLng? origin, LatLng? destination) async {
    // Get directions
    Directions directions = await DirectionsRepository().getDirections(
      origin: origin,
      destination: destination,
    );

    return directions;
  }

  // Bottom Sheets
  bool showDestination = true;
  bool showPickupDirection = false;
  String? pickupDirectionInfo;
  double? zoomLevel = 16;
  LatLng? travelOrigin;
  LatLng? myLocation;
  LatLng? travelDestination;
  Marker? travelOriginMarker;
  Marker? travelDestinationMarker;
  bool showTravelDirection = false;
  BottomSheetPage bottomSheetPage = BottomSheetPage.SELECT_ORDER;
  OrderModel? selectedOrder;
  LatLng? riderLocation;
  Directions? pickupInfo;

  bool driverIsOnline = false;
  List<Map<String, dynamic>> rideOrders = [
    {
      'name': 'Ikeja City Mall',
      'address': 'Obafemi Awolowo Way, Ikeja, Nigeria',
      'lat': 6.613607021590709,
      'lng': 3.3579758182168002,
      'rider': {
        'id': 12341,
        'lat': 6.515163147958853,
        'lng': 3.31046249717474,
        'pickupInfo': '',
        'detailedPickupInfo': ''
      },
    },
    {
      'name': 'Oshodi Market',
      'address': 'Oshodi Market, Oshodi, Nigeria',
      'lat': 6.553138345416473,
      'lng': 3.3369003608822823,
      'rider': {
        'id': 12342,
        'lat': 6.513377004308796,
        'lng': 3.3138377219438553,
        'pickupInfo': '',
        'detailedPickupInfo': ''
      },
    },
    {
      'name': 'Chevron Drive Lekki',
      'address': 'Chevron Drive, Lekki, Nigeria',
      'lat': 6.441771477695865,
      'lng': 3.53067085146904,
      'rider': {
        'id': 12343,
        'lat': 6.51361151513941,
        'lng': 3.3139265701174736,
        'pickupInfo': '',
        'detailedPickupInfo': ''
      },
    },
    {
      'name': 'Lagos State Polytechnic',
      'address': 'Lagos State Polytechnic, Isolo, Nigeria',
      'lat': 6.531149882892987,
      'lng': 3.333965353667736,
      'rider': {
        'id': 12344,
        'lat': 6.51320978203025,
        'lng': 3.3138196170330048,
        'pickupInfo': '',
        'detailedPickupInfo': ''
      },
    },
  ];

  Future toggleDriverOnlineOffline() async {
    try {
      Driver pDriver = context.read<Driver>();
      Order pOrder = context.read<Order>();
      await pDriver.updateOnline().then((value) async {
        if (pDriver.driver!.isOnline! == true) {
          await pOrder.getOrders();
        }
        success(context,
            "Driver is ${pDriver.driver!.isOnline! ? 'Online' : 'Offline'}");
      });
    } catch (e) {
      error(context, e.toString());
    }
  }

  // Select Order Sheet
  Widget showSelectOrder() {
    return Column(
      children: <Widget>[
        SizedBox(height: 12),
        Container(
          height: 5,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        SizedBox(height: 16),
        Text(
          "Select Order",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 24),
        renderOrders(),
        SizedBox(height: 16),
      ],
    );
  }

  Widget renderOrders() {
    List<Widget> tiles = [];
    int count = 0;
    Order pOrder = context.read<Order>();
    Driver pDriver = context.read<Driver>();
    if (pOrder.orders!.isEmpty == false && pDriver.driver!.isOnline! == true) {
      pOrder.orders!.forEach(
        (OrderModel order) {
          tiles.add(orderTile(order));
          if (count != pOrder.orders!.length - 1) tiles.add(Divider());
          count++;
        },
      );
      tiles.addAll([
        SizedBox(height: 20),
        if (pDriver.driver!.isOnline! == true)
          SizedBox(
            width: screen(context).width * 0.9,
            child: ElevatedButton(
              onPressed: () async {
                await pOrder.getOrders();
              },
              child: Text('Reload'),
            ),
          ),
        SizedBox(height: 20)
      ]);
    } else {
      tiles.add(noOrder());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        children: tiles,
        //to avoid scrolling conflict with the dragging sheet
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0),
        shrinkWrap: true,
      ),
    );
  }

  ListTile orderTile(OrderModel order) {
    return ListTile(
      leading: Icon(
        Icons.pin_drop_outlined,
        color: Colors.black54,
        size: 30,
      ),
      title: Text(
        order.destinationDetails!['name'],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 20,
          color: Colors.black54,
        ),
      ),
      subtitle: Text(
        order.destinationDetails!['address'],
        style: TextStyle(
          fontSize: 16,
          color: Colors.black45,
        ),
      ),
      enableFeedback: true,
      onTap: () => chooseOrder(order),
    );
  }

  Widget noOrder() {
    Driver pDriver = context.read<Driver>();
    return Container(
      width: screen(context).width * 0.9,
      child: Column(
        children: [
          Text('No ride orders. Make sure you are online.'),
          if (pDriver.driver!.isOnline! == true) Text('Click to refresh'),
          SizedBox(height: 20),
          if (pDriver.driver!.isOnline! == true)
            SizedBox(
              width: screen(context).width * 0.9,
              child: ElevatedButton(
                onPressed: () async {
                  Order pOrder = context.read<Order>();
                  await pOrder.getOrders();
                },
                child: Text('Reload'),
              ),
            ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Future chooseOrder(OrderModel order) async {
    setState(() {
      travelOrigin = order.origin;
      travelDestination = order.destination;
      selectedOrder = order;
    });

    await setTravelDirection();
    addTravelMarker();

    setState(() {
      bottomSheetPage = BottomSheetPage.CONFIRM_RIDE;
    });
  }

  void revertOrder() {
    setState(() {
      travelInfo = null;
      showTravelDirection = false;
      showPickupDirection = false;
      bottomSheetPage = BottomSheetPage.SELECT_ORDER;
    });
    removeRiderMarker();
    _googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: myLocation!,
          zoom: 16,
        ),
      ),
    );
  }

  // Select Driver Sheet
  Widget showConfirmRide() {
    return Column(
      children: <Widget>[
        SizedBox(height: 12),
        Container(
          height: 5,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: 50,
          width: screen(context).width,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                left: 20,
                child: BackButton(
                  color: Colors.black54,
                  onPressed: () => revertOrder(),
                ),
              ),
              Positioned(
                top: 10,
                child: Text(
                  "Confirm Ride",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        ListTile(
          leading: Image.asset(
            'assets/markers/destination.png',
            fit: BoxFit.cover,
            width: 60,
          ),
          title: Text(
            "${selectedOrder?.destinationDetails!['name']}",
            maxLines: 1,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            "${selectedOrder?.destinationDetails!['address']}",
            maxLines: 1,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black45,
            ),
          ),
          enableFeedback: true,
        ),
        Text(
          "Journey is ${travelInfo!.totalDistance} far and takes about ${travelInfo!.totalDuration}",
          maxLines: 2,
          overflow: TextOverflow.visible,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black45,
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          width: screen(context).width * 0.9,
          child: ElevatedButton(
            onPressed: () => confirmRide(),
            child: Text('Confirm Ride'),
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Future confirmRide() async {
    try {
      Order pOrder = context.read<Order>();
      Driver pDriver = context.read<Driver>();
      // Rider pRider = context.read<Rider>();

      await pOrder
          .acceptOrder(pDriver.driver!.id!, selectedOrder!.id!)
          .then((value) async {
        // set riders location
        setState(() {
          riderLocation = selectedOrder?.origin;
          // pRider.rider = selectedOrder?.riderId
        });

        addRiderMarker(riderLocation!, selectedOrder?.riderId);

        // show pickup trip details
        await setPickupDirection();

        setState(() {
          bottomSheetPage = BottomSheetPage.PICKUP_RIDER;
        });
      });
    } catch (e) {
      error(context, e.toString());
    }
  }

  // Show Pickup Rider Sheet
  Widget showPickupRider() {
    return Column(
      children: <Widget>[
        SizedBox(height: 12),
        Container(
          height: 5,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: screen(context).width,
          height: 50,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                left: 20,
                child: BackButton(
                  color: Colors.black54,
                  onPressed: () => revertOrder(),
                ),
              ),
              Positioned(
                top: 10,
                child: Text(
                  "Pickup Rider",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        ListTile(
          leading: Image.asset(
            'assets/markers/rider.png',
            fit: BoxFit.cover,
            // height: 100,
            alignment: Alignment.center,
          ),
          title: Text(
            "Rider",
            maxLines: 1,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            pickupDirectionInfo!,
            maxLines: 2,
            overflow: TextOverflow.visible,
            // textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black45,
            ),
          ),
          enableFeedback: true,
        ),
        SizedBox(height: 20),
        SizedBox(
          width: screen(context).width * 0.9,
          child: ElevatedButton(
            onPressed: () => confirmRiderPickup(),
            child: Text('Confirm Pickup'),
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  confirmRiderPickup() {
    setState(() {
      bottomSheetPage = BottomSheetPage.START_RIDE;
    });
  }

  Widget showStartRide() {
    return Column(
      children: <Widget>[
        SizedBox(height: 12),
        Container(
          height: 5,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: screen(context).width,
          height: 50,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                left: 20,
                child: BackButton(
                  color: Colors.black54,
                  onPressed: () => revertOrder(),
                ),
              ),
              Positioned(
                top: 10,
                child: Text(
                  "Start Ride",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        ListTile(
          leading: Image.asset(
            'assets/markers/destination.png',
            fit: BoxFit.cover,
          ),
          title: Text(
            selectedOrder?.destinationDetails!['name'],
            maxLines: 1,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            selectedOrder?.destinationDetails!['address'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.black45,
            ),
          ),
          enableFeedback: true,
        ),
        Text(
          "Journey is ${travelInfo!.totalDistance} far and takes about ${travelInfo!.totalDuration}",
          maxLines: 2,
          overflow: TextOverflow.visible,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black45,
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          width: screen(context).width * 0.9,
          child: ElevatedButton(
            onPressed: () => success(context, "Starting Ride..."),
            child: Text('Start Ride'),
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }
}

enum BottomSheetPage {
  SELECT_ORDER,
  CONFIRM_RIDE,
  PICKUP_RIDER,
  START_RIDE,
}
