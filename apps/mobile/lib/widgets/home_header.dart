// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:isar_community/isar.dart';
// import 'package:mychopdi/model/chopdi.dart';
// import 'package:mychopdi/utils/app_colors.dart';
// import 'package:mychopdi/view/notifications_screen.dart';
// import 'package:mychopdi/widgets/chopdi_bottom_sheet.dart';

// class HomeHeader extends StatelessWidget {
//   final Chopdi? currentChopdi;
//   final ValueChanged<Chopdi>? onChopdiChanged;
//   final Isar isar;

//   const HomeHeader({
//     super.key,
//     required this.isar,
//     this.currentChopdi,
//     this.onChopdiChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   currentChopdi?.name ?? "My Chopdi",
//                   style: GoogleFonts.manrope(
//                     color: ChopdiColors.navy,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20,
//                   ),
//                 ),

//                 IconButton(
//                   icon: Image.asset(
//                     'assets/tabler_edit.png',
//                   ),
//                   onPressed: () async {
//                     final selectedChopdi =
//                         await showModalBottomSheet<Chopdi>(
//                       context: context,
//                       backgroundColor: Colors.transparent,
//                       isScrollControlled: true,
//                       builder: (_) => const ChopdiBottomSheet(),
//                     );

//                     if (selectedChopdi != null) {
//                       onChopdiChanged?.call(selectedChopdi);
//                     }
//                   },
//                 ),
//               ],
//             ),

//             Text(
//               "Tap to change chopdi",
//               style: GoogleFonts.manrope(
//                 color: ChopdiColors.navy,
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),

//         const Spacer(),

//         GestureDetector(
//           child: Image.asset(
//             'assets/notifications.png',
//             height: 25,
//             width: 25,
//           ),
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => NotificationsScreen(
//                   isar: isar,
//                   chopdiId: currentChopdi!.id,
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/chopdi.dart';
import 'package:mychopdi/model/notification.dart';
import 'package:mychopdi/service/isar_service.dart';
import 'package:mychopdi/utils/app_colors.dart';
import 'package:mychopdi/view/notifications_screen.dart';
import 'package:mychopdi/widgets/chopdi_bottom_sheet.dart';

class HomeHeader extends StatelessWidget {
  final Chopdi? currentChopdi;
  final ValueChanged<Chopdi>? onChopdiChanged;

  const HomeHeader({
    super.key,
    this.currentChopdi,
    this.onChopdiChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  currentChopdi?.name ?? "My Chopdi",
                  style: GoogleFonts.manrope(
                    color: ChopdiColors.navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),

                IconButton(
                  icon: Image.asset(
                    'assets/tabler_edit.png',
                  ),
                  onPressed: () async {
                    final selectedChopdi =
                        await showModalBottomSheet<Chopdi>(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) =>
                          const ChopdiBottomSheet(),
                    );

                    if (selectedChopdi != null) {
                      onChopdiChanged?.call(
                        selectedChopdi,
                      );
                    }
                  },
                ),
              ],
            ),

            Text(
              "Tap to change chopdi",
              style: GoogleFonts.manrope(
                color: ChopdiColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const Spacer(),

        // Notification bell + unread count
        if (currentChopdi != null)
          StreamBuilder<List<NotificationModel>>(
            stream: IsarService.isar.notificationModels
                .filter()
                .chopdiIdEqualTo(
                  currentChopdi!.id,
                )
                .isReadEqualTo(false)
                .watch(
                  fireImmediately: true,
                ),
            builder: (context, snapshot) {
              final unreadCount =
                  snapshot.data?.length ?? 0;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          NotificationsScreen(
                        isar: IsarService.isar,
                        chopdiId:
                            currentChopdi!.id,
                      ),
                    ),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(
                      'assets/notifications.png',
                      height: 25,
                      width: 25,
                    ),

                    // Badge
                    if (unreadCount > 0)
                      Positioned(
                        right: -7,
                        top: -7,
                        child: Container(
                          constraints:
                              const BoxConstraints(
                            minWidth: 17,
                            minHeight: 17,
                          ),
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          decoration:
                              const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            unreadCount > 99
                                ? "99+"
                                : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}