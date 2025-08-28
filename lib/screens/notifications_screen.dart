import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_Section> sections = <_Section>[
      _Section(title: 'TODAY', items: <_NotifItem>[
        const _NotifItem(icon: Icons.chat_bubble_outline, title: 'Payment Successful!', subtitle: 'Payment via your account was successful.'),
        const _NotifItem(icon: Icons.close_rounded, title: 'Payment Failed', subtitle: 'Please check your details or balance and try again.'),
      ]),
      _Section(title: 'YESTERDAY', items: const <_NotifItem>[
        _NotifItem(icon: Icons.local_offer_outlined, title: 'Exclusive Offer Just for You', subtitle: 'Get 30% OFF with code STYLE30'),
        _NotifItem(icon: Icons.notifications_none_rounded, title: 'Did You Forget Something?', subtitle: 'Complete your purchase before it sells out.'),
      ]),
      _Section(title: 'MAR 25 2025', items: const <_NotifItem>[
        _NotifItem(icon: Icons.local_shipping_outlined, title: 'Shipping Updates', subtitle: 'Get ready! Your package is arriving soon!'),
        _NotifItem(icon: Icons.check_circle_outline, title: 'Delivered!', subtitle: 'Item moved! If you need more or customized order!'),
      ]),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Row(
                  children: const <Widget>[
                    BackButton(),
                    SizedBox(width: 8),
                    Text('Notification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              for (final _Section sec in sections) ...<Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18, bottom: 10),
                    child: Text(sec.title, style: const TextStyle(color: Color(0xFF9AA0A6), fontWeight: FontWeight.w700)),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext _, int i) => _NotifTile(item: sec.items[i]),
                    childCount: sec.items.length,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Section {
  _Section({required this.title, required this.items});
  final String title;
  final List<_NotifItem> items;
}

class _NotifItem {
  const _NotifItem({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.item});
  final _NotifItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEAEAEA))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: const Color(0xFFEFF2FF), borderRadius: BorderRadius.circular(12)),
            child: Icon(item.icon, color: const Color(0xFF2E4DFF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(item.subtitle, style: const TextStyle(color: Color(0xFF7C7C7C))),
            ]),
          ),
        ],
      ),
    );
  }
}


