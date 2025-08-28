import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class WarehouseDashboard extends StatefulWidget {
  const WarehouseDashboard({super.key});

  @override
  State<WarehouseDashboard> createState() => _WarehouseDashboardState();
}

class _WarehouseDashboardState extends State<WarehouseDashboard> {
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
        return const _WarehousesTab();
      case 2:
        return const _OrdersTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFloatingNav(BuildContext context, Color primary) {
    final List<_NavItem> items = <_NavItem>[
      const _NavItem(icon: Icons.dashboard_rounded, label: 'Overview'),
      const _NavItem(icon: Icons.warehouse_rounded, label: 'Warehouses'),
      const _NavItem(icon: Icons.local_shipping_rounded, label: 'Orders'),
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
                        Text(items[i].label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
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

class _NavItem {
  const _NavItem({required this.icon, required this.label});

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
          child: const Icon(Icons.warehouse_rounded, color: primary),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('welcome,', style: TextStyle(color: Color(0xFF7C7C7C))),
              Text('Warehouse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
        children: const <Widget>[
          _PromoCard(),
          SizedBox(height: 14),
          _StatsRow(),
        ],
      ),
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
              'Warehouse tools\nTrack and fulfill orders',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          Icon(Icons.local_shipping_rounded, color: Colors.white, size: 48),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        Expanded(child: _StatCard(title: 'Pending', value: '12')),
        SizedBox(width: 12),
        Expanded(child: _StatCard(title: 'Packed', value: '7')),
        SizedBox(width: 12),
        Expanded(child: _StatCard(title: 'Shipped', value: '5')),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final String value;

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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: const TextStyle(color: Color(0xFF9AA0A6))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        ],
      ),
    );
  }
}

class _WarehousesTab extends StatelessWidget {
  const _WarehousesTab();

  @override
  Widget build(BuildContext context) {
    final List<String> warehouses = <String>['Mumbai DC', 'Delhi DC', 'Bengaluru DC'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text('Warehouses', style: TextStyle(fontWeight: FontWeight.w700)),
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
            itemCount: warehouses.length,
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
                      child: const Icon(Icons.warehouse_rounded, color: Color(0xFF2E4DFF)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(warehouses[index], style: const TextStyle(fontWeight: FontWeight.w600))),
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

class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> orders = <Map<String, String>>[
      <String, String>{'id': '#10021', 'status': 'pending'},
      <String, String>{'id': '#10022', 'status': 'packed'},
      <String, String>{'id': '#10023', 'status': 'shipped'},
      <String, String>{'id': '#10024', 'status': 'delivered'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Orders', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) {
              final Map<String, String> o = orders[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 6)),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(o['id'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF2FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            (o['status'] ?? '').toUpperCase(),
                            style: const TextStyle(color: Color(0xFF2E4DFF), fontWeight: FontWeight.w600, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _SmallActionButton(icon: Icons.inventory_rounded, label: 'Pack', onTap: () {}),
                        _SmallActionButton(icon: Icons.local_shipping_rounded, label: 'Ship', onTap: () {}),
                        _SmallActionButton(icon: Icons.check_circle_rounded, label: 'Deliver', onTap: () {}),
                        _SmallActionButton(icon: Icons.reply_rounded, label: 'Receive Return', onTap: () {}),
                        _SmallActionButton(icon: Icons.report_gmailerrorred_rounded, label: 'Delivery Failed', onTap: () {}),
                      ],
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


