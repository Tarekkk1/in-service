import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../components/custom_buttons.dart';
import '../../../components/dialogs.dart';
import '../../../configs/constants.dart';
import '../../../forms/student_form.dart';
import '../../../mixins/appbar_mixin.dart';
import '../../../mixins/students_mixin.dart';
import '../../../utils/reponsive.dart';
import '../users/sort_users_button.dart';
import '../../../mixins/textfields.dart';
import '../users/search_users_textfield.dart';

// Provider for students-only query
final studentsQueryProvider = StateProvider<Query>((ref) {
  final query = FirebaseFirestore.instance
      .collection('users')
      .where('role', arrayContains: 'student')
      .orderBy('created_at', descending: true);
  return query;
});

class Students extends ConsumerWidget with StudentsMixins, TextFields {
  const Students({Key? key}) : super(key: key);

  void _handleCreateStudent(BuildContext context) {
    CustomDialogs.openResponsiveDialog(
      context,
      widget: const StudentForm(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          AppBarMixin.buildTitleBar(context, title: 'Students', buttons: [
            CustomButtons.customOutlineButton(
              context,
              icon: Icons.person_add,
              text: 'Add Student',
              onPressed: () => _handleCreateStudent(context),
            ),
            const SizedBox(width: 10),
            Visibility(
              visible: !Responsive.isMobile(context),
              child: SerachUsersTextField(ref: ref),
            ),
            const SizedBox(width: 10),
            SortUsersButton(ref: ref),
          ]),
          buildStudents(context, ref: ref, isMobile: Responsive.isMobile(context))
        ],
      ),
    );
  }
}