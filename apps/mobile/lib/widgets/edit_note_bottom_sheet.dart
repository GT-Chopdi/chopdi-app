import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/l10n/app_localizations.dart';
import 'package:mychopdi/utils/app_colors.dart';

class EditNoteBottomSheet extends StatefulWidget {
  const EditNoteBottomSheet({super.key});

  @override
  State<EditNoteBottomSheet> createState() =>
      _EditNoteBottomSheetState();
}

class _EditNoteBottomSheetState
    extends State<EditNoteBottomSheet> {
  final TextEditingController noteController =
  TextEditingController(
    text:
    "Customer requested payment extension until 30 July 2026",
  );

  final TextEditingController dateController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    // Default date.
    dateController.text =
        DateFormat('dd MMMM yyyy').format(
          DateTime(2026, 7, 24),
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

    final locale =
    Localizations.localeOf(context).toLanguageTag();

    // Update the displayed date according to
    // the currently selected app language.
    final localizedDate =
    DateFormat(
      'dd MMMM yyyy',
      locale,
    ).format(
      DateTime(2026, 7, 24),
    );

    if (dateController.text != localizedDate) {
      dateController.text = localizedDate;
    }

    return Container(
      height:
      MediaQuery.of(context).size.height * .82,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xffFFF8F1),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // ============================================================
          // HANDLE
          // ============================================================

          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius:
              BorderRadius.circular(20),
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
              Icons.edit_outlined,
              size: 28,
              color: ChopdiColors.navy,
            ),
          ),

          const SizedBox(height: 10),

          // ============================================================
          // TITLE
          // ============================================================

          Text(
            l10n.editNote,
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ChopdiColors.navy,
            ),
          ),

          const SizedBox(height: 30),

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

          const SizedBox(height: 8),

          // ============================================================
          // NOTE FIELD
          // ============================================================

          TextField(
            controller: noteController,
            maxLines: 5,
            maxLength: 100,
            decoration: InputDecoration(
              filled: true,
              fillColor:
              const Color(0xffFFF8F1),
              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(height: 16),

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

          const SizedBox(height: 8),

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
                borderRadius:
                BorderRadius.circular(8),
              ),
            ),
          ),

          const Spacer(),

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
                  style:
                  OutlinedButton.styleFrom(
                    minimumSize:
                    const Size.fromHeight(48),
                  ),
                  child: Text(
                    l10n.cancel,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    ChopdiColors.navy,
                    minimumSize:
                    const Size.fromHeight(48),
                  ),
                  onPressed: () {
                    Navigator.pop(context);

                    // Save Updated Note
                  },
                  child: Text(
                    l10n.saveNote,
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
    );
  }
}