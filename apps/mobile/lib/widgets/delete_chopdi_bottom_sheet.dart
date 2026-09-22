import 'package:flutter/material.dart';
import 'package:mychopdi/l10n/app_localizations.dart';

class DeleteChopdiBottomSheet extends StatefulWidget {
  const DeleteChopdiBottomSheet({
    super.key,
    required this.onDelete,
  });

  final Future<void> Function() onDelete;

  @override
  State<DeleteChopdiBottomSheet> createState() =>
      _DeleteChopdiBottomSheetState();
}

class _DeleteChopdiBottomSheetState
    extends State<DeleteChopdiBottomSheet> {
  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color sheetColor =
  Color(0xFFFFFAF4);

  static const Color darkBlue =
  Color(0xFF213F68);

  static const Color textColor =
  Color(0xFF344B68);

  static const Color secondaryText =
  Color(0xFF65758A);

  static const Color redColor =
  Color(0xFFD34E4E);

  static const Color lightRed =
  Color(0xFFF9DAD5);

  static const Color borderColor =
  Color(0xFFE2B0A9);

  static const Color checkboxBorder =
  Color(0xFFAFC0D3);

  // ===========================================================================
  // STATE
  // ===========================================================================

  bool _understood = false;
  bool _deleting = false;

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: sheetColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            11,
            16,
            17,
          ),
          child: Column(
            children: [
              // =================================================================
              // HANDLE
              // =================================================================

              _buildHandle(),

              const SizedBox(height: 20),

              // =================================================================
              // DELETE ICON
              // =================================================================

              _buildDeleteIcon(),

              const SizedBox(height: 7),

              // =================================================================
              // TITLE
              // =================================================================

              Text(
                AppLocalizations.of(context)
                    .areYouSureDeleteChopdi,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: darkBlue,
                ),
              ),

              const SizedBox(height: 2),

              // =================================================================
              // DESCRIPTION
              // =================================================================

              Text(
                '${AppLocalizations.of(context).deleteChopdiDescription}\n'
                    '${AppLocalizations.of(context).deleteChopdiDescriptionData}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 8,
                  height: 1.25,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 17),

              // =================================================================
              // WARNING BOX
              // =================================================================

              _buildWarningBox(context),

              const SizedBox(height: 21),

              // =================================================================
              // CONFIRMATION CHECKBOX
              // =================================================================

              _buildConfirmationCheckbox(context),

              const SizedBox(height: 21),

              // =================================================================
              // BUTTONS
              // =================================================================

              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HANDLE
  // ===========================================================================

  Widget _buildHandle() {
    return Container(
      width: 48,
      height: 3,
      decoration: BoxDecoration(
        color: const Color(0xFF777777),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  // ===========================================================================
  // DELETE ICON
  // ===========================================================================

  Widget _buildDeleteIcon() {
    return Container(
      width: 53,
      height: 53,
      decoration: const BoxDecoration(
        color: lightRed,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.delete_outline_rounded,
        size: 25,
        color: redColor,
      ),
    );
  }

  // ===========================================================================
  // WARNING BOX
  // ===========================================================================

  Widget _buildWarningBox(
      BuildContext context,
      ) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        15,
        9,
        12,
        9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F5),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: redColor,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _WarningLine(
            text: l10n.deleteChopdiWarningCustomers,
          ),
          _WarningLine(
            text: l10n.deleteChopdiWarningLoans,
          ),
          _WarningLine(
            text: l10n.deleteChopdiWarningNotes,
          ),
          _WarningLine(
            text: l10n.thisActionCannotBeUndone,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CHECKBOX
  // ===========================================================================

  Widget _buildConfirmationCheckbox(
      BuildContext context,
      ) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          _understood = !_understood;
        });
      },
      child: Container(
        width: double.infinity,
        height: 39,
        padding: const EdgeInsets.symmetric(
          horizontal: 7,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFAF5),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: const Color(0xFFF0D5CD),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            // ---------------------------------------------------------------
            // CHECKBOX
            // ---------------------------------------------------------------

            Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                color: _understood
                    ? darkBlue
                    : Colors.transparent,
                borderRadius:
                BorderRadius.circular(3),
                border: Border.all(
                  color: _understood
                      ? darkBlue
                      : checkboxBorder,
                  width: 1,
                ),
              ),
              child: _understood
                  ? const Icon(
                Icons.check,
                size: 13,
                color: Colors.white,
              )
                  : null,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                l10n.deleteChopdiConfirmation,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // BUTTONS
  // ===========================================================================

  Widget _buildButtons(
      BuildContext context,
      ) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        // =====================================================================
        // CANCEL
        // =====================================================================

        Expanded(
          child: SizedBox(
            height: 34,
            child: OutlinedButton(
              onPressed: _deleting
                  ? null
                  : () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                backgroundColor:
                const Color(0xFFFFFAF5),
                foregroundColor: darkBlue,
                side: const BorderSide(
                  color: redColor,
                  width: 0.8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(6),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                l10n.cancel,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: darkBlue,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 13),

        // =====================================================================
        // DELETE
        // =====================================================================

        Expanded(
          child: SizedBox(
            height: 34,
            child: ElevatedButton(
              onPressed:
              (!_understood || _deleting)
                  ? null
                  : _handleDelete,
              style: ElevatedButton.styleFrom(
                backgroundColor: redColor,
                disabledBackgroundColor:
                const Color(0xFFE5A4A1),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(6),
                ),
              ),
              child: _deleting
                  ? const SizedBox(
                width: 15,
                height: 15,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                l10n.deleteChopdi,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight:
                  FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // DELETE HANDLER
  // ===========================================================================

  Future<void> _handleDelete() async {
    if (!_understood || _deleting) {
      return;
    }

    setState(() {
      _deleting = true;
    });

    try {
      await widget.onDelete();
    } finally {
      if (mounted) {
        setState(() {
          _deleting = false;
        });
      }
    }
  }
}

// =============================================================================
// WARNING LINE
// =============================================================================

class _WarningLine extends StatelessWidget {
  const _WarningLine({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 2,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              fontSize: 8,
              color: Color(0xFFD34E4E),
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 7.5,
                height: 1.15,
                color: Color(0xFFD34E4E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}