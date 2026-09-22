import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/l10n/app_localizations.dart';
import 'package:mychopdi/utils/app_colors.dart';

class AddNoteBottomSheet extends StatefulWidget {
  const AddNoteBottomSheet({super.key});

  @override
  State<AddNoteBottomSheet> createState() => _AddNoteBottomSheetState();
}

class _AddNoteBottomSheetState extends State<AddNoteBottomSheet> {
  final TextEditingController noteController =
  TextEditingController();

  late final TextEditingController dateController;

  bool isImportant = false;

  @override
  void initState() {
    super.initState();

    dateController = TextEditingController(
      text: DateFormat(
        'd MMMM yyyy',
        'en',
      ).format(DateTime.now()),
    );
  }

  @override
  void dispose() {
    noteController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Update date according to current app locale.
    final locale = Localizations.localeOf(context).toLanguageTag();

    final currentDate = DateFormat(
      'd MMMM yyyy',
      locale,
    ).format(DateTime.now());

    if (dateController.text != currentDate) {
      dateController.text = currentDate;
    }

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Color(0xffFFF8F1),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ============================================================
            // HANDLE
            // ============================================================

            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 18),

            // ============================================================
            // ICON
            // ============================================================

            const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xffDCE5F8),
              child: Icon(
                Icons.edit_calendar_outlined,
                size: 30,
                color: ChopdiColors.navy,
              ),
            ),

            const SizedBox(height: 10),

            // ============================================================
            // TITLE
            // ============================================================

            Text(
              l10n.addNote,
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ChopdiColors.navy,
              ),
            ),

            // ============================================================
            // SUBTITLE
            // ============================================================

            Text(
              l10n.addNoteOrReminder,
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            // ============================================================
            // NOTE LABEL
            // ============================================================

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.note,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // ============================================================
            // NOTE FIELD
            // ============================================================

            TextField(
              controller: noteController,
              maxLength: 100,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: l10n.writeYourNoteHere,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ============================================================
            // DATE LABEL
            // ============================================================

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.date,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // ============================================================
            // DATE FIELD
            // ============================================================

            TextField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                suffixIcon: const Icon(
                  Icons.calendar_today_outlined,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ============================================================
            // IMPORTANT SWITCH
            // ============================================================

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.markAsImportant,
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w600,
                            color: ChopdiColors.navy,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          l10n.showNoteOnCustomerPage,
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Switch(
                    value: isImportant,
                    activeThumbColor: ChopdiColors.navy,
                    onChanged: (value) {
                      setState(() {
                        isImportant = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ============================================================
            // BUTTONS
            // ============================================================

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      l10n.cancel,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ChopdiColors.navy,
                    ),
                    onPressed: () {
                      Navigator.pop(context);

                      // Save Note
                    },
                    child: Text(
                      l10n.saveEntry,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}