import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';
import 'package:neuroaid/src/shared/widgets/primary_button.dart';

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String rating;
  final String time;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final String? imageUrl;

  const DoctorCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.time,
    required this.isFavorite,
    required this.onTap,
    this.onFavoriteTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Doctor Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: imageUrl != null
                    ? NetworkImage(imageUrl!)
                    : null,
                child: imageUrl == null
                    ? const FaIcon(
                        FontAwesomeIcons.userDoctor,
                        color: AppColors.primary,
                        size: 28,
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Doctor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialty,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Favorite Icon
              IconButton(
                onPressed: onFavoriteTap,
                icon: FaIcon(
                  isFavorite
                      ? FontAwesomeIcons.solidHeart
                      : FontAwesomeIcons.heart,
                  color: isFavorite ? Colors.red : AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Rating and Time
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.solidStar,
                color: AppColors.warning,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                rating,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              const FaIcon(
                FontAwesomeIcons.clock,
                color: AppColors.textSecondary,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                time,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Book Appointment Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: PrimaryButton(label: 'Book Appointment', onPressed: onTap),
          ),
        ],
      ),
    );
  }
}
