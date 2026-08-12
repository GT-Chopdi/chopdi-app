import 'package:flutter/material.dart';

Future<bool?> showDeleteTransactionBottomSheet(
  BuildContext context, {
  required VoidCallback onDelete,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (context) {
      return DeleteTransactionBottomSheet(
        onDelete: onDelete,
      );
    },
  );
}

class DeleteTransactionBottomSheet extends StatefulWidget {
  final VoidCallback onDelete;

  const DeleteTransactionBottomSheet({super.key, 
    required this.onDelete,
  });

  @override
  State<DeleteTransactionBottomSheet> createState() => _DeleteTransactionBottomSheetState();
}

class _DeleteTransactionBottomSheetState extends State<DeleteTransactionBottomSheet> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Container(
        width: size.width,
        height: 255,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF9F2),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Drag handle
            Container(
              width: 45,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF777777),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 20),

            // Delete icon
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFF9D9D7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Color(0xFFD14D4D),
                size: 26,
              ),
            ),

            const SizedBox(height: 7),

            // Title
            const Text(
              'Delete Transaction?',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD14D4D),
              ),
            ),

            const SizedBox(height: 2),

            // Subtitle
            const Text(
              'This action cannot be undone',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFF263A5A),
              ),
            ),

            const SizedBox(height: 20),

            // Checkbox container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 37,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9F2),
                  border: Border.all(
                    color: const Color(0xFFF3D6D0),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 5),

                    // Checkbox
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: Checkbox(
                        value: isChecked,
                        onChanged: (value) {
                          setState(() {
                            isChecked = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFFD14D4D),
                        checkColor: Colors.white,
                        side: const BorderSide(
                          color: Color(0xFFB9C3CF),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),

                    const SizedBox(width: 0),

                    const Expanded(
                      child: Text(
                        'I understand this action cannot be undone.',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF263A5A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Cancel
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFD14D4D),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF263A5A),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 13),

                  // Delete
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: isChecked
                            ? () {
                                widget.onDelete();
                                Navigator.pop(context, true);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD14D4D),
                          disabledBackgroundColor:
                              const Color(0xFFD14D4D),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}