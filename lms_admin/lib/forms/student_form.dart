import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_admin/components/custom_buttons.dart';
import 'package:lms_admin/mixins/textfields.dart';
import 'package:lms_admin/mixins/user_mixin.dart';
import 'package:lms_admin/providers/user_data_provider.dart';
import 'package:lms_admin/services/firebase_service.dart';
import 'package:lms_admin/services/platform_service.dart';
import 'package:lms_admin/utils/toasts.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../models/user_model.dart';

class StudentForm extends ConsumerStatefulWidget {
  final UserModel? student;
  const StudentForm({Key? key, this.student}) : super(key: key);

  @override
  ConsumerState<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends ConsumerState<StudentForm> with TextFields, UserMixin {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _platformController;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isDisabled = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _emailController = TextEditingController(text: widget.student?.email ?? '');
    // Auto-detect platform if creating new student, otherwise use existing student's platform
    _platformController = TextEditingController(
      text: widget.student?.platform ?? PlatformService.getCurrentPlatform(),
    );
    _isDisabled = widget.student?.isDisbaled ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _platformController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!UserMixin.hasAdminAccess(ref.read(userDataProvider))) {
      openTestingToast(context);
      return;
    }

    _btnController.start();

    try {
      if (widget.student == null) {
        // Create new student
        await FirebaseService().createStudent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          platform: _platformController.text.trim(),
          isDisabled: _isDisabled,
        );
        _btnController.success();
        if (!mounted) return;
        Navigator.of(context).pop();
        openSuccessToast(context, 'Student profile created successfully! Student will need to register with their email.');
      } else {
        // Update existing student
        await FirebaseService().updateStudent(
          userId: widget.student!.id,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          platform: _platformController.text.trim(),
          isDisabled: _isDisabled,
        );
        _btnController.success();
        if (!mounted) return;
        Navigator.of(context).pop();
        openSuccessToast(context, 'Student updated successfully!');
      }
    } catch (e) {
      _btnController.stop();
      if (!mounted) return;
      
      String errorMessage = 'An error occurred';
      if (e.toString().contains('permission-denied')) {
        errorMessage = 'Permission denied. Please check your admin rights.';
      } else if (e.toString().contains('network-request-failed')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Please enter a valid email address';
      }
      
      openFailureToast(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.student == null ? 'Create Student' : 'Edit Student',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 30),
            
            // Name field
            Text(
              'Student Name',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: inputDecoration('Enter student name', _nameController, () => _nameController.clear()),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter student name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Email field
            Text(
              'Email Address',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              decoration: inputDecoration('Enter email address', _emailController, () => _emailController.clear()),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter email address';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              enabled: widget.student == null, // Disable email editing for existing students
            ),
            const SizedBox(height: 20),

            // Platform field
            Text(
              'Platform',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _platformController.text.isNotEmpty ? _platformController.text : PlatformService.getCurrentPlatform(),
              decoration: InputDecoration(
                hintText: 'Select platform',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: ['web', 'android', 'ios', 'windows', 'macos', 'linux'].map((platform) {
                return DropdownMenuItem<String>(
                  value: platform,
                  child: Row(
                    children: [
                      Icon(_getPlatformIcon(platform), size: 20),
                      const SizedBox(width: 8),
                      Text(platform.toUpperCase()),
                      if (platform == PlatformService.getCurrentPlatform())
                        const Text(' (Current)', style: TextStyle(color: Colors.green, fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                _platformController.text = value ?? PlatformService.getCurrentPlatform();
              },
            ),
            const SizedBox(height: 20),

            // Access status
            CheckboxListTile(
              title: const Text('Disable Access'),
              subtitle: const Text('Prevent student from accessing the app'),
              value: _isDisabled,
              onChanged: (value) {
                setState(() {
                  _isDisabled = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 30),

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
                    text: widget.student == null ? 'Create Student' : 'Update Student',
                    onPressed: _handleSubmit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'web':
        return Icons.web;
      case 'android':
        return Icons.android;
      case 'ios':
        return Icons.phone_iphone;
      case 'windows':
        return Icons.desktop_windows;
      case 'macos':
        return Icons.desktop_mac;
      case 'linux':
        return Icons.computer;
      default:
        return Icons.device_unknown;
    }
  }
}