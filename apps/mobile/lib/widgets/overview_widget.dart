import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/l10n/app_localizations.dart';

class OverviewWidget extends StatelessWidget {
  const OverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 248, 240, 1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC8D2E3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            Row(
              children: [
                const SizedBox(width: 17),

                Image.asset(
                  'assets/loan_summary.png',
                ),

                const SizedBox(width: 6),

                Text(
                  l10n.loanSummary,
                  style: GoogleFonts.roboto(
                    color: const Color.fromRGBO(34, 58, 94, 1),
                  ),
                ),
              ],
            ),

            _buildRow(
              left: _tile(
                Icons.calendar_today_outlined,
                l10n.loanGivenOn,
                "10 May 2026",
              ),
              right: _tile(
                Icons.account_balance_wallet_outlined,
                l10n.loanType,
                l10n.iGaveLoan,
              ),
            ),

            _divider(),

            _buildRow(
              left: _tile(
                Icons.percent,
                l10n.interestType,
                l10n.simpleInterest,
              ),
              right: _tile(
                Icons.sync,
                l10n.interestFrequency,
                l10n.monthly,
              ),
            ),

            _divider(),

            _buildRow(
              left: _tile(
                Icons.hourglass_empty,
                l10n.loanDuration,
                "12 Months",
              ),
              right: _tile(
                Icons.event_note_outlined,
                l10n.lastPayment,
                "18 July 2026",
                subtitle: "(₹2,000 ${l10n.received})",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFE1E7F0),
    );
  }

  Widget _buildRow({
    required Widget left,
    required Widget right,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: left,
          ),

          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: Color(0xFFE1E7F0),
          ),

          Expanded(
            child: right,
          ),
        ],
      ),
    );
  }

  Widget _tile(
      IconData icon,
      String title,
      String value, {
        String? subtitle,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FD),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: const Color(0xFF456AA6),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9AA5B5),
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF243B67),
                    height: 1.2,
                  ),
                ),

                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF9AA5B5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}