import 'package:flutter/material.dart';
import 'package:mychopdi/l10n/app_localizations.dart';

class SortBottomSheet extends StatefulWidget {
  const SortBottomSheet({super.key});

  @override
  State<SortBottomSheet> createState() =>
      _SortBottomSheetState();
}

class _SortBottomSheetState
    extends State<SortBottomSheet> {
  // IMPORTANT:
  // These values are internal values.
  // Do NOT translate them.
  String selectedSort = "Name (A-Z)";

  // ================================================================
  // LOCALIZED SORT NAME
  // ================================================================

  String _localizedSortName(
      BuildContext context,
      String value,
      ) {
    final l10n = AppLocalizations.of(context);

    switch (value) {
      case "Name (A-Z)":
        return l10n.sortNameAZ;

      case "Name (Z-A)":
        return l10n.sortNameZA;

      case "Loan Amount (High to Low)":
        return l10n.sortLoanAmountHighToLow;

      case "Loan Amount (Low to High)":
        return l10n.sortLoanAmountLowToHigh;

      case "Recently Added":
        return l10n.sortRecentlyAdded;

      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FractionallySizedBox(
      heightFactor: .72,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          20,
          14,
          20,
          20,
        ),
        decoration: const BoxDecoration(
          color: Color(0xffFFF8F0),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            // ==========================================================
            // DRAG HANDLE
            // ==========================================================

            Container(
              width: 56,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xff8B857E),
                borderRadius:
                BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 22),

            // ==========================================================
            // SORT BY
            // ==========================================================

            Row(
              children: [
                const Icon(
                  Icons.swap_vert,
                  color: Color(0xff64748B),
                  size: 18,
                ),

                const SizedBox(width: 8),

                Text(
                  l10n.sortBy,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xff64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ==========================================================
            // SORT OPTIONS
            // ==========================================================

            Expanded(
              child: ListView(
                children: [
                  _sortTile(
                    context: context,
                    title: "Name (A-Z)",
                    icon: Icons.sort_by_alpha,
                  ),

                  const SizedBox(height: 10),

                  _sortTile(
                    context: context,
                    title: "Name (Z-A)",
                    icon: Icons.sort_by_alpha,
                  ),

                  const SizedBox(height: 10),

                  _sortTile(
                    context: context,
                    title:
                    "Loan Amount (High to Low)",
                    icon: Icons.currency_rupee,
                    arrowDown: true,
                  ),

                  const SizedBox(height: 10),

                  _sortTile(
                    context: context,
                    title:
                    "Loan Amount (Low to High)",
                    icon: Icons.currency_rupee,
                    arrowDown: false,
                  ),

                  const SizedBox(height: 10),

                  _sortTile(
                    context: context,
                    title: "Recently Added",
                    icon:
                    Icons.access_time_outlined,
                  ),
                ],
              ),
            ),

            // ==========================================================
            // CANCEL
            // ==========================================================

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                l10n.cancel,
                style: const TextStyle(
                  color: Color(0xff223A5E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // SORT TILE
  // ================================================================

  Widget _sortTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    bool arrowDown = true,
  }) {
    final selected = selectedSort == title;

    final localizedTitle =
    _localizedSortName(
      context,
      title,
    );

    return InkWell(
      borderRadius:
      BorderRadius.circular(12),
      onTap: () {
        setState(() {
          selectedSort = title;
        });

        // IMPORTANT:
        // Return the ORIGINAL internal value,
        // not the translated value.
        Navigator.pop(
          context,
          title,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xffCBD5E1),
          ),
        ),
        child: Row(
          children: [
            // ==========================================================
            // RADIO BUTTON
            // ==========================================================

            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? const Color(0xff223A5E)
                      : const Color(0xffC8D1DE),
                  width: 1.5,
                ),
                color: selected
                    ? const Color(0xff223A5E)
                    : Colors.white,
              ),
              child: selected
                  ? const Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              )
                  : null,
            ),

            const SizedBox(width: 16),

            // ==========================================================
            // TITLE
            // ==========================================================

            Expanded(
              child: Text(
                localizedTitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xff223A5E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // ==========================================================
            // NAME SORT ICON
            // ==========================================================

            if (title == "Name (A-Z)" ||
                title == "Name (Z-A)")
              const Text(
                "↓A\nZ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff223A5E),
                  fontWeight: FontWeight.bold,
                  height: 0.8,
                ),
              ),

            // ==========================================================
            // HIGH TO LOW
            // ==========================================================

            if (title ==
                "Loan Amount (High to Low)")
              const Row(
                children: [
                  Icon(
                    Icons.currency_rupee,
                    color: Color(0xff223A5E),
                  ),
                  Icon(
                    Icons.arrow_downward,
                    size: 18,
                    color: Color(0xff223A5E),
                  ),
                ],
              ),

            // ==========================================================
            // LOW TO HIGH
            // ==========================================================

            if (title ==
                "Loan Amount (Low to High)")
              const Row(
                children: [
                  Icon(
                    Icons.currency_rupee,
                    color: Color(0xff223A5E),
                  ),
                  Icon(
                    Icons.arrow_upward,
                    size: 18,
                    color: Color(0xff223A5E),
                  ),
                ],
              ),

            // ==========================================================
            // RECENTLY ADDED
            // ==========================================================

            if (title == "Recently Added")
              const Icon(
                Icons.access_time_outlined,
                color: Color(0xff223A5E),
              ),
          ],
        ),
      ),
    );
  }
}