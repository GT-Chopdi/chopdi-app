import 'package:flutter/material.dart';
import 'package:mychopdi/widgets/create_new_chopdi.dart';

class CreatedChopdiBottomSheet extends StatelessWidget {
  final BuildContext parentContext;

  const CreatedChopdiBottomSheet({
    super.key,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      decoration: const BoxDecoration(
        color: Color(0xffFFF6EC),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [

          const SizedBox(height: 20),

          const Text("Current Chopdi"),

          const Spacer(),

          ElevatedButton.icon(
            onPressed: () async {

              Navigator.pop(context);

              await Future.delayed(
                const Duration(milliseconds: 250),
              );

              showModalBottomSheet(
                context: parentContext,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => CreateChopdiBottomSheet(
                  parentContext: context,
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text("Add New Chopdi"),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}