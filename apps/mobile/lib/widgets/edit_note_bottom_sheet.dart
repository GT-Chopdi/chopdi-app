import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/utils/app_colors.dart';

class EditNoteBottomSheet extends StatefulWidget {
  const EditNoteBottomSheet({super.key});

  @override
  State<EditNoteBottomSheet> createState() => _EditNoteBottomSheetState();
}

class _EditNoteBottomSheetState extends State<EditNoteBottomSheet> {
  final TextEditingController noteController =
      TextEditingController(
    text: "Customer requested payment extension until 30 July 2026",
  );

  final TextEditingController dateController =
      TextEditingController(
    text: "24 July 2026",
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .82,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xffFFF8F1),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: Column(
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
              Icons.edit_outlined,
              size: 28,
              color: ChopdiColors.navy,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "Edit Note",
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ChopdiColors.navy,
            ),
          ),

          const SizedBox(height: 30),

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

          const SizedBox(height: 8),

          TextField(
            controller: noteController,
            maxLines: 5,
            maxLength: 100,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xffFFF8F1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(height: 16),

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

          const SizedBox(height: 8),

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

          const Spacer(),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text("Cancel"),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ChopdiColors.navy,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () {
                    Navigator.pop(context);

                    // Save Updated Note
                  },
                  child: const Text(
                    "Save Note",
                    style: TextStyle(color: Colors.white),
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