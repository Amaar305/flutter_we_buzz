import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';


Future<String> getCurrentCity() async {
  // get permission from user
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

  String? city = placemarks[0].locality;

  return city ?? "";
}
