import 'package:flutter/material.dart';
import '../models/address.dart';
import '../services/address_service.dart';

class AddAddressDialog extends StatefulWidget {
  final Function(Address) onAddressAdded;

  const AddAddressDialog({
    super.key,
    required this.onAddressAdded,
  });

  @override
  State<AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<AddAddressDialog> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final AddressService _addressService = AddressService();
  String _selectedType = 'home';
  bool _saving = false;
  bool _useProfilePhone = true;
  String? _profilePhone;

  final List<Map<String, dynamic>> _addressTypes = [
    {'value': 'home', 'label': 'Home', 'icon': Icons.home_outlined, 'color': Colors.green},
    {'value': 'work', 'label': 'Work', 'icon': Icons.work_outlined, 'color': Colors.blue},
    {'value': 'family', 'label': 'Family', 'icon': Icons.family_restroom_outlined, 'color': Colors.orange},
    {'value': 'other', 'label': 'Other', 'icon': Icons.location_on_outlined, 'color': Colors.grey},
  ];

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
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
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _loadProfilePhone();
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfilePhone() async {
    try {
      // Try to get phone from user profile
      // This is a placeholder - implement based on your auth service
      _profilePhone = '+91 98765 43210'; // Example phone
      if (_profilePhone != null) {
        _phoneController.text = _profilePhone!;
      }
    } catch (e) {
      // If no profile phone, allow manual input
      _useProfilePhone = false;
    }
  }

@override
Widget build(BuildContext context) {
  final maxHeight = MediaQuery.of(context).size.height * 0.8;

  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B8FAC).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.add_location_outlined,
                        color: Color(0xFF0B8FAC),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Add New Address',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Form(
              key: _formKey,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Address Type
                      const Text(
                        'Address Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Type Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: _addressTypes.length,
                        itemBuilder: (context, index) {
                          final type = _addressTypes[index];
                          final isSelected = _selectedType == type['value'];
                          return GestureDetector(
                            onTap: () => setState(() => _selectedType = type['value']!),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? type['color'].withOpacity(0.1)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? type['color'] : Colors.grey.shade200,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(type['icon'],
                                      color: isSelected ? type['color'] : Colors.grey.shade600,
                                      size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    type['label'],
                                    style: TextStyle(
                                      color: isSelected ? type['color'] : Colors.grey.shade700,
                                      fontWeight:
                                          isSelected ? FontWeight.w600 : FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Contact Title
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Contact Title',
                          hintText: 'e.g., Home, Office, Mom\'s House',
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.edit_outlined,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF0B8FAC),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a contact title';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Phone Number
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Phone Number',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const Spacer(),
                              if (_profilePhone != null)
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _useProfilePhone,
                                      onChanged: (value) {
                                        setState(() {
                                          _useProfilePhone = value ?? false;
                                          if (_useProfilePhone) {
                                            _phoneController.text = _profilePhone!;
                                          } else {
                                            _phoneController.clear();
                                          }
                                        });
                                      },
                                      activeColor: const Color(0xFF0B8FAC),
                                    ),
                                    Text(
                                      'Use profile phone',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneController,
                            enabled: !_useProfilePhone || _profilePhone == null,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              hintText: '+91 98765 43210',
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.phone_outlined,
                                  color: Colors.grey.shade600,
                                  size: 20,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0B8FAC),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: _useProfilePhone && _profilePhone != null
                                  ? Colors.grey.shade100
                                  : Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a phone number';
                              }
                              if (value.length < 10) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Address
                      TextFormField(
                        controller: _addressController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          hintText: 'Enter your complete address',
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.location_on_outlined,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF0B8FAC),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an address';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _saveAddress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B8FAC),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save Address',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
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
      ),
    ),
  );
}

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _saving = true);
    
    try {
      final address = Address(
        id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        latitude: 0.0, // Will be set by location service
        longitude: 0.0, // Will be set by location service
        phone: _phoneController.text.trim(),
        type: _selectedType,
        isDefault: false,
      );
      
             // Save address using service
       final savedAddress = await _addressService.saveAddress(address);
       
       if (mounted && savedAddress != null) {
        widget.onAddressAdded(savedAddress);
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Address saved successfully!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving address: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
