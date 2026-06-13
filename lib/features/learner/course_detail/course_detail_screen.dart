import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/button.dart';
import '../../../core/widgets/arresto_card.dart';
import '../../../core/widgets/badge.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../core/widgets/course_thumb.dart';
import '../../../data/providers/app_state.dart';
import '../../../data/models/course.dart';
import '../../../data/models/lesson.dart' show CourseLesson;

class CourseDetailScreen extends ConsumerWidget {
  final String id;
  const CourseDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesProvider);
    final lessons = ref.watch(lessonsProvider);
    final course = courses.firstWhere((c) => c.id == id, orElse: () => courses.first);
    final courseLessons = lessons.where((l) => l.courseId == id).toList();
    // Lesson to resume: first incomplete, or first lesson
    final resumeLesson = courseLessons.firstWhere(
      (l) => !l.completed,
      orElse: () => courseLessons.isNotEmpty ? courseLessons.first : CourseLesson(id: '', courseId: id, module: '', moduleNum: 1, title: '', durationSecs: 0),
    );

    return Scaffold(
      backgroundColor: ArrestoColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: ArrestoColors.surface,
            foregroundColor: ArrestoColors.ink,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            title: Text(course.title,
                style: ArrestoText.h4(),
                overflow: TextOverflow.ellipsis),
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${course.cat} · ${course.level}',
                                style: ArrestoText.eyebrow()),
                            const SizedBox(height: 6),
                            Text(course.title, style: ArrestoText.h1()),
                            const SizedBox(height: 8),
                            Text(course.desc,
                                style: ArrestoText.body()),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _stat(Icons.menu_book_rounded,
                                    '${course.lessons} lessons'),
                                const SizedBox(width: 16),
                                _stat(Icons.schedule_rounded,
                                    '${course.mins} min'),
                                const SizedBox(width: 16),
                                _stat(Icons.people_rounded,
                                    '${course.learners} learners'),
                                if (course.rating > 0) ...[
                                  const SizedBox(width: 16),
                                  _stat(Icons.star_rounded,
                                      '${course.rating}',
                                      color: ArrestoColors.amber),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (course.progress > 0) ...[
                              AnimatedArrestoProgressBar(
                                  value: course.progress / 100),
                              const SizedBox(height: 4),
                              Text(
                                  '${course.progress}% complete',
                                  style: ArrestoText.small()),
                              const SizedBox(height: 12),
                            ],
                            Wrap(
                              spacing: 10,
                              children: [
                                ArrestoButton(
                                  label: course.progress > 0 ? 'Resume Lesson' : 'Start Course',
                                  icon: const Icon(Icons.play_circle_rounded),
                                  onPressed: resumeLesson.id.isNotEmpty
                                      ? () => context.go('/learner/lesson/${course.id}/${resumeLesson.id}')
                                      : null,
                                ),
                                if (course.progress > 0)
                                  ArrestoButton(
                                    label: 'Take Assessment',
                                    variant: ArrestoButtonVariant.ghost,
                                    onPressed: () => context.go('/learner/assessment/${course.id}'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 160,
                          child: CourseThumb(
                              style: course.style,
                              code: course.code,
                              height: 160),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Course outline
                  Text('Course Outline', style: ArrestoText.h3()),
                  const SizedBox(height: 12),
                  ..._buildLessonModules(context, course, courseLessons),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String label, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 14,
            color: color ?? ArrestoColors.textMuted),
        const SizedBox(width: 4),
        Text(label, style: ArrestoText.small()),
      ],
    );
  }

  List<Widget> _buildLessonModules(BuildContext context, Course course, List<CourseLesson> courseLessons) {
    if (courseLessons.isEmpty) {
      // Fallback static modules if no lesson data
      return [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ArrestoColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ArrestoColors.cardBorder),
          ),
          child: Text('No lessons available yet.', style: ArrestoText.body()),
        ),
      ];
    }

    // Group by module
    final Map<String, List<CourseLesson>> grouped = {};
    for (final l in courseLessons) {
      grouped.putIfAbsent('Module ${l.moduleNum} — ${l.module}', () => []).add(l);
    }

    return grouped.entries.map((e) {
      final moduleName = e.key;
      final lessons    = e.value;
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: ArrestoColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ArrestoColors.cardBorder),
        ),
        child: Theme(
          data: ThemeData(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            title: Text(moduleName, style: ArrestoText.bodyBold()),
            iconColor: ArrestoColors.orange,
            collapsedIconColor: ArrestoColors.textMuted,
            children: lessons.map((lesson) {
              return ListTile(
                dense: true,
                onTap: () => context.go('/learner/lesson/${course.id}/${lesson.id}'),
                leading: Icon(
                  lesson.completed
                      ? Icons.check_circle_rounded
                      : Icons.play_circle_outline_rounded,
                  size: 18,
                  color: lesson.completed ? ArrestoColors.green : ArrestoColors.orange,
                ),
                title: Text(lesson.title, style: ArrestoText.body()),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(lesson.durationLabel, style: ArrestoText.xs()),
                  const SizedBox(width: 4),
                  if (!lesson.completed && lesson.savedPositionSecs == 0)
                    const Icon(Icons.lock_outline_rounded, size: 14, color: ArrestoColors.textMuted2)
                  else
                    const Icon(Icons.chevron_right_rounded, size: 16, color: ArrestoColors.textMuted),
                ]),
              );
            }).toList(),
          ),
        ),
      );
    }).toList();
  }
}
