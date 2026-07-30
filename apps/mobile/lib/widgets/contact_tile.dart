import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback? onTap;

  const ContactTile({
    super.key,
    required this.name,
    required this.phone,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            child: Row(
              children: [
                /// Avatar
                CircleAvatar(
                  radius: 19,
                  backgroundColor: const Color(0xffC6CEDC),
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xff223A5E),
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                /// Name & Number
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff223A5E),
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        phone,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff58677D),
                        ),
                      ),
                    ],
                  ),
                ),

                InkWell(
                  onTap: onTap,
                  child: const Icon(
                    Icons.chevron_right,
                    size: 28,
                    color: Color(0xff223A5E),
                  ),
                ),
              ],
            ),
          ),

          /// Divider
          const Padding(
            padding: EdgeInsets.only(left: 64),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Color(0xffD5D9E3),
            ),
          ),
        ],
      ),
    );
  }
}