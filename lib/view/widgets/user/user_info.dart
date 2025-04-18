import 'package:flutter/material.dart';
import 'package:mangadive/controllers/user_controller.dart';
import 'package:mangadive/models/user.dart';

class UserInfo extends StatelessWidget {
  final String userId;
  final double avatarRadius;
  final TextStyle? usernameStyle;
  final bool showAvatar;
  final bool showUsername;
  final VoidCallback? onTap;

  const UserInfo({
    Key? key,
    required this.userId,
    this.avatarRadius = 16,
    this.usernameStyle,
    this.showAvatar = true,
    this.showUsername = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userController = UserController();

    return FutureBuilder<User>(
      future: userController.getUserById(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorState();
        }

        final user = snapshot.data!;
        return _buildUserInfo(user, context);
      },
    );
  }

  Widget _buildLoadingState() {
    return Row(
      children: [
        if (showAvatar)
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Colors.grey[300],
          ),
        if (showAvatar && showUsername) const SizedBox(width: 8),
        if (showUsername)
          Container(
            width: 80,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Row(
      children: [
        if (showAvatar)
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.error, size: 16, color: Colors.grey),
          ),
        if (showAvatar && showUsername) const SizedBox(width: 8),
        if (showUsername)
          const Text(
            'Người dùng',
            style: TextStyle(color: Colors.grey),
          ),
      ],
    );
  }

  Widget _buildUserInfo(User user, BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showAvatar)
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Text(
                user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (showAvatar && showUsername) const SizedBox(width: 8),
          if (showUsername)
            Text(
              user.username,
              style: usernameStyle ?? const TextStyle(fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}

// Widget để lấy thông tin người dùng theo stream (real-time)
class UserInfoStream extends StatelessWidget {
  final String userId;
  final double avatarRadius;
  final TextStyle? usernameStyle;
  final bool showAvatar;
  final bool showUsername;
  final VoidCallback? onTap;

  const UserInfoStream({
    Key? key,
    required this.userId,
    this.avatarRadius = 16,
    this.usernameStyle,
    this.showAvatar = true,
    this.showUsername = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userController = UserController();

    return StreamBuilder<User>(
      stream: userController.getUserStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              if (showAvatar)
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Colors.grey[300],
                ),
              if (showAvatar && showUsername) const SizedBox(width: 8),
              if (showUsername)
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Row(
            children: [
              if (showAvatar)
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.error, size: 16, color: Colors.grey),
                ),
              if (showAvatar && showUsername) const SizedBox(width: 8),
              if (showUsername)
                const Text(
                  'Người dùng',
                  style: TextStyle(color: Colors.grey),
                ),
            ],
          );
        }

        final user = snapshot.data!;
        return InkWell(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showAvatar)
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  child: Text(
                    user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (showAvatar && showUsername) const SizedBox(width: 8),
              if (showUsername)
                Text(
                  user.username,
                  style: usernameStyle ?? const TextStyle(fontWeight: FontWeight.bold),
                ),
            ],
          ),
        );
      },
    );
  }
} 