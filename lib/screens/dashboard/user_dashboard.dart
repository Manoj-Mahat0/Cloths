import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/catalog_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/app_refresh.dart';
import '../../widgets/shimmers.dart';
import '../cart_screen.dart';
import '../../services/user_service.dart';
import 'package:share_plus/share_plus.dart';
import '../order_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentIndex = 0;
  late Future<Map<String, dynamic>?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = AuthService().fetchCurrentUserAndPersist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _userFuture,
            builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
              final String username = (snapshot.data != null && snapshot.data!['username'] is String)
                  ? (snapshot.data!['username'] as String)
                  : 'User';
              return _buildContent(context, username);
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildFixedNav(context),
    );
  }

  Widget _buildContent(BuildContext context, String username) {
    switch (_currentIndex) {
      case 0:
        return _HomeTab(username: username, onLogout: _logout);
      case 1:
        return const CartScreen();
      case 2:
        return const OrderScreen();
      case 3:
        return Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Hello, $username'),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _logout, child: const Text('Logout')),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFixedNav(BuildContext context) {
    const Color primary = Color(0xFF2E4DFF);
    final List<_NavItem> items = <_NavItem>[
      const _NavItem(icon: Icons.home_rounded, label: 'Home'),
      const _NavItem(icon: Icons.shopping_cart_rounded, label: 'Cart'),
      const _NavItem(icon: Icons.receipt_long_rounded, label: 'Orders'),
      const _NavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x1F000000), blurRadius: 20, offset: Offset(0, 10)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(items.length, (int i) {
            final bool active = _currentIndex == i;
            final Color color = active ? primary : const Color(0xFF9AA0A6);
            return Expanded(
              child: InkWell(
                onTap: () => setState(() => _currentIndex = i),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFFEFF2FF) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(items[i].icon, color: color),
                      const SizedBox(height: 4),
                      Text(items[i].label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/auth/login', (Route<dynamic> r) => false);
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.username, required this.onLogout});

  final String username;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2E4DFF);
    return AppRefresh(
      onRefresh: () async {
        // A simple refresh by reloading current route-level futures/stateful children
        // Navigator restates widgets; for now, just a short delay to show indicator
        await Future<void>.delayed(const Duration(milliseconds: 350));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFEFF2FF),
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : 'U',
                  style: const TextStyle(color: primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('welcome,', style: TextStyle(color: Color(0xFF7C7C7C))),
                    Text(username, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.of(context).pushNamed('/wishlist'),
                    icon: const Icon(Icons.favorite_border_rounded),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pushNamed('/notifications'),
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SearchBar(),
          const SizedBox(height: 14),
          _PromoCard(primary: primary),
          const SizedBox(height: 14),
          _Categories(),
          const SizedBox(height: 8),
          _PopularProducts(),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.of(context).pushNamed('/search'),
            child: Container(
              decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: const <Widget>[
                  Icon(Icons.search, color: Color(0xFF9AA0A6)),
                  SizedBox(width: 8),
                  Text('Search', style: TextStyle(color: Color(0xFF9AA0A6))),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () => Navigator.of(context).pushNamed('/search'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(color: const Color(0xFF2E4DFF), borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.tune_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: const <Widget>[
          Expanded(
            child: Text(
              'New collection\nDiscount 20% on first order',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          Icon(Icons.local_offer, color: Colors.white, size: 48),
        ],
      ),
    );
  }
}

class _Categories extends StatefulWidget {
  @override
  State<_Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<_Categories> {
  List<Category> _cats = <Category>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final List<Category> res = await CatalogService().listCategories();
      if (!mounted) return;
      setState(() { _cats = res; _loading = false; });
    } catch (_) { if (!mounted) return; setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Category', style: TextStyle(fontWeight: FontWeight.w700)),
              Text('see all', style: TextStyle(color: Color(0xFF9AA0A6))),
            ],
          ),
          SizedBox(height: 10),
          ShimmerChips(),
        ],
      );
    }
    final List<_ChipData> chips = <_ChipData>[
      const _ChipData(label: 'All', icon: Icons.apps_rounded),
      ..._cats.map((Category c) => _chipFromCategory(c)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const <Widget>[
            Text('Category', style: TextStyle(fontWeight: FontWeight.w700)),
            Text('see all', style: TextStyle(color: Color(0xFF9AA0A6))),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 58,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: chips.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (BuildContext context, int i) {
              final _ChipData d = chips[i];
              final Widget iconWidget = d.asset != null
                  ? SvgPicture.asset(
                      d.asset!,
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(Color(0xFF2E4DFF), BlendMode.srcIn),
                    )
                  : Icon(d.icon ?? Icons.category_rounded, size: 18);
              return OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E4DFF),
                  side: const BorderSide(color: Color(0xFFE0E4F2)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    iconWidget,
                    const SizedBox(width: 8),
                    Text(d.label),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  _ChipData _chipFromCategory(Category c) {
    final String n = c.name.toLowerCase();
    if (n.contains('shoe') || n.contains('sneaker')) {
      return const _ChipData(label: 'Shoes', asset: 'assets/icons/steps_24.svg');
    }
    if (n.contains('pant') || n.contains('jean') || n.contains('trouser')) {
      return const _ChipData(label: 'Pants', asset: 'assets/icons/pants.svg');
    }
    if (n.contains('shirt') || n.contains('tshirt') || n.contains('tee')) {
      return const _ChipData(label: 'Shirts', asset: 'assets/icons/shirts.svg');
    }
    return _ChipData(label: c.name, icon: _iconFor(c.name));
  }

  static IconData _iconFor(String name) {
    final String n = name.toLowerCase();
    if (n.contains('shirt') || n.contains('tshirt') || n.contains('tee')) return Icons.checkroom_rounded;
    if (n.contains('pant') || n.contains('jean') || n.contains('trouser')) return Icons.shopping_bag_rounded;
    // Material Icons fallback when custom asset not present
    if (n.contains('shoe') || n.contains('sneaker')) return Icons.directions_walk_rounded;
    if (n.contains('dress') || n.contains('gown')) return Icons.emoji_people_rounded;
    return Icons.category_rounded;
  }
}

class _ChipData {
  const _ChipData({required this.label, this.icon, this.asset});
  final String label;
  final IconData? icon;
  final String? asset;
}

class _PopularProducts extends StatefulWidget {
  @override
  State<_PopularProducts> createState() => _PopularProductsState();
}

class _PopularProductsState extends State<_PopularProducts> {
  List<ProductItem> _products = <ProductItem>[];
  bool _loading = true;
  Set<int> _wishlistIds = <int>{};
  final Set<int> _cartAddedIds = <int>{};
  final Set<int> _cartLoadingIds = <int>{};

  @override
  void initState() {
    super.initState();
    _fetch();
    _bootstrapWishlist();
  }

  Future<void> _fetch() async {
    try {
      final List<ProductItem> res = await CatalogService().listProducts();
      if (!mounted) return;
      setState(() { _products = res; _loading = false; });
    } catch (_) { if (!mounted) return; setState(() => _loading = false); }
  }

  Future<void> _bootstrapWishlist() async {
    try {
      final List<WishlistItem> res = await UserService().getWishlist();
      if (!mounted) return;
      setState(() => _wishlistIds = res.map((WishlistItem e) => e.productId).toSet());
    } catch (_) {}
  }

  Future<void> _toggleWishlist(int productId) async {
    if (!mounted) return;
    final bool inWish = _wishlistIds.contains(productId);
    setState(() { inWish ? _wishlistIds.remove(productId) : _wishlistIds.add(productId); });
    try {
      if (inWish) {
        await UserService().removeWishlist(productId: productId);
      } else {
        await UserService().addWishlist(productId: productId);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() { inWish ? _wishlistIds.add(productId) : _wishlistIds.remove(productId); });
    }
  }

  Future<bool> simulatePayment() async {
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    return true; // Simulate success
  }

  Widget _buildPaymentOption(BuildContext context, String title, IconData icon, Color color) {
    return InkWell(
      onTap: () async {
        Navigator.of(context).pop();
        await _processPayment(context, title);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(BuildContext context, String paymentMethod) async {
    // Show loading
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Processing payment...'),
          ],
        ),
      ),
    );

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      
      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();
      
      // Show success
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successful via $paymentMethod!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();
      
      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const <Widget>[
            Text('Popular products', style: TextStyle(fontWeight: FontWeight.w700)),
            Text('see all', style: TextStyle(color: Color(0xFF9AA0A6))),
          ],
        ),
        const SizedBox(height: 10),
        if (_loading)
          const ShimmerGrid()
        else if (_products.isEmpty)
          _EmptyState(onRetry: _fetch)
        else
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          itemCount: _products.length,
          itemBuilder: (BuildContext context, int i) {
  final ProductItem p = _products[i];
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.blueAccent, width: 1.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD), // Light blue background
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _UserProductImage(imageUrl: p.imageUrl),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InkWell(
                    onTap: () => _toggleWishlist(p.id),
                    child: Icon(
                      _wishlistIds.contains(p.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: _wishlistIds.contains(p.id)
                          ? Colors.red
                          : Colors.grey,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext context) => _ProductDetailModal(
                          product: p,
                          onToggleWishlist: _toggleWishlist,
                          wishlistIds: _wishlistIds,
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.remove_red_eye_rounded,
                      color: Colors.grey,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatPrice(p.priceCents),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _cartLoadingIds.contains(p.id) || _cartAddedIds.contains(p.id)
                          ? null
                          : () async {
                              setState(() => _cartLoadingIds.add(p.id));
                              try {
                                await UserService().addToCart(productId: p.id, quantity: 1);
                                setState(() {
                                  _cartAddedIds.add(p.id);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Added to cart!')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to add to cart: $e')),
                                );
                              } finally {
                                setState(() => _cartLoadingIds.remove(p.id));
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E4DFF),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _cartLoadingIds.contains(p.id)
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _cartAddedIds.contains(p.id) ? 'Added' : 'Buy now',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
},

        ),
      

      ],
    );
  }
}

String _formatPrice(int cents) {
  if (cents % 100 == 0) {
    return '₹ ${(cents / 100).toInt()}';
  }
  return '₹ ${(cents / 100).toStringAsFixed(2)}';
}

class _UserProductImage extends StatelessWidget {
  const _UserProductImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      final String url = imageUrl!.startsWith('http') ? imageUrl! : '${AuthService.baseUrl}$imageUrl';
      return Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _ph());
    }
    return _ph();
  }

  Widget _ph() => Container(color: const Color(0xFFF0F0F0), child: const Center(child: Icon(Icons.image, color: Color(0xFF9AA0A6))));
}


class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: <Widget>[
          const Icon(Icons.wifi_off_rounded, color: Color(0xFF9AA0A6)),
          const SizedBox(height: 8),
          const Text('Service unavailable', style: TextStyle(color: Color(0xFF9AA0A6))),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

class _ProductDetailModal extends StatefulWidget {
  const _ProductDetailModal({
    required this.product,
    required this.onToggleWishlist,
    required this.wishlistIds,
  });

  final ProductItem product;
  final Future<void> Function(int productId) onToggleWishlist;
  final Set<int> wishlistIds;

  @override
  State<_ProductDetailModal> createState() => _ProductDetailModalState();
}

class _ProductDetailModalState extends State<_ProductDetailModal> {
  late bool _isProductInWishlist;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _isProductInWishlist = widget.wishlistIds.contains(widget.product.id);
  }

  @override
  void didUpdateWidget(covariant _ProductDetailModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.wishlistIds != oldWidget.wishlistIds) {
      setState(() {
        _isProductInWishlist = widget.wishlistIds.contains(widget.product.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Hero(
                          tag: 'product_image_${widget.product.id}',
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: _UserProductImage(imageUrl: widget.product.imageUrl),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.share, color: Colors.black),
                                onPressed: () async {
                                  await Share.share('Check out this product: ${widget.product.name} - ${widget.product.imageUrl}');
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  _isProductInWishlist
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: _isProductInWishlist ? Colors.red : Colors.black,
                                ),
                                onPressed: () => widget.onToggleWishlist(widget.product.id),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _formatPrice(widget.product.priceCents),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.product.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              const Text('New York', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent vehicula feugiat metus, nec congue augue mollis sed. Mauris quis sapien sit amet tellus.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.blue.shade100,
                                child: const Text('L', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              const Text('Lora Hudson', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: Colors.blue, size: 16),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isAddingToCart
                                  ? null
                                  : () async {
                                      setState(() => _isAddingToCart = true);
                                      try {
                                        // Simulate payment processing
                                        await Future.delayed(const Duration(seconds: 2));
                                        
                                        // Add to cart after successful payment
                                        await UserService().addToCart(productId: widget.product.id, quantity: 1);
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Payment successful! Added to cart.')),
                                        );
                                      } catch (e) {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Payment failed: $e')),
                                        );
                                      } finally {
                                        if (mounted) setState(() => _isAddingToCart = false);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E4DFF),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isAddingToCart
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Buy now', style: TextStyle(color: Colors.white, fontSize: 18)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

