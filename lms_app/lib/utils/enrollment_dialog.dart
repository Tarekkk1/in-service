import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:lms_app/configs/app_assets.dart';
import 'package:lms_app/services/app_service.dart';
import 'package:lms_app/providers/app_settings_provider.dart';

Future<void> openEnrollmentDialog(BuildContext context, WidgetRef ref) {
  return Dialogs.materialDialog(
    context: context,
    title: 'enrollment-required-title'.tr(),
    msg: 'enrollment-required-subtitle'.tr(),
    titleAlign: TextAlign.center,
    titleStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).primaryColor,
    ),
    msgAlign: TextAlign.center,
    msgStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: Theme.of(context).textTheme.bodyMedium?.color,
      height: 1.5,
    ),
    barrierDismissible: true,
    color: Theme.of(context).scaffoldBackgroundColor,
    customView: Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Premium icon
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Image.asset(
              premiumImage,
              fit: BoxFit.contain,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          // Contact information
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.support_agent_rounded,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  'customer-support-info'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    actionsBuilder: (context) => [
      IconsOutlineButton(
        onPressed: () => Navigator.pop(context),
        text: 'close'.tr(),
        color: Colors.grey,
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      IconsOutlineButton(
        onPressed: () {
          Navigator.pop(context);
          final settings = ref.read(appSettingsProvider);
          if (settings?.supportEmail != null && settings!.supportEmail!.isNotEmpty) {
            AppService().openEmailSupport(settings.supportEmail!);
          }
        },
        text: 'contact-support'.tr(),
        color: Theme.of(context).primaryColor,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ],
  );
}