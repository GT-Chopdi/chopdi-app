import 'package:flutter/material.dart';

class CreateChopdiScreen extends StatefulWidget {
  const CreateChopdiScreen({super.key});

  @override
  State<CreateChopdiScreen> createState() => _CreateChopdiScreenState();
}

class _CreateChopdiScreenState extends State<CreateChopdiScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController businessController =
      TextEditingController();

  static const Color primary = Color(0xFF223A5E);
  static const Color secondary = Color(0xFFAAB9CF);
  static const Color accent = Color(0xFFC74C4C);
  static const Color background = Color(0xFFFAF8F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          "Create Chopdi",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {

                  /// Save Chopdi Name to Database

                  Navigator.pop(
                    context,
                    businessController.text.trim(),
                  );
                }
              },
              child: const Text(
                "CREATE",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              const SizedBox(height: 15),

              TextFormField(
                controller: businessController,

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter business name";
                  }
                  return null;
                },

                decoration: InputDecoration(

                  hintText: "Enter shop/business name",

                  prefixIcon: const Icon(
                    Icons.store_outlined,
                    color: primary,
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: primary,
                      width: 1.5,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: primary,
                      width: 2,
                    ),
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