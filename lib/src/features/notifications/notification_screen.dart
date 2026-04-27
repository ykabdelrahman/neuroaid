import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neuroaid/src/features/notifications/NotificationItem.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Appointment Confirmed',
      message:
          'Your appointment with Dr. Mohamed Ahmed has been successfully scheduled for tomorrow at 10:00 AM.',
      time: '1h ago',
      type: NotificationType.success,
      isRead: false,
      date: DateTime.now(),
    ),
    NotificationItem(
      id: '2',
      title: 'Appointment Cancelled',
      message:
          'Your appointment with Dr. Sarah Johnson on Dec 20 has been cancelled. Please reschedule at your convenience.',
      time: '2h ago',
      type: NotificationType.cancelled,
      isRead: false,
      date: DateTime.now(),
    ),
    NotificationItem(
      id: '3',
      title: 'Schedule Updated',
      message:
          'Dr. Ahmed has rescheduled your appointment from 2:00 PM to 3:30 PM on Dec 18.',
      time: '5h ago',
      type: NotificationType.changed,
      isRead: false,
      date: DateTime.now(),
    ),
    NotificationItem(
      id: '4',
      title: 'Appointment Reminder',
      message:
          'Don\'t forget your appointment with Dr. Mohamed Ahmed tomorrow at 10:00 AM.',
      time: '1d ago',
      type: NotificationType.success,
      isRead: true,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<NotificationItem> get _allNotifications => _notifications;

  List<NotificationItem> get _unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  List<NotificationItem> get _todayNotifications {
    final now = DateTime.now();
    return _notifications.where((notification) {
      return notification.date.year == now.year &&
          notification.date.month == now.month &&
          notification.date.day == now.day;
    }).toList();
  }

  List<NotificationItem> get _yesterdayNotifications {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _notifications.where((notification) {
      return notification.date.year == yesterday.year &&
          notification.date.month == yesterday.month &&
          notification.date.day == yesterday.day;
    }).toList();
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
  }

  void _markAsRead(NotificationItem notification) {
    setState(() {
      notification.isRead = true;
    });
  }

  void _deleteNotification(NotificationItem notification) {
    setState(() {
      _notifications.remove(notification);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasNotifications = _notifications.isNotEmpty;
    final unreadCount = _unreadNotifications.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (hasNotifications && unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const FaIcon(
                FontAwesomeIcons.checkDouble,
                size: 14,
                color: AppColors.primary,
              ),
              label: const Text(
                'Mark all',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
        bottom: hasNotifications
            ? TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: const Color(0xFF666666),
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(text: 'All (${_allNotifications.length})'),
                  Tab(
                    text: unreadCount > 0 ? 'Unread ($unreadCount)' : 'Unread',
                  ),
                ],
              )
            : null,
      ),
      body: hasNotifications
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationsList(_allNotifications),
                _unreadNotifications.isEmpty
                    ? _buildEmptyUnreadState()
                    : _buildNotificationsList(_unreadNotifications),
              ],
            )
          : _buildEmptyState(),
    );
  }

  Widget _buildNotificationsList(List<NotificationItem> notifications) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // TODAY Section
        if (_todayNotifications.isNotEmpty &&
            notifications.any((n) => _todayNotifications.contains(n))) ...[
          _buildSectionHeader('Today'),
          const SizedBox(height: 12),
          ..._todayNotifications.where((n) => notifications.contains(n)).map((
            notification,
          ) {
            return _buildNotificationCard(notification);
          }),
          const SizedBox(height: 24),
        ],

        // YESTERDAY Section
        if (_yesterdayNotifications.isNotEmpty &&
            notifications.any((n) => _yesterdayNotifications.contains(n))) ...[
          _buildSectionHeader('Yesterday'),
          const SizedBox(height: 12),
          ..._yesterdayNotifications
              .where((n) => notifications.contains(n))
              .map((notification) {
                return _buildNotificationCard(notification);
              }),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNotification(notification),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const FaIcon(
          FontAwesomeIcons.trash,
          color: Colors.white,
          size: 20,
        ),
      ),
      child: InkWell(
        onTap: () => _markAsRead(notification),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.white
                : AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? Colors.grey.shade200
                  : AppColors.primary.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getNotificationColor(
                    notification.type,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(
                    _getNotificationIcon(notification.type),
                    size: 20,
                    color: _getNotificationColor(notification.type),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.clock,
                          size: 12,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          notification.time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.bell,
                size: 50,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'We\'ll notify you when something important happens',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyUnreadState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.circleCheck,
                size: 45,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no unread notifications',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return FontAwesomeIcons.circleCheck;
      case NotificationType.cancelled:
        return FontAwesomeIcons.circleXmark;
      case NotificationType.changed:
        return FontAwesomeIcons.calendarDays;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return const Color(0xFF10B981);
      case NotificationType.cancelled:
        return const Color(0xFFEF4444);
      case NotificationType.changed:
        return const Color(0xFFF59E0B);
    }
  }
}
