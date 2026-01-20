import 'package:flutter_riverpod/flutter_riverpod.dart';

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>(
  (ref) => SubscriptionNotifier(),
);

class SubscriptionState {
  final bool isExpired;

  SubscriptionState({required this.isExpired});
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier() : super(SubscriptionState(isExpired: false));

  void updateSubscription(String? newExpireDate) {
    state = newExpireDate != null
        ? SubscriptionState(
            isExpired: DateTime.now().isAfter(DateTime.parse(newExpireDate).add(const Duration(days: 1))),
          )
        : SubscriptionState(isExpired: true);
  }
}
