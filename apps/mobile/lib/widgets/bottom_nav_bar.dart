import 'package:flutter/material.dart';
import 'package:mychopdi/l10n/app_localizations.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // @override
  // Widget build(BuildContext context) {
  //   return BottomNavigationBar(
  //     currentIndex: currentIndex,
  //     onTap: onTap,
  //     selectedItemColor: const Color(0xff243B67),
  //     unselectedItemColor: Colors.grey,
  //     type: BottomNavigationBarType.fixed,
  //     backgroundColor: const Color.fromRGBO(255, 248, 240, 1),

  //     items: const [
  //       BottomNavigationBarItem(
  //         icon: ImageIcon(
  //           AssetImage('assets/home_bottom_bar.png'),
  //           size: 24,
  //         ),
  //         activeIcon: ImageIcon(
  //           AssetImage('assets/home_fill_bottom_bar.png'),
  //           size: 24,
  //         ),
  //         label: "Home",
  //       ),

  //       BottomNavigationBarItem(
  //         icon: ImageIcon(
  //           AssetImage('assets/fluent_document_bottom_bar.png'),
  //           size: 24,
  //         ),
  //         activeIcon: ImageIcon(
  //           AssetImage('assets/fluent_document_bottom_bar_fill.png'),
  //           size: 24,
  //         ),
  //         label: "My Chopdi",
  //       ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: const Color(0xff243B67),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color.fromRGBO(255, 248, 240, 1),

      items: [
        BottomNavigationBarItem(
          icon: const ImageIcon(
            AssetImage('assets/home_bottom_bar.png'),
            size: 24,
          ),
          activeIcon: const ImageIcon(
            AssetImage('assets/home_fill_bottom_bar.png'),
            size: 24,
          ),
          label: l10n.bottomHome,
        ),

        BottomNavigationBarItem(
          icon: const ImageIcon(
            AssetImage('assets/fluent_document_bottom_bar.png'),
            size: 24,
          ),
          activeIcon: const ImageIcon(
            AssetImage('assets/fluent_document_bottom_bar_fill.png'),
            size: 24,
          ),
          label: l10n.bottomMyChopdi,
        ),
      ],
    );
  }
}