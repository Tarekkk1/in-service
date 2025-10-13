import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_admin/components/user_info.dart';
import 'package:lms_admin/components/custom_buttons.dart';
import 'package:lms_admin/components/dialogs.dart';
import 'package:lms_admin/components/course_assignment_dialog.dart';
import 'package:lms_admin/forms/student_form.dart';
import 'package:lms_admin/mixins/user_mixin.dart';
import 'package:lms_admin/mixins/users_mixin.dart';
import 'package:lms_admin/mixins/students_mixin.dart';
import 'package:lms_admin/services/firebase_service.dart';
import 'package:lms_admin/utils/toasts.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../../../models/user_model.dart';
import '../../../providers/user_data_provider.dart';

class StudentsDataSource extends DataTableSource with UsersMixins, UserMixin, StudentsMixins {
  final List<UserModel> students;
  final BuildContext context;
  final WidgetRef ref;
  StudentsDataSource(this.students, this.context, this.ref);

  void _onCopyUserId(String userId) async {
    if (UserMixin.hasAdminAccess(ref.read(userDataProvider))) {
      Clipboard.setData(ClipboardData(text: userId));
      openSuccessToast(context, 'Copied to clipboard');
    } else {
      openTestingToast(context);
    }
  }

  void _handleUserAccess(UserModel user) {
    final btnCtlr = RoundedLoadingButtonController();
    CustomDialogs.openActionDialog(
      context,
      title: user.isDisbaled! ? "Enable Access to this student?" : "Disable access to this student?",
      message: user.isDisbaled! ? 'Warning: ${user.name} can access the app and contents' : "Warning: ${user.name} can't access the app and contents",
      actionBtnController: btnCtlr,
      actionButtonText: user.isDisbaled! ? 'Yes, Enable Access' : 'Yes, Disable Access',
      onAction: () async {
        final navigator = Navigator.of(context);
        if (UserMixin.hasAdminAccess(ref.read(userDataProvider))) {
          btnCtlr.start();
          if (user.isDisbaled!) {
            await FirebaseService().updateUserAccess(userId: user.id, shouldDisable: false);
          } else {
            await FirebaseService().updateUserAccess(userId: user.id, shouldDisable: true);
          }

          btnCtlr.success();
          navigator.pop();
          if (!context.mounted) return;
          openSuccessToast(context, 'Student access has been updated!');
        } else {
          openTestingToast(context);
        }
      },
    );
  }

  void _handleEditStudent(UserModel user) {
    CustomDialogs.openResponsiveDialog(
      context,
      widget: StudentForm(student: user),
    );
  }

  void _handleCourseAssignment(UserModel user) {
    CustomDialogs.openResponsiveDialog(
      context,
      widget: CourseAssignmentDialog(student: user),
    );
  }

  @override
  DataRow getRow(int index) {
    final UserModel student = students[index];

    return DataRow.byIndex(index: index, cells: [
      DataCell(_studentName(student)),
      DataCell(getEmail(student, ref)),
      DataCell(_getEnrolledCourses(student)),
      DataCell(getSubscription(context, student)),
      DataCell(_getPlatform(student)),
      DataCell(getStudentStatus(student)), // New status column
      DataCell(_actions(student)),
    ]);
  }

  static Text _getEnrolledCourses(UserModel student) {
    return Text(student.enrolledCourses!.length.toString());
  }

  ListTile _studentName(UserModel student) {
    return ListTile(
        horizontalTitleGap: 10,
        contentPadding: const EdgeInsets.all(0),
        title: Text(
          student.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Student ID: ${student.id.substring(0, 8)}...',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        leading: getUserImage(user: student));
  }

  static Text _getPlatform(UserModel student) {
    return Text(student.platform ?? 'Undefined');
  }

  Widget _actions(UserModel student) {
    return Row(
      children: [
        CustomButtons.circleButton(
          context,
          icon: Icons.remove_red_eye,
          tooltip: 'View student info',
          onPressed: () => CustomDialogs.openResponsiveDialog(
            context,
            widget: UserInfo(user: student),
            verticalPaddingPercentage: 0.05,
          ),
        ),
        const SizedBox(width: 10),
        _menuButton(student)
      ],
    );
  }

  PopupMenuButton _menuButton(UserModel student) {
    return PopupMenuButton(
      child: const CircleAvatar(
        radius: 16,
        child: Icon(
          Icons.menu,
          size: 16,
        ),
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem(child: const Text('Copy Student ID'), onTap: () => _onCopyUserId(student.id)),
          PopupMenuItem(
            child: const Text('Edit Student'),
            onTap: () => _handleEditStudent(student),
          ),
          PopupMenuItem(
            child: const Text('Manage Courses'),
            onTap: () => _handleCourseAssignment(student),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            child: Text(student.isDisbaled! ? 'Enable Access' : 'Disable Access'),
            onTap: () => _handleUserAccess(student),
          ),
        ];
      },
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => students.length;

  @override
  int get selectedRowCount => 0;
}