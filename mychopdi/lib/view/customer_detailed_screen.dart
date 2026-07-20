import 'package:flutter/material.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String customerName;
  final String phoneNumber;

  const CustomerDetailScreen({
    super.key,
    required this.customerName,
    required this.phoneNumber,
  });

  @override
  State<CustomerDetailScreen> createState() =>
      _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  static const Color primaryColor = Color(0xFF223A5E);
  static const Color giveColor = Colors.red;
  static const Color getColor = Colors.green;

  List<Map<String, dynamic>> transactions = [
    {
      "type": "Get",
      "amount": 500,
      "date": "20 Jul 2026",
    },
    {
      "type": "Give",
      "amount": 200,
      "date": "18 Jul 2026",
    },
  ];

  double getTotal() {
    double total = 0;

    for (var item in transactions) {
      if (item["type"] == "Get") {
        total += item["amount"];
      }
    }

    return total;
  }

  double giveTotal() {
    double total = 0;

    for (var item in transactions) {
      if (item["type"] == "Give") {
        total += item["amount"];
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    double balance = getTotal() - giveTotal();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(widget.customerName),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),

      body: Column(
        children: [

          Container(
            color: primaryColor,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Text(
                    widget.customerName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  widget.phoneNumber,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 20),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                      children: [

                        Column(
                          children: [
                            const Text("You Will Give"),
                            const SizedBox(height: 8),
                            Text(
                              "₹ ${giveTotal()}",
                              style: const TextStyle(
                                color: giveColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),

                        Container(
                          width: 1,
                          height: 50,
                          color: Colors.grey.shade300,
                        ),

                        Column(
                          children: [
                            const Text("You Will Get"),
                            const SizedBox(height: 8),
                            Text(
                              "₹ ${getTotal()}",
                              style: const TextStyle(
                                color: getColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  balance >= 0
                      ? "Balance : ₹ $balance"
                      : "Balance : -₹ ${balance.abs()}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Text("No Transactions"),
                  )
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final item = transactions[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                item["type"] == "Get"
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                            child: Icon(
                              item["type"] == "Get"
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: item["type"] == "Get"
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          title: Text(item["type"]),
                          subtitle: Text(item["date"]),
                          trailing: Text(
                            "₹ ${item["amount"]}",
                            style: TextStyle(
                              color: item["type"] == "Get"
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [

              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: giveColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                  ),
                  onPressed: () {
                    // Open Give Transaction Screen
                  },
                  child: const Text(
                    "GIVE",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                  ),
                  onPressed: () {
                    // Open Get Transaction Screen
                  },
                  child: const Text(
                    "GET",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}