enum SubscriptionTier {
  free,
  premium,
  unlimited;

  int get dailyLimit {
    switch (this) {
      case SubscriptionTier.free:
        return 2;
      case SubscriptionTier.premium:
        return 5;
      case SubscriptionTier.unlimited:
        return 999;
    }
  }

  int get maxFavorites {
    switch (this) {
      case SubscriptionTier.free:
        return 5;
      case SubscriptionTier.premium:
        return 50;
      case SubscriptionTier.unlimited:
        return 999;
    }
  }

  int get maxSaves {
    switch (this) {
      case SubscriptionTier.free:
        return 10;
      case SubscriptionTier.premium:
        return 100;
      case SubscriptionTier.unlimited:
        return 999;
    }
  }

  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.premium:
        return 'Premium';
      case SubscriptionTier.unlimited:
        return 'Unlimited';
    }
  }

  double get price {
    switch (this) {
      case SubscriptionTier.free:
        return 0.0;
      case SubscriptionTier.premium:
        return 9.99;
      case SubscriptionTier.unlimited:
        return 19.99;
    }
  }

  static SubscriptionTier fromString(String value) {
    return SubscriptionTier.values.firstWhere(
      (tier) => tier.name == value,
      orElse: () => SubscriptionTier.free,
    );
  }
}
