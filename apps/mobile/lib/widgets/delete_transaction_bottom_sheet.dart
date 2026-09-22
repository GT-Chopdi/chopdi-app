import 'package:flutter/material.dart';
import 'package:mychopdi/l10n/app_localizations.dart';

Future<void> showDeleteTransactionBottomSheet(
    BuildContext context, {
      required String title,
      required String subtitle,
      required Future<void> Function() onDelete,
    }) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    builder: (_) {
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

  Future<void> _handleDelete() async {
    if (!agree || loading) return;

    setState(() {
      loading = true;
    });

    try {
      await widget.onDelete();

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      final l10n = AppLocalizations.of(context);

      setState(() {
        loading = false;
      });

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
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          24,
        ),
        decoration: const BoxDecoration(
          color: Color(0xffFFF8F3),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 22),

            // Delete Icon
            Container(
              height: 72,
              width: 72,
              decoration: const BoxDecoration(
                color: Color(0xffFCE3E0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 34,
                color: Color(0xffD9534F),
              ),
            ),

            const SizedBox(height: 18),

            // Title
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xffD9534F),
              ),
            ),

            const SizedBox(height: 4),

            // Subtitle
            Text(
              widget.subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 25),

            // Confirmation
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: loading
                  ? null
                  : () {
                setState(() {
                  agree = !agree;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xffF3D3CF),
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: agree,
                      activeColor: const Color(0xffD9534F),
                      onChanged: loading
                          ? null
                          : (v) {
                        setState(() {
                          agree = v ?? false;
                        });
                      },
                    ),

                    Expanded(
                      child: Text(
                        l10n.deleteConfirmation,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Buttons
            Row(
              children: [
                // Cancel
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: loading
                          ? null
                          : () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xffD9534F),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(
                          color: Color(0xffD9534F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Delete
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                      (!agree || loading)
                          ? null
                          : _handleDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xffD9534F),
                        disabledBackgroundColor:
                        Colors.red.shade200,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                        CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        l10n.delete,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight:
                          FontWeight.bold,
                        ),
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