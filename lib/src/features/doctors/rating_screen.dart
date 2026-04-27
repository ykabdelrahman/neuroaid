import 'package:flutter/material.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';

class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Ratings'), centerTitle: false),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, i) => const _RatingItem(),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: 6,
      ),
    );
  }
}

class _RatingItem extends StatelessWidget {
  const _RatingItem();
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  child: Icon(Icons.person_outline),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. Olivia Turner, M.D.',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Text('Dermato-Endocrinology'),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      const Text('5'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _SmallPill(icon: Icons.info_outline, text: 'Info'),
                const _SmallPill(
                  icon: Icons.event_note_outlined,
                  text: 'Notes',
                ),
                const _SmallPill(
                  icon: Icons.verified_user_outlined,
                  text: 'Pro',
                ),
                const _SmallPill(icon: Icons.help_outline, text: 'Q'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SmallPill({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: AppColors.primary)),
        ],
      ),
    );
  }
}
