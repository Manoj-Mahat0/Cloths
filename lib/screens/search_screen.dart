import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _query = TextEditingController();
  final List<String> _recent = <String>[
    'Blue shirt',
    'Crew Neck T-Shirt',
    'V Neck T-Shirt',
    'Sleeveless T-Shirt (Tank Tops)',
    'Bomber Jacket',
    'Denim Jacket',
  ];

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _openFilter() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext _) => const _FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: const <Widget>[
                BackButton(),
                SizedBox(width: 8),
                Text('Search', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _query,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search',
                        filled: true,
                        fillColor: const Color(0xFFF5F6FA),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _openFilter,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(color: const Color(0xFF2E4DFF), borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(Icons.tune_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Recent', style: TextStyle(fontWeight: FontWeight.w700)),
                  TextButton(onPressed: () => setState(() => _recent.clear()), child: const Text('Clear all')),
                ],
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: _recent.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (BuildContext context, int i) {
                    return ListTile(
                      dense: true,
                      title: Text(_recent[i]),
                      trailing: const Icon(Icons.north_east, size: 16, color: Color(0xFF9AA0A6)),
                      onTap: () {},
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

class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  int _brand = 0; // 0 All
  int _gender = 0; // 0 All
  int _sort = 1; // 1 Popular
  int _rating = 4; // 4 stars
  RangeValues _range = const RangeValues(10, 50);

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2E4DFF) : const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : const Color(0xFF121212), fontWeight: FontWeight.w600)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(40)))),
              const Text('Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              const Text('Brands', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
                _chip('All', _brand == 0, () => setState(() => _brand = 0)),
                _chip('Nike', _brand == 1, () => setState(() => _brand = 1)),
                _chip('Adidas', _brand == 2, () => setState(() => _brand = 2)),
                _chip('Puma', _brand == 3, () => setState(() => _brand = 3)),
              ]),
              const SizedBox(height: 12),
              const Text('Gender', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
                _chip('All', _gender == 0, () => setState(() => _gender = 0)),
                _chip('Men', _gender == 1, () => setState(() => _gender = 1)),
                _chip('Women', _gender == 2, () => setState(() => _gender = 2)),
              ]),
              const SizedBox(height: 12),
              const Text('Sort by', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
                _chip('Most Recent', _sort == 0, () => setState(() => _sort = 0)),
                _chip('Popular', _sort == 1, () => setState(() => _sort = 1)),
                _chip('Price High', _sort == 2, () => setState(() => _sort = 2)),
              ]),
              const SizedBox(height: 12),
              const Text('Rating', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: List<Widget>.generate(5, (int i) {
                final int star = i + 1;
                final bool selected = _rating == star;
                return _chip('$star★', selected, () => setState(() => _rating = star));
              })),
              const SizedBox(height: 12),
              const Text('Price Range', style: TextStyle(fontWeight: FontWeight.w700)),
              RangeSlider(
                values: _range,
                min: 10,
                max: 150,
                activeColor: const Color(0xFF2E4DFF),
                onChanged: (RangeValues v) => setState(() => _range = v),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() {
                        _brand = 0;
                        _gender = 0;
                        _sort = 1;
                        _rating = 4;
                        _range = const RangeValues(10, 50);
                      }),
                      child: const Text('Reset Filter'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E4DFF), foregroundColor: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


