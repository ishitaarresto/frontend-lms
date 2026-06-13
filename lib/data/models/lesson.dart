class CourseLesson {
  final String id;
  final String courseId;
  final String module;
  final int moduleNum;
  final String title;
  final int durationSecs;
  final bool completed;
  final int savedPositionSecs;

  const CourseLesson({
    required this.id,
    required this.courseId,
    required this.module,
    required this.moduleNum,
    required this.title,
    required this.durationSecs,
    this.completed = false,
    this.savedPositionSecs = 0,
  });

  String get durationLabel {
    final m = durationSecs ~/ 60;
    final s = durationSecs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
