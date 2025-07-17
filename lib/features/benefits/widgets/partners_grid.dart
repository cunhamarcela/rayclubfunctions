// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:ray_club_app/core/constants/app_colors.dart';

/// Grid widget to display partners
class PartnersGrid extends StatelessWidget {
  final List<String> partners;
  final Function(String) onPartnerSelected;
  final String? activePartner;

  const PartnersGrid({
    Key? key,
    required this.partners,
    required this.onPartnerSelected,
    this.activePartner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: partners.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final partner = partners[index];
        final isActive = activePartner == partner;
        
        return GestureDetector(
          onTap: () => onPartnerSelected(partner),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.white,
              border: Border.all(
                color: isActive ? AppColors.primary : Colors.grey.shade300,
                width: isActive ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  partner,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? AppColors.primary : AppColors.textDark,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 
