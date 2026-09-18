import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/bottom_nav_bar.dart';
import '../arena/arena_screen.dart';
import '../grades/grades_screen.dart';
import '../home/home_screen.dart';
import '../homework/homework_list_screen.dart';
import '../profile/profile_screen.dart';
import '../schedule/schedule_screen.dart';

/// Ochiq turgan tab indeksi. Boshqa ekranlar ham tabni almashtira oladi
/// (masalan Home'dagi "Barchasini ko'rish" tugmasi).
final StateProvider<int> shellTabProvider = StateProvider<int>((ref) => 0);

/// Bottom navigation'li asosiy ekran.
/// IndexedStack tablar holatini (scroll pozitsiyasi va h.k.) saqlab qoladi.
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int index = ref.watch(shellTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const <Widget>[
          HomeScreen(),
          ScheduleScreen(),
          HomeworkListScreen(),
          ArenaScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        items: AppTab.values.map((AppTab t) => t.item).toList(),
        currentIndex: index,
        onTap: (int i) => ref.read(shellTabProvider.notifier).state = i,
      ),
    );
  }
}

/// Baholar ekrani tabda emas — Home va Profil orqali ochiladi.
Route<void> gradesRoute() => MaterialPageRoute<void>(
      builder: (_) => const GradesScreen(),
    );
