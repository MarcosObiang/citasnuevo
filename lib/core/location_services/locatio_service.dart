import 'package:geolocator/geolocator.dart';

class LocationService {
  static LocationService instance = new LocationService();
  Future<Map<String, num>> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    Position position;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      throw Exception("LOCATION_DISABLED");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        throw Exception("LOCATION_DENIED");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      throw Exception("LOCATION_DENIED_FOREVER");
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);

    return {"lon": position.longitude, "lat": position.latitude};
  }

  Future<bool> _isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> _locationPermissionStatus() async {
    LocationPermission permission = await Geolocator.checkPermission();

    return permission;
  }

  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  Future<bool> gotoLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  Future<Map<String, dynamic>> locationServicesState() async {
    Map<String, dynamic> locationData = new Map();
    bool isLocationEnabled =
        await LocationService.instance._isLocationServiceEnabled();
    if (isLocationEnabled) {
      LocationPermission permission =
          await LocationService.instance._locationPermissionStatus();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        Map<String, dynamic> positionData =
            await LocationService.instance.determinePosition();
        locationData["status"] = "correct";

        locationData["lon"] = positionData["lon"];
        locationData["lat"] = positionData["lat"];
      } else {
        if (permission == LocationPermission.deniedForever) {
          locationData["status"] = "LOCATION_PERMISSION_DENIED_FOREVER";
        }
        if (permission == LocationPermission.denied) {
          locationData["status"] = "LOCATION_PERMISSION_DENIED";
        } else {
          locationData["status"] = "UNABLE_TO_DETERMINE_LOCATION_STATUS";
        }
      }
    } else {
      locationData["status"] = "LOCATION_SERVICE_DISABLED";
    }
    return locationData;
  }
}




