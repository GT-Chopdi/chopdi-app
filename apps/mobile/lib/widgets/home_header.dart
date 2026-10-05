import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/chopdi.dart';
import 'package:mychopdi/model/notification.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/widgets/chopdi_bottom_sheet.dart';
import 'package:mychopdi/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);

    final chopdiName =
        currentChopdi?.name ??
    AppLocalizations.of(context).homeMyChopdi;
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  chopdiName,
                  style: GoogleFonts.manrope(
                    color: ChopdiColors.navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),

                IconButton(
                  icon: Image.asset(
                    'assets/add_chopdi_icon.png',
                    height: 26,
                    width: 26,
                  ),
                  onPressed: () async {
                    final selectedChopdi =
                        await showModalBottomSheet<Chopdi>(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) =>
                          const ChopdiBottomSheet(),
                    );

                    if (selectedChopdi != null) {
                      onChopdiChanged?.call(
                        selectedChopdi,
                      );
                    }
                  },
                ),
              ],
            ),

            Text(
    AppLocalizations.of(context).homeTapToChangeChopdi,
              style: GoogleFonts.manrope(
                color: ChopdiColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const Spacer(),


      ],
    );
  }
}