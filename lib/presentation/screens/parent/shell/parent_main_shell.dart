import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/bottom_nav_bar.dart';
import '../children/children_list_screen.dart';
import '../home/parent_home_screen.dart';
import '../payments/payments_screen.dart';
import '../profile/parent_profile_screen.dart';

/// Ota-ona ilovasida ochiq tab indeksi.
final StateProvider<int> parentTabProvider = StateProvider<int>((ref) => 0);

/// Ota-ona ilovasining asosiy ekrani: 4 ta tabli bottom navigation.
class ParentMainShell extends ConsumerWidget {
  const ParentMainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int index = ref.watch(parentTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const <Widget>[
          ParentHomeScreen(),
          ChildrenListScreen(),
          PaymentsScreen(),
          ParentProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        items: ParentTab.values.map((ParentTab t) => t.item).toList(),
        currentIndex: index,
        onTap: (int i) => ref.read(parentTabProvider.notifier).state = i,
      ),
    );
  }
}
