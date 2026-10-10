import 'package:shared_preferences/shared_preferences.dart';

import 'mock_data.dart';

/// Learner progress shared by the Player, Dashboard and Hub.
/// Saved with shared_preferences so it survives refreshes and restarts.
const lessonsPerCourse = 20;

/// courseId -> indexes of lessons marked complete
final Map<String, Set<int>> completedLessons = {};

/// courseId -> lesson the learner was last on
final Map<String, int> lastLesson = {};

/// Courses whose quiz has been passed
final Set<String> completedCourses = {};

Future<void> loadProgress() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    for (final e in prefs.getStringList('mta_done') ?? <String>[]) {
      final i = e.indexOf(':');
      if (i < 0) continue;
      completedLessons[e.substring(0, i)] = {
        for (final n in e.substring(i + 1).split(','))
          if (n.isNotEmpty) int.parse(n),
      };
    }
    for (final e in prefs.getStringList('mta_last') ?? <String>[]) {
      final i = e.indexOf(':');
      if (i < 0) continue;
      lastLesson[e.substring(0, i)] = int.tryParse(e.substring(i + 1)) ?? 0;
    }
    completedCourses.addAll(prefs.getStringList('mta_completed') ?? <String>[]);
  } catch (_) {}
}

Future<void> saveProgress() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('mta_done', [
      for (final e in completedLessons.entries) '${e.key}:${e.value.join(',')}',
    ]);
    await prefs.setStringList('mta_last', [
      for (final e in lastLesson.entries) '${e.key}:${e.value}',
    ]);
    await prefs.setStringList('mta_completed', completedCourses.toList());
  } catch (_) {}
}

/// Called when the quiz is passed: every lesson done, course complete.
void completeCourse(String courseId) {
  completedCourses.add(courseId);
  completedLessons
      .putIfAbsent(courseId, () => <int>{})
      .addAll(List.generate(lessonsPerCourse, (i) => i));
  saveProgress();
}

/// Live progress %, or the starting value from mock_data.dart.
int progressFor(Course course) {
  final done = completedLessons[course.id];
  if (done == null) return course.progress;
  return (done.length / lessonsPerCourse * 100).round();
}