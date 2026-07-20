import 'package:flutter/material.dart';

class AddEntryBottomSheet extends StatefulWidget {
  const AddEntryBottomSheet({super.key});

  @override
  State<AddEntryBottomSheet> createState() => _AddEntryBottomSheetState();
}

class _AddEntryBottomSheetState extends State<AddEntryBottomSheet> {

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final amountController = TextEditingController();
  final interestController = TextEditingController();
  final descriptionController = TextEditingController();

  static const primary = Color(0xFF223A5E);
  static const secondary = Color(0xFFAAB9CF);
  static const accent = Color(0xFFC74C4C);

  @override
  Widget build(BuildContext context) {

    return DraggableScrollableSheet(
      initialChildSize: .80,
      maxChildSize: .95,
      minChildSize: .60,

      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),

          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Add New Entry",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),

                  const SizedBox(height: 25),

                  _buildField(
                    controller: nameController,
                    label: "Name",
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return "Name is required";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  _buildField(
                    controller: numberController,
                    label: "Mobile Number",
                    icon: Icons.phone,
                    keyboard: TextInputType.phone,
                    validator: (value) {

                      if(value!.isEmpty){
                        return "Number is required";
                      }

                      if(value.length != 10){
                        return "Enter valid number";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  _buildField(
                    controller: amountController,
                    label: "Amount",
                    icon: Icons.currency_rupee,
                    keyboard: TextInputType.number,
                    validator: (value) {

                      if(value!.isEmpty){
                        return "Amount required";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  _buildField(
                    controller: interestController,
                    label: "Interest %",
                    icon: Icons.percent,
                    keyboard: TextInputType.number,
                    validator: (value) {

                      if(value!.isEmpty){
                        return "Interest rate required";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  _buildField(
                    controller: descriptionController,
                    label: "Description (Optional)",
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      onPressed: () {
                        if(_formKey.currentState!.validate()){
                          // Save to Firebase
                          Navigator.pop(context);
                        }

                      },

                      child: const Text(
                        "Save Entry",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),

                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {

    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon,color: primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}