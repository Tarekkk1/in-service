import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_admin/components/custom_buttons.dart';
import 'package:lms_admin/mixins/user_mixin.dart';
import 'package:lms_admin/models/course.dart';
import 'package:lms_admin/models/user_model.dart';
import 'package:lms_admin/providers/user_data_provider.dart';
import 'package:lms_admin/services/firebase_service.dart';
import 'package:lms_admin/utils/toasts.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class CourseAssignmentDialog extends ConsumerStatefulWidget {
  final UserModel student;
  const CourseAssignmentDialog({Key? key, required this.student}) : super(key: key);

  @override
  ConsumerState<CourseAssignmentDialog> createState() => _CourseAssignmentDialogState();
}

class _CourseAssignmentDialogState extends ConsumerState<CourseAssignmentDialog> with UserMixin {
  List<Course> _allCourses = [];
  List<String> _enrolledCourseIds = [];
  Set<String> _selectedCourseIds = {};
  bool _isLoading = true;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      // Load all courses
      final courses = await FirebaseService().getAllPublishedCourses();
      _enrolledCourseIds = List<String>.from(widget.student.enrolledCourses ?? []);
      
      setState(() {
        _allCourses = courses;
        _selectedCourseIds = Set<String>.from(_enrolledCourseIds);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      openFailureToast(context, 'Error loading courses: ${e.toString()}');
    }
  }

  void _handleSave() async {
    if (!UserMixin.hasAdminAccess(ref.read(userDataProvider))) {
      openTestingToast(context);
      return;
    }

    _btnController.start();

    try {
      // Get courses to add and remove
      final coursesToAdd = _selectedCourseIds.difference(Set<String>.from(_enrolledCourseIds));
      final coursesToRemove = Set<String>.from(_enrolledCourseIds).difference(_selectedCourseIds);

      // Update student's enrolled courses
      await FirebaseService().updateStudentCourses(
        userId: widget.student.id,
        coursesToAdd: coursesToAdd.toList(),
        coursesToRemove: coursesToRemove.toList(),
      );

      _btnController.success();
      if (!mounted) return;
      Navigator.of(context).pop();
      openSuccessToast(context, 'Course assignments updated successfully!');
    } catch (e) {
      _btnController.reset();
      if (!mounted) return;
      openFailureToast(context, 'Error updating courses: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      height: 500,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage Course Assignments',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Student: ${widget.student.name}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),

          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            Text(
              'Available Courses (${_allCourses.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            
            Expanded(
              child: _allCourses.isEmpty
                  ? const Center(child: Text('No courses available'))
                  : ListView.builder(
                      itemCount: _allCourses.length,
                      itemBuilder: (context, index) {
                        final course = _allCourses[index];
                        final isEnrolled = _selectedCourseIds.contains(course.id);
                        final wasOriginallyEnrolled = _enrolledCourseIds.contains(course.id);
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: CheckboxListTile(
                            value: isEnrolled,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedCourseIds.add(course.id);
                                } else {
                                  _selectedCourseIds.remove(course.id);
                                }
                              });
                            },
                            title: Text(
                              course.name,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Students: ${course.studentsCount}'),
                                Text('Status: ${course.status}'),
                                if (wasOriginallyEnrolled && !isEnrolled)
                                  const Text(
                                    'Will be removed',
                                    style: TextStyle(color: Colors.red, fontSize: 12),
                                  )
                                else if (!wasOriginallyEnrolled && isEnrolled)
                                  const Text(
                                    'Will be added',
                                    style: TextStyle(color: Colors.green, fontSize: 12),
                                  ),
                              ],
                            ),
                            secondary: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                course.thumbnailUrl,
                                width: 60,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 60,
                                    height: 40,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image_not_supported),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 20),

            // Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Selected: ${_selectedCourseIds.length} courses'),
                  Text('Originally enrolled: ${_enrolledCourseIds.length} courses'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButtons.submitButton(
                    context,
                    buttonController: _btnController,
                    text: 'Save Changes',
                    onPressed: _handleSave,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}