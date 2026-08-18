import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerFilterBottomSheet extends StatefulWidget {
  const CustomerFilterBottomSheet({super.key});

  @override
  State<CustomerFilterBottomSheet> createState() =>
      _CustomerFilterBottomSheetState();
}

class _CustomerFilterBottomSheetState extends State<CustomerFilterBottomSheet> {

  String selectedStatus = "Pending";
  String selectedDate = "This Month";

  DateTime? fromDate;
  DateTime? toDate;

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff223A5E),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return FractionallySizedBox(
      heightFactor: .88,
      child: Container(
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
              children: [

                Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xff9C9C9C),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: const [

                    Icon(
                      Icons.filter_alt_outlined,
                      color: Color(0xff64748B),
                    ),

                    SizedBox(width: 8),

                    Text(
                      "Filter",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff223A5E),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 28),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Status",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff223A5E),
                          ),
                        ),

                        const SizedBox(height: 14),

                        _optionCard(
                          title: "All Customers",
                          subtitle:
                              "Show All your customers",
                          value: "All",
                          group: selectedStatus,
                          onTap: () {
                            setState(() {
                              selectedStatus = "All";
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        _optionCard(
                          title: "Pending",
                          subtitle:
                              "Customers with pending due",
                          value: "Pending",
                          group: selectedStatus,
                          onTap: () {
                            setState(() {
                              selectedStatus =
                                  "Pending";
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        _optionCard(
                          title: "Settled",
                          subtitle:
                              "Customers with cleared due",
                          value: "Settled",
                          group: selectedStatus,
                          onTap: () {
                            setState(() {
                              selectedStatus =
                                  "Settled";
                            });
                          },
                        ),

                        const SizedBox(height: 28),

                        const Text(
                          "Loan Date",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff223A5E),
                          ),
                        ),

                        const SizedBox(height: 14),

                        _optionCard(
                          title: "This Month",
                          subtitle:
                              "Customers added this month",
                          value: "This Month",
                          group: selectedDate,
                          onTap: () {
                            setState(() {
                              selectedDate =
                                  "This Month";
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        _customDateCard(),
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
                          style:
                              OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color:
                                  Color(0xffCBD5E1),
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedStatus =
                                  "Pending";
                              selectedDate =
                                  "This Month";
                              fromDate = null;
                              toDate = null;
                            });
                          },
                          child: const Text(
                            "Reset",
                            style: TextStyle(
                              color:
                                  Color(0xff223A5E),
                              fontWeight:
                                  FontWeight.w600,
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
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(
                                    0xff223A5E),
                            elevation: 0,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context, {
                              "status":
                                  selectedStatus,
                              "date":
                                  selectedDate,
                              "from":
                                  fromDate,
                              "to": toDate,
                            });
                          },
                          child: const Text(
                            "Apply Filters",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
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

Widget _customDateCard() {
  final bool selected = selectedDate == "Custom";

  return InkWell(
    onTap: () {
      setState(() {
        selectedDate = "Custom";
      });
    },
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [

          Row(
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
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Custom Date",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff223A5E),
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      "Select a start and end date",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xff7B8794),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xffFFF3E5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xffE9DCCF),
              ),
            ),
            child: Row(
              children: [

                Expanded(
                  child: _dateField(
                    "From",
                    fromDate,
                    () => _pickDate(true),
                  ),
                ),

                Container(
                  width: 1,
                  height: 34,
                  color: const Color(0xffD9CCBE),
                ),

                Expanded(
                  child: _dateField(
                    "To",
                    toDate,
                    () => _pickDate(false),
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

Widget _dateField(
  String title,
  DateTime? date,
  VoidCallback onTap,
) {
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
                      ? "Select Date"
                      : DateFormat(
                          "dd MMM yyyy",
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