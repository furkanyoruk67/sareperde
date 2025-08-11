import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import 'whatsapp_icon.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildContactItem({
    required Widget icon,
    required String title,
    required String subtitle,
    required String owner,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: icon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    owner,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32, 
        vertical: isMobile ? 20 : 40
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Contact information section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.contact_phone, color: AppColors.primary, size: isMobile ? 20 : 24),
                    SizedBox(width: isMobile ? 8 : 12),
                    Text(
                      'İletişim Bilgileri',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 16 : 24),
                isMobile 
                  ? Column(
                      children: [
                        _buildContactItem(
                          icon: Icon(Icons.phone, color: AppColors.primary, size: 20),
                          title: 'Telefon',
                          subtitle: '+90 536 495 02 62',
                          owner: 'Gülden ÖZDEMİR',
                          onTap: () => _launchUrl('tel:+905364950262'),
                        ),
                                                 SizedBox(height: 12),
                         _buildContactItem(
                           icon: WhatsAppIcon(size: 20, color: const Color(0xFF25D366)),
                           title: 'WhatsApp',
                           subtitle: '+90 536 495 02 62',
                           owner: 'Gülden ÖZDEMİR',
                           onTap: () => _launchUrl('https://wa.me/905364950262'),
                         ),
                         SizedBox(height: 12),
                        _buildContactItem(
                          icon: Icon(Icons.location_on, color: AppColors.primary, size: 20),
                          title: 'Adres',
                          subtitle: 'İstiklal Mahallesi Şehit Karabaşoğlu No:15',
                          owner: 'Serdivan/SAKARYA',
                          onTap: () => _launchUrl('https://www.google.com/maps/place/%C4%B0stiklal,+%C5%9Eht.+Mehmet+Karaba%C5%9Fo%C4%9Flu+Cd.+No:15+D:1,+54100+Serdivan%2FSakarya/@40.7716751,30.3613879,1319m/data=!3m1!1e3!4m15!1m8!3m7!1s0x14ccb2be05b7013f:0x3604f00ab8790848!2zxLBzdGlrbGFsLCDFnmh0LiBNZWhtZXQgS2FyYWJhxZ9vxJ9sdSBDZC4gTm86MTUgRDoxLCA1NDEwMCBTZXJkaXZhbi9TYWthcnlh!3b1!8m2!3d40.7714326!4d30.3613183!16s%2Fg%2F11hbq_jkzd!3m5!1s0x14ccb2be05b7013f:0x3604f00ab8790848!8m2!3d40.7714326!4d30.3613183!16s%2Fg%2F11hbq_jkzd?entry=ttu&g_ep=EgoyMDI1MDczMC4wIKXMDSoASAFQAw%3D%3D'),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                                                 Expanded(
                           child: _buildContactItem(
                             icon: Icon(Icons.phone, color: AppColors.primary, size: 20),
                             title: 'Telefon',
                             subtitle: '+90 536 495 02 62',
                             owner: 'Gülden ÖZDEMİR',
                             onTap: () => _launchUrl('tel:+905364950262'),
                           ),
                         ),
                        const SizedBox(width: 16),
                                                 Expanded(
                           child: _buildContactItem(
                             icon: WhatsAppIcon(size: 20, color: const Color(0xFF25D366)),
                             title: 'WhatsApp',
                             subtitle: '+90 536 495 02 62',
                             owner: 'Gülden ÖZDEMİR',
                             onTap: () => _launchUrl('https://wa.me/905364950262'),
                           ),
                         ),
                        const SizedBox(width: 16),
                                                 Expanded(
                           child: _buildContactItem(
                             icon: Icon(Icons.location_on, color: AppColors.primary, size: 20),
                             title: 'Adres',
                             subtitle: 'İstiklal Mahallesi Şehit Karabaşoğlu No:15',
                             owner: 'Serdivan/SAKARYA',
                             onTap: () => _launchUrl('https://www.google.com/maps/place/%C4%B0stiklal,+%C5%9Eht.+Mehmet+Karaba%C5%9Fo%C4%9Flu+Cd.+No:15+D:1,+54100+Serdivan%2FSakarya/@40.7716751,30.3613879,1319m/data=!3m1!1e3!4m15!1m8!3m7!1s0x14ccb2be05b7013f:0x3604f00ab8790848!2zxLBzdGlrbGFsLCDFnmh0LiBNZWhtZXQgS2FyYWJhxZ9vxJ9sdSBDZC4gTm86MTUgRDoxLCA1NDEwMCBTZXJkaXZhbi9TYWthcnlh!3b1!8m2!3d40.7714326!4d30.3613183!16s%2Fg%2F11hbq_jkzd!3m5!1s0x14ccb2be05b7013f:0x3604f00ab8790848!8m2!3d40.7714326!4d30.3613183!16s%2Fg%2F11hbq_jkzd?entry=ttu&g_ep=EgoyMDI1MDczMC4wIKXMDSoASAFQAw%3D%3D'),
                           ),
                         ),
                      ],
                    ),
              ],
            ),
          ),
          
          SizedBox(height: isMobile ? 16 : 24),
          
          // Copyright section
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(
                '© 2025 Sare Perde. Tüm hakları saklıdır.',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
