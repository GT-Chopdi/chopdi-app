import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/widgets/chopdi_bottom_sheet.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "My Chopdi",
                  style: GoogleFonts.manrope(
                    color: ChopdiColors.navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),

                IconButton(
                  icon: Image.asset('assets/tabler_edit.png'),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      barrierColor: Colors.black54,
                      isScrollControlled: false,
                      useSafeArea: true,
                      builder: (context) {
                        return const Wrap(
                          children: [
                            ChopdiBottomSheet(),
                          ],
                        );
                      },
                    );
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
            )
          ],
        ),

        const Spacer(),
        const Icon(Icons.notifications_none,size:28)
      ],
    );
  }
}