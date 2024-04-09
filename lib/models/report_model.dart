class Report {
  final String buyerId;
  final String sellerId;
  final String reason;
  final String shopName;

  Report({
    required this.buyerId,
    required this.sellerId,
    required this.reason,
    required this.shopName,
  });

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'sellerId': sellerId,
      'reason': reason,
      'shopName': shopName
    };
  }
}
