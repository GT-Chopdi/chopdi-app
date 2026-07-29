import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/widgets/add_note_bottom_sheet.dart';
import 'package:mychopdi/widgets/record_payment_sheet.dart';

class AddEntryBottomSheet extends StatelessWidget {
  const AddEntryBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
      decoration: const BoxDecoration(
        color: Color(0xffFFF8F1),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          /// Handle
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Add Entry",
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 15),

          _buildTile(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: "Record Payment",
            subtitle: "Add money given or received",
            onTap: () {
              Navigator.pop(context);

              // Open Record Payment Bottom Sheet
              Future.delayed(
                const Duration(milliseconds: 200),
                () {
                  showRecordPaymentBottomSheet(context);
                },
              );
            },
          ),

          const SizedBox(height: 10),

          _buildTile(
            context,
            icon: Icons.edit_calendar_outlined,
            title: "Add Note",
            subtitle: "Add a note or reminder",
            onTap: () {
              Navigator.pop(context);

              Future.delayed(
                const Duration(milliseconds: 200),
                () {
                  showAddNoteBottomSheet(context);
                },
              );
            },
          ),

          const SizedBox(height: 16),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.roboto(
                color: ChopdiColors.navy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 248, 240, 1),
          border: Border.all(
            color: const Color(0xffC9D2E3),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [

            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xffDCE5F8),
              child: Icon(
                icon,
                color: ChopdiColors.navy,
                size: 18,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w700,
                      color: ChopdiColors.navy,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: ChopdiColors.navy,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  void showAddNoteBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddNoteBottomSheet(),
    );
  }

  void showRecordPaymentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RecordPaymentBottomSheet(),
    );
  }
}