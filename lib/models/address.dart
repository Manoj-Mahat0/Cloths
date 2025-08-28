class Address {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String type; // home, work, family, other
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.type,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      phone: json['phone'] ?? '',
      type: json['type'] ?? 'other',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'type': type,
      'isDefault': isDefault,
    };
  }

  Address copyWith({
    int? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? type,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
