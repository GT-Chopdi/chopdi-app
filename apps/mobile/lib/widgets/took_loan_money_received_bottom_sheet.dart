import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/l10n/app_localizations.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/service/local_notification_service.dart';
import 'package:mychopdi/service/transaction_service.dart';
import 'package:mychopdi/utils/money.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TookLoanMoneyReceivedBottomSheet extends StatefulWidget {
  final Customer customer;
  final VoidCallback onSaved;

  const TookLoanMoneyReceivedBottomSheet({
    super.key,
    required this.customer,
    required this.onSaved,
  });

  @override
  State<TookLoanMoneyReceivedBottomSheet> createState() =>
      _MoneyReceiveBottomSheetState();
}

class _MoneyReceiveBottomSheetState
    extends State<TookLoanMoneyReceivedBottomSheet> {
  final TextEditingController amountController =
  TextEditingController();

  final TextEditingController interestController =
  TextEditingController();

  final TextEditingController descriptionController =
  TextEditingController();

  final ScrollController _scrollController =
  ScrollController();

  final FocusNode _amountFocusNode =
  FocusNode();

  final FocusNode _descriptionFocusNode =
  FocusNode();

  DateTime selectedDate = DateTime.now();

  String paymentMode = "";

  @override
  void initState() {
    super.initState();

    _amountFocusNode.addListener(() {
      if (_amountFocusNode.hasFocus) {
        _scrollToAmount();
      }
    });

    _descriptionFocusNode.addListener(() {
      if (_descriptionFocusNode.hasFocus) {
        _scrollToDescription();
      }
    });
  }

  void _scrollToAmount() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _scrollToDescription() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _pickDate() async {
    final DateTime today = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate:
      selectedDate.isAfter(today)
          ? today
          : selectedDate,
      firstDate: DateTime(2000),
      lastDate: today,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  InputDecoration decoration({
    String? hint,
    Widget? suffix,
    Widget? prefix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xff8A93A6),
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xffC9D2E3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xff29406B),
          width: 1.3,
        ),
      ),
    );
  }

  Widget title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xff737D8C),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (amountController.text.trim().isEmpty) {
      return;
    }

    final amount =
    double.tryParse(amountController.text.trim());

    if (amount == null) {
      return;
    }

    final tx = Transaction()
      ..customerId = widget.customer.id
      ..chopdiId = widget.customer.chopdiId
      ..amountPaise = Money.toPaise(amount)
      ..interestRateBp = 0
      ..date = selectedDate
      ..type = TransactionType.paid
      ..description = descriptionController.text.trim()
      ..paymentMode = paymentMode
      ..interestType = ""
      ..interestFrequency = "";

    await TransactionService.addTransaction(tx);

    await LocalNotificationService.instance
        .syncNotifications(
      database: IsarService.isar,
    );

    final localNotificationService =
        LocalNotificationService.instance;

    final prefs =
    await SharedPreferences.getInstance();

    final paymentReminderEnabled =
        prefs.getBool(
          'notification_payment_reminder_enabled',
        ) ??
            true;

    if (paymentReminderEnabled) {
      await localNotificationService
          .rescheduleAllPaymentReminders();
    }

    widget.onSaved();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    interestController.dispose();
    descriptionController.dispose();

    _scrollController.dispose();

    _amountFocusNode.dispose();
    _descriptionFocusNode.dispose();

    super.dispose();
  }

  String _localizedPaymentMode(
      BuildContext context,
      String value,
      ) {
    final l10n = AppLocalizations.of(context);

    switch (value) {
      case "Cash":
        return l10n.cash;

      case "UPI":
        return l10n.upi;

      case "Bank":
        return l10n.bankTransfer;

      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final keyboardHeight =
        MediaQuery.of(context).viewInsets.bottom;

    final locale =
    Localizations.localeOf(context).toLanguageTag();

    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: keyboardHeight,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height:
          MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: Color(0xffFFF8F0),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(34),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: 55,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                    borderRadius:
                    BorderRadius.circular(50),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior
                      .onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    22,
                    10,
                    22,
                    25,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      Container(
                        height: 72,
                        width: 72,
                        decoration:
                        const BoxDecoration(
                          color: Color.fromRGBO(
                            141,
                            208,
                            113,
                            0.34,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor:
                            Colors.transparent,
                            child: Image.asset(
                              'assets/you_got.png',
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        l10n.youPaid,
                        style: GoogleFonts.manrope(
                          color:
                          const Color(0xFF00901B),
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),

                      const SizedBox(height: 28),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: title(l10n.amount),
                      ),

                      TextField(
                        controller: amountController,
                        focusNode: _amountFocusNode,
                        keyboardType:
                        TextInputType.number,
                        decoration: decoration(
                          hint: l10n.enterAmount,
                          prefix: const Icon(
                            Icons.currency_rupee,
                            size: 20,
                            color: Color(0xff6D7B94),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: title(l10n.date),
                      ),

                      TextField(
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: decoration(
                          suffix: const Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.black,
                          ),
                        ).copyWith(
                          hintText: DateFormat(
                            "dd MMM yyyy",
                            locale,
                          ).format(selectedDate),
                          hintStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: title(l10n.description),
                      ),

                      TextField(
                        controller:
                        descriptionController,
                        focusNode:
                        _descriptionFocusNode,
                        maxLength: 100,
                        maxLines: 4,
                        decoration: decoration(
                          hint:
                          l10n.enterDescriptionHere,
                        ).copyWith(
                          counterText: "",
                        ),
                        onChanged: (_) =>
                            setState(() {}),
                      ),

                      const SizedBox(height: 18),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: title(
                          l10n.paymentModeOptional,
                        ),
                      ),

                      DropdownButtonFormField<String>(
                        initialValue:
                        paymentMode.isEmpty
                            ? null
                            : paymentMode,
                        selectedItemBuilder:
                            (context) => [
                          Text(l10n.cash),
                          Text(l10n.upi),
                          Text(l10n.bankTransfer),
                        ],
                        decoration: decoration(
                          hint:
                          l10n.selectPaymentMode,
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: "Cash",
                            child: Text(l10n.cash),
                          ),
                          DropdownMenuItem(
                            value: "UPI",
                            child: Text(l10n.upi),
                          ),
                          DropdownMenuItem(
                            value: "Bank",
                            child:
                            Text(l10n.bankTransfer),
                          ),
                        ],
                        onChanged: (v) {
                          setState(() {
                            paymentMode = v!;
                          });
                        },
                      ),

                      const SizedBox(height: 18),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(
                  22,
                  12,
                  22,
                  20,
                ),
                color: const Color(0xffFFF8F0),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            FocusScope.of(context)
                                .unfocus();

                            Navigator.pop(context);
                          },
                          style:
                          OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xffC7D0DF),
                            ),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                          child: Text(
                            l10n.cancel,
                            style: const TextStyle(
                              color: Color(0xff29406B),
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 18),

                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                          _saveTransaction,
                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(
                              0xff29406B,
                            ),
                            elevation: 0,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                          child: Text(
                            l10n.saveEntry,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight:
                              FontWeight.w700,
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
      ),
    );
  }
}