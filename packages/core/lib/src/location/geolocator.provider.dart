import 'package:geolocator/geolocator.dart';

import 'package:core/src/location/location.provider.dart';

class GeolocatorLocationProvider implements LocationProvider {
  const GeolocatorLocationProvider();

  @override
  Future<LocationPermissionStatus> ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionStatus.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.restricted;
    }

    return LocationPermissionStatus.granted;
  }

  @override
  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
    } on Exception {
      return null;
    }
  }

  @override
  Stream<LocationPermissionStatus> permissionChanges() async* {
    await for (final status in Geolocator.getServiceStatusStream()) {
      if (status == ServiceStatus.disabled) {
        yield LocationPermissionStatus.serviceDisabled;
      } else {
        final permission = await Geolocator.checkPermission();
        yield permission == LocationPermission.deniedForever
            ? LocationPermissionStatus.restricted
            : permission == LocationPermission.denied
                ? LocationPermissionStatus.denied
                : LocationPermissionStatus.granted;
      }
    }
  }
}