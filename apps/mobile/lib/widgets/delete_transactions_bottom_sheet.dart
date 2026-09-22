import 'package:flutter/material.dart';
import 'package:mychopdi/l10n/app_localizations.dart';

Future<bool?> showDeleteTransactionBottomSheet(
    BuildContext context, {
      required String title,
      required String subtitle,
      required Future<void> Function() onDelete,
    }) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    enableDrag: true,
    builder: (context) {
      return DeleteBottomSheet(
        title: title,
        subtitle: subtitle,
        onDelete: onDelete,
      );
    },
  );
}

class DeleteBottomSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final Future<void> Function() onDelete;

  const DeleteBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onDelete,
  });

  @override
  State<DeleteBottomSheet> createState() =>
      _DeleteBottomSheetState();
}

class _DeleteBottomSheetState
    extends State<DeleteBottomSheet> {
  bool agree = false;
  bool loading = false;

  Future<void> _deleteTransaction() async {
    if (!agree || loading) return;

    setState(() {
      loading = true;
    });

    try {
      await widget.onDelete();

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      final l10n = AppLocalizations.of(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.failedToDeleteTransaction}: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Container(
        // Screenshot has approximately 10px margin
        // from both left and right.
        margin: const EdgeInsets.fromLTRB(
          10,
          0,
          10,
          8,
        ),

        height: 274,

        decoration: BoxDecoration(
          color: const Color(0xFFFFF9F2),

          // Screenshot has rounded corners on all sides.
          borderRadius: BorderRadius.circular(25),
        ),

        child: Column(
          children: [
            // =========================================================
            // DRAG HANDLE
            // =========================================================

            const SizedBox(height: 10),

            Container(
              width: 49,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF777777),
                borderRadius:
                BorderRadius.circular(10),
              ),
            ),

            // =========================================================
            // DELETE ICON
            // =========================================================

            const SizedBox(height: 21),

            Container(
              width: 53,
              height: 53,
              decoration: const BoxDecoration(
                color: Color(0xFFF9D9D7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Color(0xFFD14D4D),
                size: 27,
              ),
            ),

            // =========================================================
            // TITLE
            // =========================================================

            const SizedBox(height: 6),

            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD14D4D),
              ),
            ),

            // =========================================================
            // SUBTITLE
            // =========================================================

            const SizedBox(height: 1),

            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF263A5A),
              ),
            ),

            // =========================================================
            // CHECKBOX
            // =========================================================

            const SizedBox(height: 21),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: InkWell(
                borderRadius:
                BorderRadius.circular(7),
                onTap: loading
                    ? null
                    : () {
                  setState(() {
                    agree = !agree;
                  });
                },
                child: Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9F2),
                    border: Border.all(
                      color: const Color(0xFFF3D6D0),
                      width: 1,
                    ),
                    borderRadius:
                    BorderRadius.circular(7),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 5),

                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Checkbox(
                          value: agree,
                          onChanged: loading
                              ? null
                              : (value) {
                            setState(() {
                              agree =
                                  value ?? false;
                            });
                          },
                          activeColor:
                          const Color(0xFFD14D4D),
                          checkColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0xFFB9C3CF),
                            width: 1.2,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(3),
                          ),
                          materialTapTargetSize:
                          MaterialTapTargetSize
                              .shrinkWrap,
                        ),
                      ),

                      const SizedBox(width: 0),

                      Expanded(
                        child: Text(
                          l10n.deleteConfirmation,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF263A5A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // =========================================================
            // BUTTONS
            // =========================================================

            const SizedBox(height: 21),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: Row(
                children: [
                  // ---------------------------------------------------
                  // CANCEL
                  // ---------------------------------------------------

                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: OutlinedButton(
                        onPressed: loading
                            ? null
                            : () {
                          Navigator.pop(
                            context,
                            false,
                          );
                        },
                        style:
                        OutlinedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFFFFF9F2),
                          side: const BorderSide(
                            color: Color(0xFFD14D4D),
                            width: 1,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(7),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight:
                            FontWeight.w500,
                            color: Color(0xFF263A5A),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // ---------------------------------------------------
                  // DELETE
                  // ---------------------------------------------------

                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: ElevatedButton(
                        onPressed:
                        (!agree || loading)
                            ? null
                            : _deleteTransaction,
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFFD14D4D),

                          // Keep the button red even
                          // when disabled.
                          disabledBackgroundColor:
                          const Color(0xFFD14D4D),

                          disabledForegroundColor:
                          Colors.white,

                          elevation: 0,

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(7),
                          ),

                          padding: EdgeInsets.zero,
                        ),
                        child: loading
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child:
                          CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          l10n.delete,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight:
                            FontWeight.w500,
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