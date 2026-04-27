import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neuroaid/src/core/routes/app_router.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';

class SearchBarSection extends StatelessWidget {
  const SearchBarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, AppRouter.searchScreen);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: FaIcon(
                  FontAwesomeIcons.magnifyingGlass,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              Expanded(
                child: Text(
                  'Search...',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.sliders,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
