import 'package:flutter/material.dart';
import 'package:mychopdi/view/create_new_chopdi_screen.dart';
import 'package:mychopdi/view/select_customer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  static const Color primaryColor = Color(0xFF223A5E);
  static const Color secondaryColor = Color(0xFFAAB9CF);
  static const Color accentColor = Color(0xFFC74C4C);
  static const Color backgroundColor = Color(0xFFFAF8F5);

  String selectedApp = "MyChopdi";

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: backgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: InkWell(
          onTap: () {
            _showBusinessBottomSheet();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedApp,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.edit, color: Colors.white, size: 18),
            ],
          ),
        ),

        actions: [

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search,color: Colors.white),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert,color: Colors.white),
          ),

        ],
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 15),

            const Text(
              "Welcome!!!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Manage your daily loan records easily.",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 50),

            Expanded(

              child: Center(

                child: Column(

                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [

                    CircleAvatar(
                      radius: 50,
                      backgroundColor: secondaryColor.withValues(alpha: .35),
                      child: const Icon(
                        Icons.receipt_long,
                        size: 50,
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "No Entries Yet",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Tap the Add Customers button\nand start recording loans.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.person_add),
        label: const Text(
          "Add Customer",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SelectCustomerScreen(),
            ),
          );
        }
      ),
    );
  }

  Future<void> _showCreateNameDialog() async {

    TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(

          title: const Text("Create App Name"),

          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Enter app name",
              border: OutlineInputBorder(),
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _showBusinessBottomSheet() {
    final TextEditingController controller =
        TextEditingController(text: selectedApp);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Edit Business Name",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedApp = controller.text;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "SAVE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Center(
                child: InkWell(
                  onTap: () async {

                    Navigator.pop(context);

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateChopdiScreen(),
                      ),
                    );

                    if (result != null) {
                      setState(() {
                        selectedApp = result;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Choose another chopdi",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
