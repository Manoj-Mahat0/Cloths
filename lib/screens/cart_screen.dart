import 'package:flutter/material.dart';

import '../services/user_service.dart';
import '../services/catalog_service.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import '../services/address_service.dart';
import '../models/address.dart';
import '../widgets/address_selection_dialog.dart';
import '../models/user.dart'; // Make sure this file exists and is correctly structured

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  final UserService _svc = UserService();
  final PaymentService _paymentService = PaymentService();
  final AddressService _addressService = AddressService();
  
  List<CartItem> _items = <CartItem>[];
  bool _loading = true;
  bool _checkingOut = false;
  final Set<int> _updating = <int>{};
  final Map<int, ProductItem> _productById = <int, ProductItem>{};
  
  Address? _selectedAddress;
  List<Address> _savedAddresses = [];
  
  User? _user; // This is the user model you need
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fetch();
    _bootstrapProducts();
    _loadSavedAddresses();
    _loadUser(); // Load user info on screen start
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _svc.getMe();
      if (!mounted) return;
      setState(() {
        _user = user;
      });
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  Future<void> _loadSavedAddresses() async {
  try {
    final addresses = await _addressService.getSavedAddresses();
    if (!mounted) return;

    setState(() {
      _savedAddresses = addresses;

      if (addresses.isNotEmpty) {
        _selectedAddress = addresses.firstWhere(
          (addr) => addr.isDefault,
          orElse: () => addresses.first,
        );
      } else {
        _selectedAddress = null;
      }
    });
  } catch (e) {
    debugPrint('Error loading addresses: $e');
  }
}

  Future<void> _fetch() async {
    try {
      final List<CartItem> res = await _svc.getCart();
      if (!mounted) return;
      setState(() { _items = res; _loading = false; });
    } catch (_) { 
      if (!mounted) return; 
      setState(() => _loading = false); 
    }
  }

  Future<void> _bootstrapProducts() async {
    try {
      final List<ProductItem> prods = await CatalogService().listProducts();
      if (!mounted) return;
      setState(() { 
        _productById.clear(); 
        for (final ProductItem p in prods) { 
          _productById[p.id] = p; 
        } 
      });
    } catch (_) {}
  }

  Future<void> _remove(int productId) async {
    try {
      final bool ok = await _svc.removeFromCart(productId: productId);
      if (!mounted) return;
      if (ok) setState(() => _items = _items.where((CartItem e) => e.productId != productId).toList());
    } catch (_) {}
  }

  Future<void> _inc(int index) async {
    final CartItem it = _items[index];
    await _setQuantity(productId: it.productId, quantity: it.quantity + 1);
  }

  Future<void> _dec(int index) async {
    final CartItem it = _items[index];
    if (it.quantity <= 1) return;
    await _setQuantity(productId: it.productId, quantity: it.quantity - 1);
  }

  Future<void> _setQuantity({required int productId, required int quantity}) async {
    setState(() => _updating.add(productId));
    try {
      final CartItem updated = await _svc.addToCart(productId: productId, quantity: quantity);
      if (!mounted) return;
      setState(() {
        _items = _items.map((CartItem e) => 
          e.productId == productId ? 
          CartItem(id: updated.id, productId: updated.productId, quantity: updated.quantity) : e
        ).toList();
      });
    } catch (_) {}
    finally {
      if (mounted) {
        setState(() => _updating.remove(productId));
      }
    }
  }

  int get _subtotalCents => _items.fold<int>(0, (int a, CartItem b) => a + b.quantity * _unitPriceCents(b));

  int _unitPriceCents(CartItem it) {
    final ProductItem? p = _productById[it.productId];
    return p?.priceCents ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(0, 248, 250, 252),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0B8FAC), strokeWidth: 3))
                  : _items.isEmpty
                      ? _buildEmptyCart()
                      : CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(child: _buildAddressSection()),
                            SliverList.separated(
                              itemCount: _items.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, i) {
                                final CartItem it = _items[i];
                                return FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: SlideTransition(
                                    position: _slideAnimation,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: _buildCartItem(it, i),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SliverToBoxAdapter(child: SizedBox(height: 12)),
                          ],
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _items.isNotEmpty
          ? SafeArea(
              minimum: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCheckoutSection(),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0B8FAC).withAlpha(26),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: Color(0xFF0B8FAC),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Cart',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '${_items.length} items',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (_items.isNotEmpty)
            GestureDetector(
              onTap: () async {
                for (final item in _items) {
                  await _remove(item.productId);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade400,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF0B8FAC).withAlpha((0.1 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: const Color(0xFF0B8FAC).withAlpha((0.1 * 255).round()),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Start Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B8FAC),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    final ProductItem? product = _productById[item.productId];
    if (product == null) return const SizedBox.shrink();

    return Dismissible(
      key: ValueKey<int>(item.productId),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade500,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) => _remove(item.productId),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _CartProductImage(product: product),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF1E293B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 0,
                          child: Text(
                            '₹${(product.priceCents / 100).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF0B8FAC),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _QuantityControl(
                        quantity: item.quantity,
                        onDecrement: _updating.contains(item.productId) ? null : () => _dec(index),
                        onIncrement: _updating.contains(item.productId) ? null : () => _inc(index),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).round()),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showAddressSelection,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B8FAC).withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF0B8FAC),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedAddress?.name ?? 'Select Delivery Address',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: _selectedAddress != null ? const Color(0xFF1E293B) : Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (_selectedAddress != null) ...[
                        Text(
                          _selectedAddress!.address,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_selectedAddress!.phone.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _selectedAddress!.phone,
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ] else ...[
                        Text('Choose where to deliver your order', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B8FAC).withAlpha((0.05 * 255).round()),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, size: 20, color: Color(0xFF0B8FAC)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _user?.name ?? 'Guest',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (_user?.email != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 18, color: Color(0xFF0B8FAC)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _user!.email,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.06 * 255).round()),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfo(),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0B8FAC).withAlpha((0.05 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Subtotal', style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                Text('₹${(_subtotalCents / 100).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1E293B))),
              ]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Text(
                  '₹${(_subtotalCents / 100).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: Color(0xFF0B8FAC),
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _canProceedToCheckout() ? (_checkingOut ? null : _proceedToCheckout) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canProceedToCheckout() ? const Color(0xFF0B8FAC) : Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _checkingOut
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                      Icon(Icons.shopping_cart_checkout, size: 18),
                      SizedBox(width: 10),
                      Text('Check Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressSelection() {
    showDialog(
      context: context,
      builder: (context) => AddressSelectionDialog(
        savedAddresses: _savedAddresses,
        onAddressSelected: (address) {
          setState(() {
            _selectedAddress = address;
          });
        },
      ),
    );
  }

  bool _canProceedToCheckout() {
    return _items.isNotEmpty && _selectedAddress != null && _user != null;
  }

  Future<void> _proceedToCheckout() async {
    if (!_canProceedToCheckout()) return;
    
    setState(() => _checkingOut = true);
    try {
      final upiResult = await _paymentService.startUpiPayment(
        productName: 'Cloth Order',
        amountInCents: _subtotalCents,
      );
      
      if (upiResult['status'] == 'success') {
        final bool ok = await _svc.checkout();
        if (!mounted) return;
        setState(() => _checkingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Checkout successful' : 'Cart is empty'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        if (ok) _fetch();
      } else {
        if (!mounted) return;
        setState(() => _checkingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('UPI Payment failed or cancelled\n${upiResult['status']}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
        setState(() => _checkingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing payment: $e')),
      );
    }
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _miniIconButton(icon: Icons.remove_rounded, onTap: onDecrement),
          Container(
            width: 28,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1E293B),
              ),
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ),
          _miniIconButton(icon: Icons.add_rounded, onTap: onIncrement),
        ],
      ),
    );
  }

  Widget _miniIconButton({required IconData icon, required VoidCallback? onTap}) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Material(
        color: onTap != null 
            ? const Color(0xFF0B8FAC).withAlpha((0.08 * 255).round()) 
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Icon(
            icon,
            size: 16,
            color: onTap != null ? const Color(0xFF0B8FAC) : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}

class _CartProductImage extends StatelessWidget {
  const _CartProductImage({required this.product});

  final ProductItem? product;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = product?.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final String url = imageUrl.startsWith('http') ? imageUrl : '${AuthService.baseUrl}$imageUrl';
      return Image.network(
        url,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey.shade400,
        size: 24,
      ),
    );
  }
}