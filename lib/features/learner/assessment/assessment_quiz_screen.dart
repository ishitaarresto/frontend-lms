import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/button.dart';
import '../../../core/widgets/arresto_card.dart';
import '../../../core/widgets/badge.dart';
import '../../../data/providers/app_state.dart';
import '../../../data/models/question.dart';

class AssessmentQuizScreen extends ConsumerStatefulWidget {
  final String courseId;
  const AssessmentQuizScreen({super.key, required this.courseId});

  @override
  ConsumerState<AssessmentQuizScreen> createState() =>
      _AssessmentQuizScreenState();
}

class _AssessmentQuizScreenState extends ConsumerState<AssessmentQuizScreen> {
  Timer? _timer;
  int _secondsLeft = 30 * 60;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
        _submit();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeStr {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _submit() {
    ref.read(assessmentProvider.notifier).submit();
    context.go('/learner/assessment/${widget.courseId}/result');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assessmentProvider);
    final questions = ref.watch(questionsProvider);
    if (questions.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final q = questions[state.currentIndex];
    final isFlagged = state.flagged.contains(state.currentIndex);
    final selectedOpt = state.answers[state.currentIndex];

    return Scaffold(
      backgroundColor: ArrestoColors.background,
      appBar: AppBar(
        backgroundColor: ArrestoColors.surface,
        foregroundColor: ArrestoColors.ink,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              'Q ${state.currentIndex + 1}/${questions.length}',
              style: ArrestoText.h4(),
            ),
            const Spacer(),
            // Timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _secondsLeft < 300
                    ? ArrestoColors.redSoft
                    : ArrestoColors.bg2,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_rounded,
                      size: 14,
                      color: _secondsLeft < 300
                          ? ArrestoColors.red
                          : ArrestoColors.textMuted),
                  const SizedBox(width: 4),
                  Text(_timeStr,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _secondsLeft < 300
                            ? ArrestoColors.red
                            : ArrestoColors.ink,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (state.currentIndex + 1) / questions.length,
            backgroundColor: ArrestoColors.line,
            valueColor:
                const AlwaysStoppedAnimation(ArrestoColors.amber),
            minHeight: 3,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question card
                  ArrestoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ArrestoBadge(
                              label: _typeLabel(q.type),
                              variant: BadgeVariant.blue,
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => ref
                                  .read(assessmentProvider.notifier)
                                  .toggleFlag(state.currentIndex),
                              child: Row(
                                children: [
                                  Icon(
                                    isFlagged
                                        ? Icons.flag_rounded
                                        : Icons.flag_outlined,
                                    size: 16,
                                    color: isFlagged
                                        ? ArrestoColors.amber
                                        : ArrestoColors.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text('Flag',
                                      style: ArrestoText.small(
                                          color: isFlagged
                                              ? ArrestoColors.amber
                                              : ArrestoColors.textMuted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(q.q, style: ArrestoText.h3()),
                        const SizedBox(height: 16),
                        if (q.opts.isNotEmpty)
                          ...List.generate(q.opts.length, (i) {
                            final letter =
                                String.fromCharCode(65 + i); // A, B, C, D
                            final selected = selectedOpt == i;
                            return GestureDetector(
                              onTap: () => ref
                                  .read(assessmentProvider.notifier)
                                  .answer(state.currentIndex, i),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 150),
                                margin:
                                    const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? ArrestoColors.amberSoft
                                      : ArrestoColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selected
                                        ? ArrestoColors.amber
                                        : ArrestoColors.line,
                                    width: selected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? ArrestoColors.amber
                                            : ArrestoColors.bg2,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        letter,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: selected
                                              ? ArrestoColors.ink
                                              : ArrestoColors.textMuted,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: Text(q.opts[i],
                                            style: ArrestoText.body(
                                                color: selected
                                                    ? ArrestoColors.ink
                                                    : null))),
                                  ],
                                ),
                              ),
                            );
                          })
                        else
                          TextField(
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Type your answer here...',
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Question navigator
                  Text('Questions', style: ArrestoText.label()),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(questions.length, (i) {
                      final isCurrent = i == state.currentIndex;
                      final isAnswered =
                          state.answers.containsKey(i);
                      final isFlaggedQ =
                          state.flagged.contains(i);

                      Color bg;
                      Color border;
                      Color text;

                      if (isCurrent) {
                        bg = ArrestoColors.orange;
                        border = ArrestoColors.orange;
                        text = Colors.white;
                      } else if (isAnswered) {
                        bg = ArrestoColors.greenSoft;
                        border = ArrestoColors.green;
                        text = ArrestoColors.green;
                      } else if (isFlaggedQ) {
                        bg = ArrestoColors.amberSoft;
                        border = ArrestoColors.amber;
                        text = const Color(0xFF92400E);
                      } else {
                        bg = ArrestoColors.surface;
                        border = ArrestoColors.line;
                        text = ArrestoColors.textMuted;
                      }

                      return GestureDetector(
                        onTap: () => ref
                            .read(assessmentProvider.notifier)
                            .goTo(i),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: border),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: text,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          // Nav buttons
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: const BoxDecoration(
              color: ArrestoColors.surface,
              border: Border(top: BorderSide(color: ArrestoColors.line)),
            ),
            child: Row(
              children: [
                if (state.currentIndex > 0)
                  ArrestoButton(
                    label: 'Previous',
                    variant: ArrestoButtonVariant.ghost,
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => ref
                        .read(assessmentProvider.notifier)
                        .goTo(state.currentIndex - 1),
                  ),
                const Spacer(),
                if (state.currentIndex < questions.length - 1)
                  ArrestoButton(
                    label: 'Next',
                    icon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: () => ref
                        .read(assessmentProvider.notifier)
                        .goTo(state.currentIndex + 1),
                  )
                else
                  ArrestoButton(
                    label: 'Submit',
                    variant: ArrestoButtonVariant.dark,
                    icon: const Icon(Icons.check_rounded),
                    onPressed: () => _showSubmitDialog(context),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(String type) {
    return switch (type) {
      'mcq' => 'Multiple Choice',
      'truefalse' => 'True / False',
      'scenario' => 'Scenario',
      'descriptive' => 'Descriptive',
      _ => type.toUpperCase(),
    };
  }

  void _showSubmitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ArrestoColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Submit Assessment?', style: ArrestoText.h3()),
        content: Text(
          'Are you sure you want to submit? You cannot change your answers after submission.',
          style: ArrestoText.body(),
        ),
        actions: [
          ArrestoButton(
            label: 'Cancel',
            variant: ArrestoButtonVariant.ghost,
            onPressed: () => Navigator.pop(ctx),
          ),
          const SizedBox(width: 8),
          ArrestoButton(
            label: 'Submit',
            variant: ArrestoButtonVariant.dark,
            onPressed: () {
              Navigator.pop(ctx);
              _submit();
            },
          ),
        ],
      ),
    );
  }
}
