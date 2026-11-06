import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marky/features/quick_actions/data/quick_action_controller.dart';

final Provider<QuickActionController> quickActionControllerProvider =
    Provider<QuickActionController>((Ref ref) {
  return QuickActionController();
});
