import 'package:flutter/material.dart';
import '../models/address.dart';
import '../services/address_service.dart';
import 'add_address_dialog.dart';

class AddressSelectionDialog extends StatefulWidget {
  final List<Address> savedAddresses;
  final Function(Address) onAddressSelected;

  const AddressSelectionDialog({
    super.key,
    required this.savedAddresses,
    required this.onAddressSelected,
  });

  @override
  State<AddressSelectionDialog> createState() => _AddressSelectionDialogState();
}

class _AddressSelectionDialogState extends State<AddressSelectionDialog> with TickerProviderStateMixin {
  final AddressService _addressService = AddressService();
  bool _loading = false;
  String? _currentAddress;
  
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
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B8FAC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF0B8FAC),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                  'Select Delivery Address',
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
            const SizedBox(height: 24),
            
            // Current Location Option
            if (_currentAddress != null) ...[
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildAddressCard(
                Address(
                  id: -1,
                  name: 'Current Location',
                  address: _currentAddress!,
                  latitude: 0,
                  longitude: 0,
                  phone: '',
                  type: 'current',
                ),
                    true,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Get Current Location Button
            if (_currentAddress == null)
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B8FAC).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF0B8FAC).withOpacity(0.3),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _loading ? null : _getCurrentLocation,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _loading 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF0B8FAC),
                                    ),
                                  )
                                : const Icon(
                                    Icons.my_location,
                                    color: Color(0xFF0B8FAC),
                                    size: 20,
                                  ),
                              const SizedBox(width: 12),
                              Text(
                                _loading ? 'Getting Location...' : 'Use Current Location',
                                style: const TextStyle(
                                  color: Color(0xFF0B8FAC),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            
            if (_currentAddress == null && widget.savedAddresses.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            
            // Saved Addresses
            if (widget.savedAddresses.isNotEmpty) ...[
              Row(
                children: [
                  Text(
                'Saved Addresses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _showAddAddressDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add New'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0B8FAC),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            
              // Address List
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.savedAddresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final address = widget.savedAddresses[index];
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildAddressCard(address, false),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              // No saved addresses
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_off_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No saved addresses',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first address to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showAddAddressDialog,
                          icon: const Icon(Icons.add_location_outlined),
                          label: const Text('Add Address'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B8FAC),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                ),
              ),
            ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(Address address, bool isCurrentLocation) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.onAddressSelected(address);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Address Icon
                Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
                    color: isCurrentLocation 
                        ? Colors.blue.shade50 
                        : const Color(0xFF0B8FAC).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
                  child: Icon(
                    isCurrentLocation ? Icons.my_location : Icons.location_on_outlined,
                    color: isCurrentLocation 
                        ? Colors.blue.shade600 
                        : const Color(0xFF0B8FAC),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Address Details
                Expanded(
                  child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                      Row(
                        children: [
                          Text(
                            address.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          if (address.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B8FAC).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Default',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF0B8FAC),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
            const SizedBox(height: 4),
            Text(
              address.address,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
            ),
            if (address.phone.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 6),
              Text(
                address.phone,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          ],
              ),
            ],
          ],
        ),
                ),
                
                // Selection Indicator
                Container(
                  padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _loading = true);
    
    try {
      // Simulate getting current location
      await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() {
          _currentAddress = 'Current Location (GPS)';
            _loading = false;
          });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showAddAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AddAddressDialog(
        onAddressAdded: (address) {
          // Refresh the dialog to show the new address
          setState(() {});
        },
      ),
    );
  }
}
