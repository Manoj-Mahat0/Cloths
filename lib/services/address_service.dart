import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/address.dart';
import 'auth_service.dart';

class AddressService {
  static String get _baseUrl => AuthService.baseUrl;
  
  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Fetch address from coordinates using reverse geocoding
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=YOUR_GOOGLE_MAPS_API_KEY'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
      return null;
    } catch (e) {
      print('Error fetching address: $e');
      return null;
    }
  }

  // Get saved addresses
  Future<List<Address>> getSavedAddresses() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/addresses'),
        headers: await AuthService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Address.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching addresses: $e');
      return [];
    }
  }

  // Save new address
  Future<Address?> saveAddress(Address address) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/addresses'),
        headers: await AuthService.getHeaders(),
        body: json.encode(address.toJson()),
      );

      if (response.statusCode == 201) {
        return Address.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error saving address: $e');
      return null;
    }
  }

  // Update address
  Future<bool> updateAddress(Address address) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/addresses/${address.id}'),
        headers: await AuthService.getHeaders(),
        body: json.encode(address.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating address: $e');
      return false;
    }
  }

  // Delete address
  Future<bool> deleteAddress(int addressId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/addresses/$addressId'),
        headers: await AuthService.getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting address: $e');
      return false;
    }
  }

  // Set default address
  Future<bool> setDefaultAddress(int addressId) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/addresses/$addressId/default'),
        headers: await AuthService.getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error setting default address: $e');
      return false;
    }
  }
}
