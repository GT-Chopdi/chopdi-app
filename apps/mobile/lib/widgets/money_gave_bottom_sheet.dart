import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/service/local_notification_service.dart';
import 'package:mychopdi/service/notification_service.dart';
import 'package:mychopdi/service/transaction_service.dart';
import 'package:mychopdi/utils/interest_calculator.dart';
import 'package:mychopdi/utils/money.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoneyGaveBottomSheet extends StatefulWidget {
  final Customer customer;
  final VoidCallback onSaved;
  final bool isEdit;
  final Transaction? transaction;

  const MoneyGaveBottomSheet({
    super.key,
    required this.customer,
    required this.onSaved,
    required this.isEdit,
    this.transaction,
  });

  @override
  State<MoneyGaveBottomSheet> createState() =>
      _MoneyGaveBottomSheetState();
}

class _MoneyGaveBottomSheetState
    extends State<MoneyGaveBottomSheet> {
  final TextEditingController amountController =
  TextEditingController();

  final TextEditingController interestController =
  TextEditingController();

  final TextEditingController descriptionController =
  TextEditingController();

  // ============================================================
  // SCROLL CONTROLLER
  // ============================================================

  final ScrollController _scrollController =
  ScrollController();

  // ============================================================
  // FOCUS NODES
  // ============================================================

  final FocusNode _amountFocusNode =
  FocusNode();

  final FocusNode _interestFocusNode =
  FocusNode();

  final FocusNode _descriptionFocusNode =
  FocusNode();

  // ============================================================
  // FIELD KEYS
  // ============================================================

  final GlobalKey _amountKey =
  GlobalKey();

  final GlobalKey _interestKey =
  GlobalKey();

  final GlobalKey _descriptionKey =
  GlobalKey();

  // ============================================================
  // VALIDATION
  // ============================================================

  bool _interestRateError = false;

  bool _amountError = false;

  // ============================================================
  // VALUES
  // ============================================================

  DateTime selectedDate = DateTime.now();

  String interestType = "Simple Interest";

  String interestFrequency = "Monthly";

  String paymentMode = "";

  // ============================================================
  // INTEREST AMOUNT
  // ============================================================

  double get interestAmount {
    final amount =
        double.tryParse(amountController.text) ?? 0;

    final percent =
        double.tryParse(interestController.text) ?? 0;

    return amount * percent / 100;
  }

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    if (widget.transaction != null) {
      amountController.text =
          widget.transaction!.amount.toString();

      interestController.text =
          widget.transaction!.interestRate.toString();

      descriptionController.text =
          widget.transaction!.description;

      paymentMode =
          widget.transaction!.paymentMode;

      selectedDate =
          widget.transaction!.date;

      interestType =
          widget.transaction!.interestType;

      interestFrequency =
          widget.transaction!.interestFrequency;
    }

    // ============================================================
    // AMOUNT FOCUS
    // ============================================================

    _amountFocusNode.addListener(() {
      if (_amountFocusNode.hasFocus) {
        _scrollToField(_amountKey);
      }
    });

    // ============================================================
    // INTEREST FOCUS
    // ============================================================

    _interestFocusNode.addListener(() {
      if (_interestFocusNode.hasFocus) {
        _scrollToField(_interestKey);
      }
    });

    // ============================================================
    // DESCRIPTION FOCUS
    // ============================================================

    _descriptionFocusNode.addListener(() {
      if (_descriptionFocusNode.hasFocus) {
        _scrollToField(_descriptionKey);
      }
    });
  }

  // ============================================================
  // SCROLL FIELD INTO VIEW
  // ============================================================

  void _scrollToField(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = key.currentContext;

      if (context == null) return;

      Scrollable.ensureVisible(
        context,
        duration:
        const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        alignment: 0.25,
      );
    });
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    amountController.dispose();
    interestController.dispose();
    descriptionController.dispose();

    _scrollController.dispose();

    _amountFocusNode.dispose();
    _interestFocusNode.dispose();
    _descriptionFocusNode.dispose();

    super.dispose();
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _pickDate() async {
    final DateTime today =
    DateTime.now();

    final picked =
    await showDatePicker(
      context: context,
      initialDate:
      selectedDate.isAfter(today)
          ? today
          : selectedDate,
      firstDate:
      DateTime(2000),
      lastDate: today,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // ============================================================
  // COMMON DECORATION
  // ============================================================

  InputDecoration decoration({
    String? hint,
    Widget? suffix,
    Widget? prefix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
      const TextStyle(
        color: Color(0xff8A93A6),
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12),
        borderSide:
        const BorderSide(
          color: Color(0xffC9D2E3),
        ),
      ),
      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12),
        borderSide:
        const BorderSide(
          color: Color(0xff29406B),
          width: 1.3,
        ),
      ),
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

  Widget title(String text) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 8,
      ),
      child: Align(
        alignment:
        Alignment.centerLeft,
        child: Text(
          text,
          style:
          const TextStyle(
            fontSize: 15,
            color:
            Color(0xff737D8C),
            fontWeight:
            FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final keyboardHeight =
        MediaQuery.of(context)
            .viewInsets
            .bottom;

    return AnimatedPadding(
      duration:
      const Duration(
        milliseconds: 250,
      ),
      curve: Curves.easeOut,

      // Move entire bottom sheet above keyboard.
      padding: EdgeInsets.only(
        bottom: keyboardHeight,
      ),

      child: SafeArea(
        top: false,
        child: Container(
          height:
          MediaQuery.of(context)
              .size
              .height *
              0.90,

          decoration:
          const BoxDecoration(
            color:
            Color(0xffFFF8F0),
            borderRadius:
            BorderRadius.vertical(
              top:
              Radius.circular(34),
            ),
          ),

          child: Column(
            children: [
              // ==========================================================
              // TOP HANDLE
              // ==========================================================

              Padding(
                padding:
                const EdgeInsets.only(
                  top: 10,
                ),
                child: Container(
                  width: 55,
                  height: 5,
                  decoration:
                  BoxDecoration(
                    color: Colors.grey,
                    borderRadius:
                    BorderRadius.circular(
                      50,
                    ),
                  ),
                ),
              ),

              // ==========================================================
              // SCROLLABLE FORM
              // ==========================================================

              Expanded(
                child:
                SingleChildScrollView(
                  controller:
                  _scrollController,

                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior
                      .onDrag,

                  padding:
                  const EdgeInsets.fromLTRB(
                    22,
                    10,
                    22,
                    25,
                  ),

                  child: Column(
                    children: [
                      const SizedBox(
                        height: 12,
                      ),

                      // ==================================================
                      // ICON
                      // ==================================================

                      Container(
                        height: 72,
                        width: 72,
                        decoration:
                        const BoxDecoration(
                          color:
                          Color.fromRGBO(
                            199,
                            76,
                            76,
                            0.19,
                          ),
                          shape:
                          BoxShape.circle,
                        ),
                        child:
                        Center(
                          child:
                          CircleAvatar(
                            radius: 18,
                            backgroundColor:
                            Colors
                                .transparent,
                            child:
                            Image.asset(
                              'assets/you_gave.png',
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        "You Gave",
                        style:
                        GoogleFonts
                            .manrope(
                          color:
                          const Color
                              .fromRGBO(
                            199,
                            76,
                            76,
                            1,
                          ),
                          fontWeight:
                          FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // ==================================================
                      // AMOUNT
                      // ==================================================

                      Align(
                        alignment:
                        Alignment
                            .centerLeft,
                        child:
                        title("Amount"),
                      ),

                      Container(
                        key: _amountKey,
                        child:
                        TextField(
                          controller:
                          amountController,
                          focusNode:
                          _amountFocusNode,

                          keyboardType:
                          const TextInputType
                              .numberWithOptions(
                            decimal:
                            true,
                          ),

                          onChanged:
                              (value) {
                            if (_amountError &&
                                value
                                    .trim()
                                    .isNotEmpty) {
                              setState(() {
                                _amountError =
                                false;
                              });
                            }

                            setState(() {});
                          },

                          decoration:
                          decoration(
                            hint:
                            "Enter Amount",
                            prefix:
                            const Icon(
                              Icons
                                  .currency_rupee,
                              size: 20,
                              color:
                              Color(
                                0xff6D7B94,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ==================================================
                      // DATE
                      // ==================================================

                      Align(
                        alignment:
                        Alignment
                            .centerLeft,
                        child:
                        title("Date"),
                      ),

                      TextField(
                        readOnly: true,
                        onTap:
                        _pickDate,

                        decoration:
                        decoration(
                          suffix:
                          const Icon(
                            Icons
                                .calendar_today_outlined,
                            color:
                            Colors.black,
                          ),
                        ).copyWith(
                          hintText:
                          DateFormat(
                            "dd MMM yyyy",
                          ).format(
                            selectedDate,
                          ),
                          hintStyle:
                          const TextStyle(
                            color:
                            Colors.black,
                            fontWeight:
                            FontWeight
                                .w500,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ==================================================
                      // INTEREST RATE
                      // ==================================================

                      Align(
                        alignment:
                        Alignment
                            .centerLeft,
                        child: title(
                          "Interest Rate (%)",
                        ),
                      ),

                      Container(
                        key: _interestKey,
                        child:
                        _buildInterestRateField(),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ==================================================
                      // DESCRIPTION
                      // ==================================================

                      Align(
                        alignment:
                        Alignment
                            .centerLeft,
                        child:
                        title(
                          "Description",
                        ),
                      ),

                      Container(
                        key:
                        _descriptionKey,
                        child:
                        TextField(
                          controller:
                          descriptionController,
                          focusNode:
                          _descriptionFocusNode,
                          maxLength: 100,
                          maxLines: 4,

                          decoration:
                          decoration(
                            hint:
                            "Enter Description here...",
                          ).copyWith(
                            counterText:
                            "",
                          ),

                          onChanged:
                              (_) =>
                              setState(
                                    () {},
                              ),
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ==================================================
                      // INTEREST TYPE
                      // ==================================================

                      Align(
                        alignment:
                        Alignment
                            .centerLeft,
                        child:
                        title(
                          "Interest Type",
                        ),
                      ),

                      DropdownButtonFormField<
                          String>(
                        initialValue:
                        interestType,
                        decoration:
                        decoration(),
                        icon:
                        const Icon(
                          Icons
                              .keyboard_arrow_down,
                        ),
                        items:
                        const [
                          DropdownMenuItem(
                            value:
                            "Simple Interest",
                            child: Text(
                              "Simple Interest",
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                            "Compound Interest",
                            child: Text(
                              "Compound Interest",
                            ),
                          ),
                        ],
                        onChanged:
                            (v) {
                          if (v ==
                              null) {
                            return;
                          }

                          setState(() {
                            interestType =
                                v;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ==================================================
                      // INTEREST FREQUENCY
                      // ==================================================

                      Align(
                        alignment:
                        Alignment
                            .centerLeft,
                        child:
                        title(
                          "Interest Frequency",
                        ),
                      ),

                      DropdownButtonFormField<
                          String>(
                        initialValue:
                        interestFrequency,
                        decoration:
                        decoration(),
                        icon:
                        const Icon(
                          Icons
                              .keyboard_arrow_down,
                        ),
                        items:
                        const [
                          DropdownMenuItem(
                            value:
                            "Daily",
                            child:
                            Text(
                              "Daily",
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                            "Weekly",
                            child:
                            Text(
                              "Weekly",
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                            "Monthly",
                            child:
                            Text(
                              "Monthly",
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                            "Yearly",
                            child:
                            Text(
                              "Yearly",
                            ),
                          ),
                        ],
                        onChanged:
                            (v) {
                          if (v ==
                              null) {
                            return;
                          }

                          setState(() {
                            interestFrequency =
                                v;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ==================================================
                      // PAYMENT MODE
                      // ==================================================

                      Align(
                        alignment:
                        Alignment
                            .centerLeft,
                        child:
                        title(
                          "Payment Mode (Optional)",
                        ),
                      ),

                      DropdownButtonFormField<
                          String>(
                        initialValue:
                        paymentMode
                            .isEmpty
                            ? null
                            : paymentMode,

                        decoration:
                        decoration(
                          hint:
                          "Select Payment Mode",
                        ),

                        icon:
                        const Icon(
                          Icons
                              .keyboard_arrow_down,
                        ),

                        items:
                        const [
                          DropdownMenuItem(
                            value:
                            "Cash",
                            child:
                            Text(
                              "Cash",
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                            "UPI",
                            child:
                            Text(
                              "UPI",
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                            "Bank",
                            child:
                            Text(
                              "Bank Transfer",
                            ),
                          ),
                        ],

                        onChanged:
                            (v) {
                          if (v ==
                              null) {
                            setState(() {
                              paymentMode =
                              "";
                            });
                            return;
                          }

                          setState(() {
                            paymentMode =
                                v;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // ==================================================
                      // CONTACT SUPPORT
                      // ==================================================

                      _buildContactBox(),

                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),

              // ==========================================================
              // FIXED BUTTONS
              // ==========================================================

              Container(
                padding:
                const EdgeInsets.fromLTRB(
                  22,
                  12,
                  22,
                  20,
                ),

                decoration:
                const BoxDecoration(
                  color:
                  Color(0xffFFF8F0),
                ),

                child: Row(
                  children: [
                    // ====================================================
                    // CANCEL
                    // ====================================================

                    Expanded(
                      child:
                      SizedBox(
                        height: 52,
                        child:
                        OutlinedButton(
                          onPressed:
                              () {
                            FocusScope
                                .of(
                              context,
                            ).unfocus();

                            Navigator.pop(
                              context,
                            );
                          },

                          style:
                          OutlinedButton
                              .styleFrom(
                            side:
                            const BorderSide(
                              color:
                              Color(
                                0xffC7D0DF,
                              ),
                            ),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                12,
                              ),
                            ),
                          ),

                          child:
                          const Text(
                            "Cancel",
                            style:
                            TextStyle(
                              color:
                              Color(
                                0xff29406B,
                              ),
                              fontWeight:
                              FontWeight
                                  .w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 18,
                    ),

                    // ====================================================
                    // SAVE ENTRY
                    // ====================================================

                    Expanded(
                      child:
                      SizedBox(
                        height: 52,
                        child:
                        ElevatedButton(
                          onPressed:
                          _saveEntry,

                          style:
                          ElevatedButton
                              .styleFrom(
                            backgroundColor:
                            const Color(
                              0xff29406B,
                            ),
                            elevation: 0,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                12,
                              ),
                            ),
                          ),

                          child:
                          const Text(
                            "Save Entry",
                            style:
                            TextStyle(
                              color:
                              Colors.white,
                              fontWeight:
                              FontWeight
                                  .w700,
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

  // ============================================================
  // INTEREST RATE FIELD
  // ============================================================

  Widget _buildInterestRateField() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        TextField(
          controller:
          interestController,
          focusNode:
          _interestFocusNode,

          keyboardType:
          const TextInputType
              .numberWithOptions(
            decimal: true,
          ),

          onChanged:
              (value) {
            if (_interestRateError &&
                value.trim().isNotEmpty) {
              setState(() {
                _interestRateError =
                false;
              });
            }

            setState(() {});
          },

          decoration:
          decoration(
            hint:
            "Enter Interest rate",
          ).copyWith(
            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                12,
              ),
              borderSide:
              BorderSide(
                color:
                _interestRateError
                    ? Colors.red
                    : const Color(
                  0xffC9D2E3,
                ),
              ),
            ),

            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                12,
              ),
              borderSide:
              BorderSide(
                color:
                _interestRateError
                    ? Colors.red
                    : const Color(
                  0xff29406B,
                ),
                width: 1.3,
              ),
            ),
          ),
        ),

        // ==========================================================
        // ERROR MESSAGE
        // ==========================================================

        if (_interestRateError)
          Padding(
            padding:
            const EdgeInsets.only(
              left: 4,
              top: 5,
            ),
            child: Text(
              "Interest rate is required",
              style:
              GoogleFonts.manrope(
                color:
                Colors.red,
                fontSize: 12,
                fontWeight:
                FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // CONTACT BOX
  // ============================================================

  Widget _buildContactBox() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration:
      BoxDecoration(
        color:
        const Color(0xFFFEE0C9),
        borderRadius:
        BorderRadius.circular(8),
        border:
        Border.all(
          color:
          const Color.fromRGBO(
            177,
            95,
            39,
            0.23,
          ),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline,
            size: 16,
            color:
            Color(0xFFC74C4C),
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  "If you have any questions, feel free to contact us at",
                  style:
                  GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    const Color(
                      0xFF223A5E,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  "chopdi@geloratech.com",
                  style:
                  GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    const Color(
                      0xFFC74C4C,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAVE ENTRY
  // ============================================================

  Future<void> _saveEntry() async {
    // ==========================================================
    // AMOUNT VALIDATION
    // ==========================================================

    if (amountController.text
        .trim()
        .isEmpty) {
      setState(() {
        _amountError = true;
      });

      _amountFocusNode.requestFocus();
      _scrollToField(_amountKey);

      return;
    }

    final amount =
    double.tryParse(
      amountController.text.trim(),
    );

    if (amount == null ||
        amount <= 0) {
      _showError(
        "Please enter a valid amount",
      );

      return;
    }

    // ==========================================================
    // INTEREST RATE REQUIRED VALIDATION
    // ==========================================================

    if (interestController.text
        .trim()
        .isEmpty) {
      setState(() {
        _interestRateError =
        true;
      });

      _interestFocusNode
          .requestFocus();

      _scrollToField(
        _interestKey,
      );

      return;
    }

    // ==========================================================
    // INTEREST RATE NUMBER VALIDATION
    // ==========================================================

    final rate =
    double.tryParse(
      interestController.text
          .trim(),
    );

    if (rate == null ||
        rate < 0) {
      setState(() {
        _interestRateError =
        true;
      });

      _interestFocusNode
          .requestFocus();

      _scrollToField(
        _interestKey,
      );

      return;
    }

    try {
      // ========================================================
      // CALCULATE INTEREST
      // ========================================================

      final calculatedInterest =
      InterestCalculator.calculate(
        principal: amount,
        rate: rate,
        startDate: selectedDate,
        interestType:
        interestType,
        frequency:
        interestFrequency,
      );

      // ========================================================
      // CREATE TRANSACTION
      // ========================================================

      final tx =
      Transaction()
        ..customerId =
            widget.customer.id
        ..amountPaise =
        Money.toPaise(
          amount,
        )
        ..interest =
            calculatedInterest
        ..interestRateBp =
        Money
            .rateToBasisPoints(
          rate,
        )
        ..date =
            selectedDate
        ..type =
            TransactionType.gave
        ..description =
        descriptionController
            .text
            .trim()
        ..paymentMode =
            paymentMode
        ..interestType =
            interestType
        ..interestFrequency =
            interestFrequency;

      // ========================================================
      // SAVE TRANSACTION
      // ========================================================

      await TransactionService
          .addTransaction(tx);

      // ========================================================
      // SYNC NOTIFICATIONS
      // ========================================================

      await LocalNotificationService
          .instance
          .syncNotifications(
        database:
        IsarService.isar,
      );

      // ========================================================
      // PAYMENT REMINDER
      // ========================================================

      final localNotificationService =
          LocalNotificationService
              .instance;

      final prefs =
      await SharedPreferences
          .getInstance();

      final paymentReminderEnabled =
          prefs.getBool(
            'notification_payment_reminder_enabled',
          ) ??
              true;

      if (paymentReminderEnabled) {
        final reminderType =
            prefs.getString(
              'notification_selected_reminder',
            ) ??
                'dueDate';

        await localNotificationService
            .scheduleCustomerPaymentReminder(
          customer:
          widget.customer,
          loanDate:
          selectedDate,
          interestFrequency:
          interestFrequency,
          reminderType:
          reminderType,
          amount:
          amount,
        );
      }

      // ========================================================
      // INTEREST NOTIFICATION
      // ========================================================

      if (calculatedInterest >
          0) {
        final notificationService =
        NotificationService(
          IsarService.isar,
        );

        await notificationService
            .createInterestNotification(
          chopdiId:
          widget.customer.chopdiId,
          customerName:
          widget.customer.name,
          interestAmount:
          calculatedInterest,
          customerId:
          widget.customer.id,
        );
      }

      // ========================================================
      // SUCCESS
      // ========================================================

      widget.onSaved();

      if (mounted) {
        FocusScope.of(context)
            .unfocus();

        Navigator.pop(
          context,
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      final message =
      e.toString().contains(
        'Cannot add an entry to a deleted customer',
      )
          ? 'This customer has been deleted. You cannot add a new entry.'
          : 'Unable to save the transaction. Please try again.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
          Text(message),
          behavior:
          SnackBarBehavior
              .floating,
        ),
      );
    }
  }

  // ============================================================
  // ERROR SNACKBAR
  // ============================================================

  void _showError(
      String message,
      ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
        Text(message),
        behavior:
        SnackBarBehavior
            .floating,
      ),
    );
  }
}