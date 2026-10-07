import 'package:flutter/material.dart';
import 'package:mychopdi/view/my_chopdi_screen.dart';
import 'package:mychopdi/widgets/bottom_nav_bar.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  final bool initialGaveLoanSelected;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
    this.initialGaveLoanSelected = true,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int selectedIndex;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    selectedIndex = widget.initialIndex;

    pages = [
      HomeScreen(
        initialGaveLoanSelected: widget.initialGaveLoanSelected,
      ),
      MyChopdiScreen(),
    ];
  }

  void _handleBack() {
    if (selectedIndex != 0) {
      // If user is on MyChopdi (tab 2),
      // back button should return to Home (tab 1).
      setState(() {
        selectedIndex = 0;
      });
    }
    // If already on Home, do nothing.
    // Android will handle the back action normally.
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        _handleBack();
      },
      child: Scaffold(
        body: pages[selectedIndex],

        bottomNavigationBar: BottomNavbar(
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}