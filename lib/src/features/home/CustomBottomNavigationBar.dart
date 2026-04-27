import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neuroaid/src/core/routes/app_router.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8FF), // Light blue background
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bottom Navigation Items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: FontAwesomeIcons.house,
                activeIcon: FontAwesomeIcons.house,
                label: 'Home',
                index: 0,
              ),
              _buildNavItem(
                icon: FontAwesomeIcons.heart,
                activeIcon: FontAwesomeIcons.solidHeart,
                label: 'Favorite',
                index: 1,
              ),
              const SizedBox(width: 60), // Space for center button
              _buildNavItem(
                icon: FontAwesomeIcons.robot,
                activeIcon: FontAwesomeIcons.robot,
                label: 'Chatbot',
                index: 2,
              ),
              _buildNavItem(
                icon: FontAwesomeIcons.user,
                activeIcon: FontAwesomeIcons.solidUser,
                label: 'Profile',
                index: 3,
              ),
            ],
          ),

          // Center Floating Button
          Positioned(
            top: -25,
            left: MediaQuery.of(context).size.width / 2 - 35,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRouter.scanScreen);
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF107B92), Color(0xFF2D8CFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D8CFF).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.camera,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
