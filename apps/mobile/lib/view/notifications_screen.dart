// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:mychopdi/utils/app_colors.dart';

// // class NotificationsScreen extends StatelessWidget {
// //   const NotificationsScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xffFFF3E2),

// //       body: SafeArea(
// //         child: Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 18),
// //           child: Column(
// //             children: [

// //               const SizedBox(height: 18),

// //               Row(
// //                 children: [

// //                   InkWell(
// //                     onTap: (){
// //                       Navigator.pop(context);
// //                     },
// //                     child: const Icon(
// //                       Icons.arrow_back,
// //                       color: ChopdiColors.navy,
// //                     ),
// //                   ),

// //                   const SizedBox(width: 12),

// //                   Text(
// //                     "Notifications",
// //                     style: GoogleFonts.manrope(
// //                       fontSize: 24,
// //                       fontWeight: FontWeight.bold,
// //                       color: ChopdiColors.navy,
// //                     ),
// //                   ),
// //                 ],
// //               ),

// //               const SizedBox(height: 24),

// //               _notificationTile(
// //                 icon: Icons.collections_bookmark,
// //                 iconColor: Colors.red,
// //                 title: "Collection Reminder",
// //                 subtitle: "You have 3 collections\ndue today.",
// //                 time: "2 mins ago",
// //               ),

// //               const SizedBox(height: 12),

// //               _notificationTile(
// //                 icon: Icons.notifications_none,
// //                 iconColor: Colors.red,
// //                 title: "Payment Pending",
// //                 subtitle:
// //                     "Khushi's payment of ₹8,500 is\npending since 5 days.",
// //                 time: "15 mins ago",
// //               ),

// //               const SizedBox(height: 12),

// //               _notificationTile(
// //                 icon: Icons.calendar_today,
// //                 iconColor: Colors.red,
// //                 title: "Payment Due Tomorrow",
// //                 subtitle:
// //                     "Dada's payment of ₹6,000 is due\ntomorrow.",
// //                 time: "Yesterday,\n4:15 PM",
// //               ),

// //               const SizedBox(height: 12),

// //               _notificationTile(
// //                 icon: Icons.download,
// //                 iconColor: Colors.blue,
// //                 title: "App Update",
// //                 subtitle:
// //                     "A new version of Chopdi\nis available.",
// //                 time: "2 days ago",
// //               ),

// //               const SizedBox(height: 60),

// //               Container(
// //                 padding: const EdgeInsets.all(8),
// //                 decoration: BoxDecoration(
// //                   color: Color.fromRGBO(170, 185, 207, 0.6),
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     CircleAvatar(
// //                       radius: 24,
// //                       backgroundColor: Colors.transparent,
// //                       child: Image.asset('assets/notifications.png')
// //                     ),

// //                     const SizedBox(width: 15),

// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [

// //                           Text(
// //                             "Notifications Off",
// //                             style: GoogleFonts.manrope(
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: 14,
// //                               color: ChopdiColors.navy,
// //                             ),
// //                           ),

// //                           const SizedBox(height: 5),

// //                           Text(
// //                             "Turn on notifications to receive payment due reminders and collection alerts.",
// //                             style: GoogleFonts.manrope(
// //                               fontSize: 13,
// //                               color: ChopdiColors.navy,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),

// //                     ElevatedButton(
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: ChopdiColors.navy,
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                       ),
// //                       onPressed: () {},

// //                       child: const Text(
// //                         "Enable Notifications",
// //                         style: TextStyle(
// //                           color: Color(0xFFFDEDD9),
// //                         ),
// //                       ),
// //                     )
// //                   ],
// //                 ),
// //               ),

// //               const SizedBox(height: 20),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _notificationTile({
// //     required IconData icon,
// //     required Color iconColor,
// //     required String title,
// //     required String subtitle,
// //     required String time,
// //   }) {
// //     return Container(
// //       padding: const EdgeInsets.all(14),
// //       decoration: BoxDecoration(
// //         color: Colors.white.withValues(alpha: .45),
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(
// //           color: Colors.grey.shade300,
// //         ),
// //       ),
// //       child: Row(
// //         children: [

// //           CircleAvatar(
// //             radius: 22,
// //             backgroundColor: iconColor.withValues(alpha: .15),
// //             child: Image.asset('assets/notifications.png'),
// //           ),

// //           const SizedBox(width: 14),

// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [

// //                 Text(
// //                   title,
// //                   style: GoogleFonts.manrope(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 16,
// //                     color: ChopdiColors.navy,
// //                   ),
// //                 ),

// //                 const SizedBox(height: 4),

// //                 Text(
// //                   subtitle,
// //                   style: GoogleFonts.manrope(
// //                     fontSize: 13,
// //                     color: ChopdiColors.navy,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),

// //           Text(
// //             time,
// //             textAlign: TextAlign.right,
// //             style: GoogleFonts.manrope(
// //               fontSize: 11,
// //               color: Colors.grey.shade700,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:isar_community/isar.dart';
// import 'package:mychopdi/model/notification.dart';
// import 'package:mychopdi/utils/app_colors.dart';

// class NotificationsScreen extends StatelessWidget {
//   final Isar isar;
//   final int chopdiId;

//   const NotificationsScreen({
//     super.key,
//     required this.isar,
//     required this.chopdiId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffFFF3E2),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 18),
//           child: Column(
//             children: [
//               const SizedBox(height: 18),

//               // Header
//               Row(
//                 children: [
//                   InkWell(
//                     borderRadius: BorderRadius.circular(20),
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: const Padding(
//                       padding: EdgeInsets.all(4),
//                       child: Icon(
//                         Icons.arrow_back,
//                         color: ChopdiColors.navy,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(width: 12),

//                   Text(
//                     "Notifications",
//                     style: GoogleFonts.manrope(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: ChopdiColors.navy,
//                     ),
//                   ),

//                   const Spacer(),

//                   // Mark all as read
//                   StreamBuilder<List<NotificationModel>>(
//                     stream: isar.notificationModels
//                         .filter()
//                         .chopdiIdEqualTo(chopdiId)
//                         .sortByCreatedAtDesc()
//                         .watch(
//                           fireImmediately: true,
//                         ),
//                     builder: (context, snapshot) {
//                       final notifications =
//                           snapshot.data ?? [];

//                       final hasUnread = notifications.any(
//                         (notification) =>
//                             !notification.isRead,
//                       );

//                       if (!hasUnread) {
//                         return const SizedBox.shrink();
//                       }

//                       return IconButton(
//                         tooltip: "Mark all as read",
//                         onPressed: () async {
//                           final unread =
//                               notifications
//                                   .where(
//                                     (notification) =>
//                                         !notification.isRead,
//                                   )
//                                   .toList();

//                           if (unread.isEmpty) return;

//                           for (final notification in unread) {
//                             notification.isRead = true;
//                           }

//                           await isar.writeTxn(() async {
//                             await isar.notificationModels.putAll(
//                               unread,
//                             );
//                           });
//                         },
//                         icon: const Icon(
//                           Icons.done_all,
//                           color: ChopdiColors.navy,
//                           size: 22,
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 24),

//               // Notifications
//               Expanded(
//                 child: StreamBuilder<List<NotificationModel>>(
//                   stream: isar.notificationModels
//                       .filter()
//                       .chopdiIdEqualTo(chopdiId)
//                       .sortByCreatedAtDesc()
//                       .watch(
//                         fireImmediately: true,
//                       ),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState ==
//                             ConnectionState.waiting &&
//                         !snapshot.hasData) {
//                       return const Center(
//                         child: CircularProgressIndicator(
//                           color: ChopdiColors.navy,
//                         ),
//                       );
//                     }

//                     final notifications =
//                         snapshot.data ?? [];

//                     return Column(
//                       children: [
//                         Expanded(
//                           child: notifications.isEmpty
//                               ? _emptyNotifications()
//                               : ListView.separated(
//                                   padding:
//                                       const EdgeInsets.only(
//                                     bottom: 20,
//                                   ),
//                                   itemCount:
//                                       notifications.length,
//                                   separatorBuilder:
//                                       (_, _) =>
//                                           const SizedBox(
//                                     height: 12,
//                                   ),
//                                   itemBuilder:
//                                       (context, index) {
//                                     final notification =
//                                         notifications[index];

//                                     return _notificationTile(
//                                       context,
//                                       notification,
//                                     );
//                                   },
//                                 ),
//                         ),

//                         const SizedBox(height: 12),

//                         // Notifications off section
//                         _notificationsOffCard(),

//                         const SizedBox(height: 20),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ------------------------------------------------------------
//   // NOTIFICATION TILE
//   // ------------------------------------------------------------

//   Widget _notificationTile(
//     BuildContext context,
//     NotificationModel notification,
//   ) {
//     final iconColor =
//         _getNotificationColor(notification.type);

//     final icon =
//         _getNotificationIcon(notification.type);

//     return GestureDetector(
//       onTap: () async {
//         // Mark notification as read
//         if (!notification.isRead) {
//           notification.isRead = true;

//           await isar.writeTxn(() async {
//             await isar.notificationModels.put(
//               notification,
//             );
//           });
//         }

//         // You can later navigate to the
//         // related transaction/customer here.
//       },
//       onLongPress: () {
//         _showNotificationOptions(
//           context,
//           notification,
//         );
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: notification.isRead
//               ? Colors.white.withValues(alpha: .35)
//               : Colors.white.withValues(alpha: .60),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: notification.isRead
//                 ? Colors.grey.shade300
//                 : iconColor.withValues(alpha: .45),
//           ),
//         ),
//         child: Row(
//           crossAxisAlignment:
//               CrossAxisAlignment.start,
//           children: [
//             // Icon
//             CircleAvatar(
//               radius: 22,
//               backgroundColor:
//                   iconColor.withValues(alpha: .15),
//               child: Icon(
//                 icon,
//                 color: iconColor,
//                 size: 23,
//               ),
//             ),

//             const SizedBox(width: 14),

//             // Title + subtitle
//             Expanded(
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           notification.title,
//                           maxLines: 2,
//                           overflow:
//                               TextOverflow.ellipsis,
//                           style: GoogleFonts.manrope(
//                             fontWeight:
//                                 notification.isRead
//                                     ? FontWeight.w600
//                                     : FontWeight.bold,
//                             fontSize: 16,
//                             color:
//                                 ChopdiColors.navy,
//                           ),
//                         ),
//                       ),

//                       if (!notification.isRead)
//                         Container(
//                           width: 7,
//                           height: 7,
//                           margin:
//                               const EdgeInsets.only(
//                             left: 6,
//                             top: 4,
//                           ),
//                           decoration:
//                               const BoxDecoration(
//                             color:
//                                 ChopdiColors.navy,
//                             shape:
//                                 BoxShape.circle,
//                           ),
//                         ),
//                     ],
//                   ),

//                   const SizedBox(height: 4),

//                   Text(
//                     notification.subtitle,
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                     style: GoogleFonts.manrope(
//                       fontSize: 13,
//                       color: ChopdiColors.navy,
//                     ),
//                   ),

//                   // Amount if available
//                   if (notification.amount != null) ...[
//                     const SizedBox(height: 5),
//                     Text(
//                       "₹${notification.amount!.toStringAsFixed(0)}",
//                       style: GoogleFonts.manrope(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: iconColor,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),

//             const SizedBox(width: 8),

//             // Time
//             Text(
//               _formatNotificationTime(
//                 notification.createdAt,
//               ),
//               textAlign: TextAlign.right,
//               style: GoogleFonts.manrope(
//                 fontSize: 11,
//                 color: Colors.grey.shade700,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ------------------------------------------------------------
//   // EMPTY NOTIFICATIONS
//   // ------------------------------------------------------------

//   Widget _emptyNotifications() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 30,
//         ),
//         child: Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: ChopdiColors.navy.withValues(
//                   alpha: .08,
//                 ),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.notifications_none,
//                 size: 45,
//                 color: ChopdiColors.navy.withValues(
//                   alpha: .65,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             Text(
//               "No Notifications",
//               style: GoogleFonts.manrope(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: ChopdiColors.navy,
//               ),
//             ),

//             const SizedBox(height: 6),

//             Text(
//               "You're all caught up. New payment and collection reminders will appear here.",
//               textAlign: TextAlign.center,
//               style: GoogleFonts.manrope(
//                 fontSize: 13,
//                 color: ChopdiColors.navy.withValues(
//                   alpha: .7,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ------------------------------------------------------------
//   // NOTIFICATIONS OFF CARD
//   // ------------------------------------------------------------

//   Widget _notificationsOffCard() {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: const Color.fromRGBO(
//           170,
//           185,
//           207,
//           0.6,
//         ),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         crossAxisAlignment:
//             CrossAxisAlignment.center,
//         children: [
//           CircleAvatar(
//             radius: 24,
//             backgroundColor: Colors.transparent,
//             child: Image.asset(
//               'assets/notifications.png',
//             ),
//           ),

//           const SizedBox(width: 15),

//           Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Notifications Off",
//                   style: GoogleFonts.manrope(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                     color: ChopdiColors.navy,
//                   ),
//                 ),

//                 const SizedBox(height: 5),

//                 Text(
//                   "Turn on notifications to receive payment due reminders and collection alerts.",
//                   style: GoogleFonts.manrope(
//                     fontSize: 13,
//                     color: ChopdiColors.navy,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(width: 8),

//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor:
//                   ChopdiColors.navy,
//               padding:
//                   const EdgeInsets.symmetric(
//                 horizontal: 12,
//                 vertical: 10,
//               ),
//               shape:
//                   RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.circular(8),
//               ),
//             ),
//             onPressed: () {
//               // TODO:
//               // Add notification permission logic here.
//             },
//             child: const Text(
//               "Enable",
//               style: TextStyle(
//                 color: Color(0xFFFDEDD9),
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ------------------------------------------------------------
//   // NOTIFICATION OPTIONS
//   // ------------------------------------------------------------

//   void _showNotificationOptions(
//     BuildContext context,
//     NotificationModel notification,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: const Color(0xffFFF3E2),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(20),
//         ),
//       ),
//       builder: (context) {
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade400,
//                     borderRadius:
//                         BorderRadius.circular(10),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 ListTile(
//                   leading: const Icon(
//                     Icons.mark_email_read,
//                     color: ChopdiColors.navy,
//                   ),
//                   title: Text(
//                     notification.isRead
//                         ? "Mark as unread"
//                         : "Mark as read",
//                     style: GoogleFonts.manrope(
//                       fontWeight: FontWeight.w600,
//                       color: ChopdiColors.navy,
//                     ),
//                   ),
//                   onTap: () async {
//                     notification.isRead =
//                         !notification.isRead;

//                     await isar.writeTxn(() async {
//                       await isar.notificationModels
//                           .put(notification);
//                     });

//                     if (context.mounted) {
//                       Navigator.pop(context);
//                     }
//                   },
//                 ),

//                 ListTile(
//                   leading: const Icon(
//                     Icons.delete_outline,
//                     color: Colors.red,
//                   ),
//                   title: Text(
//                     "Delete notification",
//                     style: GoogleFonts.manrope(
//                       fontWeight: FontWeight.w600,
//                       color: Colors.red,
//                     ),
//                   ),
//                   onTap: () async {
//                     await isar.writeTxn(() async {
//                       await isar.notificationModels
//                           .delete(notification.id);
//                     });

//                     if (context.mounted) {
//                       Navigator.pop(context);
//                     }
//                   },
//                 ),

//                 const SizedBox(height: 8),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ------------------------------------------------------------
//   // ICON
//   // ------------------------------------------------------------

//   // IconData _getNotificationIcon(
//   //   String type,
//   // ) {
//   //   switch (type) {
//   //     case "collection":
//   //       return Icons.collections_bookmark;

//   //     case "payment_pending":
//   //       return Icons.notifications_none;

//   //     case "payment_due":
//   //       return Icons.calendar_today;

//   //     case "app_update":
//   //       return Icons.download;

//   //     default:
//   //       return Icons.notifications_none;
//   //   }
//   // }

//   IconData _getNotificationIcon(String type) {
//   switch (type) {
//     case "interest_calculated":
//       return Icons.percent_rounded;

//     case "app_update":
//       return Icons.system_update_rounded;

//     default:
//       return Icons.notifications_none;
//   }
// }

//   // ------------------------------------------------------------
//   // COLOR
//   // ------------------------------------------------------------

//   // Color _getNotificationColor(
//   //   String type,
//   // ) {
//   //   switch (type) {
//   //     case "collection":
//   //       return Colors.red;

//   //     case "payment_pending":
//   //       return Colors.red;

//   //     case "payment_due":
//   //       return Colors.red;

//   //     case "app_update":
//   //       return Colors.blue;

//   //     default:
//   //       return ChopdiColors.navy;
//   //   }
//   // }
// Color _getNotificationColor(String type) {
//   switch (type) {
//     case "interest_calculated":
//       return Colors.green;

//     case "app_update":
//       return Colors.blue;

//     default:
//       return ChopdiColors.navy;
//   }
// }

//   // ------------------------------------------------------------
//   // TIME FORMAT
//   // ------------------------------------------------------------

//   String _formatNotificationTime(
//     DateTime dateTime,
//   ) {
//     final now = DateTime.now();

//     final difference =
//         now.difference(dateTime);

//     if (difference.isNegative) {
//       return "Just now";
//     }

//     if (difference.inSeconds < 60) {
//       return "Just now";
//     }

//     if (difference.inMinutes < 60) {
//       final minutes =
//           difference.inMinutes;

//       return minutes == 1
//           ? "1 min ago"
//           : "$minutes mins ago";
//     }

//     if (difference.inHours < 24) {
//       final hours =
//           difference.inHours;

//       return hours == 1
//           ? "1 hour ago"
//           : "$hours hours ago";
//     }

//     if (difference.inDays == 1) {
//       return "Yesterday";
//     }

//     if (difference.inDays < 7) {
//       return "${difference.inDays} days ago";
//     }

//     final day =
//         dateTime.day.toString().padLeft(2, '0');

//     final month =
//         dateTime.month.toString().padLeft(2, '0');

//     final year =
//         dateTime.year.toString();

//     return "$day/$month/$year";
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/notification.dart';
import 'package:mychopdi/service/notification_service.dart';
import 'package:mychopdi/utils/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  final Isar isar;
  final int chopdiId;

  const NotificationsScreen({
    super.key,
    required this.isar,
    required this.chopdiId,
  });

  NotificationService get notificationService {
    return NotificationService(isar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF3E2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          child: Column(
            children: [
              const SizedBox(height: 18),

              // ==================================================
              // HEADER
              // ==================================================

              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.arrow_back,
                        color: ChopdiColors.navy,
                      ),
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

                  const Spacer(),

                  // MARK ALL AS READ
                  StreamBuilder<int>(
                    stream: notificationService.watchUnreadCount(
                      chopdiId,
                    ),
                    builder: (
                      context,
                      snapshot,
                    ) {
                      final unreadCount =
                          snapshot.data ?? 0;

                      if (unreadCount == 0) {
                        return const SizedBox.shrink();
                      }

                      return IconButton(
                        tooltip: "Mark all as read",
                        onPressed: () async {
                          await notificationService
                              .markAllAsRead(
                            chopdiId,
                          );
                        },
                        icon: const Icon(
                          Icons.done_all,
                          color: ChopdiColors.navy,
                          size: 22,
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ==================================================
              // NOTIFICATIONS
              // ==================================================

              Expanded(
                child: StreamBuilder<
                    List<NotificationModel>>(
                  stream: notificationService
                      .watchNotifications(
                    chopdiId,
                  ),
                  builder: (
                    context,
                    snapshot,
                  ) {
                    if (snapshot.connectionState ==
                            ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: ChopdiColors.navy,
                        ),
                      );
                    }

                    final notifications =
                        snapshot.data ?? [];

                    if (notifications.isEmpty) {
                      return _emptyNotifications();
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(
                        bottom: 20,
                      ),
                      itemCount: notifications.length,
                      separatorBuilder: (
                        _,
                        _,
                      ) {
                        return const SizedBox(
                          height: 12,
                        );
                      },
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        final notification =
                            notifications[index];

                        return _notificationTile(
                          context,
                          notification,
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // NOTIFICATIONS OFF CARD
              // ==================================================

              _notificationsOffCard(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NOTIFICATION TILE
  // ============================================================

  Widget _notificationTile(
    BuildContext context,
    NotificationModel notification,
  ) {
    final iconColor = _getNotificationColor(
      notification.type,
    );

    final icon = _getNotificationIcon(
      notification.type,
    );

    return GestureDetector(
      onTap: () async {
        if (!notification.isRead) {
          await notificationService.markAsRead(
            notification.id,
          );
        }
      },
      onLongPress: () {
        _showNotificationOptions(
          context,
          notification,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white.withValues(
                  alpha: .35,
                )
              : Colors.white.withValues(
                  alpha: .60,
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? Colors.grey.shade300
                : iconColor.withValues(
                    alpha: .45,
                  ),
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================================
            // ICON
            // ==================================================

            CircleAvatar(
              radius: 22,
              backgroundColor:
                  iconColor.withValues(
                alpha: .15,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 23,
              ),
            ),

            const SizedBox(width: 14),

            // ==================================================
            // TITLE + SUBTITLE
            // ==================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: ChopdiColors.navy,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    notification.subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      height: 1.35,
                      color: ChopdiColors.navy,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ==================================================
            // TIME
            // ==================================================

            Text(
              _formatNotificationTime(
                notification.createdAt,
              ),
              textAlign: TextAlign.right,
              style: GoogleFonts.manrope(
                fontSize: 10,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ICON
  // ============================================================

  IconData _getNotificationIcon(
    String type,
  ) {
    switch (type) {
      case "interest_calculated":
        return Icons.percent_rounded;

      case "app_update":
        return Icons.system_update_rounded;

      default:
        return Icons.notifications_none;
    }
  }

  // ============================================================
  // COLOR
  // ============================================================

  Color _getNotificationColor(
    String type,
  ) {
    switch (type) {
      case "interest_calculated":
        return Colors.green;

      case "app_update":
        return Colors.blue;

      default:
        return ChopdiColors.navy;
    }
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyNotifications() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: ChopdiColors.navy.withValues(
                alpha: .08,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 36,
              color: ChopdiColors.navy,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "No Notifications",
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ChopdiColors.navy,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "You're all caught up!",
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTIFICATIONS OFF CARD
  // ============================================================

  Widget _notificationsOffCard() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(
          170,
          185,
          207,
          0.6,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.transparent,
            child: Image.asset(
              'assets/notifications.png',
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                  "Turn on notifications to receive app updates and interest alerts.",
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: ChopdiColors.navy,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ChopdiColors.navy,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // Add notification permission
              // logic here later.
            },
            child: const Text(
              "Enable",
              style: TextStyle(
                color: Color(0xFFFDEDD9),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTIFICATION OPTIONS
  // ============================================================

  void _showNotificationOptions(
    BuildContext context,
    NotificationModel notification,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xffFFF8F0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius:
                        BorderRadius.circular(50),
                  ),
                ),

                const SizedBox(height: 20),

                ListTile(
                  leading: Icon(
                    notification.isRead
                        ? Icons.mark_email_unread
                        : Icons.mark_email_read,
                    color: ChopdiColors.navy,
                  ),
                  title: Text(
                    notification.isRead
                        ? "Mark as unread"
                        : "Mark as read",
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w600,
                      color: ChopdiColors.navy,
                    ),
                  ),
                  onTap: () async {
                    if (!notification.isRead) {
                      await notificationService
                          .markAsRead(
                        notification.id,
                      );
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  title: Text(
                    "Delete notification",
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () async {
                    await notificationService
                        .deleteNotification(
                      notification.id,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // TIME FORMAT
  // ============================================================

  String _formatNotificationTime(
    DateTime dateTime,
  ) {
    final now = DateTime.now();

    final difference =
        now.difference(dateTime);

    if (difference.isNegative) {
      return "Just now";
    }

    if (difference.inSeconds < 60) {
      return "Just now";
    }

    if (difference.inMinutes < 60) {
      final minutes =
          difference.inMinutes;

      return minutes == 1
          ? "1 min ago"
          : "$minutes mins ago";
    }

    if (difference.inHours < 24) {
      final hours =
          difference.inHours;

      return hours == 1
          ? "1 hour ago"
          : "$hours hours ago";
    }

    if (difference.inDays == 1) {
      return "Yesterday";
    }

    if (difference.inDays < 7) {
      return "${difference.inDays} days ago";
    }

    final day =
        dateTime.day.toString().padLeft(2, '0');

    final month =
        dateTime.month.toString().padLeft(2, '0');

    final year =
        dateTime.year.toString();

    return "$day/$month/$year";
  }
}