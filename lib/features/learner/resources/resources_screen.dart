import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/arresto_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/chip_group.dart';

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  String _filter = 'All';

  static const _resources = [
    (title: 'Fall Protection Checklist',         type: 'PDF', size: '1.2 MB', cat: 'Checklists',  updated: 'Jun 2, 2026'),
    (title: 'OHSMS Compliance Matrix',            type: 'XLS', size: '2.1 MB', cat: 'Compliance',  updated: 'May 28, 2026'),
    (title: 'Suspension Trauma Field Guide',      type: 'PDF', size: '0.9 MB', cat: 'Guides',      updated: 'May 15, 2026'),
    (title: 'Anchor Point Rating Chart',          type: 'PDF', size: '0.8 MB', cat: 'Reference',   updated: 'Apr 30, 2026'),
    (title: 'Harness Inspection Worksheet',       type: 'PDF', size: '0.5 MB', cat: 'Checklists',  updated: 'Apr 10, 2026'),
    (title: 'Emergency Rescue Procedures',        type: 'PDF', size: '1.5 MB', cat: 'Guides',      updated: 'Mar 22, 2026'),
    (title: 'Site Safety Assessment Template',    type: 'XLS', size: '1.8 MB', cat: 'Compliance',  updated: 'Mar 10, 2026'),
    (title: 'Lanyard & SRL Selection Guide',      type: 'PDF', size: '0.7 MB', cat: 'Reference',   updated: 'Feb 28, 2026'),
  ];

  @override
  Widget build(BuildContext context) {
    final cats = ['All', 'Checklists', 'Guides', 'Reference', 'Compliance'];
    final filtered = _filter == 'All'
        ? _resources
        : _resources.where((r) => r.cat == _filter).toList();

    return Scaffold(
      backgroundColor: ArrestoColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    icon: Icons.download_rounded,
                    title: 'Resources',
                    subtitle: 'Course materials, guides and reference documents',
                  ),
                  const SizedBox(height: 16),
                  ChipGroup(
                    options: cats,
                    selected: _filter,
                    onChanged: (v) => setState(() => _filter = v),
                  ),
                  const SizedBox(height: 12),
                  Text('${filtered.length} files', style: ArrestoText.small()),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _ResourceRow(r: filtered[i]),
                childCount: filtered.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _ResourceRow extends StatelessWidget {
  final ({String title, String type, String size, String cat, String updated}) r;
  const _ResourceRow({required this.r});

  @override
  Widget build(BuildContext context) {
    final isPdf = r.type == 'PDF';
    final iconColor = isPdf ? ArrestoColors.red     : ArrestoColors.green;
    final iconBg    = isPdf ? ArrestoColors.redSoft  : ArrestoColors.greenSoft;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ArrestoCard(
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.description_rounded, size: 22, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${r.title}.${r.type.toLowerCase()}', style: ArrestoText.bodyBold()),
              const SizedBox(height: 2),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(4)),
                  child: Text(r.type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: iconColor)),
                ),
                const SizedBox(width: 6),
                Text(r.size, style: ArrestoText.xs()),
                const SizedBox(width: 6),
                Text('· Updated ${r.updated}', style: ArrestoText.xs()),
              ]),
            ]),
          ),
          const SizedBox(width: 10),
          _DownloadButton(type: r.type),
        ]),
      ),
    );
  }
}

class _DownloadButton extends StatefulWidget {
  final String type;
  const _DownloadButton({required this.type});
  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  bool _downloading = false;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return const Icon(Icons.check_circle_rounded, color: ArrestoColors.green, size: 24);
    }
    return IconButton(
      icon: _downloading
          ? const SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: ArrestoColors.orange))
          : const Icon(Icons.download_rounded, color: ArrestoColors.orange),
      onPressed: _downloading ? null : () async {
        setState(() => _downloading = true);
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) setState(() { _downloading = false; _done = true; });
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => _done = false);
      },
    );
  }
}
