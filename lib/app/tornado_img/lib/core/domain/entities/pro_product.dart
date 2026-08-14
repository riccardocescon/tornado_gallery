import 'package:equatable/equatable.dart';

/// Which SKU an entitlement came from. Both unlock exactly the same features —
/// nothing outside the paywall and the "manage subscription" row cares which.
enum ProPlan {
  monthly,
  lifetime;

  bool get isSubscription => this == ProPlan.monthly;
}

/// A Pro SKU as the store describes it.
class ProProduct extends Equatable {
  final String id;
  final String title;
  final String description;

  /// Store-formatted, localised and currency-correct (e.g. `1,99 €`).
  /// Never build this ourselves — the store decides what the user pays.
  final String price;

  final ProPlan plan;

  const ProProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.plan,
  });

  @override
  List<Object?> get props => [id, title, description, price, plan];
}
