import 'package:flutter/foundation.dart';

@immutable
class BillingProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currencyCode;
  final String formattedPrice;

  const BillingProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currencyCode,
    required this.formattedPrice,
  });
}
