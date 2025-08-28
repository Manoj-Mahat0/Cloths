import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../services/auth_service.dart';
import '../../services/catalog_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2E4DFF);
    return Scaffold(
      body: Stack(
          children: <Widget>[
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _TopBar(onLogout: _logout),
                  const SizedBox(height: 14),
                  Expanded(child: _buildContent(context)),
                ],
              ),
            ),
          ),
          _buildFloatingNav(context, primary),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return const _OverviewTab();
      case 1:
        return const _CatalogTab();
      case 2:
        return const _ProductsCrud();
      case 3:
        return const _ReviewsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFloatingNav(BuildContext context, Color primary) {
    final List<_AdminNavItem> items = <_AdminNavItem>[
      const _AdminNavItem(icon: Icons.dashboard_rounded, label: 'Overview'),
      const _AdminNavItem(icon: Icons.inventory_2_rounded, label: 'Catalog'),
      const _AdminNavItem(icon: Icons.storefront_rounded, label: 'Products'),
      const _AdminNavItem(icon: Icons.reviews_rounded, label: 'Reviews'),
    ];
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: SafeArea(
        top: false,
        child: Container(
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
                        Text(
                          items[i].label,
                          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
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

class _AdminNavItem {
  const _AdminNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2E4DFF);
    return Row(
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF2FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.admin_panel_settings_rounded, color: primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('welcome,', style: TextStyle(color: Color(0xFF7C7C7C))),
              FutureBuilder<Map<String, dynamic>?>(
                future: AuthService().fetchCurrentUserAndPersist(),
                builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
                  final String username = (snapshot.data != null && snapshot.data!['username'] is String)
                      ? (snapshot.data!['username'] as String)
                      : 'Admin';
                  return Text(username, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));
                },
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        const SizedBox(width: 4),
        ElevatedButton.icon(
          onPressed: onLogout,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEFF2FF),
            foregroundColor: primary,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            elevation: 0,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text('Logout'),
        ),
      ],
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SearchBar(),
          const SizedBox(height: 14),
          const _PromoCard(),
          const SizedBox(height: 14),
          const Text('Quick actions', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.10,
            children: const <Widget>[
              _QuickActionCard(icon: Icons.inventory_2_rounded, title: 'Manage Catalog', subtitle: 'Categories, sizes, colors'),
              _QuickActionCard(icon: Icons.storefront_rounded, title: 'Manage Products', subtitle: 'Add, edit, images'),
              _QuickActionCard(icon: Icons.reviews_rounded, title: 'Moderate Reviews', subtitle: 'Hide or delete'),
              _QuickActionCard(icon: Icons.bar_chart_rounded, title: 'Analytics', subtitle: 'Coming soon'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: const <Widget>[
                Icon(Icons.search, color: Color(0xFF9AA0A6)),
                SizedBox(width: 8),
                Text('Search in admin...', style: TextStyle(color: Color(0xFF9AA0A6))),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(color: const Color(0xFF2E4DFF), borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(10),
          child: const Icon(Icons.tune_rounded, color: Colors.white),
        ),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFF2E4DFF), borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: const <Widget>[
          Expanded(
            child: Text(
              'Admin tools\nManage your store effortlessly',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 48),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF2E4DFF)),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: Color(0xFF9AA0A6), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CatalogTab extends StatefulWidget {
  const _CatalogTab();

  @override
  State<_CatalogTab> createState() => _CatalogTabState();
}

class _CatalogTabState extends State<_CatalogTab> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 6)),
              ],
            ),
            child: const TabBar(
              isScrollable: true,
              indicatorColor: Color(0xFF2E4DFF),
              labelColor: Color(0xFF2E4DFF),
              unselectedLabelColor: Color(0xFF9AA0A6),
              tabs: <Widget>[
                Tab(text: 'Categories'),
                Tab(text: 'Shapes'),
                Tab(text: 'Sizes'),
                Tab(text: 'Colors'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Expanded(
            child: TabBarView(
              children: <Widget>[
                _CategoriesCrud(),
                _ShapesCrud(),
                _SizesCrud(),
                _ColorsCrud(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CrudList extends StatelessWidget {
  const _CrudList({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E4DFF),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 6)),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: const Icon(Icons.label_rounded, color: Color(0xFF2E4DFF)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(items[index], style: const TextStyle(fontWeight: FontWeight.w600))),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.edit_rounded, color: Color(0xFF2E4DFF))),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFD32F2F))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoriesCrud extends StatefulWidget {
  const _CategoriesCrud();

  @override
  State<_CategoriesCrud> createState() => _CategoriesCrudState();
}

class _CategoriesCrudState extends State<_CategoriesCrud> {
  List<Category> _categories = <Category>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final List<Category> cats = await CatalogService().listCategories();
      if (!mounted) return;
      setState(() {
        _categories = cats;
        _loading = false;
      });
      _showToast('Loaded ${cats.length} categories');
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showToast('Failed to load categories', error: true);
    }
  }

  Future<void> _create() async {
    final String? name = await _promptName(initial: '');
    if (name == null || name.trim().isEmpty) return;
    try {
      final Category c = await CatalogService().createCategory(name: name.trim());
      if (!mounted) return;
      setState(() => _categories = <Category>[c, ..._categories]);
      _showToast('Created "${c.name}"');
    } catch (e) {
      _showToast('Create failed', error: true);
    }
  }

  Future<void> _edit(Category cat) async {
    final String? name = await _promptName(initial: cat.name);
    if (name == null || name.trim().isEmpty) return;
    try {
      final Category updated = await CatalogService().updateCategory(id: cat.id, name: name.trim(), isActive: cat.isActive);
      if (!mounted) return;
      setState(() => _categories = _categories.map((Category c) => c.id == updated.id ? updated : c).toList());
      _showToast('Updated to "${updated.name}"');
    } catch (e) {
      _showToast('Update failed', error: true);
    }
  }

  Future<void> _delete(Category cat) async {
    try {
      final bool ok = await CatalogService().deleteCategory(id: cat.id);
      if (!mounted) return;
      if (ok) {
        setState(() => _categories = _categories.where((Category c) => c.id != cat.id).toList());
        _showToast('Deleted');
      } else {
        _showToast('Delete failed', error: true);
      }
    } catch (e) {
      _showToast('Delete failed', error: true);
    }
  }

  Future<String?> _promptName({required String initial}) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _CategoryNameDialog(initial: initial),
    );
  }

  void _showToast(String message, {bool error = false}) {
    final Color bg = error ? const Color(0xFFD32F2F) : const Color(0xFF2E4DFF);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text('Categories', style: TextStyle(fontWeight: FontWeight.w700)),
            ElevatedButton.icon(
              onPressed: _create,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E4DFF),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) {
              final Category cat = _categories[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 6)),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: const Icon(Icons.folder_rounded, color: Color(0xFF2E4DFF)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                    Switch(
                      value: cat.isActive,
                      onChanged: (bool val) async {
                        try {
                          final Category updated = await CatalogService().updateCategory(id: cat.id, name: cat.name, isActive: val);
                          if (!mounted) return;
                          setState(() => _categories = _categories.map((Category c) => c.id == updated.id ? updated : c).toList());
                          _showToast(val ? 'Activated' : 'Deactivated');
                        } catch (_) {
                          _showToast('Update failed', error: true);
                        }
                      },
                    ),
                    IconButton(onPressed: () => _edit(cat), icon: const Icon(Icons.edit_rounded, color: Color(0xFF2E4DFF))),
                    IconButton(onPressed: () => _delete(cat), icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFD32F2F))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ShapesCrud extends StatefulWidget {
  const _ShapesCrud();

  @override
  State<_ShapesCrud> createState() => _ShapesCrudState();
}

class _ShapesCrudState extends State<_ShapesCrud> {
  List<Shape> _shapes = <Shape>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final List<Shape> list = await CatalogService().listShapes();
      if (!mounted) return;
      setState(() {
        _shapes = list;
        _loading = false;
      });
      _showToast('Loaded ${list.length} shapes');
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showToast('Failed to load shapes', error: true);
    }
  }

  Future<void> _create() async {
    final String? name = await _promptName(initial: '');
    if (name == null || name.trim().isEmpty) return;
    try {
      final Shape s = await CatalogService().createShape(name: name.trim());
      if (!mounted) return;
      setState(() => _shapes = <Shape>[s, ..._shapes]);
      _showToast('Created "${s.name}"');
    } catch (_) {
      _showToast('Create failed', error: true);
    }
  }

  Future<void> _edit(Shape shape) async {
    final String? name = await _promptName(initial: shape.name);
    if (name == null || name.trim().isEmpty) return;
    try {
      final Shape updated = await CatalogService().updateShape(id: shape.id, name: name.trim(), isActive: shape.isActive);
      if (!mounted) return;
      setState(() => _shapes = _shapes.map((Shape s) => s.id == updated.id ? updated : s).toList());
      _showToast('Updated to "${updated.name}"');
    } catch (_) {
      _showToast('Update failed', error: true);
    }
  }

  Future<void> _delete(Shape shape) async {
    try {
      final bool ok = await CatalogService().deleteShape(id: shape.id);
      if (!mounted) return;
      if (ok) {
        setState(() => _shapes = _shapes.where((Shape s) => s.id != shape.id).toList());
        _showToast('Deleted');
      } else {
        _showToast('Delete failed', error: true);
      }
    } catch (_) {
      _showToast('Delete failed', error: true);
    }
  }

  Future<String?> _promptName({required String initial}) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _CategoryNameDialog(initial: initial),
    );
  }

  void _showToast(String message, {bool error = false}) {
    final Color bg = error ? const Color(0xFFD32F2F) : const Color(0xFF2E4DFF);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text('Shapes', style: TextStyle(fontWeight: FontWeight.w700)),
            ElevatedButton.icon(
              onPressed: _create,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E4DFF),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            itemCount: _shapes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) {
              final Shape s = _shapes[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 6)),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: const Icon(Icons.category_rounded, color: Color(0xFF2E4DFF)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                    Switch(
                      value: s.isActive,
                      onChanged: (bool val) async {
                        try {
                          final Shape updated = await CatalogService().updateShape(id: s.id, name: s.name, isActive: val);
                          if (!mounted) return;
                          setState(() => _shapes = _shapes.map((Shape x) => x.id == updated.id ? updated : x).toList());
                          _showToast(val ? 'Activated' : 'Deactivated');
                        } catch (_) {
                          _showToast('Update failed', error: true);
                        }
                      },
                    ),
                    IconButton(onPressed: () => _edit(s), icon: const Icon(Icons.edit_rounded, color: Color(0xFF2E4DFF))),
                    IconButton(onPressed: () => _delete(s), icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFD32F2F))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SizesCrud extends StatefulWidget {
  const _SizesCrud();

  @override
  State<_SizesCrud> createState() => _SizesCrudState();
}

class _SizesCrudState extends State<_SizesCrud> {
  List<SizeItem> _sizes = <SizeItem>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final List<SizeItem> list = await CatalogService().listSizes();
      if (!mounted) return;
      setState(() {
        _sizes = list;
        _loading = false;
      });
      _showToast('Loaded ${list.length} sizes');
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showToast('Failed to load sizes', error: true);
    }
  }

  Future<void> _create() async {
    final String? name = await _promptName(initial: '');
    if (name == null || name.trim().isEmpty) return;
    try {
      final SizeItem s = await CatalogService().createSize(name: name.trim());
      if (!mounted) return;
      setState(() => _sizes = <SizeItem>[s, ..._sizes]);
      _showToast('Created "${s.name}"');
    } catch (_) {
      _showToast('Create failed', error: true);
    }
  }

  Future<void> _edit(SizeItem size) async {
    final String? name = await _promptName(initial: size.name);
    if (name == null || name.trim().isEmpty) return;
    try {
      final SizeItem updated = await CatalogService().updateSize(id: size.id, name: name.trim(), isActive: size.isActive);
      if (!mounted) return;
      setState(() => _sizes = _sizes.map((SizeItem s) => s.id == updated.id ? updated : s).toList());
      _showToast('Updated to "${updated.name}"');
    } catch (_) {
      _showToast('Update failed', error: true);
    }
  }

  Future<void> _delete(SizeItem size) async {
    try {
      final bool ok = await CatalogService().deleteSize(id: size.id);
      if (!mounted) return;
      if (ok) {
        setState(() => _sizes = _sizes.where((SizeItem s) => s.id != size.id).toList());
        _showToast('Deleted');
      } else {
        _showToast('Delete failed', error: true);
      }
    } catch (_) {
      _showToast('Delete failed', error: true);
    }
  }

  Future<String?> _promptName({required String initial}) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _CategoryNameDialog(initial: initial),
    );
  }

  void _showToast(String message, {bool error = false}) {
    final Color bg = error ? const Color(0xFFD32F2F) : const Color(0xFF2E4DFF);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text('Sizes', style: TextStyle(fontWeight: FontWeight.w700)),
            ElevatedButton.icon(
              onPressed: _create,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E4DFF),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            itemCount: _sizes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) {
              final SizeItem s = _sizes[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 6)),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: const Icon(Icons.straighten_rounded, color: Color(0xFF2E4DFF)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                    Switch(
                      value: s.isActive,
                      onChanged: (bool val) async {
                        try {
                          final SizeItem updated = await CatalogService().updateSize(id: s.id, name: s.name, isActive: val);
                          if (!mounted) return;
                          setState(() => _sizes = _sizes.map((SizeItem x) => x.id == updated.id ? updated : x).toList());
                          _showToast(val ? 'Activated' : 'Deactivated');
                        } catch (_) {
                          _showToast('Update failed', error: true);
                        }
                      },
                    ),
                    IconButton(onPressed: () => _edit(s), icon: const Icon(Icons.edit_rounded, color: Color(0xFF2E4DFF))),
                    IconButton(onPressed: () => _delete(s), icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFD32F2F))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ColorsCrud extends StatefulWidget {
  const _ColorsCrud();

  @override
  State<_ColorsCrud> createState() => _ColorsCrudState();
}

class _ColorsCrudState extends State<_ColorsCrud> {
  List<ColorItem> _colors = <ColorItem>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final List<ColorItem> list = await CatalogService().listColors();
      if (!mounted) return;
      setState(() {
        _colors = list;
        _loading = false;
      });
      _showToast('Loaded ${list.length} colors');
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showToast('Failed to load colors', error: true);
    }
  }

  Future<void> _create() async {
    final String? name = await _promptName(initial: '');
    if (name == null || name.trim().isEmpty) return;
    try {
      final ColorItem s = await CatalogService().createColor(name: name.trim());
      if (!mounted) return;
      setState(() => _colors = <ColorItem>[s, ..._colors]);
      _showToast('Created "${s.name}"');
    } catch (_) {
      _showToast('Create failed', error: true);
    }
  }

  Future<void> _edit(ColorItem color) async {
    final String? name = await _promptName(initial: color.name);
    if (name == null || name.trim().isEmpty) return;
    try {
      final ColorItem updated = await CatalogService().updateColor(id: color.id, name: name.trim(), isActive: color.isActive);
      if (!mounted) return;
      setState(() => _colors = _colors.map((ColorItem s) => s.id == updated.id ? updated : s).toList());
      _showToast('Updated to "${updated.name}"');
    } catch (_) {
      _showToast('Update failed', error: true);
    }
  }

  Future<void> _delete(ColorItem color) async {
    try {
      final bool ok = await CatalogService().deleteColor(id: color.id);
      if (!mounted) return;
      if (ok) {
        setState(() => _colors = _colors.where((ColorItem s) => s.id != color.id).toList());
        _showToast('Deleted');
      } else {
        _showToast('Delete failed', error: true);
      }
    } catch (_) {
      _showToast('Delete failed', error: true);
    }
  }

  Future<String?> _promptName({required String initial}) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _CategoryNameDialog(initial: initial),
    );
  }

  void _showToast(String message, {bool error = false}) {
    final Color bg = error ? const Color(0xFFD32F2F) : const Color(0xFF2E4DFF);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text('Colors', style: TextStyle(fontWeight: FontWeight.w700)),
            ElevatedButton.icon(
              onPressed: _create,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E4DFF),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            itemCount: _colors.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) {
              final ColorItem s = _colors[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 6)),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: const Icon(Icons.palette_rounded, color: Color(0xFF2E4DFF)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                    Switch(
                      value: s.isActive,
                      onChanged: (bool val) async {
                        try {
                          final ColorItem updated = await CatalogService().updateColor(id: s.id, name: s.name, isActive: val);
                          if (!mounted) return;
                          setState(() => _colors = _colors.map((ColorItem x) => x.id == updated.id ? updated : x).toList());
                          _showToast(val ? 'Activated' : 'Deactivated');
                        } catch (_) {
                          _showToast('Update failed', error: true);
                        }
                      },
                    ),
                    IconButton(onPressed: () => _edit(s), icon: const Icon(Icons.edit_rounded, color: Color(0xFF2E4DFF))),
                    IconButton(onPressed: () => _delete(s), icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFD32F2F))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryNameDialog extends StatefulWidget {
  const _CategoryNameDialog({required this.initial});

  final String initial;

  @override
  State<_CategoryNameDialog> createState() => _CategoryNameDialogState();
}

class _CategoryNameDialogState extends State<_CategoryNameDialog> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF2E4DFF);
    final bool canSave = _controller.text.trim().isNotEmpty && !_saving;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Text('Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _onSave(canSave),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: canSave ? () => _onSave(true) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _saving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSave(bool canSave) {
    if (!canSave) return;
    setState(() => _saving = true);
    final String value = _controller.text.trim();
    // Mimic tiny delay so progress is visible for fast requests
    Future<void>.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      Navigator.pop(context, value);
    });
  }
}

class _ProductsCrud extends StatefulWidget {
  const _ProductsCrud();

  @override
  State<_ProductsCrud> createState() => _ProductsCrudState();
}

class _ProductsCrudState extends State<_ProductsCrud> {
  List<ProductItem> _products = <ProductItem>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final List<ProductItem> list = await CatalogService().listProducts();
      if (!mounted) return;
      setState(() {
        _products = list;
        _loading = false;
      });
      _toast('Loaded ${list.length} products');
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _toast('Failed to load products', error: true);
    }
  }

  Future<void> _create() async {
    final _ProductDialogResult? result = await showDialog<_ProductDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const _ProductDialog(),
    );
    if (result == null) return;
    try {
      final ProductItem item = await CatalogService().createProductMultipart(
        name: result.name,
        categoryId: result.categoryId,
        shapeId: result.shapeId,
        sizeId: result.sizeId,
        colorId: result.colorId,
        priceCents: result.priceCents,
        file: result.file,
      );
      if (!mounted) return;
      setState(() => _products = <ProductItem>[item, ..._products]);
      _toast('Created "${item.name}"');
    } catch (e) {
      _toast('Create failed: $e', error: true);
    }
  }

  Future<void> _delete(ProductItem p) async {
    try {
      final bool ok = await CatalogService().deleteProduct(id: p.id);
      if (!mounted) return;
      if (ok) {
        setState(() => _products = _products.where((ProductItem x) => x.id != p.id).toList());
        _toast('Deleted');
      } else {
        _toast('Delete failed', error: true);
      }
    } catch (_) {
      _toast('Delete failed', error: true);
    }
  }

  void _toast(String msg, {bool error = false}) {
    final Color bg = error ? const Color(0xFFD32F2F) : const Color(0xFF2E4DFF);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text('Products', style: TextStyle(fontWeight: FontWeight.w700)),
            ElevatedButton.icon(
              onPressed: _create,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E4DFF),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.78,
            ),
            itemCount: _products.length,
            itemBuilder: (BuildContext context, int i) {
              final ProductItem p = _products[i];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 6)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: _ProductImage(imageUrl: p.imageUrl),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 8,
                            runSpacing: 8,
                            children: <Widget>[
                              _SmallActionButton(icon: Icons.edit_rounded, label: 'Edit', onTap: () async {
                                final _ProductDialogResult? result = await showDialog<_ProductDialogResult>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) => _ProductDialog(
                                    initial: _ProductInitial(
                                      name: p.name,
                                      categoryId: p.categoryId,
                                      shapeId: p.shapeId,
                                      sizeId: p.sizeId,
                                      colorId: p.colorId,
                                      priceCents: p.priceCents,
                                    ),
                                  ),
                                );
                                if (result == null) return;
                                try {
                                  final ProductItem updated = await CatalogService().updateProduct(
                                    id: p.id,
                                    name: result.name,
                                    categoryId: result.categoryId,
                                    shapeId: result.shapeId,
                                    sizeId: result.sizeId,
                                    colorId: result.colorId,
                                    priceCents: result.priceCents,
                                    isActive: p.isActive,
                                  );
                                  setState(() => _products = _products.map((ProductItem x) => x.id == updated.id ? updated : x).toList());
                                  _toast('Updated');
                                } catch (e) {
                                  _toast('Update failed: $e', error: true);
                                }
                              }),
                              _SmallActionButton(icon: Icons.image_rounded, label: 'Image', onTap: () async {
                                File? file;
                                try {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
                                  if (picked != null) file = File(picked.path);
                                } catch (_) {}
                                if (file == null) {
                                  final FilePickerResult? res = await FilePicker.platform.pickFiles(type: FileType.image);
                                  if (res != null && res.files.single.path != null) file = File(res.files.single.path!);
                                }
                                if (file == null) return;
                                try {
                                  await CatalogService().uploadProductImage(productId: p.id, file: file);
                                  _toast('Image uploaded');
                                } catch (_) {
                                  _toast('Upload failed', error: true);
                                }
                              }),
                              IconButton(
                                onPressed: () => _delete(p),
                                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFD32F2F)),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductDialogResult {
  _ProductDialogResult({required this.name, required this.categoryId, required this.shapeId, required this.sizeId, required this.colorId, required this.priceCents, this.file});

  final String name;
  final int categoryId;
  final int shapeId;
  final int sizeId;
  final int colorId;
  final int priceCents;
  final File? file;
}

class _ProductInitial {
  const _ProductInitial({required this.name, required this.categoryId, required this.shapeId, required this.sizeId, required this.colorId, required this.priceCents});

  final String name;
  final int categoryId;
  final int shapeId;
  final int sizeId;
  final int colorId;
  final int priceCents;
}

class _ProductDialog extends StatefulWidget {
  const _ProductDialog({this.initial});

  final _ProductInitial? initial;

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _price = TextEditingController();
  int? _categoryId;
  int? _shapeId;
  int? _sizeId;
  int? _colorId;
  File? _file;
  bool _saving = false;

  List<Category> _cats = <Category>[];
  List<Shape> _shapes = <Shape>[];
  List<SizeItem> _sizes = <SizeItem>[];
  List<ColorItem> _colors = <ColorItem>[];

  @override
  void initState() {
    super.initState();
    _bootstrap();
    final _ProductInitial? init = widget.initial;
    if (init != null) {
      _name.text = init.name;
      _price.text = init.priceCents.toString();
      _categoryId = init.categoryId;
      _shapeId = init.shapeId;
      _sizeId = init.sizeId;
      _colorId = init.colorId;
    }
  }

  Future<void> _bootstrap() async {
    try {
      final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
        CatalogService().listCategories(),
        CatalogService().listShapes(),
        CatalogService().listSizes(),
        CatalogService().listColors(),
      ]);
      if (!mounted) return;
      setState(() {
        _cats = results[0] as List<Category>;
        _shapes = results[1] as List<Shape>;
        _sizes = results[2] as List<SizeItem>;
        _colors = results[3] as List<ColorItem>;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Text('Add Product', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(onPressed: _saving ? null : () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                validator: (String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(child: _Dropdown<Category>(label: 'Category', items: _cats, selectedId: _categoryId, getId: (Category c) => c.id, getLabel: (Category c) => c.name, onChanged: (int? v) => setState(() => _categoryId = v))),
                  const SizedBox(width: 10),
                  Expanded(child: _Dropdown<Shape>(label: 'Shape', items: _shapes, selectedId: _shapeId, getId: (Shape s) => s.id, getLabel: (Shape s) => s.name, onChanged: (int? v) => setState(() => _shapeId = v))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(child: _Dropdown<SizeItem>(label: 'Size', items: _sizes, selectedId: _sizeId, getId: (SizeItem s) => s.id, getLabel: (SizeItem s) => s.name, onChanged: (int? v) => setState(() => _sizeId = v))),
                  const SizedBox(width: 10),
                  Expanded(child: _Dropdown<ColorItem>(label: 'Color', items: _colors, selectedId: _colorId, getId: (ColorItem c) => c.id, getLabel: (ColorItem c) => c.name, onChanged: (int? v) => setState(() => _colorId = v))),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price in cents', border: OutlineInputBorder()),
                validator: (String? v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final int? parsed = int.tryParse(v);
                  if (parsed == null || parsed <= 0) return 'Invalid';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saving
                          ? null
                          : () async {
                              // Prefer ImagePicker on mobile; fall back to FilePicker on desktop
                              try {
                                final ImagePicker picker = ImagePicker();
                                final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
                                if (picked != null) {
                                  setState(() => _file = File(picked.path));
                                  return;
                                }
                              } catch (_) {}
                              final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                              if (result != null && result.files.single.path != null) {
                                setState(() => _file = File(result.files.single.path!));
                              }
                            },
                      icon: const Icon(Icons.image_rounded),
                      label: Text(_file == null ? 'Select Image' : 'Image selected'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _saving
                      ? null
                      : () {
                          if (!_formKey.currentState!.validate()) return;
                          if (_categoryId == null || _shapeId == null || _sizeId == null || _colorId == null) return;
                          setState(() => _saving = true);
                          Navigator.pop<_ProductDialogResult>(
                            context,
                            _ProductDialogResult(
                              name: _name.text.trim(),
                              categoryId: _categoryId!,
                              shapeId: _shapeId!,
                              sizeId: _sizeId!,
                              colorId: _colorId!,
                              priceCents: int.parse(_price.text.trim()),
                              file: _file,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E4DFF), foregroundColor: Colors.white),
                  child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({required this.label, required this.items, required this.selectedId, required this.getId, required this.getLabel, required this.onChanged});

  final String label;
  final List<T> items;
  final int? selectedId;
  final int Function(T) getId;
  final String Function(T) getLabel;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: selectedId,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: items.map((T e) => DropdownMenuItem<int>(value: getId(e), child: Text(getLabel(e)))).toList(),
      onChanged: onChanged,
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      final String url = imageUrl!.startsWith('http') ? imageUrl! : '${AuthService.baseUrl}$imageUrl';
      return Container(
        color: const Color(0xFFF2F3F7),
        child: SizedBox.expand(
          child: Image.network(
            url,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => _placeholder(),
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                return AnimatedOpacity(duration: const Duration(milliseconds: 200), opacity: 1, child: child);
              }
              return Stack(
                children: <Widget>[
                  Positioned.fill(child: child),
                  const Positioned.fill(
                    child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF2F3F7),
      child: const Center(child: Icon(Icons.image, color: Color(0xFF9AA0A6), size: 28)),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF2FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: const Color(0xFF2E4DFF)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Color(0xFF2E4DFF), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> reviews = <Map<String, String>>[
      <String, String>{'user': 'Ravi', 'text': 'Great quality!'},
      <String, String>{'user': 'Anita', 'text': 'Color slightly different.'},
      <String, String>{'user': 'Kunal', 'text': 'Fast delivery.'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Reviews', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) {
              final Map<String, String> r = reviews[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 6)),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFEFF2FF),
                      child: Text((r['user'] ?? 'U').substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Color(0xFF2E4DFF), fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(r['user'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(r['text'] ?? ''),
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              _SmallActionButton(icon: Icons.visibility_off_rounded, label: 'Hide', onTap: () {}),
                              const SizedBox(width: 8),
                              _SmallActionButton(icon: Icons.delete_outline_rounded, label: 'Delete', onTap: () {}),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


