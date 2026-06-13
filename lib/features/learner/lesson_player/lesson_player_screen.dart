import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/arresto_card.dart';
import '../../../core/widgets/button.dart';
import '../../../data/providers/app_state.dart';
import '../../../data/models/lesson.dart' show CourseLesson;
import '../../../data/models/course.dart';

// ── Note model ────────────────────────────────────────────────────────────────
class _Note {
  final String timestamp;
  final String text;
  _Note(this.timestamp, this.text);
}

// ── Lesson player screen ──────────────────────────────────────────────────────
class LessonPlayerScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String lessonId;
  const LessonPlayerScreen({super.key, required this.courseId, required this.lessonId});

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  Timer? _ticker;
  bool  _playing    = false;
  int   _posSecs    = 0;
  bool  _showKCheck = false;
  int?  _kcAnswer;
  bool  _kcDone     = false;
  int   _xp         = 120;
  int   _answered   = 0;
  String _activeTab = 'Notes';

  final _noteCtrl = TextEditingController();
  final List<_Note> _notes = [];

  // Knowledge-check question shown mid-lesson
  static const _kc = (
    q: 'Before connecting your lanyard, what\'s the minimum rating an anchor point must have?',
    opts: ['10 kN', '22 kN', '5 kN', 'Any steel beam'],
    correct: 1, // 22 kN
  );

  @override
  void initState() {
    super.initState();
    final lessons = ref.read(lessonsProvider);
    final lesson  = _lesson(lessons);
    if (lesson != null) _posSecs = lesson.savedPositionSecs;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _noteCtrl.dispose();
    super.dispose();
  }

  CourseLesson? _lesson(List<CourseLesson> lessons) =>
      lessons.where((l) => l.id == widget.lessonId).firstOrNull;

  void _togglePlay() {
    if (_showKCheck && !_kcDone) return; // blocked by knowledge check
    setState(() => _playing = !_playing);
    if (_playing) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          final lessons = ref.read(lessonsProvider);
          final dur = _lesson(lessons)?.durationSecs ?? 540;
          if (_posSecs < dur) {
            _posSecs++;
            // Trigger knowledge check at 25% if not done
            if (!_kcDone && _posSecs == (dur * 0.25).round()) {
              _playing = false;
              _ticker?.cancel();
              _showKCheck = true;
            }
          } else {
            _playing = false;
            _ticker?.cancel();
          }
        });
      });
    } else {
      _ticker?.cancel();
    }
  }

  void _answerKc(int idx) {
    setState(() {
      _kcAnswer = idx;
      _kcDone   = true;
      if (idx == _kc.correct) {
        _xp += 10;
        _answered++;
      }
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _showKCheck = false;
        _kcAnswer   = null;
      });
      _togglePlay();
    });
  }

  void _addNote(CourseLesson lesson) {
    final text = _noteCtrl.text.trim();
    if (text.isEmpty) return;
    final m = _posSecs ~/ 60;
    final s = _posSecs % 60;
    final ts = '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
    setState(() => _notes.add(_Note(ts, text)));
    _noteCtrl.clear();
  }

  String _fmtSecs(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final lessons  = ref.watch(lessonsProvider);
    final courses  = ref.watch(coursesProvider);
    final lesson   = _lesson(lessons);
    if (lesson == null) return const Scaffold(body: Center(child: Text('Lesson not found')));

    final course   = courses.firstWhere((c) => c.id == widget.courseId, orElse: () => courses.first);
    final dur      = lesson.durationSecs;
    final progress = dur > 0 ? _posSecs / dur : 0.0;

    // Lessons for this course
    final courseLessons = lessons.where((l) => l.courseId == widget.courseId).toList();
    final lessonIndex   = courseLessons.indexWhere((l) => l.id == widget.lessonId);
    final hasPrev       = lessonIndex > 0;
    final hasNext       = lessonIndex < courseLessons.length - 1;

    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: ArrestoColors.background,
      body: Column(
        children: [
          // ── Top breadcrumb bar ─────────────────────────────────────────────
          Container(
            color: ArrestoColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              TextButton.icon(
                onPressed: () => context.go('/learner/course/${widget.courseId}'),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: Text(course.title, style: ArrestoText.bodyMd()),
                style: TextButton.styleFrom(foregroundColor: ArrestoColors.ink),
              ),
            ]),
          ),

          // ── Body ───────────────────────────────────────────────────────────
          Expanded(
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: player + tabs
                      Expanded(child: _LeftPanel(
                        lesson: lesson, course: course,
                        courseLessons: courseLessons, lessonIndex: lessonIndex,
                        posSecs: _posSecs, dur: dur, progress: progress,
                        playing: _playing, showKCheck: _showKCheck,
                        kcAnswer: _kcAnswer, kcDone: _kcDone,
                        hasPrev: hasPrev, hasNext: hasNext,
                        notes: _notes, noteCtrl: _noteCtrl,
                        activeTab: _activeTab,
                        onTogglePlay: _togglePlay,
                        onAnswerKc: _answerKc,
                        onAddNote: () => _addNote(lesson),
                        onDeleteNote: (i) => setState(() => _notes.removeAt(i)),
                        onTabChange: (t) => setState(() => _activeTab = t),
                        onPrev: hasPrev ? () {
                          _ticker?.cancel();
                          context.go('/learner/lesson/${widget.courseId}/${courseLessons[lessonIndex - 1].id}');
                        } : null,
                        onNext: hasNext ? () {
                          _ticker?.cancel();
                          context.go('/learner/lesson/${widget.courseId}/${courseLessons[lessonIndex + 1].id}');
                        } : null,
                        fmtSecs: _fmtSecs,
                      )),
                      // Right: learning companion
                      SizedBox(
                        width: 300,
                        child: _RightSidebar(
                          lesson: lesson, course: course,
                          courseLessons: courseLessons,
                          lessonIndex: lessonIndex,
                          lessonProgress: progress,
                          xp: _xp, answered: _answered,
                          courseProgress: course.progress / 100,
                          onGoToQuiz: () => context.go('/learner/assessment/${widget.courseId}'),
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(child: Column(children: [
                    _VideoBox(
                      lesson: lesson, posSecs: _posSecs, dur: dur, progress: progress,
                      playing: _playing, showKCheck: _showKCheck,
                      kcAnswer: _kcAnswer, kcDone: _kcDone,
                      onTogglePlay: _togglePlay, onAnswerKc: _answerKc, fmtSecs: _fmtSecs,
                    ),
                    _RightSidebar(
                      lesson: lesson, course: course, courseLessons: courseLessons,
                      lessonIndex: lessonIndex, lessonProgress: progress,
                      xp: _xp, answered: _answered, courseProgress: course.progress / 100,
                      onGoToQuiz: () => context.go('/learner/assessment/${widget.courseId}'),
                    ),
                  ])),
          ),
        ],
      ),
    );
  }
}

// ── Left panel (player + tabs) ────────────────────────────────────────────────
class _LeftPanel extends StatelessWidget {
  final CourseLesson lesson;
  final Course course;
  final List<CourseLesson> courseLessons;
  final int lessonIndex, posSecs, dur;
  final double progress;
  final bool playing, showKCheck, kcDone;
  final int? kcAnswer;
  final bool hasPrev, hasNext;
  final List<_Note> notes;
  final TextEditingController noteCtrl;
  final String activeTab;
  final VoidCallback onTogglePlay;
  final Function(int) onAnswerKc;
  final VoidCallback onAddNote;
  final Function(int) onDeleteNote;
  final Function(String) onTabChange;
  final VoidCallback? onPrev, onNext;
  final String Function(int) fmtSecs;

  const _LeftPanel({
    required this.lesson, required this.course, required this.courseLessons, // CourseLesson
    required this.lessonIndex, required this.posSecs, required this.dur,
    required this.progress, required this.playing, required this.showKCheck,
    required this.kcAnswer, required this.kcDone, required this.hasPrev,
    required this.hasNext, required this.notes, required this.noteCtrl,
    required this.activeTab, required this.onTogglePlay, required this.onAnswerKc,
    required this.onAddNote, required this.onDeleteNote, required this.onTabChange,
    required this.onPrev, required this.onNext, required this.fmtSecs,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Lesson title header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${lesson.module} · Lesson ${lessonIndex + 1} of ${courseLessons.length}',
              style: ArrestoText.small(),
            ),
            const SizedBox(height: 2),
            Text(lesson.title, style: ArrestoText.h2()),
          ]),
        ),

        // Video player
        _VideoBox(
          lesson: lesson, posSecs: posSecs, dur: dur, progress: progress,
          playing: playing, showKCheck: showKCheck,
          kcAnswer: kcAnswer, kcDone: kcDone,
          onTogglePlay: onTogglePlay, onAnswerKc: onAnswerKc, fmtSecs: fmtSecs,
        ),

        // Prev / Next
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            ArrestoButton(
              label: 'Prev',
              variant: ArrestoButtonVariant.ghost,
              size: ArrestoButtonSize.sm,
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: onPrev,
            ),
            const Spacer(),
            ArrestoButton(
              label: 'Next lesson',
              size: ArrestoButtonSize.sm,
              icon: const Icon(Icons.arrow_forward_rounded),
              onPressed: onNext,
            ),
            const SizedBox(width: 12),
            ArrestoButton(
              label: 'Ask Arresto AI',
              variant: ArrestoButtonVariant.ghost,
              size: ArrestoButtonSize.sm,
              icon: const Icon(Icons.smart_toy_rounded),
              onPressed: () {},
            ),
          ]),
        ),

        const Divider(height: 1),

        // Tabs
        _TabBar(activeTab: activeTab, noteCount: notes.length, onTabChange: onTabChange),

        const Divider(height: 1),

        // Tab content
        Padding(
          padding: const EdgeInsets.all(20),
          child: activeTab == 'Notes'
              ? _NotesTab(
                  notes: notes, noteCtrl: noteCtrl,
                  onAdd: onAddNote, onDelete: onDeleteNote,
                )
              : activeTab == 'Resources'
                  ? _ResourcesTab()
                  : _TranscriptTab(lesson: lesson),
        ),

        // Related lessons
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.grid_view_rounded, size: 18, color: ArrestoColors.orange),
              const SizedBox(width: 8),
              Text('Related lessons', style: ArrestoText.h3()),
            ]),
            const SizedBox(height: 4),
            Text('In this course', style: ArrestoText.small()),
            const SizedBox(height: 12),
            ...courseLessons.where((l) => l.id != lesson.id).take(3).map((l) => _RelatedLessonRow(lesson: l)),
          ]),
        ),
      ]),
    );
  }
}

// ── Video box (simulated player) ──────────────────────────────────────────────
class _VideoBox extends StatelessWidget {
  final CourseLesson lesson;
  final int posSecs, dur;
  final double progress;
  final bool playing, showKCheck, kcDone;
  final int? kcAnswer;
  final VoidCallback onTogglePlay;
  final Function(int) onAnswerKc;
  final String Function(int) fmtSecs;

  const _VideoBox({
    required this.lesson, required this.posSecs, required this.dur,
    required this.progress, required this.playing, required this.showKCheck,
    required this.kcAnswer, required this.kcDone,
    required this.onTogglePlay, required this.onAnswerKc, required this.fmtSecs,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Video area
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: const Color(0xFF111111),
            child: Stack(
              children: [
                // "Video" gradient background
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1a1a1a), Color(0xFF0d0d0d)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                // Play state indicator
                if (!playing && !showKCheck)
                  Center(
                    child: GestureDetector(
                      onTap: onTogglePlay,
                      child: Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          color: ArrestoColors.amber,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: ArrestoColors.amber.withValues(alpha: 0.4), blurRadius: 24)],
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: ArrestoColors.ink, size: 40),
                      ),
                    ),
                  ),
                if (playing)
                  Positioned(
                    right: 16, top: 16,
                    child: GestureDetector(
                      onTap: onTogglePlay,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.pause_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ),

                // Knowledge check overlay
                if (showKCheck) _KnowledgeCheckOverlay(kcAnswer: kcAnswer, kcDone: kcDone, onAnswer: onAnswerKc),

                // Bottom progress bar + controls
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xDD000000), Colors.transparent],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 24, 12, 8),
                    child: Column(children: [
                      // Scrub bar
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                          activeTrackColor: ArrestoColors.amber,
                          inactiveTrackColor: Colors.white30,
                          thumbColor: ArrestoColors.amber,
                          overlayColor: ArrestoColors.amber.withValues(alpha: 0.3),
                        ),
                        child: Slider(
                          value: progress.clamp(0.0, 1.0),
                          onChanged: (_) {},
                        ),
                      ),
                      // Controls row
                      Row(children: [
                        _ctrl(Icons.replay_10_rounded, () {}),
                        _ctrl(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, onTogglePlay),
                        _ctrl(Icons.forward_10_rounded, () {}),
                        _ctrl(Icons.volume_up_rounded, () {}),
                        const SizedBox(width: 6),
                        Text(
                          '${fmtSecs(posSecs)} / ${fmtSecs(dur)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const Spacer(),
                        _speedChip(),
                        const SizedBox(width: 6),
                        _pill('CC'),
                        const SizedBox(width: 6),
                        _ctrl(Icons.note_alt_outlined, () {}),
                        _ctrl(Icons.grid_view_rounded, () {}),
                        _ctrl(Icons.fullscreen_rounded, () {}),
                      ]),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _ctrl(IconData icon, VoidCallback onTap) => IconButton(
        icon: Icon(icon, color: Colors.white70, size: 20),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      );

  Widget _speedChip() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text('1×', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
      );

  Widget _pill(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
      );
}

// ── Knowledge check overlay ───────────────────────────────────────────────────
class _KnowledgeCheckOverlay extends StatelessWidget {
  final int? kcAnswer;
  final bool kcDone;
  final Function(int) onAnswer;

  static const _kc = (
    q: 'Before connecting your lanyard, what\'s the minimum rating an anchor point must have?',
    opts: ['10 kN', '22 kN', '5 kN', 'Any steel beam'],
    correct: 1,
  );

  const _KnowledgeCheckOverlay({this.kcAnswer, required this.kcDone, required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: ArrestoColors.amberSoft, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.smart_toy_rounded, color: ArrestoColors.orange, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Arresto AI · Knowledge check', style: ArrestoText.bodyBold()),
                    Text('Answer to continue your lesson', style: ArrestoText.small()),
                  ]),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: ArrestoColors.blueSoft, borderRadius: BorderRadius.circular(6)),
                  child: const Text('MCQ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: ArrestoColors.blue)),
                ),
                const SizedBox(height: 10),
                Text(_kc.q, style: ArrestoText.bodyBold()),
                const SizedBox(height: 12),
                ...List.generate(_kc.opts.length, (i) {
                  final label = String.fromCharCode(65 + i);
                  final isSelected = kcAnswer == i;
                  final isCorrect  = i == _kc.correct;
                  Color bg = Colors.white;
                  Color border = ArrestoColors.line;
                  if (kcDone && isSelected) {
                    bg     = isCorrect ? ArrestoColors.greenSoft : ArrestoColors.redSoft;
                    border = isCorrect ? ArrestoColors.green      : ArrestoColors.red;
                  } else if (kcDone && isCorrect) {
                    bg = ArrestoColors.greenSoft; border = ArrestoColors.green;
                  }
                  return GestureDetector(
                    onTap: kcDone ? null : () => onAnswer(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: border),
                      ),
                      child: Row(children: [
                        Container(
                          width: 26, height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? ArrestoColors.ink : ArrestoColors.bg2,
                          ),
                          alignment: Alignment.center,
                          child: Text(label, style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : ArrestoColors.textMuted,
                          )),
                        ),
                        const SizedBox(width: 12),
                        Text(_kc.opts[i], style: ArrestoText.bodyBold()),
                        if (kcDone && isCorrect) ...[
                          const Spacer(),
                          const Icon(Icons.check_circle_rounded, color: ArrestoColors.green, size: 18),
                        ],
                        if (kcDone && isSelected && !isCorrect) ...[
                          const Spacer(),
                          const Icon(Icons.cancel_rounded, color: ArrestoColors.red, size: 18),
                        ],
                      ]),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tab bar ───────────────────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final String activeTab;
  final int noteCount;
  final Function(String) onTabChange;
  const _TabBar({required this.activeTab, required this.noteCount, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['Notes', 'Resources', 'Transcript'].map((tab) {
        final active = tab == activeTab;
        return GestureDetector(
          onTap: () => onTabChange(tab),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: active ? ArrestoColors.orange : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(tab, style: active ? ArrestoText.bodyBold(color: ArrestoColors.orange) : ArrestoText.body()),
              if (tab == 'Notes' && noteCount > 0) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: ArrestoColors.orange, borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text('$noteCount', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ],
            ]),
          ),
        );
      }).toList(),
    );
  }
}

// ── Notes tab ─────────────────────────────────────────────────────────────────
class _NotesTab extends StatelessWidget {
  final List<_Note> notes;
  final TextEditingController noteCtrl;
  final VoidCallback onAdd;
  final Function(int) onDelete;
  const _NotesTab({required this.notes, required this.noteCtrl, required this.onAdd, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Input
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
          child: TextField(
            controller: noteCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Write a note…'),
          ),
        ),
        const SizedBox(width: 10),
        ArrestoButton(label: 'Add note', size: ArrestoButtonSize.sm, onPressed: onAdd),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        ArrestoButton(
          label: 'Arresto AI notes',
          size: ArrestoButtonSize.sm,
          variant: ArrestoButtonVariant.ghost,
          icon: const Icon(Icons.smart_toy_rounded),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        ArrestoButton(
          label: 'Export',
          size: ArrestoButtonSize.sm,
          variant: ArrestoButtonVariant.ghost,
          icon: const Icon(Icons.download_rounded),
          onPressed: () {},
        ),
      ]),
      const SizedBox(height: 12),
      if (notes.isEmpty)
        Text('No notes yet. Add a note above!', style: ArrestoText.small()),
      ...notes.asMap().entries.map((e) {
        final i = e.key;
        final n = e.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ArrestoColors.amberSoft,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ArrestoColors.amber.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: ArrestoColors.amber, borderRadius: BorderRadius.circular(6)),
              child: Text(n.timestamp, style: ArrestoText.xs()),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(n.text, style: ArrestoText.body())),
            Row(children: [
              IconButton(icon: const Icon(Icons.copy_rounded, size: 15, color: ArrestoColors.textMuted), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
              IconButton(icon: const Icon(Icons.edit_rounded, size: 15, color: ArrestoColors.textMuted), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
              IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 15, color: ArrestoColors.textMuted), onPressed: () => onDelete(i), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
            ]),
          ]),
        );
      }),
    ]);
  }
}

// ── Resources tab ─────────────────────────────────────────────────────────────
class _ResourcesTab extends StatelessWidget {
  static const _res = [
    ('Fall Protection Checklist.pdf', 'PDF', '1.2 MB'),
    ('Anchor Point Rating Chart.pdf', 'PDF', '0.8 MB'),
    ('OHSMS Compliance Matrix.xlsx',  'XLS', '2.1 MB'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _res.map((r) {
        final isPdf = r.$2 == 'PDF';
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: ArrestoColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ArrestoColors.line),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPdf ? ArrestoColors.redSoft : ArrestoColors.greenSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.description_rounded, size: 18, color: isPdf ? ArrestoColors.red : ArrestoColors.green),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.$1, style: ArrestoText.bodyBold()),
              Text('${r.$2} · ${r.$3}', style: ArrestoText.xs()),
            ])),
            IconButton(
              icon: const Icon(Icons.download_rounded, color: ArrestoColors.orange),
              onPressed: () {},
            ),
          ]),
        );
      }).toList(),
    );
  }
}

// ── Transcript tab ────────────────────────────────────────────────────────────
class _TranscriptTab extends StatelessWidget {
  final CourseLesson lesson;
  const _TranscriptTab({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Transcript — ${lesson.title}', style: ArrestoText.bodyBold()),
        const SizedBox(height: 12),
        ...[
          ('0:00', 'Welcome to this lesson on ${lesson.title}. In this session we\'ll cover the key concepts you need to understand.'),
          ('1:30', 'Let\'s start by looking at the regulatory requirements. According to OSHA 1926.502, all fall protection systems must meet minimum safety standards.'),
          ('3:00', 'Anchor points must be capable of supporting at least 5,000 lbs (22 kN) per attached worker.'),
          ('4:45', 'Always inspect your equipment before each use. Look for cuts, fraying, or corrosion that may indicate damage.'),
          ('6:20', 'In this demonstration, notice how the inspector systematically checks each component.'),
        ].map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 36,
              child: Text(entry.$1, style: ArrestoText.xs()),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(entry.$2, style: ArrestoText.body())),
          ]),
        )),
      ],
    );
  }
}

// ── Related lesson row ────────────────────────────────────────────────────────
class _RelatedLessonRow extends StatelessWidget {
  final CourseLesson lesson;
  const _RelatedLessonRow({required this.lesson});

  static const _icons = [
    Icons.grid_view_rounded,
    Icons.edit_rounded,
    Icons.layers_rounded,
    Icons.auto_awesome_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final icon = _icons[lesson.id.hashCode % _icons.length];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ArrestoColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ArrestoColors.line),
      ),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: ArrestoColors.amberSoft, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: ArrestoColors.orange),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(lesson.title, style: ArrestoText.bodyBold(), overflow: TextOverflow.ellipsis),
          Text('${lesson.module} · ${lesson.durationSecs ~/ 60} min', style: ArrestoText.xs()),
        ])),
        const Icon(Icons.chevron_right_rounded, color: ArrestoColors.textMuted),
      ]),
    );
  }
}

// ── Right sidebar ─────────────────────────────────────────────────────────────
class _RightSidebar extends StatelessWidget {
  final CourseLesson lesson;
  final Course course;
  final List<CourseLesson> courseLessons;
  final int lessonIndex;
  final double lessonProgress, courseProgress;
  final int xp, answered;
  final VoidCallback onGoToQuiz;

  const _RightSidebar({
    required this.lesson, required this.course, required this.courseLessons, // CourseLesson
    required this.lessonIndex, required this.lessonProgress, required this.courseProgress,
    required this.xp, required this.answered, required this.onGoToQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Learning companion card
        ArrestoCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: ArrestoColors.amberSoft, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.smart_toy_rounded, color: ArrestoColors.orange, size: 18),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Learning companion', style: ArrestoText.bodyBold()),
                Text('Powered by Arresto AI', style: ArrestoText.xs()),
              ]),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.play_arrow_rounded, size: 14, color: ArrestoColors.orange),
              const SizedBox(width: 4),
              Text('NOW PLAYING', style: ArrestoText.eyebrow()),
            ]),
            Text(lesson.title, style: ArrestoText.bodyBold(), overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            _progressRow('Lesson progress', lessonProgress, ArrestoColors.amber),
            const SizedBox(height: 8),
            _progressRow('Knowledge score', 1.0, ArrestoColors.green),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Column(children: [
                Text('$answered', style: ArrestoText.stat()),
                Text('Answered', style: ArrestoText.xs()),
              ])),
              Expanded(child: Column(children: [
                Text('$xp', style: ArrestoText.stat().copyWith(color: ArrestoColors.orange)),
                Text('XP', style: ArrestoText.xs()),
              ])),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ArrestoButton(
                label: 'Ask Arresto AI',
                variant: ArrestoButtonVariant.dark,
                icon: const Icon(Icons.smart_toy_rounded),
                onPressed: () {},
              ),
            ),
          ]),
        ),
        const SizedBox(height: 14),

        // Quick tools
        ArrestoCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Quick tools', style: ArrestoText.bodyBold()),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _quickTool(Icons.note_rounded, 'Notes', badge: '1')),
              const SizedBox(width: 8),
              Expanded(child: _quickTool(Icons.description_rounded, 'Resources')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _quickTool(Icons.text_snippet_rounded, 'Transcript')),
              const SizedBox(width: 8),
              Expanded(child: GestureDetector(
                onTap: onGoToQuiz,
                child: _quickTool(Icons.quiz_rounded, 'Go to quiz'),
              )),
            ]),
          ]),
        ),
        const SizedBox(height: 14),

        // Course progress
        ArrestoCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Course progress', style: ArrestoText.bodyBold()),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: courseProgress,
                  backgroundColor: ArrestoColors.amberSoft,
                  valueColor: const AlwaysStoppedAnimation(ArrestoColors.amber),
                  minHeight: 6,
                ),
              )),
              const SizedBox(width: 8),
              Text('${(courseProgress * 100).round()}%', style: ArrestoText.smallBold()),
            ]),
            Text('${(courseProgress * 100).round()}% complete · ${courseLessons.length} lessons', style: ArrestoText.xs()),
            const SizedBox(height: 12),
            ...courseLessons.take(8).map((l) {
              final isActive = l.id == lesson.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Icon(
                    l.completed ? Icons.check_circle_rounded : (isActive ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded),
                    size: 16,
                    color: l.completed ? ArrestoColors.green : (isActive ? ArrestoColors.orange : ArrestoColors.textMuted2),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    l.title,
                    style: isActive
                        ? ArrestoText.bodyBold(color: ArrestoColors.orange)
                        : ArrestoText.body(color: l.completed ? ArrestoColors.textSecondary : ArrestoColors.textMuted),
                    overflow: TextOverflow.ellipsis,
                  )),
                ]),
              );
            }),
          ]),
        ),
      ]),
    );
  }

  Widget _progressRow(String label, double value, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: ArrestoText.small()),
        const Spacer(),
        Text('${(value * 100).round()}%', style: ArrestoText.smallBold()),
      ]),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: color.withValues(alpha: 0.15),
          valueColor: AlwaysStoppedAnimation(color),
          minHeight: 6,
        ),
      ),
    ]);
  }

  Widget _quickTool(IconData icon, String label, {String? badge}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: ArrestoColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Icon(icon, size: 16, color: ArrestoColors.orange),
        const SizedBox(width: 6),
        Text(label, style: ArrestoText.small()),
        if (badge != null) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(color: ArrestoColors.orange, borderRadius: BorderRadius.circular(99)),
            child: Text(badge, style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ]),
    );
  }
}
