import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/url_launcher_util.dart';

import '../../../../app/app.dart';
import '../bloc/settings_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(context.l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader(title: context.l10n.settingsAccount),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, auth) {
              if (auth.isAuthenticated && auth.user != null) {
                return _AccountTile(
                  initials: auth.user!.initials,
                  name: auth.user!.displayName ?? 'Anonymous',
                  email: auth.user!.email ?? '',
                  onSignOut: () => context
                      .read<AuthBloc>()
                      .add(const AuthSignOutRequested()),
                );
              }
              return _SettingsTile(
                icon: Icons.login_rounded,
                title: context.l10n.settingsSignIn,
                subtitle: 'Required to report missing persons',
                onTap: () => context.pushNamed(RouteNames.loginName),
                trailing: const Icon(Icons.chevron_right_rounded,
                    size: 18, color: AppColors.textMuted),
              );
            },
          ),
          const _Divider(),
          _SectionHeader(title: context.l10n.settingsLanguage),
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, settings) => Column(
              children: [
                _LanguageTile(
                  flag: '🇬🇧',
                  label: 'English',
                  selected: !settings.isPortuguese,
                  onTap: () => context
                      .read<SettingsBloc>()
                      .add(const SettingsLocaleChanged(Locale('en'))),
                ),
                _LanguageTile(
                  flag: '🇧🇷',
                  label: 'Português',
                  selected: settings.isPortuguese,
                  onTap: () => context
                      .read<SettingsBloc>()
                      .add(const SettingsLocaleChanged(Locale('pt'))),
                ),
              ],
            ),
          ),
          const _Divider(),
          _SectionHeader(title: context.l10n.settingsEmergency),
          _SettingsTile(
            icon: Icons.sos_rounded,
            iconColor: AppColors.primary,
            title: 'Emergency number',
            subtitle: '112 — European emergency services',
            onTap: () async {
              final uri = Uri.parse(AppConstants.emergencyNumber);
              await launchSafely(uri.toString());
            },
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('112',
                  style: AppTextTheme.labelLarge
                      .copyWith(color: AppColors.textOnRed)),
            ),
          ),
          const _Divider(),
          _SectionHeader(title: context.l10n.settingsAbout),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: context.l10n.settingsVersion,
            subtitle: AppConstants.appVersion,
          ),
          _SettingsTile(
            icon: Icons.shield_outlined,
            title: context.l10n.settingsPrivacy,
            onTap: () async {
              final uri = Uri.parse('https://www.anthropic.com/privacy');
              await launchSafely(uri.toString());
            },
            trailing: const Icon(Icons.open_in_new_rounded,
                size: 14, color: AppColors.textMuted),
          ),
          _SettingsTile(
            icon: Icons.business_outlined,
            title: context.l10n.settingsDataSources,
            subtitle: 'INTERPOL Yellow Notices + community reports',
          ),
          _SettingsTile(
            icon: Icons.language_outlined,
            title: 'INTERPOL',
            subtitle: 'ws-public.interpol.int',
            onTap: () async {
              final uri = Uri.parse(
                  'https://www.interpol.int/en/How-we-work/Notices/Yellow-Notices');
              await launchSafely(uri.toString());
            },
            trailing: const Icon(Icons.open_in_new_rounded,
                size: 14, color: AppColors.textMuted),
          ),
          const _Divider(),
          const _SectionHeader(title: 'Admin'),
          _SettingsTile(
            icon: Icons.admin_panel_settings_outlined,
            iconColor: AppColors.warning,
            title: 'Review pending cases',
            subtitle: 'Approve or reject community reports',
            onTap: () => context.pushNamed(RouteNames.adminName),
            trailing: const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textMuted),
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Icon(Icons.person_search_rounded,
                          color: AppColors.textOnRed, size: 13),
                    ),
                    const SizedBox(width: 8),
                    Text('Where Am I?', style: AppTextTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'v${AppConstants.appVersion} · Missing persons registry',
                  style: AppTextTheme.caption,
                ),
                const SizedBox(height: 4),
                Text(
                  'Data from INTERPOL & community reports',
                  style: AppTextTheme.caption,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final String initials;
  final String name;
  final String email;
  final VoidCallback onSignOut;

  const _AccountTile({
    required this.initials,
    required this.name,
    required this.email,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primaryDark,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: AppTextTheme.headlineSmall.copyWith(
                    color: AppColors.textOnRed,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextTheme.titleMedium),
                  if (email.isNotEmpty)
                    Text(email,
                        style: AppTextTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            TextButton(
              onPressed: onSignOut,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
              ),
              child: Text(
                context.l10n.settingsSignOut,
                style:
                    AppTextTheme.labelMedium.copyWith(color: AppColors.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Text(flag, style: const TextStyle(fontSize: 22)),
      title: Text(label, style: AppTextTheme.bodyMedium),
      trailing: AnimatedSwitcher(
        duration: AppConstants.animFast,
        child: selected
            ? const Icon(Icons.check_rounded,
                key: ValueKey('check'), size: 18, color: AppColors.primary)
            : const SizedBox.shrink(key: ValueKey('empty')),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            Icon(icon, size: 18, color: iconColor ?? AppColors.textSecondary),
      ),
      title: Text(title, style: AppTextTheme.titleMedium),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTextTheme.bodySmall)
          : null,
      trailing: trailing,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Text(title.toUpperCase(), style: AppTextTheme.overline),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
        height: 1, indent: 20, endIndent: 20, color: AppColors.divider);
  }
}
