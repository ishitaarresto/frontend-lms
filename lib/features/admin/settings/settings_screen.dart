import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/arresto_card.dart';
import '../../../core/widgets/section_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _section = 'Admin Profile';

  static const _navSections = [
    ('Account', ['Admin Profile']),
    ('People', ['User Management', 'Approval Center', 'Roles & Permissions']),
    ('Platform', ['Course Defaults', 'AI Generation', 'Assessments', 'Certificates']),
    ('Configuration', ['Notifications', 'Branding', 'Languages', 'System']),
    ('Danger Zone', ['Delete Platform Data']),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: ArrestoColors.background,
      body: isWide
          ? Row(
              children: [
                _SettingsNav(
                    sections: _navSections,
                    selected: _section,
                    onSelect: (s) => setState(() => _section = s)),
                Expanded(child: _SettingsContent(section: _section)),
              ],
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                      icon: Icons.settings_rounded, title: 'Settings'),
                  const SizedBox(height: 16),
                  _SettingsContent(section: _section),
                ],
              ),
            ),
    );
  }
}

class _SettingsNav extends StatelessWidget {
  final List<(String, List<String>)> sections;
  final String selected;
  final ValueChanged<String> onSelect;

  const _SettingsNav({
    required this.sections,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: ArrestoColors.surface,
        border: Border(right: BorderSide(color: ArrestoColors.cardBorder)),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Text('Settings', style: ArrestoText.h3()),
          ),
          ...sections.map((section) {
            final isDanger = section.$1 == 'Danger Zone';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                  child: Text(
                    section.$1,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: ArrestoColors.textMuted2,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                ...section.$2.map((item) {
                  final isActive = selected == item;
                  return GestureDetector(
                    onTap: () => onSelect(item),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 9),
                      decoration: BoxDecoration(
                        color: isActive
                            ? ArrestoColors.amberSoft
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isDanger
                              ? ArrestoColors.red
                              : isActive
                                  ? ArrestoColors.orange
                                  : ArrestoColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  final String section;
  const _SettingsContent({required this.section});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section, style: ArrestoText.h2()),
          const SizedBox(height: 4),
          Text('Manage your $section settings',
              style: ArrestoText.small()),
          const SizedBox(height: 24),
          if (section == 'Admin Profile') _ProfileSettings(),
          if (section == 'AI Generation') _AISettings(),
          if (section == 'Notifications') _NotificationSettings(),
          if (section == 'Branding') _BrandingSettings(),
          if (section == 'Delete Platform Data') _DangerZone(),
          if (!['Admin Profile', 'AI Generation', 'Notifications', 'Branding', 'Delete Platform Data'].contains(section))
            ArrestoCard(
              child: Column(children: [
                const Icon(Icons.construction_rounded,
                    color: ArrestoColors.textMuted2, size: 32),
                const SizedBox(height: 8),
                Text('Coming soon', style: ArrestoText.body()),
              ]),
            ),
        ],
      ),
    );
  }
}

class _ProfileSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ArrestoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile Information', style: ArrestoText.h4()),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _field('First Name', 'Admin')),
              const SizedBox(width: 12),
              Expanded(child: _field('Last Name', 'User')),
            ],
          ),
          const SizedBox(height: 12),
          _field('Email', 'admin@arresto.com'),
          const SizedBox(height: 12),
          _field('Organisation', 'Arresto Safety Training'),
          const SizedBox(height: 16),
          _toggle('Receive email notifications', true),
          const SizedBox(height: 8),
          _toggle('Two-factor authentication', false),
        ],
      ),
    );
  }

  Widget _field(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ArrestoText.label()),
        const SizedBox(height: 5),
        TextFormField(initialValue: value),
      ],
    );
  }

  Widget _toggle(String label, bool value) {
    return Row(
      children: [
        Expanded(child: Text(label, style: ArrestoText.body(color: ArrestoColors.ink))),
        Switch(
          value: value,
          onChanged: (_) {},
          activeColor: ArrestoColors.amber,
          activeTrackColor: ArrestoColors.amberSoft,
        ),
      ],
    );
  }
}

class _AISettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ArrestoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI Generation Settings', style: ArrestoText.h4()),
          const SizedBox(height: 16),
          ...[
            ('Enable AI course generation', true),
            ('Auto-generate assessments', true),
            ('Use knowledge packs by default', false),
            ('Generate bilingual courses', false),
          ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(item.$1, style: ArrestoText.body(color: ArrestoColors.ink))),
                    Switch(
                      value: item.$2,
                      onChanged: (_) {},
                      activeColor: ArrestoColors.amber,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _NotificationSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ArrestoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notification Preferences', style: ArrestoText.h4()),
          const SizedBox(height: 16),
          ...[
            ('Course completion alerts', true),
            ('Assessment submissions', true),
            ('New support tickets', true),
            ('Generation completed', false),
            ('Weekly digest', true),
          ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(item.$1, style: ArrestoText.body(color: ArrestoColors.ink))),
                    Switch(
                      value: item.$2,
                      onChanged: (_) {},
                      activeColor: ArrestoColors.amber,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _BrandingSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ArrestoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Brand Settings', style: ArrestoText.h4()),
          const SizedBox(height: 16),
          Text('Primary Colour', style: ArrestoText.label()),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ArrestoColors.amber,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ArrestoColors.lineStrong),
                ),
              ),
              const SizedBox(width: 10),
              Text('#F5BE3F', style: ArrestoText.mono()),
            ],
          ),
          const SizedBox(height: 16),
          Text('Logo Upload', style: ArrestoText.label()),
          const SizedBox(height: 8),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: ArrestoColors.surfaceSoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ArrestoColors.lineStrong),
            ),
            child: Center(
              child: Text('Drop logo here or click to upload',
                  style: ArrestoText.small()),
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ArrestoColors.redSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ArrestoColors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_rounded, color: ArrestoColors.red),
              const SizedBox(width: 8),
              Text('Danger Zone',
                  style: ArrestoText.h4(color: ArrestoColors.red)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
              'These actions are irreversible. Please proceed with extreme caution.',
              style: ArrestoText.body()),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: ArrestoColors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)),
            ),
            icon: const Icon(Icons.delete_forever_rounded, size: 16),
            label: const Text('Delete All Platform Data'),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
