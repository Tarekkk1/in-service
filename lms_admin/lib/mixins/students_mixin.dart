import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../tabs/admin_tabs/students/students_data_source.dart';
import '../providers/user_data_provider.dart';
import '../tabs/admin_tabs/students/students.dart';
import '../utils/empty_with_image.dart';

final List<String> _studentColumns = [
  'Student',
  'Email',
  'Enrolled Courses',
  'Subscription',
  'Platform',
  'Status',
  'Actions',
];

const _itemsPerPage = 10;

mixin StudentsMixins {
  Widget buildStudents(
    BuildContext context, {
    required WidgetRef ref,
    required isMobile,
  }) {
    return FirestoreQueryBuilder(
      pageSize: 10,
      query: ref.watch(studentsQueryProvider),
      builder: (context, snapshot, _) {
        List<UserModel> students = [];
        students = snapshot.docs.map((e) => UserModel.fromFirebase(e)).toList();
        DataTableSource source = StudentsDataSource(students, context, ref);

        if (snapshot.isFetching) return const CircularProgressIndicator.adaptive();
        if (snapshot.docs.isEmpty) return const EmptyPageWithImage(title: 'No students found');

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: PaginatedDataTable2(
              rowsPerPage: _itemsPerPage - 1,
              source: source,
              empty: const Center(child: Text('No Students Found')),
              minWidth: 1200,
              wrapInCard: false,
              horizontalMargin: 20,
              columnSpacing: 20,
              fit: FlexFit.tight,
              lmRatio: 2,
              dataRowHeight: isMobile ? 90 : 70,
              onPageChanged: (_) => snapshot.fetchMore(),
              columns: _studentColumns.map((e) => DataColumn(label: Text(e))).toList(),
            ),
          ),
        );
      },
    );
  }

  // Add a status column specifically for students
  Widget getStudentStatus(UserModel student) {
    if (student.isDisbaled == true) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Disabled',
          style: TextStyle(color: Colors.red, fontSize: 12),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Active',
          style: TextStyle(color: Colors.green, fontSize: 12),
        ),
      );
    }
  }
}