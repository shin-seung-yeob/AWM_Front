
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:mapdesign_flutter/Screen/location_category.dart';
import 'package:mapdesign_flutter/app_colors.dart';
import 'package:mapdesign_flutter/components/MapMarker/custom_marker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  latLng.LatLng? currentLocation;
  bool highlightMarker = false;
  bool toggleAimPoint = false;
  late final mapController = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
  );
  List<CircleMarker> circles = [];

  double zoom = 15.0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocationData();
  }
  void setFocusOnCurrentLocation(){
    mapController.animateTo(dest: currentLocation!);
    setState(() {
      highlightMarker = true; // 마커를 강조
    });
  }
  Future<void> getLocationData() async{
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스가 활성화되어 있는지 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return; // 위치 서비스가 비활성화된 경우 추가 작업을 수행하지 않음
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return; // 권한이 거부된 경우 추가 작업을 수행하지 않음
      }
    }
    final Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    setState(() {
      currentLocation = latLng.LatLng(position.latitude, position.longitude);
      circles.add(
        CircleMarker(
            point: currentLocation!,
            color: Colors.blue.withOpacity(0.1),
            borderColor: Colors.blue.withOpacity(0.1),
            borderStrokeWidth: 2,
            useRadiusInMeter: true,  // 미터 단위 사용
            radius: 300  //
        ),
      );
    });
    setFocusOnCurrentLocation();
  }
  void setShowAimPoint(){
    setState(() {
      toggleAimPoint = !toggleAimPoint;
    });
  }
  void getCoordinates() {
    var center = mapController.mapController.camera.center; // 지도의 중앙 위치 가져오기
    print(center.latitude);
    print(center.longitude);
  }
  @override
  Widget build(BuildContext context) {
    var markers = <Marker>[];
    if(currentLocation != null){
      if(toggleAimPoint){
        markers.add(
          Marker(
            point: mapController.mapController.camera.center,
            width: 60,
            height: 60,
              child: Icon(
                Icons.add_location,
                color: AppColors.instance.skyBlue,
                size: 60,
              ),
          )
        );
      }
      markers.add(
        // current position
        Marker(
            point: currentLocation!,
            width: 60,
            height: 60,
            child: CustomMarkerIcon(
              isPlace: false,
              imagePath: "asset/img/pepe.webp",
              size: Size(400.0, 400.0),
            ),
        ),
      );
      // test
      markers.add(
        Marker(
            point: latLng.LatLng(35.85836750155731, 128.48694463271696),
            width: 60,
            height: 60,
            child: CustomMarkerIcon(
              isPlace: true,
              imagePath: "asset/img/bombom.jpg",
              size: Size(400.0, 400.0),
            )
        )
      );

      // 이후 API 요청을 하여 주변 근처 위치를 탐색
      // markers.add()
    }
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: Center(
            child: TextField(
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.instance.skyBlue,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      /* Clear the search field */
                    },
                    color: AppColors.instance.skyBlue,
                  ),
                  hintText: 'Search & Explore',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.black,
                  ),
              ),
            ),
          ),
        ),
        backgroundColor: AppColors.instance.whiteGrey,
      ),
      drawer: Drawer(

      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController.mapController,
            options: MapOptions(
              initialCenter: currentLocation ?? latLng.LatLng(0,0),
              initialZoom: zoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              CircleLayer(
                circles: circles,
              ),
              MarkerLayer(
                markers: markers,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Stack(
       children: [
         Positioned(
           bottom: 10.0,
           right: 10.0,
           child: FloatingActionButton(
             onPressed: () => {
               setFocusOnCurrentLocation()
             },
             backgroundColor: AppColors.instance.skyBlue,
             child: Icon(
               Icons.my_location,
               color: AppColors.instance.white,
             ),
           ),
         ),
         Positioned(
           bottom: 80.0,
           right: 10.0,
           child: FloatingActionButton(
             onPressed: () => {
               setShowAimPoint()
             },
             backgroundColor: AppColors.instance.skyBlue,
             child: Icon(
               toggleAimPoint ? Icons.close : Icons.add,
               color: AppColors.instance.white,
             ),
           ),
         ),
         Positioned(
           bottom: 150.0,
           right: 10.0,
           child: FloatingActionButton(
             onPressed: () => {
               showModalBottomSheet(
                 context: context,
                 builder: (BuildContext context) {
                   return LocationCategory(); // Your custom widget
                 },
               )
             },
             backgroundColor: AppColors.instance.skyBlue,
             child: Icon(
               Icons.add_location,
               color: AppColors.instance.white,
             ),
           ),
         ),
         Positioned(
           bottom: 220.0,
           right: 10.0,
           child: FloatingActionButton(
             onPressed: () => {
               mapController.animatedZoomOut()
             },
             backgroundColor: AppColors.instance.skyBlue,
             child: Icon(
               Icons.remove,
               color: AppColors.instance.white,
             ),
          ),
         ),
         Positioned(
           bottom: 290.0,
           right: 10.0,
           child: FloatingActionButton(
             onPressed: () => {
               mapController.animatedZoomIn()
             },
             backgroundColor: AppColors.instance.skyBlue,
             child: Icon(
               Icons.add,
               color: AppColors.instance.white,
             ),
           )
         )
       ],
      )
    );
  }
}

