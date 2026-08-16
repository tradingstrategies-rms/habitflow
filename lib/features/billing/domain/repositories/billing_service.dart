import '../entities/billing_product.dart';
import '../entities/purchase_result.dart';

abstract class BillingService {
  Future<List<BillingProduct>> getProducts();
  Future<PurchaseResult> purchase(String productId);
  Future<PurchaseResult> restorePurchases();
}
