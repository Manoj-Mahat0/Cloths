class Order {
  final int id;
  final int productId;
  final int quantity;
  final String status;
  final int? warehouseId;
  final int? deliveryBoyId;
  final String? remark;
  final int totalPriceCents;
  final bool paid;

  Order({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.status,
    this.warehouseId,
    this.deliveryBoyId,
    this.remark,
    required this.totalPriceCents,
    required this.paid,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as int,
        productId: json['product_id'] as int,
        quantity: json['quantity'] as int,
        status: json['status'] as String,
        warehouseId: json['warehouse_id'] as int?,
        deliveryBoyId: json['delivery_boy_id'] as int?,
        remark: json['remark'] as String?,
        totalPriceCents: json['total_price_cents'] as int,
        paid: json['paid'] as bool,
      );
}
