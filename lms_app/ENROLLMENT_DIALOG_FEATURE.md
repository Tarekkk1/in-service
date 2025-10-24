# Enrollment Dialog Feature

## Overview
This feature implements a premium course enrollment dialog that appears when users try to access paid courses they are not enrolled in. The dialog encourages users to contact customer support via WhatsApp for enrollment assistance.

## Implementation Details

### Files Modified/Created:
1. **`lib/utils/enrollment_dialog.dart`** - New dialog component
2. **`lib/mixins/user_mixin.dart`** - Updated to use enrollment dialog
3. **`lib/services/app_service.dart`** - Added WhatsApp support functionality
4. **Translation files** - Added new translation keys

### How It Works:
1. When a user clicks on a paid course they're not enrolled in, the `handleEnrollment` method in `UserMixin` is called
2. If the course is not free and the user is not enrolled, the enrollment dialog is displayed
3. The dialog shows:
   - Premium course icon
   - Clear message about enrollment requirement
   - WhatsApp contact support information
   - Action buttons (Close/Contact Support via WhatsApp)

### Translation Keys Added:
- `enrollment-required-title`: "Enrollment Required"
- `enrollment-required-subtitle`: "This premium course requires enrollment approval..."
- `customer-support-info`: "Contact us via WhatsApp for quick assistance..."
- `contact-support`: "Contact Support"
- `whatsapp-enrollment-message`: Pre-filled WhatsApp message for support

### Languages Supported:
- English (en-US)
- Arabic (ar-SA)

### WhatsApp Integration:
The dialog integrates with WhatsApp via `AppService().openWhatsAppSupport()` method:
- **Phone Number**: +201147157411
- **Pre-filled Message**: Localized message asking for enrollment assistance
- **Cross-platform**: Works on web, iOS, and Android

## Usage:
The feature automatically activates when:
1. User is logged in
2. Course price status is not 'free'
3. User is not enrolled in the course
4. User attempts to access the course

## Design Features:
- Premium icon with themed styling
- Chat icon to indicate WhatsApp communication
- Responsive layout with Material Design principles
- Proper spacing and visual hierarchy
- Theme-aware colors and styling
- Dismissible dialog (can be closed by tapping outside or back button)
- Accessible button styling with proper contrast

## WhatsApp Features:
- Automatically opens WhatsApp when "Contact Support" is pressed
- Pre-fills message in user's language
- Uses international phone number format
- Fallback error handling if WhatsApp can't be opened