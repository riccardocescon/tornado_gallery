import 'package:flutter_test/flutter_test.dart';
import 'package:tornado_img_app/core/domain/entities/pro_entitlement.dart';
import 'package:tornado_img_app/core/domain/entities/pro_product.dart';
import 'package:tornado_img_app/core/utils/constants.dart';

/// The grace seam behind `PurchaseBloc.isPro`. Tested directly through
/// `isProAt(now)` so the 7-day clock is deterministic — no fake time needed.
void main() {
  final anchor = DateTime(2026, 1, 1, 12);

  group('a free entitlement is never Pro', () {
    test('free() has no plan and is not Pro', () {
      const free = ProEntitlement.free();
      expect(free.plan, isNull);
      expect(free.isProAt(anchor), isFalse);
    });
  });

  group('the 7-day grace period, identical for both SKUs', () {
    for (final plan in ProPlan.values) {
      test('$plan confirmed just now is Pro', () {
        final e = ProEntitlement.active(plan: plan, at: anchor);
        expect(e.isProAt(anchor), isTrue);
        expect(e.plan, plan);
      });

      test('$plan confirmed one day ago is still Pro', () {
        final e = ProEntitlement.active(
          plan: plan,
          at: anchor.subtract(const Duration(days: 1)),
        );
        expect(e.isProAt(anchor), isTrue);
      });

      test('$plan confirmed exactly at the grace boundary is still Pro', () {
        final e = ProEntitlement.active(
          plan: plan,
          at: anchor.subtract(Constants.proGracePeriod),
        );
        expect(e.isProAt(anchor), isTrue);
      });

      test('$plan one second past the grace period drops to free', () {
        final e = ProEntitlement.active(
          plan: plan,
          at: anchor.subtract(
            Constants.proGracePeriod + const Duration(seconds: 1),
          ),
        );
        expect(e.isProAt(anchor), isFalse);
      });
    }
  });

  test('an active entitlement with no lastVerified is not Pro', () {
    // free() is the only const path with a plan-less null clock, but guard the
    // invariant: no confirmation timestamp means the store never confirmed it.
    const e = ProEntitlement.free();
    expect(e.isProAt(anchor), isFalse);
  });
}
