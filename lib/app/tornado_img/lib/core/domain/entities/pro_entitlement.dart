import 'package:equatable/equatable.dart';
import 'package:tornado_img_app/core/domain/entities/pro_product.dart';
import 'package:tornado_img_app/core/utils/constants.dart';

/// The app-wide answer to "is this user Pro?".
///
/// Purchases are never validated against a server (the app is offline by design,
/// see `docs/tornado-pro-premium-plan.md`). Instead the store is the source of
/// truth and [lastVerified] records when it last confirmed the entitlement.
class ProEntitlement extends Equatable {
  /// The SKU that granted Pro, or null when the user is on the free tier.
  final ProPlan? plan;

  /// When the store last reported this purchase as active.
  final DateTime? lastVerified;

  const ProEntitlement._({this.plan, this.lastVerified});

  const ProEntitlement.free() : this._();

  ProEntitlement.active({required ProPlan plan, DateTime? at})
    : this._(plan: plan, lastVerified: at ?? DateTime.now());

  /// Pro holds only while the store has confirmed it inside the grace period.
  ///
  /// The store reports *active* purchases only, so a cancelled subscription (or
  /// a refunded lifetime) simply stops being confirmed — letting this clock run
  /// out is how we notice. Same rule for both SKUs, on purpose.
  bool isProAt(DateTime now) {
    final verified = lastVerified;
    if (plan == null || verified == null) return false;
    return now.difference(verified) <= Constants.proGracePeriod;
  }

  bool get isPro => isProAt(DateTime.now());

  @override
  List<Object?> get props => [plan, lastVerified];
}
