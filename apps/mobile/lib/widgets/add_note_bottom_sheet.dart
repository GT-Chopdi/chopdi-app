import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/utils/app_colors.dart';

class AddNoteBottomSheet extends StatefulWidget {
  const AddNoteBottomSheet({super.key});

  @override
  State<AddNoteBottomSheet> createState() => _AddNoteBottomSheetState();
}

class _AddNoteBottomSheetState extends State<AddNoteBottomSheet> {

  final TextEditingController noteController = TextEditingController();
  final TextEditingController dateController =
      TextEditingController(text: "24 July 2026");

  bool isImportant = false;

  @override
  Widget build(BuildContext context) {
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

            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 18),

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

            Text(
              "Add Note",
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ChopdiColors.navy,
              ),
            ),

            Text(
              "Add a note or reminder",
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Note",
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 6),

            TextField(
              controller: noteController,
              maxLength: 100,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Write your note here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Date",
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 6),

            TextField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          "Mark as Important",
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w600,
                            color: ChopdiColors.navy,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          "Show this note on the customer page.",
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
                  )
                ],
              ),
            ),

            const SizedBox(height: 28),

            Row(
              children: [

                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
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
                    child: const Text(
                      "Save Entry",
                      style: TextStyle(color: Colors.white),
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