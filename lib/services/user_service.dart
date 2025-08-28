import 'dart:convert';

import 'package:cloth/models/user.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';
import '../models/order_model.dart';

class UserService {
  Uri _uri(String path) => Uri.parse('${AuthService.baseUrl}$path');

  Future<List<CartItem>> getCart() async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) return <CartItem>[];
    final http.Response resp = await http.get(
      _uri('/user/cart'),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((dynamic e) => CartItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('Get cart failed', statusCode: resp.statusCode, body: resp.body);
  }
Future<User> getMe() async {
  final String? token = await AuthService.getStoredAccessToken();
  if (token == null || token.isEmpty) {
    throw HttpException('No token', statusCode: 401);
  }

  final http.Response resp = await http.get(
    Uri.parse('${AuthService.baseUrl}/user/me'),
    headers: <String, String>{
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (resp.statusCode >= 200 && resp.statusCode < 300) {
    final Map<String, dynamic> data = jsonDecode(resp.body) as Map<String, dynamic>;
    return User.fromJson(data); // ✅ Now works if User model is implemented
  }
  throw HttpException('Get user info failed', statusCode: resp.statusCode, body: resp.body);
}

  Future<CartItem> addToCart({required int productId, required int quantity}) async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);
    final http.Response resp = await http.post(
      _uri('/user/cart'),
      headers: <String, String>{
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'product_id': productId,
        'quantity': quantity,
      }),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return CartItem.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw HttpException('Add to cart failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<bool> removeFromCart({required int productId}) async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);
    final http.Response resp = await http.delete(
      _uri('/user/cart/$productId'),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(resp.body) as Map<String, dynamic>;
      return (data['ok'] as bool?) ?? false;
    }
    throw HttpException('Remove from cart failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<bool> checkout() async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);
    final http.Response resp = await http.post(
      _uri('/user/checkout'),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) return true;
    if (resp.statusCode == 400) return false; // e.g., cart empty
    throw HttpException('Checkout failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<List<WishlistItem>> getWishlist() async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) return <WishlistItem>[];
    final http.Response resp = await http.get(
      _uri('/user/wishlist'),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((dynamic e) => WishlistItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('Get wishlist failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<WishlistItem> addWishlist({required int productId}) async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);
    final http.Response resp = await http.post(
      _uri('/user/wishlist/$productId'),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return WishlistItem.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw HttpException('Add wishlist failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<bool> removeWishlist({required int productId}) async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);
    final http.Response resp = await http.delete(
      _uri('/user/wishlist/$productId'),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(resp.body) as Map<String, dynamic>;
      return (data['ok'] as bool?) ?? false;
    }
    throw HttpException('Remove wishlist failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<List<Order>> getOrders() async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) return <Order>[];
    final http.Response resp = await http.get(
      _uri('/user/orders'),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((dynamic e) => Order.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('Get orders failed', statusCode: resp.statusCode, body: resp.body);
  }
}

class CartItem {
  CartItem({required this.id, required this.productId, required this.quantity});
  final int id;
  final int productId;
  final int quantity;
  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: (json['id'] as num).toInt(),
        productId: (json['product_id'] as num).toInt(),
        quantity: (json['quantity'] as num).toInt(),
      );
}

class WishlistItem {
  WishlistItem({required this.id, required this.productId});
  final int id;
  final int productId;
  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        id: (json['id'] as num).toInt(),
        productId: (json['product_id'] as num).toInt(),
      );
}


