import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../utils/app_colors.dart';

class ProfileSection extends StatelessWidget {
  final String phoneNumber;
  final String? userName;
  final VoidCallback onEditName;
  final VoidCallback onAddName;

  const ProfileSection({
    super.key,
    required this.phoneNumber,
    this.userName,
    required this.onEditName,
    required this.onAddName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final hasName = userName != null && userName!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ChopdiColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFAAC0D8),
          width: 0.9,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------------------------------------------
          // HEADER
          // ---------------------------------------------------------------
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0x99AAB9CF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFF3D5F8B),
                  size: 23,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  l10n.profile,
                  style: GoogleFonts.manrope(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: ChopdiColors.navy,
                  ),
                ),
              ),

              if (hasName)
                TextButton.icon(
                  onPressed: onEditName,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 17,
                  ),
                  label: Text(l10n.edit),
                  style: TextButton.styleFrom(
                    foregroundColor: ChopdiColors.navy,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          // ---------------------------------------------------------------
          // NAME
          // ---------------------------------------------------------------
          Text(
            l10n.name,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF58687A),
            ),
          ),

          const SizedBox(height: 5),

          if (hasName)
            Text(
              userName!,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ChopdiColors.navy,
              ),
            )
          else
            InkWell(
              onTap: onAddName,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.addYourName,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ChopdiColors.navy,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.add_rounded,
                    size: 20,
                    color: ChopdiColors.navy,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          const Divider(
            height: 1,
            color: Colors.white,
          ),

          const SizedBox(height: 16),

          // ---------------------------------------------------------------
          // PHONE NUMBER
          // ---------------------------------------------------------------
          Text(
            l10n.phoneNumber,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF58687A),
            ),
          ),

          const SizedBox(height: 7),

          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 20,
                color: Color(0xFF3D5F8B),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  phoneNumber,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ChopdiColors.navy,
                  ),
                ),
              ),

              const Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: ChopdiColors.navy,
              ),
            ],
          ),
        ],
      ),
    );
  }
}