import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/model/chopdi.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/view/notifications_screen.dart';
import 'package:mychopdi/widgets/chopdi_bottom_sheet.dart';

class HomeHeader extends StatelessWidget {
  final Chopdi? currentChopdi;
  final ValueChanged<Chopdi>? onChopdiChanged;

  const HomeHeader({
    super.key,
    this.currentChopdi,
    this.onChopdiChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  currentChopdi?.name ?? "My Chopdi",
                  style: GoogleFonts.manrope(
                    color: ChopdiColors.navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),

                IconButton(
                  icon: Image.asset(
                    'assets/tabler_edit.png',
                  ),
                  onPressed: () async {
                    final selectedChopdi =
                        await showModalBottomSheet<Chopdi>(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => const ChopdiBottomSheet(),
                    );

                    if (selectedChopdi != null) {
                      onChopdiChanged?.call(selectedChopdi);
                    }
                  },
                ),
              ],
            ),

            Text(
              "Tap to change chopdi",
              style: GoogleFonts.manrope(
                color: ChopdiColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const Spacer(),

        GestureDetector(
          child: Image.asset(
            'assets/notifications.png',
            height: 25,
            width: 25,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const NotificationsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}