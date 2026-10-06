import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/l10n/app_localizations.dart';

class CustomerFilterBottomSheet extends StatefulWidget {
  final String selectedStatus;
  final String selectedSort;

  const CustomerFilterBottomSheet({
    super.key,
    required this.selectedStatus,
    required this.selectedSort,
  });

  @override
  State<CustomerFilterBottomSheet> createState() =>
      _CustomerFilterBottomSheetState();
}

class _CustomerFilterBottomSheetState
    extends State<CustomerFilterBottomSheet> {
  String selectedStatus = "All";
  String selectedSort = "Most Recent";

  @override
  void initState() {
    super.initState();

    selectedStatus =
        widget.selectedStatus == "Settled"
            ? "Settled"
            : "All";

    selectedSort = _validSort(widget.selectedSort);
  }

  String _validSort(String value) {
    const validSorts = {
      "Most Recent",
      "Highest Amount",
      "By Name (A-Z)",
      "Oldest",
      "Least Amount",
    };

    return validSorts.contains(value)
        ? value
        : "Most Recent";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        decoration: const BoxDecoration(
          color: Color(0xffFFF8F0),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              14,
              20,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xff9C9C9C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    const Icon(
                      Icons.filter_alt_outlined,
                      color: Color(0xff64748B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.filter,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff223A5E),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ---------------- FILTER BY ----------------

                          Text(
                            l10n.filterBy,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff223A5E),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _sortChip(
                                title: l10n.allCustomers,
                                value: "All",
                                selected: selectedStatus == "All",
                                onTap: () {
                                  setState(() {
                                    selectedStatus = "All";
                                  });
                                },
                              ),

                              _sortChip(
                                title: l10n.settled,
                                value: "Settled",
                                selected: selectedStatus == "Settled",
                                onTap: () {
                                  setState(() {
                                    selectedStatus = "Settled";
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // ---------------- SORT BY ----------------


                          Text(
                            l10n.sortBy,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff223A5E),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _sortChip(
                                title: l10n.mostRecent,
                                value: "Most Recent",
                                selected: selectedSort == "Most Recent",
                                onTap: () {
                                  setState(() {
                                    selectedSort = "Most Recent";
                                  });
                                },
                              ),

                              _sortChip(
                                title: l10n.highestAmount,
                                value: "Highest Amount",
                                selected: selectedSort == "Highest Amount",
                                onTap: () {
                                  setState(() {
                                    selectedSort = "Highest Amount";
                                  });
                                },
                              ),

                              _sortChip(
                                title: l10n.byNameAZ,
                                value: "By Name (A-Z)",
                                selected: selectedSort == "By Name (A-Z)",
                                onTap: () {
                                  setState(() {
                                    selectedSort = "By Name (A-Z)";
                                  });
                                },
                              ),

                              _sortChip(
                                title: l10n.oldest,
                                value: "Oldest",
                                selected: selectedSort == "Oldest",
                                onTap: () {
                                  setState(() {
                                    selectedSort = "Oldest";
                                  });
                                },
                              ),

                              _sortChip(
                                title: l10n.leastAmount,
                                value: "Least Amount",
                                selected: selectedSort == "Least Amount",
                                onTap: () {
                                  setState(() {
                                    selectedSort = "Least Amount";
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xffCBD5E1),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedStatus = "All";
                              selectedSort = "Most Recent";
                            });
                          },
                          child: Text(
                            l10n.reset,
                            style: const TextStyle(
                              color: Color(0xff223A5E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xff223A5E),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context, {
                              "status": selectedStatus,
                              "sort": selectedSort,
                            });
                          },
                          child: Text(
                            l10n.applyFilters,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
        ),
      );
  }

  Widget _optionCard({
    required String title,
    required String subtitle,
    required String value,
    required String group,
    required VoidCallback onTap,
  }) {
    final bool selected = value == group;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xff223A5E)
                : const Color(0xffD7DEE8),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? const Color(0xff223A5E)
                    : Colors.white,
                border: Border.all(
                  color: selected
                      ? const Color(0xff223A5E)
                      : const Color(0xffC6CEDA),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 14,
              )
                  : null,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff223A5E),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff7B8794),
                      height: 1.4,
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

  Widget _sortChip({
  required String title,
  required String value,
  required bool selected,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? const Color(0xff223A5E)
              : const Color(0xffD7DEE8),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? const Color(0xff223A5E)
                  : Colors.white,
              border: Border.all(
                color: selected
                    ? const Color(0xff223A5E)
                    : const Color(0xffC6CEDA),
                width: 1.5,
              ),
            ),
            child: selected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 13,
                  )
                : null,
          ),

          const SizedBox(width: 8),

          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.w500,
              color: const Color(0xff223A5E),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _sortOptionCard({
    required String title,
    required String value,
  }) {
    final bool selected = selectedSort == value;

    return InkWell(
      onTap: () {
        setState(() {
          selectedSort = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xff223A5E)
                : const Color(0xffD7DEE8),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Bullet / radio
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? const Color(0xff223A5E)
                    : Colors.white,
                border: Border.all(
                  color: selected
                      ? const Color(0xff223A5E)
                      : const Color(0xffC6CEDA),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),

            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff223A5E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField(
      String title,
      DateTime? date,
      VoidCallback onTap,
      ) {
    final l10n = AppLocalizations.of(context);
    final locale =
    Localizations.localeOf(context).toLanguageTag();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xff7B8794),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    date == null
                        ? l10n.selectDate
                        : DateFormat(
                      "dd MMM yyyy",
                      locale,
                    ).format(date),
                    style: TextStyle(
                      fontSize: 13,
                      color: date == null
                          ? const Color(0xff9AA5B1)
                          : const Color(0xff223A5E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Color(0xff7B8794),
            ),
          ],
        ),
      ),
    );
  }
}