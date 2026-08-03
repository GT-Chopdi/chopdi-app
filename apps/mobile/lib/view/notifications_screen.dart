import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mychopdi/utils/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF3E2),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [

              const SizedBox(height: 18),

              Row(
                children: [

                  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: ChopdiColors.navy,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Text(
                    "Notifications",
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ChopdiColors.navy,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _notificationTile(
                icon: Icons.collections_bookmark,
                iconColor: Colors.red,
                title: "Collection Reminder",
                subtitle: "You have 3 collections\ndue today.",
                time: "2 mins ago",
              ),

              const SizedBox(height: 12),

              _notificationTile(
                icon: Icons.notifications_none,
                iconColor: Colors.red,
                title: "Payment Pending",
                subtitle:
                    "Khushi's payment of ₹8,500 is\npending since 5 days.",
                time: "15 mins ago",
              ),

              const SizedBox(height: 12),

              _notificationTile(
                icon: Icons.calendar_today,
                iconColor: Colors.red,
                title: "Payment Due Tomorrow",
                subtitle:
                    "Dada's payment of ₹6,000 is due\ntomorrow.",
                time: "Yesterday,\n4:15 PM",
              ),

              const SizedBox(height: 12),

              _notificationTile(
                icon: Icons.download,
                iconColor: Colors.blue,
                title: "App Update",
                subtitle:
                    "A new version of Chopdi\nis available.",
                time: "2 days ago",
              ),

              const SizedBox(height: 60),

              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(170, 185, 207, 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.transparent,
                      child: Image.asset('assets/notifications.png')
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            "Notifications Off",
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: ChopdiColors.navy,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            "Turn on notifications to receive payment due reminders and collection alerts.",
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              color: ChopdiColors.navy,
                            ),
                          ),
                        ],
                      ),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ChopdiColors.navy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},

                      child: const Text(
                        "Enable Notifications",
                        style: TextStyle(
                          color: Color(0xFFFDEDD9),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notificationTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [

          CircleAvatar(
            radius: 22,
            backgroundColor: iconColor.withValues(alpha: .15),
            child: Image.asset('assets/notifications.png'),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: ChopdiColors.navy,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: ChopdiColors.navy,
                  ),
                ),
              ],
            ),
          ),

          Text(
            time,
            textAlign: TextAlign.right,
            style: GoogleFonts.manrope(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}