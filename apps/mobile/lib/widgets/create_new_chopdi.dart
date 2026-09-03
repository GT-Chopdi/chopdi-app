import 'package:flutter/material.dart';
import 'package:mychopdi/service/chopdi_service.dart';
import 'package:mychopdi/utils/app_colors.dart';

class CreateChopdiBottomSheet extends StatefulWidget {
  final BuildContext parentContext;

  const CreateChopdiBottomSheet({
    super.key,
    required this.parentContext,
  });

  @override
  State<CreateChopdiBottomSheet> createState() =>
      _CreateChopdiBottomSheetState();
}

class _CreateChopdiBottomSheetState
    extends State<CreateChopdiBottomSheet> {
  final TextEditingController nameController =
      TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _createChopdi() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Chopdi name"),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final chopdi =
          await ChopdiService.createChopdi(name);

      if (!mounted) return;

      // Return the newly created Chopdi
      Navigator.pop(context, chopdi);
    } catch (e) {
      debugPrint(
        "CREATE CHOPDI ERROR: $e",
      );

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to create Chopdi: $e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight =
        MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: keyboardHeight,
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          // No margin.
          // This makes the sheet full width like
          // the Khatabook-style bottom sheet.
          margin: EdgeInsets.zero,

          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20,
          ),

          decoration: const BoxDecoration(
            color: AppColors.card,

            // Only top corners are rounded.
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),

          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 28),

                // Input field
                TextField(
                  controller: nameController,

                  textCapitalization:
                      TextCapitalization.words,

                  decoration: InputDecoration(
                    hintText:
                        "Enter Shop/Business name",

                    hintStyle: const TextStyle(
                      color: Color(0xff7B869C),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),

                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),

                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),

                      borderSide:
                          const BorderSide(
                        color: Color(0xffB9C9E8),
                      ),
                    ),

                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),

                      borderSide:
                          const BorderSide(
                        color: Color(0xff243B67),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                // Original spacing when keyboard
                // is closed.
                //
                // Reduce it when keyboard is open
                // so the sheet fits above keyboard.
                SizedBox(
                  height:
                      keyboardHeight > 0
                          ? 40
                          : 120,
                ),

                // Create button
                SizedBox(
                  width: double.infinity,
                  height: 58,

                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xff243B67),

                      elevation: 0,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),

                    onPressed:
                        isSaving
                            ? null
                            : _createChopdi,

                    child: isSaving
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Create",

                            style: TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}