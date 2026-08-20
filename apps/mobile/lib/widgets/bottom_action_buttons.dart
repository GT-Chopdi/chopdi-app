import 'package:flutter/material.dart';

class BottomActionButtons extends StatefulWidget {
  final VoidCallback? onYouGave;
  final VoidCallback? onYouGot;

  const BottomActionButtons({
    super.key,
    this.onYouGave,
    this.onYouGot,
  });

  @override
  State<BottomActionButtons> createState() =>
      _BottomActionButtonsState();
}

class _BottomActionButtonsState
    extends State<BottomActionButtons> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: Color(0xffFFF8F0),
          border: Border(
            top: BorderSide(
              color: Color(0xffE5DED3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: widget.onYouGave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffF25B42),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(
                    Icons.arrow_upward,
                    size: 20,
                  ),
                  label: const Text(
                    "You Gave",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: widget.onYouGot,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff22A45D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(
                    Icons.arrow_downward,
                    size: 20,
                  ),
                  label: const Text(
                    "You Got",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}