import 'package:geolocator/geolocator.dart';

enum LocationPermissionStatus {
  granted,
  denied,
  restricted,
  serviceDisabled,
}

abstract class LocationProvider {
  Future<LocationPermissionStatus> ensurePermission();

  Future<Position?> getCurrentPosition();

  Stream<LocationPermissionStatus> permissionChanges();
}