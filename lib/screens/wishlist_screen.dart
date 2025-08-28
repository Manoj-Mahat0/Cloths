import 'package:flutter/material.dart';

import '../services/user_service.dart';
import '../services/catalog_service.dart';
import '../services/auth_service.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final UserService _svc = UserService();
  List<WishlistItem> _items = <WishlistItem>[];
  bool _loading = true;
  final Map<int, ProductItem> _productById = <int, ProductItem>{};

  @override
  void initState() {
    super.initState();
    _fetch();
    _bootstrapProducts();
  }

  Future<void> _fetch() async {
    try {
      final List<WishlistItem> res = await _svc.getWishlist();
      if (!mounted) return;
      setState(() { _items = res; _loading = false; });
    } catch (_) { if (!mounted) return; setState(() => _loading = false); }
  }

  Future<void> _bootstrapProducts() async {
    try {
      final List<ProductItem> prods = await CatalogService().listProducts();
      if (!mounted) return;
      setState(() { for (final ProductItem p in prods) { _productById[p.id] = p; } });
    } catch (_) {}
  }

  Future<void> _remove(int productId) async {
    try {
      final bool ok = await _svc.removeWishlist(productId: productId);
      if (!mounted) return;
      if (ok) setState(() => _items = _items.where((WishlistItem e) => e.productId != productId).toList());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(children: const <Widget>[
                      BackButton(),
                      SizedBox(width: 8),
                      Text('Wishlist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 12),
                    if (_items.isEmpty)
                      const Expanded(child: Center(child: Text('No items in wishlist')))
                    else
                    Expanded(
                      child: ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (BuildContext context, int i) {
                          final WishlistItem it = _items[i];
                          final ProductItem? p = _productById[it.productId];
                          return Dismissible(
                            key: ValueKey<int>(it.productId),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              decoration: BoxDecoration(color: const Color(0xFFD32F2F), borderRadius: BorderRadius.circular(16)),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                            ),
                            onDismissed: (_) => _remove(it.productId),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const <BoxShadow>[
                                  BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 5)),
                                ],
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: <Widget>[
                                  _WishProductImage(imageUrl: p?.imageUrl),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(p?.name ?? 'Item', style: const TextStyle(fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 4),
                                        if (p != null) Text('₹ ${(p.priceCents / 100).toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF2E4DFF), fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                  IconButton(onPressed: () => _remove(it.productId), icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFD32F2F))),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _WishProductImage extends StatelessWidget {
  const _WishProductImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      final String url = imageUrl!.startsWith('http') ? imageUrl! : '${AuthService.baseUrl}$imageUrl';
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(url, width: 64, height: 64, fit: BoxFit.cover),
      );
    }
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(color: const Color(0xFFF2F3F7), borderRadius: BorderRadius.circular(12)),
      child: const Icon(Icons.image, color: Color(0xFF9AA0A6)),
    );
  }
}


