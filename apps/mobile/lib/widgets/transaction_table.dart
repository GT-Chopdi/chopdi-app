import 'package:flutter/material.dart';
import 'package:mychopdi/utils/app_colors.dart';

class TransactionTable extends StatelessWidget {
  const TransactionTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 248, 240, 1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [

          /// Header
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 248, 240, 1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: const Row(
              children: [

                _HeaderCell("Date", flex: 2),

                VerticalDivider(width: 1),

                _HeaderCell("Given"),

                VerticalDivider(width: 1),

                _HeaderCell("Received"),

                VerticalDivider(width: 1),

                _HeaderCell("Balance"),
              ],
            ),
          ),

          _row(
            date: "10 May 2026",
            given: "₹15,000",
            givenSub: "Loan Given",
            received: "-",
            receivedSub: "",
            balance: "₹15,000",
          ),

          _divider(),

          _row(
            date: "18 May 2026",
            given: "-",
            givenSub: "",
            received: "₹1,000",
            receivedSub: "Payment Received",
            balance: "₹14,000",
          ),

          _divider(),

          _row(
            date: "20 May 2026",
            given: "-",
            givenSub: "",
            received: "₹150",
            receivedSub: "Interest Added",
            balance: "₹14,150",
          ),

          _divider(),

          _row(
            date: "25 May 2026",
            given: "-",
            givenSub: "",
            received: "₹2,000",
            receivedSub: "Payment Received",
            balance: "₹12,150",
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _row({
    required String date,
    required String given,
    required String givenSub,
    required String received,
    required String receivedSub,
    required String balance,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [

          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                date,
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),

          VerticalDivider(width: 1, color: Colors.grey.shade300),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [

                  Text(
                    given,
                    style: TextStyle(
                      color: given == "-"
                          ? Colors.black
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),

                  if (givenSub.isNotEmpty)
                    Text(
                      givenSub,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ),

          VerticalDivider(width: 1, color: Colors.grey.shade300),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [

                  Text(
                    received,
                    style: TextStyle(
                      color: received == "-"
                          ? Colors.black
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),

                  if (receivedSub.isNotEmpty)
                    Text(
                      receivedSub,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ),

          VerticalDivider(width: 1, color: Colors.grey.shade300),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                balance,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String title;
  final int flex;

  const _HeaderCell(
    this.title, {
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: ChopdiColors.navy,
          ),
        ),
      ),
    );
  }
}