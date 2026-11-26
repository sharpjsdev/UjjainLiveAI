import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/speech_provider.dart';
import '../constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        ),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.tune_rounded, color: AppColors.templeGold, size: 22),
            SizedBox(width: 10),
            Text(
              'Voice & App Settings',
              style: TextStyle(
                fontSize: 17.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<SpeechProvider>(
        builder: (context, speechProvider, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            children: [
              _buildSectionHeader('Spiritual Voice Controls'),
              _buildAutoListenTile(speechProvider),
              const SizedBox(height: 10),
              _buildSpeechRateSlider(speechProvider),
              const SizedBox(height: 10),
              _buildSpeechPitchSlider(speechProvider),
              const SizedBox(height: 10),
              _buildSpeechVolumeSlider(speechProvider),
              const SizedBox(height: 10),
              _buildLanguageSelector(speechProvider),

              const SizedBox(height: 24),
              _buildSectionHeader('Hardware Permissions'),
              _buildPermissionTile(
                title: 'Microphone Access',
                subtitle: 'Required for hands-free spoken queries',
                granted: speechProvider.hasPermission,
                onTap: () => speechProvider.requestPermissions(),
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('About Ujjain Live'),
              _buildInfoTile(
                title: 'Ujjain Live',
                subtitle: 'Your Digital Guide to Sacred Ujjain (v1.0.0)',
                icon: Icons.temple_hindu_rounded,
              ),
              const SizedBox(height: 8),
              _buildInfoTile(
                title: 'Offline Capability',
                subtitle: 'Complete 18+ Ujjain attraction database embedded',
                icon: Icons.offline_bolt_rounded,
              ),
              const SizedBox(height: 8),
              _buildInfoTile(
                title: 'Sacred Motto',
                subtitle: 'हर हर महादेव • जय श्री महाकाल',
                icon: Icons.favorite_rounded,
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDark,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildSpeechRateSlider(SpeechProvider speechProvider) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Speaking Speed (गति)',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${speechProvider.speechRate.toStringAsFixed(1)}x',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: speechProvider.speechRate,
              min: 0.1,
              max: 2.0,
              divisions: 19,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.primary.withValues(alpha: 0.2),
              onChanged: (value) => speechProvider.setSpeechRate(value),
            ),
            const Text(
              'Slow speed (0.4x - 0.6x) is recommended for spiritual clarity',
              style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeechPitchSlider(SpeechProvider speechProvider) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Voice Tone / Pitch (स्वर)',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${speechProvider.speechPitch.toStringAsFixed(1)}x',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: speechProvider.speechPitch,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.primary.withValues(alpha: 0.2),
              onChanged: (value) => speechProvider.setSpeechPitch(value),
            ),
            const Text(
              'Adjusts frequency/tone for serene spiritual recitation',
              style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeechVolumeSlider(SpeechProvider speechProvider) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Output Volume (ध्वनि स्तर)',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(speechProvider.speechVolume * 100).round()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: speechProvider.speechVolume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.primary.withValues(alpha: 0.2),
              onChanged: (value) => speechProvider.setSpeechVolume(value),
            ),
            const Text(
              'Higher volume is helpful in bustling ghats and temple grounds',
              style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(SpeechProvider speechProvider) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Response & Voice Language',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: speechProvider.isHindi ? 'hi-IN' : 'en-IN',
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'en-IN', child: Text('English')),
                DropdownMenuItem(value: 'hi-IN', child: Text('Hindi')),
              ],
              onChanged: (language) {
                if (language != null) speechProvider.setLanguage(language);
              },
            ),
            const SizedBox(height: 4),
            const Text(
              'This changes AI replies, voice input, and spoken replies.',
              style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoListenTile(SpeechProvider speechProvider) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: const Text(
          'Auto-Listen to Responses',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: const Text(
          'Automatically read out AI responses aloud when they arrive (ऑटो स्पीक)',
          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
        ),
        value: speechProvider.autoSpeakResponse,
        activeColor: AppColors.primary,
        onChanged: (value) => speechProvider.setAutoSpeakResponse(value),
      ),
    );
  }

  Widget _buildPermissionTile({
    required String title,
    required String subtitle,
    required bool granted,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: granted
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (granted ? AppColors.success : AppColors.error).withValues(
              alpha: 0.12,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            granted ? Icons.mic_rounded : Icons.mic_off_rounded,
            color: granted ? AppColors.success : AppColors.error,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (granted ? AppColors.success : AppColors.error).withValues(
              alpha: 0.12,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            granted ? 'Granted' : 'Enable',
            style: TextStyle(
              color: granted ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
        ),
        onTap: granted ? null : onTap,
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
