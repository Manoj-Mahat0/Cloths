import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

class CatalogService {
  CatalogService();

  Uri _uri(String path) => Uri.parse('${AuthService.baseUrl}$path');

  Future<List<Category>> listCategories() async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) return <Category>[];
    final http.Response resp = await http.get(
      _uri('/admin/categories'),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((dynamic e) => Category.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('List categories failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<Category> createCategory({required String name}) async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);
    final http.Response resp = await http.post(
      _uri('/admin/categories'),
      headers: <String, String>{
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{'name': name}),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return Category.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw HttpException('Create category failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<Category> updateCategory({required int id, required String name, required bool isActive}) async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);
    final http.Response resp = await http.put(
      _uri('/admin/categories/$id'),
      headers: <String, String>{
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{'name': name, 'is_active': isActive}),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return Category.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw HttpException('Update category failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<bool> deleteCategory({required int id}) async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);
    final http.Response resp = await http.delete(
      _uri('/admin/categories/$id'),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(resp.body) as Map<String, dynamic>;
      return (data['deleted'] as bool?) ?? false;
    }
    throw HttpException('Delete category failed', statusCode: resp.statusCode, body: resp.body);
  }

  // Shapes
  Future<List<Shape>> listShapes() async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) return <Shape>[];
    final http.Response resp = await http.get(
      _uri('/admin/shapes'),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((dynamic e) => Shape.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('List shapes failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<Shape> createShape({required String name}) async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);
    final http.Response resp = await http.post(
      _uri('/admin/shapes'),
      headers: <String, String>{
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{'name': name}),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return Shape.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw HttpException('Create shape failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<Shape> updateShape({required int id, required String name, required bool isActive}) async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);
    final http.Response resp = await http.put(
      _uri('/admin/shapes/$id'),
      headers: <String, String>{
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{'name': name, 'is_active': isActive}),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return Shape.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw HttpException('Update shape failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<bool> deleteShape({required int id}) async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);
    final http.Response resp = await http.delete(
      _uri('/admin/shapes/$id'),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(resp.body) as Map<String, dynamic>;
      return (data['deleted'] as bool?) ?? false;
    }
    throw HttpException('Delete shape failed', statusCode: resp.statusCode, body: resp.body);
  }
}

class Category {
  Category({required this.id, required this.name, required this.isActive});

  final int id;
  final String name;
  final bool isActive;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class Shape {
  Shape({required this.id, required this.name, required this.isActive});

  final int id;
  final String name;
  final bool isActive;

  factory Shape.fromJson(Map<String, dynamic> json) {
    return Shape(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class SizeItem {
  SizeItem({required this.id, required this.name, required this.isActive});

  final int id;
  final String name;
  final bool isActive;

  factory SizeItem.fromJson(Map<String, dynamic> json) {
    return SizeItem(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class ColorItem {
  ColorItem({required this.id, required this.name, required this.isActive});

  final int id;
  final String name;
  final bool isActive;

  factory ColorItem.fromJson(Map<String, dynamic> json) {
    return ColorItem(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

extension SizesApi on CatalogService {
  Future<List<SizeItem>> listSizes() async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) return <SizeItem>[];
    final http.Response resp = await http.get(
      _uri('/admin/sizes'),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((dynamic e) => SizeItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('List sizes failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<SizeItem> createSize({required String name}) async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);
    final http.Response resp = await http.post(
      _uri('/admin/sizes'),
      headers: <String, String>{
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{'name': name}),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return SizeItem.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw HttpException('Create size failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<SizeItem> updateSize({required int id, required String name, required bool isActive}) async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);
    final http.Response resp = await http.put(
      _uri('/admin/sizes/$id'),
      headers: <String, String>{
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{'name': name, 'is_active': isActive}),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return SizeItem.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw HttpException('Update size failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<bool> deleteSize({required int id}) async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);
    final http.Response resp = await http.delete(
      _uri('/admin/sizes/$id'),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(resp.body) as Map<String, dynamic>;
      return (data['deleted'] as bool?) ?? false;
    }
    throw HttpException('Delete size failed', statusCode: resp.statusCode, body: resp.body);
  }
}

extension ColorsApi on CatalogService {
  Future<List<ColorItem>> listColors() async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) return <ColorItem>[];
    final http.Response resp = await http.get(
      _uri('/admin/colors'),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((dynamic e) => ColorItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('List colors failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<ColorItem> createColor({required String name}) async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);
    final http.Response resp = await http.post(
      _uri('/admin/colors'),
      headers: <String, String>{
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{'name': name}),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return ColorItem.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw HttpException('Create color failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<ColorItem> updateColor({required int id, required String name, required bool isActive}) async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);
    final http.Response resp = await http.put(
      _uri('/admin/colors/$id'),
      headers: <String, String>{
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{'name': name, 'is_active': isActive}),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return ColorItem.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw HttpException('Update color failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<bool> deleteColor({required int id}) async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);
    final http.Response resp = await http.delete(
      _uri('/admin/colors/$id'),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(resp.body) as Map<String, dynamic>;
      return (data['deleted'] as bool?) ?? false;
    }
    throw HttpException('Delete color failed', statusCode: resp.statusCode, body: resp.body);
  }
}

class ProductItem {
  ProductItem({required this.id, required this.name, required this.categoryId, required this.shapeId, required this.sizeId, required this.colorId, required this.priceCents, this.imageUrl, required this.isActive});

  final int id;
  final String name;
  final int categoryId;
  final int shapeId;
  final int sizeId;
  final int colorId;
  final int priceCents;
  final String? imageUrl;
  final bool isActive;

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      categoryId: (json['category_id'] as num).toInt(),
      shapeId: (json['shape_id'] as num).toInt(),
      sizeId: (json['size_id'] as num).toInt(),
      colorId: (json['color_id'] as num).toInt(),
      priceCents: (json['price_cents'] as num).toInt(),
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

extension ProductsApi on CatalogService {
  Future<List<ProductItem>> listProducts() async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) return <ProductItem>[];
    // Debug: request log
    // ignore: avoid_print
    print('GET /admin/products');
    final http.Response resp = await http.get(
      _uri('/admin/products'),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    // Debug: response log
    // ignore: avoid_print
    print('Response ${resp.statusCode} /admin/products: ${resp.body}');
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((dynamic e) => ProductItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('List products failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<ProductItem> createProductMultipart({
    required String name,
    required int categoryId,
    required int shapeId,
    required int sizeId,
    required int colorId,
    required int priceCents,
    File? file,
  }) async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);

    final Uri uri = _uri('/admin/products/create');
    // Debug: request log
    // ignore: avoid_print
    print('POST /admin/products/create name=$name category=$categoryId shape=$shapeId size=$sizeId color=$colorId price_cents=$priceCents file=${file?.path ?? 'none'}');
    final http.MultipartRequest req = http.MultipartRequest('POST', uri);
    req.headers['accept'] = 'application/json';
    req.headers['Authorization'] = 'Bearer $token';
    req.fields['name'] = name;
    req.fields['category_id'] = categoryId.toString();
    req.fields['shape_id'] = shapeId.toString();
    req.fields['size_id'] = sizeId.toString();
    req.fields['color_id'] = colorId.toString();
    req.fields['price_cents'] = priceCents.toString();
    if (file != null) {
      final http.MultipartFile part = await http.MultipartFile.fromPath('file', file.path);
      req.files.add(part);
    }
    final http.StreamedResponse streamed = await req.send();
    final http.Response resp = await http.Response.fromStream(streamed);
    // Debug: response log
    // ignore: avoid_print
    print('Response ${resp.statusCode} /admin/products/create: ${resp.body}');
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return ProductItem.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw HttpException('Create product failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<ProductItem> updateProduct({
    required int id,
    required String name,
    required int categoryId,
    required int shapeId,
    required int sizeId,
    required int colorId,
    required int priceCents,
    bool isActive = true,
  }) async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);
    final Map<String, dynamic> body = <String, dynamic>{
      'name': name,
      'category_id': categoryId,
      'shape_id': shapeId,
      'size_id': sizeId,
      'color_id': colorId,
      'price_cents': priceCents,
      'is_active': isActive,
    };
    // Debug: request log
    // ignore: avoid_print
    print('PUT /admin/products/$id body=${jsonEncode(body)}');
    final http.Response resp = await http.put(
      _uri('/admin/products/$id'),
      headers: <String, String>{
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    // Debug: response log
    // ignore: avoid_print
    print('Response ${resp.statusCode} /admin/products/$id: ${resp.body}');
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return ProductItem.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw HttpException('Update product failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<bool> deleteProduct({required int id}) async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);
    // Debug: request log
    // ignore: avoid_print
    print('DELETE /admin/products/$id');
    final http.Response resp = await http.delete(
      _uri('/admin/products/$id'),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    // Debug: response log
    // ignore: avoid_print
    print('Response ${resp.statusCode} /admin/products/$id: ${resp.body}');
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(resp.body) as Map<String, dynamic>;
      return (data['deleted'] as bool?) ?? false;
    }
    throw HttpException('Delete product failed', statusCode: resp.statusCode, body: resp.body);
  }

  Future<ProductItem> uploadProductImage({required int productId, required File file}) async {
    final String? token = await AuthService.getStoredAccessToken();
    if (token == null || token.isEmpty) throw HttpException('No token', statusCode: 401);
    final Uri uri = _uri('/admin/products/$productId/image');
    // Debug: request log
    // ignore: avoid_print
    print('POST /admin/products/$productId/image file=${file.path}');
    final http.MultipartRequest req = http.MultipartRequest('POST', uri);
    req.headers['accept'] = 'application/json';
    req.headers['Authorization'] = 'Bearer $token';
    req.files.add(await http.MultipartFile.fromPath('file', file.path));
    final http.StreamedResponse streamed = await req.send();
    final http.Response resp = await http.Response.fromStream(streamed);
    // Debug: response log
    // ignore: avoid_print
    print('Response ${resp.statusCode} /admin/products/$productId/image: ${resp.body}');
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return ProductItem.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    }
    throw HttpException('Upload image failed', statusCode: resp.statusCode, body: resp.body);
  }
}


