import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/button.dart';
import '../../../core/widgets/arresto_card.dart';
import '../../../core/widgets/chip_group.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../core/widgets/course_thumb.dart';

class CourseGeneratorWizard extends StatefulWidget {
  const CourseGeneratorWizard({super.key});

  @override
  State<CourseGeneratorWizard> createState() => _CourseGeneratorWizardState();
}

class _CourseGeneratorWizardState extends State<CourseGeneratorWizard> {
  int _step = 0;

  static const _steps = [
    'Requirements',
    'Sources',
    'Packs',
    'Script',
    'Style',
    'Language',
    'Review',
    'Assessment',
    'Publish',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArrestoColors.background,
      body: Column(
        children: [
          // Stepper header
          Container(
            color: ArrestoColors.surface,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Course Generator', style: ArrestoText.h3()),
                    const Spacer(),
                    Text('Step ${_step + 1} of ${_steps.length}',
                        style: ArrestoText.small()),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedArrestoProgressBar(
                  value: (_step + 1) / _steps.length,
                  tone: ProgressTone.orange,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 56,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _steps.length,
                    itemBuilder: (ctx, i) {
                      final done = i < _step;
                      final active = i == _step;
                      return GestureDetector(
                        onTap: () => setState(() => _step = i),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Connecting line
                                  if (i > 0)
                                    Container(
                                      width: 16,
                                      height: 2,
                                      color: done || active
                                          ? ArrestoColors.orange
                                          : ArrestoColors.line,
                                    ),
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: done
                                          ? ArrestoColors.green
                                          : active
                                              ? ArrestoColors.orange
                                              : ArrestoColors.bg2,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: done
                                            ? ArrestoColors.green
                                            : active
                                                ? ArrestoColors.orange
                                                : ArrestoColors.lineStrong,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: done
                                        ? const Icon(Icons.check_rounded,
                                            size: 14, color: Colors.white)
                                        : Text(
                                            '${i + 1}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: active
                                                  ? Colors.white
                                                  : ArrestoColors.textMuted,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _steps[i],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: active
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: active
                                      ? ArrestoColors.orange
                                      : done
                                          ? ArrestoColors.green
                                          : ArrestoColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStep(_step),
            ),
          ),

          // Navigation
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: const BoxDecoration(
              color: ArrestoColors.surface,
              border:
                  Border(top: BorderSide(color: ArrestoColors.line)),
            ),
            child: Row(
              children: [
                if (_step > 0)
                  ArrestoButton(
                    label: 'Back',
                    variant: ArrestoButtonVariant.ghost,
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => setState(() => _step--),
                  ),
                const Spacer(),
                if (_step < _steps.length - 1)
                  ArrestoButton(
                    label: 'Continue',
                    icon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: () => setState(() => _step++),
                  )
                else
                  ArrestoButton(
                    label: 'Publish Course',
                    variant: ArrestoButtonVariant.dark,
                    icon: const Icon(Icons.rocket_launch_rounded),
                    onPressed: () {},
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int step) {
    return switch (step) {
      0 => _StepRequirements(),
      1 => _StepSources(),
      2 => _StepPacks(),
      3 => _StepScript(),
      4 => _StepStyle(),
      5 => _StepLanguage(),
      6 => _StepReview(),
      7 => _StepAssessment(),
      8 => _StepPublish(),
      _ => const SizedBox.shrink(),
    };
  }
}

class _StepRequirements extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ArrestoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.description_rounded,
            title: 'Course Requirements',
            subtitle: 'Define what you want to teach',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _field('Course Name', 'e.g. Working at Heights — Foundation')),
              const SizedBox(width: 12),
              Expanded(child: _field('Topic', 'e.g. Fall protection principles')),
            ],
          ),
          const SizedBox(height: 12),
          _field('Description', null, maxLines: 3),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Target Audience', style: ArrestoText.label()),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: 'Construction workers',
                      decoration: const InputDecoration(),
                      items: const [
                        'Construction workers',
                        'Site supervisors',
                        'Safety officers',
                        'All workers',
                      ]
                          .map((o) =>
                              DropdownMenuItem(value: o, child: Text(o)))
                          .toList(),
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Difficulty', style: ArrestoText.label()),
                    const SizedBox(height: 5),
                    ChipGroup(
                      options: const ['Beginner', 'Intermediate', 'Advanced'],
                      selected: 'Beginner',
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _field('Learning Objectives', 'List what learners will be able to do after this course...', maxLines: 3),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Course Length', style: ArrestoText.label()),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: '60-90 minutes',
                      decoration: const InputDecoration(),
                      items: const ['30-45 minutes', '60-90 minutes', '2-3 hours', '3+ hours']
                          .map((o) =>
                              DropdownMenuItem(value: o, child: Text(o)))
                          .toList(),
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Generation Mode', style: ArrestoText.label()),
                    const SizedBox(height: 5),
                    ChipGroup(
                      options: const ['Quick', 'Detailed'],
                      selected: 'Detailed',
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String? hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ArrestoText.label()),
        const SizedBox(height: 5),
        TextFormField(
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

class _StepSources extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ArrestoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.upload_file_rounded,
            title: 'Source Documents',
            subtitle: 'Upload PDFs, Word docs, or videos to train the AI',
          ),
          const SizedBox(height: 16),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: ArrestoColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: ArrestoColors.lineStrong,
                  style: BorderStyle.solid),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_upload_rounded,
                      size: 36, color: ArrestoColors.textMuted2),
                  const SizedBox(height: 8),
                  Text('Drag and drop files here',
                      style: ArrestoText.bodyMd()),
                  Text('PDF, DOCX, MP4, MP3 up to 500MB',
                      style: ArrestoText.small()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Mock uploaded file
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ArrestoColors.surfaceSoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ArrestoColors.line),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: ArrestoColors.redSoft,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('PDF',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: ArrestoColors.red)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WAH_Standard_AS1891.pdf',
                          style: ArrestoText.bodyBold()),
                      Text('2.4 MB', style: ArrestoText.xs()),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle_rounded,
                    color: ArrestoColors.green, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepPacks extends StatelessWidget {
  static const _packs = [
    ('AS/NZS Standards', 'Australian & NZ safety standards', 42, Icons.book_rounded, ArrestoColors.blue),
    ('WorkSafe Guidelines', 'Workplace health & safety guidelines', 28, Icons.security_rounded, ArrestoColors.green),
    ('OSHA Library', 'US occupational safety standards', 87, Icons.account_balance_rounded, ArrestoColors.orange),
    ('ISO Documents', 'International safety standards', 34, Icons.public_rounded, ArrestoColors.amber),
    ('Arresto Internal', 'Company-specific procedures', 16, Icons.business_rounded, ArrestoColors.red),
    ('Training Videos', 'Reference training materials', 22, Icons.video_library_rounded, ArrestoColors.blue),
  ];

  @override
  Widget build(BuildContext context) {
    return ArrestoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.library_books_rounded,
            title: 'Knowledge Packs',
            subtitle: 'Select reference materials for the AI',
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: _packs.length,
            itemBuilder: (ctx, i) {
              final p = _packs[i];
              return _PackCard(
                name: p.$1,
                desc: p.$2,
                docs: p.$3,
                icon: p.$4,
                color: p.$5,
                selected: i < 2,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PackCard extends StatefulWidget {
  final String name;
  final String desc;
  final int docs;
  final IconData icon;
  final Color color;
  final bool selected;

  const _PackCard({
    required this.name,
    required this.desc,
    required this.docs,
    required this.icon,
    required this.color,
    required this.selected,
  });

  @override
  State<_PackCard> createState() => _PackCardState();
}

class _PackCardState extends State<_PackCard> {
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _selected = !_selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _selected
              ? widget.color.withOpacity(0.08)
              : ArrestoColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selected ? widget.color : ArrestoColors.line,
            width: _selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, color: widget.color, size: 20),
                const Spacer(),
                Checkbox(
                  value: _selected,
                  onChanged: (v) => setState(() => _selected = v ?? false),
                  activeColor: widget.color,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(widget.name, style: ArrestoText.bodyBold()),
            Text('${widget.docs} documents',
                style: ArrestoText.xs()),
          ],
        ),
      ),
    );
  }
}

class _StepScript extends StatefulWidget {
  @override
  State<_StepScript> createState() => _StepScriptState();
}

class _StepScriptState extends State<_StepScript> {
  bool _generating = false;
  double _progress = 0;
  bool _done = false;
  int _stage = 0;

  static const _stages = [
    'Analysing requirements...',
    'Processing source documents...',
    'Generating course structure...',
    'Writing lesson content...',
    'Finalising script...',
  ];

  Future<void> _generate() async {
    setState(() {
      _generating = true;
      _progress = 0;
      _stage = 0;
    });

    for (int i = 0; i < 5; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() {
        _progress = (i + 1) / 5;
        _stage = i;
      });
    }

    setState(() {
      _generating = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ArrestoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                icon: Icons.auto_fix_high_rounded,
                title: 'Script Generation',
                subtitle: 'Configure AI settings and generate your course',
              ),
              const SizedBox(height: 16),
              Text('AI Configuration', style: ArrestoText.label()),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Depth', style: ArrestoText.xs()),
                        const SizedBox(height: 4),
                        ChipGroup(
                          options: const ['Overview', 'Standard', 'Deep Dive'],
                          selected: 'Standard',
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tone', style: ArrestoText.xs()),
                        const SizedBox(height: 4),
                        ChipGroup(
                          options: const ['Formal', 'Conversational', 'Technical'],
                          selected: 'Conversational',
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!_generating && !_done)
                ArrestoButton(
                  label: 'Generate Script',
                  fullWidth: true,
                  size: ArrestoButtonSize.lg,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  variant: ArrestoButtonVariant.orange,
                  onPressed: _generate,
                ),
              if (_generating) ...[
                AnimatedArrestoProgressBar(
                  value: _progress,
                  tone: ProgressTone.orange,
                ),
                const SizedBox(height: 8),
                Text(_stages[_stage],
                    style: ArrestoText.small()),
              ],
            ],
          ),
        ),
        if (_done) ...[
          const SizedBox(height: 16),
          _CourseOutline(),
        ],
      ],
    );
  }
}

class _CourseOutline extends StatelessWidget {
  static const _modules = [
    ('Module 1 — Introduction to Fall Protection', [
      'What is fall protection?',
      'Regulatory framework',
      'Statistics and case studies',
    ]),
    ('Module 2 — Equipment & Systems', [
      'Harness types and selection',
      'Anchor point requirements',
      'Connecting devices',
      'Inspection procedures',
    ]),
    ('Module 3 — Practical Application', [
      'Pre-use inspection checklist',
      'Donning and adjustment',
      'Working safely at height',
      'Emergency response',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return ArrestoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Course Outline', style: ArrestoText.h3()),
              const Spacer(),
              const Icon(Icons.check_circle_rounded,
                  color: ArrestoColors.green, size: 18),
              const SizedBox(width: 4),
              Text('Generated', style: ArrestoText.small(color: ArrestoColors.green)),
            ],
          ),
          const SizedBox(height: 14),
          ..._modules.map((m) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ArrestoColors.line),
              ),
              child: Theme(
                data: ThemeData(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(m.$1, style: ArrestoText.bodyBold()),
                  iconColor: ArrestoColors.orange,
                  children: m.$2.map((lesson) {
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.video_library_rounded,
                          size: 16, color: ArrestoColors.orange),
                      title: Text(lesson, style: ArrestoText.body()),
                      trailing: const Icon(Icons.drag_handle_rounded,
                          size: 16, color: ArrestoColors.textMuted2),
                    );
                  }).toList(),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StepStyle extends StatefulWidget {
  @override
  State<_StepStyle> createState() => _StepStyleState();
}

class _StepStyleState extends State<_StepStyle> {
  int _selected = 0;

  static const _styles = [
    ('Animated Scene', 'Professional animated video with voiceover', CourseStyle.animated),
    ('Whiteboard', 'Hand-drawn whiteboard style animation', CourseStyle.whiteboard),
    ('AI Presenter', 'Realistic AI presenter with background', CourseStyle.claude),
    ('Hybrid', 'Mix of animated and live action', CourseStyle.hybrid),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose Video Style', style: ArrestoText.h3()),
        const SizedBox(height: 6),
        Text('Select the visual style for your course videos',
            style: ArrestoText.small()),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.9,
          ),
          itemCount: _styles.length,
          itemBuilder: (ctx, i) {
            final s = _styles[i];
            final isSelected = _selected == i;
            return GestureDetector(
              onTap: () => setState(() => _selected = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: ArrestoColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? ArrestoColors.orange
                        : ArrestoColors.cardBorder,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? ArrestoColors.sh3
                      : ArrestoColors.sh1,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Column(
                    children: [
                      CourseThumb(style: s.$3, height: 120),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.$1, style: ArrestoText.h4()),
                              const SizedBox(height: 4),
                              Text(s.$2,
                                  style: ArrestoText.small(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              if (isSelected) ...[
                                const Spacer(),
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        size: 14,
                                        color: ArrestoColors.orange),
                                    const SizedBox(width: 4),
                                    Text('Selected',
                                        style: ArrestoText.small(
                                            color: ArrestoColors.orange)
                                          ..copyWith(fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StepLanguage extends StatefulWidget {
  @override
  State<_StepLanguage> createState() => _StepLanguageState();
}

class _StepLanguageState extends State<_StepLanguage> {
  String _language = 'English';
  bool _subtitles = true;

  static const _languages = [
    ('English', '🇺🇸'),
    ('Spanish', '🇪🇸'),
    ('French', '🇫🇷'),
    ('German', '🇩🇪'),
    ('Chinese (Simplified)', '🇨🇳'),
    ('Arabic', '🇸🇦'),
    ('Portuguese', '🇧🇷'),
    ('Hindi', '🇮🇳'),
  ];

  @override
  Widget build(BuildContext context) {
    return ArrestoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.language_rounded,
            title: 'Language & Voice',
            subtitle: 'Configure output language and voice settings',
          ),
          const SizedBox(height: 16),
          Text('Primary Language', style: ArrestoText.label()),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.5,
            ),
            itemCount: _languages.length,
            itemBuilder: (ctx, i) {
              final l = _languages[i];
              final isSelected = _language == l.$1;
              return GestureDetector(
                onTap: () => setState(() => _language = l.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ArrestoColors.amberSoft
                        : ArrestoColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? ArrestoColors.amber
                          : ArrestoColors.line,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(l.$2,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(l.$1,
                            style: ArrestoText.bodySm(
                                color: isSelected
                                    ? ArrestoColors.ink
                                    : null),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text('Include subtitles / captions',
                    style: ArrestoText.body(color: ArrestoColors.ink)),
              ),
              Switch(
                value: _subtitles,
                onChanged: (v) => setState(() => _subtitles = v),
                activeColor: ArrestoColors.amber,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepReview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review Course', style: ArrestoText.h3()),
        const SizedBox(height: 6),
        Text('Confirm everything looks correct before generating',
            style: ArrestoText.small()),
        const SizedBox(height: 16),
        ArrestoCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15)),
                child: const CourseThumb(
                    style: CourseStyle.animated, height: 160),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FALL PROTECTION · BEGINNER',
                        style: ArrestoText.eyebrow()),
                    const SizedBox(height: 4),
                    Text('Working at Heights — Foundation',
                        style: ArrestoText.h2()),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _chip(Icons.menu_book_rounded, '3 modules'),
                        const SizedBox(width: 12),
                        _chip(Icons.video_library_rounded, '10 lessons'),
                        const SizedBox(width: 12),
                        _chip(Icons.schedule_rounded, '90 min'),
                        const SizedBox(width: 12),
                        _chip(Icons.language_rounded, 'English'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: ArrestoColors.textMuted),
        const SizedBox(width: 4),
        Text(label, style: ArrestoText.small()),
      ],
    );
  }
}

class _StepAssessment extends StatefulWidget {
  @override
  State<_StepAssessment> createState() => _StepAssessmentState();
}

class _StepAssessmentState extends State<_StepAssessment> {
  bool _generating = false;
  bool _done = false;
  double _progress = 0;

  Future<void> _generate() async {
    setState(() {
      _generating = true;
      _progress = 0;
    });
    for (int i = 0; i < 4; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _progress = (i + 1) / 4);
    }
    setState(() {
      _generating = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ArrestoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.quiz_rounded,
            title: 'Assessment Configuration',
            subtitle: 'Configure and generate the course assessment',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _numField('Questions', '10')),
              const SizedBox(width: 12),
              Expanded(child: _numField('Pass %', '70')),
              const SizedBox(width: 12),
              Expanded(child: _numField('Time (min)', '30')),
              const SizedBox(width: 12),
              Expanded(child: _numField('Retakes', '3')),
            ],
          ),
          const SizedBox(height: 12),
          Text('Question Types', style: ArrestoText.label()),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              ArrestoChip(label: 'Multiple Choice', active: true),
              ArrestoChip(label: 'True/False', active: true),
              ArrestoChip(label: 'Scenario', active: false),
              ArrestoChip(label: 'Descriptive', active: false),
            ],
          ),
          const SizedBox(height: 16),
          if (!_generating && !_done)
            ArrestoButton(
              label: 'Generate Assessment',
              fullWidth: true,
              variant: ArrestoButtonVariant.orange,
              icon: const Icon(Icons.auto_awesome_rounded),
              onPressed: _generate,
            ),
          if (_generating) ...[
            AnimatedArrestoProgressBar(
                value: _progress, tone: ProgressTone.orange),
            const SizedBox(height: 6),
            Text('Generating questions...', style: ArrestoText.small()),
          ],
          if (_done) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: ArrestoColors.green, size: 18),
                const SizedBox(width: 6),
                Text('10 questions generated',
                    style: ArrestoText.body(color: ArrestoColors.green)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _numField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ArrestoText.label()),
        const SizedBox(height: 5),
        TextFormField(initialValue: value),
      ],
    );
  }
}

class _StepPublish extends StatefulWidget {
  @override
  State<_StepPublish> createState() => _StepPublishState();
}

class _StepPublishState extends State<_StepPublish> {
  String _mode = 'Publish Now';
  bool _notifyLearners = true;
  bool _requireCompletion = true;

  @override
  Widget build(BuildContext context) {
    return ArrestoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.rocket_launch_rounded,
            title: 'Publish Course',
            subtitle: 'Set publishing options and assign to learners',
          ),
          const SizedBox(height: 16),
          Text('Publish Mode', style: ArrestoText.label()),
          const SizedBox(height: 8),
          ChipGroup(
            options: const ['Publish Now', 'Save as Draft', 'Schedule'],
            selected: _mode,
            onChanged: (v) => setState(() => _mode = v),
          ),
          const SizedBox(height: 16),
          Text('Assign to Learners', style: ArrestoText.label()),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: 'All Active Learners',
            decoration: const InputDecoration(),
            items: const ['All Active Learners', 'Selected Groups', 'No one yet']
                .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                .toList(),
            onChanged: (_) {},
          ),
          const SizedBox(height: 16),
          ...[
            ('Notify learners on publish', _notifyLearners, (v) => setState(() => _notifyLearners = v)),
            ('Require completion for certificate', _requireCompletion, (v) => setState(() => _requireCompletion = v)),
          ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(item.$1,
                            style: ArrestoText.body(
                                color: ArrestoColors.ink))),
                    Switch(
                      value: item.$2,
                      onChanged: item.$3,
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
