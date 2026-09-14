import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import 'package:mychopdi/model/notification.dart';
import 'package:mychopdi/service/local_notification_service.dart';
import 'package:mychopdi/service/notification_service.dart';
import 'package:mychopdi/utils/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  final Isar isar;
  final int chopdiId;

  const NotificationsScreen({
    super.key,
    required this.isar,
    required this.chopdiId,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationService notificationService;

  final LocalNotificationService localNotificationService =
      LocalNotificationService.instance;

  bool _notificationsEnabled = true;
  bool _loadingNotificationSetting = true;

  @override
  void initState() {
    super.initState();

    notificationService = NotificationService(widget.isar);

    _loadNotificationSetting();
  }

  // ============================================================
  // LOAD MASTER SETTING
  // ============================================================

  Future<void> _loadNotificationSetting() async {
    final enabled =
        await localNotificationService.areNotificationsEnabled();

    if (!mounted) {
      return;
    }

    setState(() {
      _notificationsEnabled = enabled;
      _loadingNotificationSetting = false;
    });
  }

  // ============================================================
  // TOGGLE NOTIFICATIONS
  // ============================================================

  Future<void> _toggleNotifications() async {
    final bool newValue = !_notificationsEnabled;

    if (!newValue) {
      await _disableNotifications();
    } else {
      await _enableNotifications();
    }
  }

  // ============================================================
  // DISABLE
  // ============================================================

  Future<void> _disableNotifications() async {
    await localNotificationService.setNotificationsEnabled(
      false,
      database: widget.isar,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _notificationsEnabled = false;
    });

    await _showNotificationStatusDialog(
      enabled: false,
    );
  }

  // ============================================================
  // ENABLE
  // ============================================================

  Future<void> _enableNotifications() async {
    await localNotificationService.setNotificationsEnabled(
      true,
      database: widget.isar,
    );

    await localNotificationService.requestPermission();

    await localNotificationService.syncNotifications(
      database: widget.isar,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _notificationsEnabled = true;
    });

    await _showNotificationStatusDialog(
      enabled: true,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF3E2),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final horizontalPadding = width < 360
                ? 12.0
                : width < 600
                    ? 18.0
                    : 24.0;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 18),

                  // ==================================================
                  // HEADER
                  // ==================================================

                  _buildHeader(),

                  const SizedBox(height: 20),

                  // ==================================================
                  // NOTIFICATIONS
                  // ==================================================

                  Expanded(
                    child: StreamBuilder<List<NotificationModel>>(
                      stream: notificationService.watchNotifications(
                        widget.chopdiId,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: ChopdiColors.navy,
                            ),
                          );
                        }

                        final notifications = snapshot.data ?? [];

                        if (notifications.isEmpty) {
                          return _emptyNotifications();
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.only(
                            bottom: 20,
                          ),
                          itemCount: notifications.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final notification = notifications[index];

                            return _notificationTile(
                              context,
                              notification,
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.pop(context);
          },
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: ChopdiColors.navy,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            'Notifications',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ChopdiColors.navy,
            ),
          ),
        ),

        // ========================================================
        // MARK ALL AS READ
        // ========================================================

        StreamBuilder<int>(
          stream: notificationService.watchUnreadCount(
            widget.chopdiId,
          ),
          builder: (context, snapshot) {
            final unreadCount = snapshot.data ?? 0;

            if (unreadCount == 0) {
              return const SizedBox.shrink();
            }

            return IconButton(
              tooltip: 'Mark all as read',
              onPressed: () async {
                await notificationService.markAllAsRead(
                  widget.chopdiId,
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

    final bool isUnread = !notification.isRead;

    return GestureDetector(
      // ==========================================================
      // TAP
      // ==========================================================

      onTap: () async {
        // Tapping an unread notification automatically
        // changes it to read.
        if (isUnread) {
          await notificationService.markAsRead(
            notification.id,
          );
        }

        // No popup/dialog here.
        // The StreamBuilder automatically rebuilds the tile
        // with the read appearance.
      },

      // ==========================================================
      // LONG PRESS
      // ==========================================================

      onLongPress: () {
        _showNotificationOptions(
          context,
          notification,
        );
      },

      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 250,
        ),
        curve: Curves.easeInOut,

        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          // ======================================================
          // UNREAD = HIGHLIGHTED
          // READ = SOFT
          // ======================================================

          color: isUnread
              ? const Color(0xffEAF2FF)
              : Colors.white,

          borderRadius: BorderRadius.circular(16),

          border: Border.all(
            color: isUnread
                ? const Color(0xffB8CCEE)
                : Colors.grey.shade300,
            width: isUnread ? 1.4 : 1,
          ),

          boxShadow: isUnread
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.04,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // ICON
                // ==================================================

                AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 250,
                  ),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(
                      alpha: isUnread ? .15 : .10,
                    ),
                    shape: BoxShape.circle,
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
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // ==================================================
                          // UNREAD DOT
                          // ==================================================

                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(
                                right: 7,
                                top: 5,
                              ),
                              decoration: BoxDecoration(
                                color: iconColor,
                                shape: BoxShape.circle,
                              ),
                            ),

                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontWeight: isUnread
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                                fontSize: 16,
                                color: ChopdiColors.navy,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        notification.subtitle,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          height: 1.35,
                          color: ChopdiColors.navy.withValues(
                            alpha: isUnread ? .85 : .65,
                          ),
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
                    fontWeight: isUnread
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isUnread
                        ? ChopdiColors.navy
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ICON
  // ============================================================

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'interest_calculated':
        return Icons.percent_rounded;

      case 'interest_updated':
        return Icons.currency_rupee_rounded;

      case 'app_update':
        return Icons.system_update_rounded;

      case 'payment_reminder':
        return Icons.notifications_active_rounded;

      default:
        return Icons.notifications_none_rounded;
    }
  }

  // ============================================================
  // COLOR
  // ============================================================

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'interest_calculated':
        return Colors.green;

      case 'interest_updated':
        return Colors.orange;

      case 'app_update':
        return Colors.blue;

      case 'payment_reminder':
        return Colors.red;

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
        mainAxisAlignment: MainAxisAlignment.center,
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
            'No Notifications',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ChopdiColors.navy,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'You\'re all caught up!',
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
      builder: (sheetContext) {
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
                // ==================================================
                // HANDLE
                // ==================================================

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

                // ==================================================
                // READ / UNREAD
                // ==================================================

                ListTile(
                  leading: Icon(
                    notification.isRead
                        ? Icons.mark_email_unread_outlined
                        : Icons.mark_email_read_outlined,
                    color: ChopdiColors.navy,
                  ),
                  title: Text(
                    notification.isRead
                        ? 'Mark as unread'
                        : 'Mark as read',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w600,
                      color: ChopdiColors.navy,
                    ),
                  ),
                  onTap: () async {
                    if (notification.isRead) {
                      await notificationService.markAsUnread(
                        notification.id,
                      );
                    } else {
                      await notificationService.markAsRead(
                        notification.id,
                      );
                    }

                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext);
                    }
                  },
                ),

                // ==================================================
                // DELETE
                // ==================================================

                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  title: Text(
                    'Delete notification',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);

                    await _confirmDelete(
                      notification,
                    );
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
  // CONFIRM DELETE
  // ============================================================

  Future<void> _confirmDelete(
    NotificationModel notification,
  ) async {
    if (!mounted) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xffFFF8F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Delete Notification?',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ChopdiColors.navy,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this notification?',
            style: GoogleFonts.manrope(
              fontSize: 13,
              height: 1.4,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(
                'Delete',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await notificationService.deleteNotification(
        notification.id,
      );
    }
  }

  // ============================================================
  // STATUS DIALOG
  // ============================================================

  Future<void> _showNotificationStatusDialog({
    required bool enabled,
  }) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xffFFF8F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: enabled
                      ? Colors.green.withValues(
                          alpha: .12,
                        )
                      : Colors.red.withValues(
                          alpha: .12,
                        ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  enabled
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_off_outlined,
                  color: enabled
                      ? Colors.green
                      : Colors.red,
                  size: 21,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  enabled
                      ? 'Notifications Enabled'
                      : 'Notifications Disabled',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ChopdiColors.navy,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            enabled
                ? 'You will receive notifications for payment reminders, interest updates and other important alerts.'
                : 'You will no longer receive notifications from Chopdi until you enable them again.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'OK',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ChopdiColors.navy,
                ),
              ),
            ),
          ],
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

    final difference = now.difference(dateTime);

    if (difference.isNegative) {
      return 'Just now';
    }

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;

      return minutes == 1
          ? '1 min ago'
          : '$minutes mins ago';
    }

    if (difference.inHours < 24) {
      final hours = difference.inHours;

      return hours == 1
          ? '1 hour ago'
          : '$hours hours ago';
    }

    if (difference.inDays == 1) {
      return 'Yesterday';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }

    final day = dateTime.day
        .toString()
        .padLeft(2, '0');

    final month = dateTime.month
        .toString()
        .padLeft(2, '0');

    final year = dateTime.year.toString();

    return '$day/$month/$year';
  }
}