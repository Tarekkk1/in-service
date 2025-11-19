import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/configs/app_assets.dart';
import 'package:lms_app/constants/app_constants.dart';
import 'package:lms_app/mixins/course_mixin.dart';
import 'package:lms_app/mixins/user_mixin.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/utils/loading_widget.dart';
import '../../providers/user_data_provider.dart';

final _isLoadingEnrollmentProvider = StateProvider.autoDispose((ref) => false);

class EnrollButton extends ConsumerWidget with UserMixin {
  const EnrollButton({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userDataProvider);
    final bool isLoading = ref.watch(_isLoadingEnrollmentProvider);
    final String text = CourseMixin.enrollButtonText(course, user);
    final bool isPremium = course.priceStatus != 'free';
    final bool isEnrolled = hasEnrolled(user, course);
    final bool hasSubscription = isUserPremium(user);
    
    // Show access denied bar for premium courses when not enrolled and no subscription
    final bool showAccessDeniedBar = isPremium && !isEnrolled && !hasSubscription;

    return BottomAppBar(
      padding: const EdgeInsets.all(0),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: MediaQuery.of(context).size.width,
        child: showAccessDeniedBar
            ? _AccessDeniedBar()
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: !isEnrolled,
                    child: Flexible(
                      fit: FlexFit.loose,
                      flex: isPremium ? 1 : 2,
                      child: isPremium ? _PremiumTag() : _FreeTag(),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 5,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const LoadingIndicatorWidget(color: Colors.white)
                            : Text(
                                text,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ).tr(),
                        onPressed: () async {
                          ref.read(_isLoadingEnrollmentProvider.notifier).state = true;
                          await handleEnrollment(context, user: user, course: course, ref: ref);
                          ref.read(_isLoadingEnrollmentProvider.notifier).state = false;
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _FreeTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      height: 50,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(30)),
      child: Text(
        priceStatus.values.first.toUpperCase(),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _PremiumTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).primaryColor,
      ),
      child: Image.asset(premiumImage, fit: BoxFit.contain),
    );
  }
}

class _AccessDeniedBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            color: Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            'no-access-message',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
          ).tr(),
        ],
      ),
    );
  }
}
