# Enrollment Dialog Feature

## Overview
This feature implements a premium course enrollment dialog that appears when users try to access paid courses they are not enrolled in. The dialog encourages users to contact customer support for enrollment assistance.

## Implementation Details

### Files Modified/Created:
1. **`lib/utils/enrollment_dialog.dart`** - New dialog component
2. **`lib/mixins/user_mixin.dart`** - Updated to use enrollment dialog
3. **Translation files** - Added new translation keys

### How It Works:
1. When a user clicks on a paid course they're not enrolled in, the `handleEnrollment` method in `UserMixin` is called
2. If the course is not free and the user is not enrolled, the enrollment dialog is displayed
3. The dialog shows:
   - Premium course icon
   - Clear message about enrollment requirement
   - Contact support information
   - Action buttons (Close/Contact Support)

### Translation Keys Added:
- `enrollment-required-title`: "Enrollment Required"
- `enrollment-required-subtitle`: "This premium course requires enrollment approval..."
- `customer-support-info`: "Our support team is ready to assist you..."
- `contact-support`: "Contact Support"

### Languages Supported:
- English (en-US)
- Arabic (ar-SA)
- French (fr-FR)
- Spanish (es-ES)

### Contact Support Integration:
The dialog integrates with the existing `AppService().openEmailSupport()` method to open the default email client with a pre-filled support email when users click "Contact Support".

## Usage:
The feature automatically activates when:
1. User is logged in
2. Course price status is not 'free'
3. User is not enrolled in the course
4. User attempts to access the course

## Design Features:
- Premium icon with themed styling
- Responsive layout with Material Design principles
- Proper spacing and visual hierarchy
- Theme-aware colors and styling
- Dismissible dialog (can be closed by tapping outside or back button)
- Accessible button styling with proper contrast