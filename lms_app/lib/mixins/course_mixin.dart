import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/lesson.dart';
import 'package:lms_app/models/user_model.dart';

mixin CourseMixin {

  bool isLessonCompleted(Lesson lesson, UserModel? user) {
    if (user != null && user.completedLessons!.isNotEmpty && user.completedLessons!.any((element) => element.toString().contains(lesson.id))) {
      return true;
    } else {
      return false;
    }
  }

  static String enrollButtonText(Course course, UserModel? user) {
    if (user == null || !user.enrolledCourses!.contains(course.id)) {
      // Return 'enroll-for-free' for free courses, 'enroll-now' for premium (though it won't be shown)
      return course.priceStatus == 'free' ? 'enroll-for-free' : 'enroll-now';
    } else {
      List validIds = user.completedLessons!.where((element) => element.toString().contains(course.id)).toList();
      final double courseProgess = validIds.isEmpty ? 0 : (validIds.length / course.lessonsCount);
      if (courseProgess == 0) {
        return 'start-course';
      } else 
      if (courseProgess > 0 && courseProgess < 1) {
        return 'continue-course';
      } else {
        return 'restart-course';
      }
    }
  }
}
