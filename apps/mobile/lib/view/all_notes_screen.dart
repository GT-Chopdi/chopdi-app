import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/widgets/add_note_bottom_sheet.dart';
import 'package:mychopdi/widgets/edit_note_bottom_sheet.dart';

class AllNotesBottomSheet extends StatelessWidget {
  const AllNotesBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * .88,
          decoration: const BoxDecoration(
            color: Color(0xffFFF8F1),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 20),

              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xffDCE5F8),
                child: Icon(
                  Icons.description_outlined,
                  color: Color(0xff24365D),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "All Notes",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff24365D),
                  fontSize: 18,
                ),
              ),

              const Text(
                "5 Notes",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    90, // leave space for FAB
                  ),
                  itemCount: 5,
                  itemBuilder: (_, index) {
                    bool important = index == 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: important
                            ? const Color(0xffFFF7F5)
                            : Color.fromRGBO(255, 248, 240, 1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: important
                              ? Colors.red
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: important
                                ? const Color(0xffFFE5E1)
                                : const Color(0xffDCE5F8),
                            child: Icon(
                              important
                                  ? Icons.push_pin
                                  : Icons.description,
                              size: 14,
                              color: important
                                  ? Colors.red
                                  : const Color(0xff24365D),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                if (important)
                                  const Text(
                                    "Important Note",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                const SizedBox(height: 2),

                                const Text(
                                  "Customer requested payment extension until 30 July 2026",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff24365D),
                                  ),
                                ),

                                const SizedBox(height: 5),

                                const Text(
                                  "24 July 2026",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // PopupMenuButton(
                          //   itemBuilder: (_) => const [
                          //     PopupMenuItem(
                          //       value: 1,
                          //       child: Text("Edit"),
                          //     ),
                          //     PopupMenuItem(
                          //       value: 2,
                          //       child: Text("Delete"),
                          //     ),
                          //   ],
                          // ),

                          PopupMenuButton<String>(
                            color: Color.fromRGBO(255, 248, 240, 1),
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            icon: const Icon(
                              Icons.more_vert,
                              color: Color(0xff24365D),
                              size: 20,
                            ),
                            offset: const Offset(-10, 35),
                            onSelected: (value) {
                              // switch (value) {
                              //   case "edit":
                              //     // Edit Note
                              //     break;

                              //   case "important":
                              //     // Mark as Important
                              //     break;

                              //   case "delete":
                              //     // Delete Note
                              //     break;
                              // }
                              if (value == "edit") {
                                Future.delayed(const Duration(milliseconds: 150), () {
                                  showEditNoteBottomSheet(context);
                                });
                              }

                              if (value == "important") {
                                // Mark Important
                              }

                              if (value == "delete") {
                                // Delete Note
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: "edit",
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: Color(0xff24365D),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Edit Note",
                                      style: GoogleFonts.roboto(
                                        fontSize: 13,
                                        color: const Color(0xff24365D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const PopupMenuDivider(height: 1),

                              PopupMenuItem(
                                value: "important",
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_border,
                                      size: 18,
                                      color: Color(0xff24365D),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Mark as important",
                                      style: GoogleFonts.roboto(
                                        fontSize: 13,
                                        color: const Color(0xff24365D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const PopupMenuDivider(height: 1),

                              PopupMenuItem(
                                value: "delete",
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Delete Note",
                                      style: GoogleFonts.roboto(
                                        fontSize: 13,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        /// Floating Button
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton.extended(
            heroTag: "addNote",
            backgroundColor: ChopdiColors.navy,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            onPressed: () {
              // Open Add Note Bottom Sheet
              showAddNoteBottomSheet(context);
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
              size: 18,
            ),
            label: Text(
              "Add Note",
              style: GoogleFonts.roboto(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ChopdiColors.cream,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showEditNoteBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EditNoteBottomSheet(),
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
} 