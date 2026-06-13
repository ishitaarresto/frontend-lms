import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/arresto_card.dart';
import '../../../core/widgets/badge.dart';
import '../../../core/widgets/button.dart';
import '../../../core/widgets/chip_group.dart';
import '../../../core/widgets/course_thumb.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/providers/app_state.dart';
import '../../../data/models/course.dart';

class AllCoursesScreen extends ConsumerStatefulWidget {
  const AllCoursesScreen({super.key});

  @override
  ConsumerState<AllCoursesScreen> createState() => _AllCoursesScreenState();
}

class _AllCoursesScreenState extends ConsumerState<AllCoursesScreen> {
  String _search   = '';
  String _status   = 'All';
  String _viewMode = 'Grid'; // Grid | Table

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(coursesProvider);

    final filtered = all.where((c) {
      final matchSearch = _search.isEmpty ||
          c.title.toLowerCase().contains(_search.toLowerCase()) ||
          c.code.toLowerCase().contains(_search.toLowerCase());
      final matchStatus = _status == 'All' || c.status == _status.toLowerCase();
      return matchSearch && matchStatus;
    }).toList();

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
                  Row(children: [
                    Expanded(
                      child: SectionHeader(
                        icon: Icons.library_books_rounded,
                        title: 'All Courses',
                        subtitle: '${all.length} courses · ${all.where((c) => c.status == 'published').length} published',
                      ),
                    ),
                    ArrestoButton(
                      label: 'Generate New',
                      icon: const Icon(Icons.auto_awesome_rounded),
                      size: ArrestoButtonSize.sm,
                      onPressed: () => context.go('/admin/generator'),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Summary chips
                  Row(children: [
                    _statChip('${all.length}', 'Total', ArrestoColors.ink),
                    const SizedBox(width: 8),
                    _statChip(
                        '${all.where((c) => c.status == 'published').length}',
                        'Published', ArrestoColors.green),
                    const SizedBox(width: 8),
                    _statChip(
                        '${all.where((c) => c.status == 'draft').length}',
                        'Draft', ArrestoColors.amber),
                    const SizedBox(width: 8),
                    _statChip(
                        '${all.where((c) => c.status == 'generating').length}',
                        'Generating', ArrestoColors.orange),
                  ]),
                  const SizedBox(height: 16),

                  Row(children: [
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _search = v),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded, color: ArrestoColors.textMuted),
                          hintText: 'Search by title or code…',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(999))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ChipGroup(
                      options: const ['All', 'Published', 'Draft'],
                      selected: _status,
                      onChanged: (v) => setState(() => _status = v),
                    ),
                    const SizedBox(width: 12),
                    // Grid/Table toggle
                    Container(
                      decoration: BoxDecoration(
                        color: ArrestoColors.bg2,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ArrestoColors.line),
                      ),
                      child: Row(children: [
                        _viewBtn(Icons.grid_view_rounded, 'Grid'),
                        _viewBtn(Icons.table_rows_rounded, 'Table'),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Text('${filtered.length} results', style: ArrestoText.small()),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          if (_viewMode == 'Grid')
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 360,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.75,
                ),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) => _AdminCourseCard(course: filtered[i]),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _CoursesTable(courses: filtered),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _statChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(width: 5),
        Text(label, style: ArrestoText.xs()),
      ]),
    );
  }

  Widget _viewBtn(IconData icon, String mode) {
    final active = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: active ? ArrestoColors.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 16, color: active ? Colors.white : ArrestoColors.textMuted),
      ),
    );
  }
}

// ── Grid card ────────────────────────────────────────────────────────────────
class _AdminCourseCard extends StatelessWidget {
  final Course course;
  const _AdminCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return ArrestoCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: CourseThumb(style: course.style, code: course.code),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(course.cat, style: ArrestoText.eyebrow(), overflow: TextOverflow.ellipsis)),
                    StatusBadge(status: course.status),
                  ]),
                  const SizedBox(height: 4),
                  Text(course.title, style: ArrestoText.h3(), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.people_rounded, size: 12, color: ArrestoColors.textMuted),
                    const SizedBox(width: 3),
                    Text('${course.learners}', style: ArrestoText.small()),
                    const SizedBox(width: 10),
                    Icon(Icons.menu_book_rounded, size: 12, color: ArrestoColors.textMuted),
                    const SizedBox(width: 3),
                    Text('${course.lessons} lessons', style: ArrestoText.small()),
                    const SizedBox(width: 10),
                    Icon(Icons.star_rounded, size: 12, color: ArrestoColors.amber),
                    const SizedBox(width: 3),
                    Text(course.rating > 0 ? '${course.rating}' : '—', style: ArrestoText.small()),
                  ]),
                  const Spacer(),
                  Row(children: [
                    Expanded(
                      child: ArrestoButton(
                        label: 'Edit',
                        size: ArrestoButtonSize.sm,
                        variant: ArrestoButtonVariant.ghost,
                        icon: const Icon(Icons.edit_rounded),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ArrestoButton(
                        label: 'View',
                        size: ArrestoButtonSize.sm,
                        icon: const Icon(Icons.visibility_rounded),
                        onPressed: () {},
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Table view ───────────────────────────────────────────────────────────────
class _CoursesTable extends StatelessWidget {
  final List<Course> courses;
  const _CoursesTable({required this.courses});

  @override
  Widget build(BuildContext context) {
    return ArrestoCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Expanded(flex: 3, child: Text('Course', style: ArrestoText.smallBold())),
              Expanded(child: Text('Style',   style: ArrestoText.smallBold())),
              Expanded(child: Text('Status',  style: ArrestoText.smallBold())),
              Expanded(child: Text('Learners',style: ArrestoText.smallBold())),
              Expanded(child: Text('Rating',  style: ArrestoText.smallBold())),
              const SizedBox(width: 80),
            ]),
          ),
          const Divider(height: 1, color: ArrestoColors.line),
          ...courses.map((c) => _TableRow(course: c)),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final Course course;
  const _TableRow({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ArrestoColors.line, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          SizedBox(
            width: 36, height: 36,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CourseThumb(style: course.style, code: null, height: 36),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(course.title, style: ArrestoText.bodyBold(), overflow: TextOverflow.ellipsis),
              Text(course.code,  style: ArrestoText.xs()),
            ]),
          ),
          Expanded(child: Text(
            course.style.name[0].toUpperCase() + course.style.name.substring(1),
            style: ArrestoText.small(),
          )),
          Expanded(child: StatusBadge(status: course.status)),
          Expanded(child: Text('${course.learners}', style: ArrestoText.body(color: ArrestoColors.ink))),
          Expanded(child: Row(children: [
            Icon(Icons.star_rounded, size: 12, color: ArrestoColors.amber),
            const SizedBox(width: 3),
            Text(course.rating > 0 ? '${course.rating}' : '—', style: ArrestoText.small()),
          ])),
          Row(children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 16, color: ArrestoColors.textMuted),
              onPressed: () {},
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 16, color: ArrestoColors.textMuted),
              onPressed: () {},
              tooltip: 'Delete',
            ),
          ]),
        ]),
      ),
    );
  }
}
