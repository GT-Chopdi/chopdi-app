import 'package:flutter/material.dart';

class SortBottomSheet extends StatefulWidget {
  const SortBottomSheet({super.key});

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  String selectedSort = "Name (A-Z)";

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: .72,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: const BoxDecoration(
          color: Color(0xffFFF8F0),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [

            /// Drag Handle
            Container(
              width: 56,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xff8B857E),
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 22),

            Row(
              children: const [

                Icon(
                  Icons.swap_vert,
                  color: Color(0xff64748B),
                  size: 18,
                ),

                SizedBox(width: 8),

                Text(
                  "Sort By",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff64748B),
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),

            const SizedBox(height: 14),

            Expanded(
              child: ListView(
                children: [

                  _sortTile(
                    title: "Name (A-Z)",
                    icon: Icons.sort_by_alpha,
                  ),

                  const SizedBox(height: 10),

                  _sortTile(
                    title: "Name (Z-A)",
                    icon: Icons.sort_by_alpha,
                  ),

                  const SizedBox(height: 10),

                  _sortTile(
                    title: "Loan Amount (High to Low)",
                    icon: Icons.currency_rupee,
                    arrowDown: true,
                  ),

                  const SizedBox(height: 10),

                  _sortTile(
                    title: "Loan Amount (Low to High)",
                    icon: Icons.currency_rupee,
                    arrowDown: false,
                  ),

                  const SizedBox(height: 10),

                  _sortTile(
                    title: "Recently Added",
                    icon: Icons.access_time_outlined,
                  ),
                ],
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Color(0xff223A5E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _sortTile({
    required String title,
    required IconData icon,
    bool arrowDown = true,
  }) {
    bool selected = selectedSort == title;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          selectedSort = title;
        });

        Navigator.pop(context, title);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xffCBD5E1),
          ),
        ),
        child: Row(
          children: [

            /// Radio Button
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? const Color(0xff223A5E)
                      : const Color(0xffC8D1DE),
                  width: 1.5,
                ),
                color: selected
                    ? const Color(0xff223A5E)
                    : Colors.white,
              ),
              child: selected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xff223A5E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            if (title.contains("Name"))
              const Text(
                "↓A\nZ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff223A5E),
                  fontWeight: FontWeight.bold,
                  height: 0.8,
                ),
              ),

            if (title.contains("High"))
              const Row(
                children: [
                  Icon(Icons.currency_rupee,
                      color: Color(0xff223A5E)),
                  Icon(Icons.arrow_downward,
                      size: 18,
                      color: Color(0xff223A5E)),
                ],
              ),

            if (title.contains("Low"))
              const Row(
                children: [
                  Icon(Icons.currency_rupee,
                      color: Color(0xff223A5E)),
                  Icon(Icons.arrow_upward,
                      size: 18,
                      color: Color(0xff223A5E)),
                ],
              ),

            if (title == "Recently Added")
              const Icon(
                Icons.access_time_outlined,
                color: Color(0xff223A5E),
              ),
          ],
        ),
      ),
    );
  }
}