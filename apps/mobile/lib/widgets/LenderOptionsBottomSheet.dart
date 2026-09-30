import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mychopdi/model/lender.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/widgets/summary_tile.dart';
import 'package:mychopdi/data/repository/repositories.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart'
    show rootBundle, SystemUiOverlayStyle, FilteringTextInputFormatter;
import 'package:printing/printing.dart';
import 'package:mychopdi/l10n/app_localizations.dart';

class LenderOptionsBottomSheet extends StatelessWidget {
  const LenderOptionsBottomSheet({
    super.key,
    required this.onEdit,
    required this.onSummary,
    required this.onExport,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onSummary;
  final VoidCallback onExport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 55,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Lender Options", // Fallback if l10n.lenderOptions doesn't exist yet
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: const Color.fromRGBO(34, 58, 94, 0.62),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _OptionTile(
              image: 'assets/edit_customer_logo.png',
              title: "Edit Lender",
              subtitle: l10n.editNamePhoneOrLoanDetails,
              onTap: onEdit,
            ),
            const SizedBox(height: 10),
            _OptionTile(
              image: 'assets/summary.png',
              title: l10n.accountSummary,
              subtitle: l10n.overviewAndSummary,
              onTap: onSummary,
            ),
            const SizedBox(height: 10),
            _OptionTile(
              image: 'assets/export_pdf.png',
              title: l10n.exportPdf,
              subtitle: l10n.downloadLedgerAsPdf,
              onTap: onExport,
            ),
            const SizedBox(height: 10),
            _OptionTile(
              image: 'assets/delete_logo.png',
              title: "Delete Lender",
              subtitle: "Delete lender permanently",
              titleColor: Colors.red,
              onTap: onDelete,
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: GoogleFonts.manrope(
                  color: ChopdiColors.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor = ChopdiColors.navy,
  });

  final String image;
  final String title;
  final String subtitle;
  final Color titleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 248, 240, 1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color.fromRGBO(170, 185, 207, 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 34,
              width: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(255, 248, 240, 1),
              ),
              child: Center(
                child: Image.asset(
                  image,
                  height: 18,
                  width: 18,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: const Color.fromRGBO(34, 58, 94, 0.86),
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(
              "assets/right_arrow.png",
              width: 18,
              height: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class EditLenderBottomSheet extends StatefulWidget {
  final Lender lender;
  final VoidCallback onSaved;

  const EditLenderBottomSheet({
    super.key,
    required this.lender,
    required this.onSaved,
  });

  @override
  State<EditLenderBottomSheet> createState() => _EditLenderBottomSheetState();
}

class _EditLenderBottomSheetState extends State<EditLenderBottomSheet> {
  late TextEditingController nameController;
  late TextEditingController phoneController;

  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.lender.name);

    final existingPhone = widget.lender.phone.trim();
    String phoneDigits = existingPhone;

    if (phoneDigits.startsWith('+91')) {
      phoneDigits = phoneDigits.substring(3);
    } else if (phoneDigits.startsWith('91') && phoneDigits.length == 12) {
      phoneDigits = phoneDigits.substring(2);
    }

    phoneController = TextEditingController(text: phoneDigits);
    phoneController.addListener(_phoneChanged);
  }

  void _phoneChanged() {
    final digitsOnly = phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limitedDigits = digitsOnly.length > 10 ? digitsOnly.substring(0, 10) : digitsOnly;

    if (phoneController.text != limitedDigits) {
      phoneController.value = TextEditingValue(
        text: limitedDigits,
        selection: TextSelection.collapsed(offset: limitedDigits.length),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    phoneController.removeListener(_phoneChanged);
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color.fromRGBO(255, 248, 240, 1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xff2F477A)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      errorStyle: GoogleFonts.manrope(fontSize: 11, color: Colors.red),
    );
  }

  String? _phoneValidator(String? value) {
    final l10n = AppLocalizations.of(context);
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return l10n.phoneNumberRequired;
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) return l10n.onlyNumbersAllowed;
    if (phone.length != 10) return l10n.enterValid10DigitPhone;
    return null;
  }

  bool get _isPhoneValid {
    final phone = phoneController.text.trim();
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    if (!_isPhoneValid) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final phone = phoneController.text.trim();
      final fullPhoneNumber = '+91$phone';

      await Repositories.lenders.update(
        widget.lender,
        name: nameController.text.trim(),
        phone: fullPhoneNumber,
      );

      if (!mounted) return;
      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(255, 248, 240, 1),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 55,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: const Color(0xffEAF2FF),
                    child: const Icon(Icons.edit, size: 32, color: Color(0xff2F477A)),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    "Edit Lender Details",
                    style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  "Name",
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                    color: const Color.fromRGBO(34, 58, 94, 0.62),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: inputDecoration("Lender Name"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return "Lender name is required";
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                Text(
                  "Phone Number",
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                    color: const Color.fromRGBO(34, 58, 94, 0.62),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 248, 240, 1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        "+91",
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ChopdiColors.navy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        maxLength: 10,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: inputDecoration("Mobile Number").copyWith(counterText: ""),
                        validator: _phoneValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(55),
                          side: const BorderSide(color: Color(0xff2F477A)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _isSaving ? null : () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Color(0xff2F477A), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ChopdiColors.navy,
                          disabledBackgroundColor: Colors.grey.shade400,
                          minimumSize: const Size.fromHeight(55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: (_isPhoneValid && !_isSaving) ? _saveChanges : null,
                        child: _isSaving
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Text(
                          "Save Changes",
                          style: TextStyle(color: ChopdiColors.cream, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AccountSummaryBottomSheet extends StatelessWidget {
  final double totalGiven;
  final double totalOutstanding;
  final double totalInterest;
  final Transaction? lastPayment;
  final Transaction? firstLoan;

  const AccountSummaryBottomSheet({
    super.key,
    required this.totalGiven,
    required this.totalOutstanding,
    required this.totalInterest,
    required this.lastPayment,
    required this.firstLoan,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xffFFF8F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 55,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xffDCE4F2),
              child: const Icon(
                Icons.fact_check_outlined,
                size: 30,
                color: Color(0xff3564A8),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.accountSummary,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xff223A5E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Overview of Account",
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: const Color(0xff6E7A8A),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            SummaryTile(
              icon: Icons.account_balance_wallet_outlined,
              title: l10n.totalAmountGiven,
              value: "₹${totalGiven.toStringAsFixed(0)}",
              valueColor: const Color(0xff223A5E),
            ),
            SummaryTile(
              icon: Icons.location_on_outlined,
              title: l10n.currentOutstanding,
              value: "₹${totalOutstanding.toStringAsFixed(0)}",
              valueColor: Colors.red,
            ),
            SummaryTile(
              icon: Icons.percent,
              title: l10n.totalInterest,
              value: "₹${totalInterest.toStringAsFixed(0)}",
              valueColor: Colors.green,
            ),
            SummaryTile(
              icon: Icons.calendar_month_outlined,
              title: l10n.lastPayment,
              value: lastPayment == null
                  ? "-"
                  : DateFormat("dd MMM yyyy").format(lastPayment!.date),
              subtitle: lastPayment == null
                  ? null
                  : "(₹${lastPayment!.amount.toStringAsFixed(0)} received)",
              valueColor: const Color(0xff223A5E),
            ),
            SummaryTile(
              icon: Icons.calendar_today_outlined,
              title: "Loan Given On",
              value: firstLoan == null
                  ? "-"
                  : DateFormat("dd MMM yyyy").format(firstLoan!.date),
              valueColor: const Color(0xff223A5E),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class ExportLenderPdfBottomSheet extends StatelessWidget {
  final List<Transaction> transactions;
  final bool isTookLoan;
  final Lender lender;

  const ExportLenderPdfBottomSheet({
    super.key,
    required this.lender,
    required this.transactions,
    this.isTookLoan = false,
  });

  double calculateInterest(Transaction tx) {
    final days = DateTime.now().difference(tx.date).inDays;
    double time;
    if (tx.interestFrequency == "Monthly") {
      time = days / 30;
    } else {
      time = days / 365;
    }
    if (tx.interestType == "Simple Interest") {
      return tx.amount * tx.interestRate * time / 100;
    }
    return tx.amount * (pow(1 + tx.interestRate / 100, time) - 1);
  }

  String transactionTypeText(TransactionType type) {
    switch (type) {
      case TransactionType.gave:
        return "Given";
      case TransactionType.received:
        return "Received";
      case TransactionType.took:
        return "Took";
      case TransactionType.paid:
        return "Paid";
    }
  }

  double get totalGiven => transactions
      .where((tx) => tx.type == TransactionType.gave)
      .fold<double>(0, (sum, tx) => sum + tx.amount);

  double get totalReceived => transactions
      .where((tx) => tx.type == TransactionType.received)
      .fold<double>(0, (sum, tx) => sum + tx.amount);

  double get totalTook => transactions
      .where((tx) => tx.type == TransactionType.took)
      .fold<double>(0, (sum, tx) => sum + tx.amount);

  double get totalPaid => transactions
      .where((tx) => tx.type == TransactionType.paid)
      .fold<double>(0, (sum, tx) => sum + tx.amount);

  double get totalInterest {
    final interestTransactions = isTookLoan
        ? transactions.where((tx) => tx.type == TransactionType.took)
        : transactions.where((tx) => tx.type == TransactionType.gave);
    return interestTransactions.fold<double>(0, (sum, tx) => sum + calculateInterest(tx));
  }

  double get pdfPrincipal => isTookLoan ? totalTook : totalGiven;
  double get pdfPaid => isTookLoan ? totalPaid : totalReceived;
  double get pdfOutstanding => (pdfPrincipal + totalInterest - pdfPaid).clamp(0.0, double.infinity);
  double get outstanding => pdfOutstanding;

  String money(double value) {
    final formatter = NumberFormat("#,##0.00");
    return "\u20B9${formatter.format(value)}";
  }

  Future<pw.MemoryImage> loadLogo() async {
    final logoData = await rootBundle.load("assets/app_logo.png");
    return pw.MemoryImage(logoData.buffer.asUint8List());
  }

  List<Transaction> get pdfTransactions {
    return transactions.where((tx) {
      if (isTookLoan) {
        return tx.type == TransactionType.took || tx.type == TransactionType.paid;
      }
      return tx.type == TransactionType.gave || tx.type == TransactionType.received;
    }).toList();
  }

  Future<Uint8List> generatePdf() async {
    final pdf = pw.Document();
    final regularFont = await PdfGoogleFonts.notoSansDevanagariRegular();
    final boldFont = await PdfGoogleFonts.notoSansDevanagariBold();
    final logo = await loadLogo();

    final sortedTransactions = [...pdfTransactions]..sort((a, b) => b.date.compareTo(a.date));
    final generatedDate = DateFormat("dd MMM yyyy, hh:mm a").format(DateTime.now());

    const navy = PdfColor.fromInt(0xff223A5E);
    const blue = PdfColor.fromInt(0xff2F5D9F);
    const lightBlue = PdfColor.fromInt(0xffEEF5FC);
    const cream = PdfColor.fromInt(0xffFFF8F0);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        margin: const pw.EdgeInsets.fromLTRB(38, 30, 38, 38),
        header: (context) {
          return pw.Column(
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 40,
                    height: 40,
                    decoration: pw.BoxDecoration(color: lightBlue, borderRadius: pw.BorderRadius.circular(10)),
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Image(logo, fit: pw.BoxFit.contain),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Chopdi", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: navy)),
                      pw.SizedBox(height: 2),
                      pw.Text("Your trusted digital ledger", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: pw.BoxDecoration(color: lightBlue, borderRadius: pw.BorderRadius.circular(7)),
                    child: pw.Text("ACCOUNT STATEMENT", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: navy)),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Container(height: 2, width: double.infinity, color: blue),
            ],
          );
        },
        footer: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 10),
            decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300))),
            child: pw.Row(
              children: [
                pw.Text("Generated by Chopdi", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                pw.SizedBox(width: 5),
                pw.Text("•", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey400)),
                pw.SizedBox(width: 5),
                pw.Text(generatedDate, style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                pw.Spacer(),
                pw.Text("Page ${context.pageNumber} of ${context.pagesCount}", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
              ],
            ),
          );
        },
        build: (context) {
          return [
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    isTookLoan ? "Took Loan Statement" : "Lender Statement",
                    style: pw.TextStyle(fontSize: 21, fontWeight: pw.FontWeight.bold, color: navy),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    isTookLoan ? "Loan summary and repayment history" : "Account summary and transaction history",
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey500),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    "As of ${DateFormat("dd MMM yyyy, hh:mm a").format(DateTime.now())}",
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.blueGrey500),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 22),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: lightBlue,
                borderRadius: pw.BorderRadius.circular(14),
                border: pw.Border.all(color: const PdfColor.fromInt(0xffD6E5F5)),
              ),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 52,
                    height: 52,
                    decoration: pw.BoxDecoration(color: navy, borderRadius: pw.BorderRadius.circular(26)),
                    child: pw.Center(
                      child: pw.Text(
                        lender.name.isNotEmpty ? lender.name[0].toUpperCase() : "?",
                        style: pw.TextStyle(fontSize: 21, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 14),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(lender.name, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: navy)),
                        pw.SizedBox(height: 5),
                        pw.Text(lender.phone, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                        pw.SizedBox(height: 5),
                        pw.Text("${transactions.length} transaction${transactions.length == 1 ? '' : 's'}", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("CURRENT BALANCE", style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        money(outstanding),
                        style: pw.TextStyle(fontSize: 17, fontWeight: pw.FontWeight.bold, color: outstanding > 0 ? PdfColors.red800 : PdfColors.green800),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(outstanding > 0 ? "Outstanding" : "Settled", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 22),
            pw.Text("Account Overview", style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: navy)),
            pw.SizedBox(height: 10),
            pw.Row(
              children: [
                summaryCard(title: isTookLoan ? "YOU TOOK" : "YOU GAVE", value: money(pdfPrincipal), subtitle: isTookLoan ? "Total loan taken" : "Total given", valueColor: navy),
                pw.SizedBox(width: 9),
                summaryCard(title: isTookLoan ? "YOU PAID" : "YOU RECEIVED", value: money(pdfPaid), subtitle: isTookLoan ? "Total repaid" : "Total received", valueColor: PdfColors.green800),
                pw.SizedBox(width: 9),
                summaryCard(title: "INTEREST", value: money(totalInterest), subtitle: "Calculated interest", valueColor: PdfColors.orange800),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Row(
              children: [
                pw.Text("Transaction History", style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: navy)),
                pw.Spacer(),
                pw.Text("${transactions.length} records", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              ],
            ),
            pw.SizedBox(height: 10),
            sortedTransactions.isEmpty ? emptyTransactions() : transactionTable(sortedTransactions),
            pw.SizedBox(height: 22),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(17),
              decoration: pw.BoxDecoration(
                color: cream,
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: const PdfColor.fromInt(0xffE9D8C5)),
              ),
              child: pw.Column(
                children: [
                  pw.Row(
                    children: [
                      pw.Text("Account Summary", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: navy)),
                      pw.Spacer(),
                      pw.Text("FINAL BALANCE", style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  finalSummaryRow(isTookLoan ? "Total Taken" : "Total Given", money(pdfPrincipal)),
                  finalSummaryRow(isTookLoan ? "Total Paid" : "Total Received", money(pdfPaid)),
                  finalSummaryRow("Total Interest", money(totalInterest)),
                  pw.SizedBox(height: 6),
                  pw.Container(
                    padding: const pw.EdgeInsets.only(top: 11),
                    decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300))),
                    child: pw.Row(
                      children: [
                        pw.Text("Outstanding Balance", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: navy)),
                        pw.Spacer(),
                        pw.Text(
                          money(pdfOutstanding),
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: pdfOutstanding > 0 ? PdfColors.red800 : PdfColors.green800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 25),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(vertical: 15),
              child: pw.Column(
                children: [
                  pw.Container(
                    width: 30,
                    height: 30,
                    padding: const pw.EdgeInsets.all(4),
                    decoration: pw.BoxDecoration(color: lightBlue, borderRadius: pw.BorderRadius.circular(8)),
                    child: pw.Image(logo, fit: pw.BoxFit.contain),
                  ),
                  pw.SizedBox(height: 7),
                  pw.Text("Thank you for using Chopdi", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: navy)),
                  pw.SizedBox(height: 3),
                  pw.Text("Keep your records simple. Keep them with Chopdi.", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget summaryCard({required String title, required String value, required String subtitle, required PdfColor valueColor}) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(color: PdfColors.white, borderRadius: pw.BorderRadius.circular(10), border: pw.Border.all(color: PdfColors.grey300)),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
            pw.SizedBox(height: 7),
            pw.Text(value, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: valueColor)),
            pw.SizedBox(height: 3),
            pw.Text(subtitle, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
          ],
        ),
      ),
    );
  }

  pw.Widget transactionTable(List<Transaction> sortedTransactions) {
    return pw.Table(
      border: pw.TableBorder(
        top: const pw.BorderSide(color: PdfColors.grey300),
        bottom: const pw.BorderSide(color: PdfColors.grey300),
        horizontalInside: const pw.BorderSide(color: PdfColors.grey200),
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.35),
        1: const pw.FlexColumnWidth(1.15),
        2: const pw.FlexColumnWidth(1.35),
        3: const pw.FlexColumnWidth(1.2),
        4: const pw.FlexColumnWidth(2.0),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            tableHeader("DATE"),
            tableHeader("TYPE"),
            tableHeader("AMOUNT", align: pw.TextAlign.right),
            tableHeader("MODE"),
            tableHeader("DESCRIPTION"),
          ],
        ),
        ...sortedTransactions.map((tx) {
          return pw.TableRow(
            children: [
              tableCell(DateFormat("dd MMM yyyy").format(tx.date)),
              transactionTypeCell(tx.type),
              tableCell(money(tx.amount), align: pw.TextAlign.right, bold: true),
              tableCell(tx.paymentMode.isEmpty ? "-" : tx.paymentMode),
              tableCell(tx.description.isEmpty ? "-" : tx.description),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget emptyTransactions() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 30),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(10)),
      child: pw.Center(child: pw.Text("No transactions available", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600))),
    );
  }

  pw.Widget tableHeader(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 10),
      child: pw.Text(text, textAlign: align, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
    );
  }

  pw.Widget tableCell(String text, {pw.TextAlign align = pw.TextAlign.left, bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 11),
      child: pw.Text(text, textAlign: align, style: pw.TextStyle(fontSize: 8.5, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, color: PdfColors.grey900)),
    );
  }

  pw.Widget transactionTypeCell(TransactionType type) {
    PdfColor background;
    PdfColor textColor;
    switch (type) {
      case TransactionType.gave:
        background = PdfColors.blue50;
        textColor = PdfColors.blue900;
        break;
      case TransactionType.received:
        background = PdfColors.green50;
        textColor = PdfColors.green800;
        break;
      case TransactionType.took:
        background = PdfColors.orange50;
        textColor = PdfColors.orange800;
        break;
      case TransactionType.paid:
        background = PdfColors.red50;
        textColor = PdfColors.red800;
        break;
    }
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 7),
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: pw.BoxDecoration(color: background, borderRadius: pw.BorderRadius.circular(5)),
        child: pw.Text(transactionTypeText(type), textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: textColor)),
      ),
    );
  }

  pw.Widget finalSummaryRow(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
          pw.Spacer(),
          pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
        ],
      ),
    );
  }

  Future<void> viewPdf(BuildContext context) async {
    try {
      final bytes = await generatePdf();
      if (!context.mounted) return;
      const previewColor = Color(0xff223A5E);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text("PDF Preview", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              backgroundColor: previewColor,
              foregroundColor: Colors.white,
              elevation: 0,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: previewColor,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
            ),
            body: PdfPreview(
              build: (format) async => bytes,
              allowPrinting: true,
              allowSharing: true,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              pdfFileName: "${lender.name}_Chopdi.pdf",
              actionBarTheme: const PdfActionBarTheme(backgroundColor: previewColor, iconColor: Colors.white, elevation: 0),
            ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unable to generate PDF: $e")));
    }
  }

  Future<void> downloadPdf(BuildContext context) async {
    try {
      final bytes = await generatePdf();
      final safeName = lender.name.replaceAll(RegExp(r'[^\w\s-]'), '').trim().replaceAll(' ', '_');
      await Printing.sharePdf(bytes: bytes, filename: "${safeName.isEmpty ? 'Lender' : safeName}_Chopdi.pdf");
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unable to export PDF: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(255, 248, 240, 1),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(width: 55, height: 5, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(20))),
              const SizedBox(height: 24),
              CircleAvatar(radius: 30, backgroundColor: const Color(0xffDCE4F2), child: Image.asset("assets/export_pdf.png", width: 32, height: 32)),
              const SizedBox(height: 14),
              Text("Export PDF", style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: ChopdiColors.navy)),
              const SizedBox(height: 6),
              Text("Create a professional statement for ${lender.name}", textAlign: TextAlign.center, style: GoogleFonts.manrope(fontSize: 12, color: ChopdiColors.navy)),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xffFDEDD9), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color.fromRGBO(177, 95, 39, 0.25))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset("assets/download_warning.png", width: 26, height: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "The PDF includes ${lender.name}'s details, complete transaction history and account summary.",
                        style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: ChopdiColors.navy),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () => viewPdf(context),
                  icon: const Icon(Icons.visibility_outlined, color: ChopdiColors.navy),
                  label: Text("View PDF", style: GoogleFonts.manrope(color: ChopdiColors.navy, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: ChopdiColors.navy), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => downloadPdf(context),
                  icon: const Icon(Icons.download_outlined, color: ChopdiColors.cream),
                  label: Text("Download PDF", style: GoogleFonts.manrope(color: ChopdiColors.cream, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(backgroundColor: ChopdiColors.navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: GoogleFonts.manrope(color: ChopdiColors.navy, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeleteLenderBottomSheet extends StatefulWidget {
  final String lenderName;
  final VoidCallback onDelete;

  const DeleteLenderBottomSheet({
    super.key,
    required this.lenderName,
    required this.onDelete,
  });

  @override
  State<DeleteLenderBottomSheet> createState() =>  _DeleteLenderBottomSheetState();
}

class _DeleteLenderBottomSheetState extends State<DeleteLenderBottomSheet> {
  bool agreed = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child :Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(255, 248, 240, 1),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// Drag Handle
              Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 26),

              /// Delete Icon
              CircleAvatar(
                radius: 34,
                backgroundColor: const Color(0xffFFE7E3),
                child: Icon(
                  Icons.delete_outline,
                  size: 34,
                  color: Colors.red.shade400,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                "Delete ${widget.lenderName}?",
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ChopdiColors.navy,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "This action cannot be undone",
                style: GoogleFonts.manrope(
                  color: ChopdiColors.navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 28),

              /// Warning Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 248, 240, 1),
                  border: Border.all(
                    color: const Color(0xFFC74C4C),
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xffFFE7E3),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red.shade400,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          Text(
                            "All lender data will be permanently deleted including:",
                            style: GoogleFonts.manrope(
                              color: const Color(0xffE4554B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "• Lender Details",
                            style: GoogleFonts.manrope(
                              color: const Color(0xffE4554B),
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            "• Ledger and Transactions",
                            style: GoogleFonts.manrope(
                              color: const Color(0xffE4554B),
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            "• Notes and reminders",
                            style: GoogleFonts.manrope(
                              color: const Color(0xffE4554B),
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            "• Loan information",
                            style: GoogleFonts.manrope(
                              color: const Color(0xffE4554B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              /// Checkbox
              Material(
                color: const Color.fromRGBO(255, 248, 240, 1),
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: agreed,
                    activeColor: Colors.red,
                    checkboxShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    title: Text(
                      "I understand this action cannot be undone.",
                      style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w700,
                          color: ChopdiColors.navy,
                          fontSize: 14
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        agreed = value ?? false;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Row(
                children: [

                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize:
                        const Size.fromHeight(54),
                        side: const BorderSide(
                          color: Color(0xffF26C63),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Color(0xff2F477A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xffD5544D),
                        minimumSize:
                        const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: agreed
                          ? widget.onDelete
                          : null,
                      child: const Text(
                        "Delete Lender",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}