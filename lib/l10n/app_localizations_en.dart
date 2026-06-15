// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get incomeRequest => 'Service Request';

  @override
  String get noRequestFound => 'No request found';

  @override
  String get home => 'Home';

  @override
  String get inventory => 'Inventory';

  @override
  String get requestList => 'Request List';

  @override
  String get profile => 'Profile';

  @override
  String get myRequests => 'My Requests';

  @override
  String get noRequestsFound => 'No requests found';

  @override
  String get materialInventory => 'Material Inventory';

  @override
  String get noMaterialFound => 'No Material Found';

  @override
  String get addNewMaterial => 'Add New Material';

  @override
  String get submitRequest => 'Submit Request';

  @override
  String materialNumber(Object index) {
    return 'Material $index';
  }

  @override
  String get materialName => 'Material Name';

  @override
  String get selectProduct => 'Select Product';

  @override
  String get quantityNeeded => 'Quantity Needed';

  @override
  String get exampleQuantity => 'e.g 25';

  @override
  String get fillAllMaterials => 'Please fill all materials';

  @override
  String get pleaseSelectProduct => 'Please select product';

  @override
  String get enterQuantity => 'Enter quantity';

  @override
  String get materialRequestSuccess =>
      'Material requests submitted successfully';

  @override
  String get bulkRequest => 'Bulk Request';

  @override
  String get optionalNotes => 'Optional Notes';

  @override
  String get optionalNotesHint => 'If other issue please mention here';

  @override
  String get addBulkRequest => 'Add Bulk Request';

  @override
  String get requestMaterial => 'Request Material';

  @override
  String get materialRequest => 'Material Request';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get countLabel => 'Count:';

  @override
  String get priceLabel => '| Price:';

  @override
  String get all => 'All';

  @override
  String get accepted => 'Assigned';

  @override
  String get inProgress => 'In-progress';

  @override
  String get pending => 'Pending';

  @override
  String get completed => 'Completed';

  @override
  String get rejected => 'Rejected';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get rejectReason => 'Reject Reason';

  @override
  String get rejectReasonHint => 'Why are you rejecting this request?';

  @override
  String get save => 'Save';

  @override
  String get enterReasonError => 'Please enter a reason';

  @override
  String get serviceAccepted => 'Service Accepted';

  @override
  String get serviceRejected => 'Service Rejected';

  @override
  String get startWork => 'Start Work';

  @override
  String get customerDetails => 'Customer Details';

  @override
  String get serviceDetails => 'Service Details';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get distance => 'Distance';

  @override
  String get serviceType => 'Service Type';

  @override
  String get description => 'Description';

  @override
  String get status => 'Status';

  @override
  String get viewMedia => 'View Media';

  @override
  String get tapToView => 'Tap to view';

  @override
  String get voiceNote => 'Voice Note';

  @override
  String get playing => 'Playing...';

  @override
  String get tapToPlay => 'Tap to play';

  @override
  String get dateRequired => 'Date Required';

  @override
  String get timeWindow => 'Time Window';

  @override
  String get dateCreated => 'Date Created';

  @override
  String get mediaFiles => 'Media Files';

  @override
  String get pleaseEnterReason => 'Please enter a reason';

  @override
  String get requestInformation => 'Request Information';

  @override
  String get requestId => 'Request ID';

  @override
  String get clientName => 'Client Name';

  @override
  String get scheduledFor => 'Scheduled For';

  @override
  String get createdOn => 'Created On';

  @override
  String get sparePartsUsed => 'Spare Parts Used';

  @override
  String get noSparePartUsed => 'No Spare Part Used';

  @override
  String get completedService => 'Completed Service';

  @override
  String get timeDuration => 'Time duration';

  @override
  String get fixedMedia => 'Fixed Media';

  @override
  String get totalServiceCost => 'Total Service Cost';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get timer => 'Timer';

  @override
  String get start => 'Start';

  @override
  String get onHold => 'On Hold';

  @override
  String get updatedStatus => 'Updated Status';

  @override
  String get addNotes => 'Add Notes';

  @override
  String get mediaUploadOptional => 'Media Upload (optional)';

  @override
  String imagesSelectedCount(Object count) {
    return '$count / 10 images selected';
  }

  @override
  String get saveUpdates => 'Save Updates';

  @override
  String get updateSavedSuccessfully => 'Update saved successfully';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String sparePartsUsedCount(Object count) {
    return 'Spare Parts Used ($count)';
  }

  @override
  String get error => 'Error';

  @override
  String get noSparePartsAvailable => 'No spare parts available';

  @override
  String get selectedParts => 'Selected parts';

  @override
  String get proceedToPayment => 'Proceed to Payment';

  @override
  String get availableParts => 'Available Parts';

  @override
  String get paymentSummary => 'Payment Summary';

  @override
  String get total => 'Total';

  @override
  String get profileManagement => 'Profile Management';

  @override
  String get logOut => 'Log Out';

  @override
  String get accountDelete => 'Account Delete';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get selectReasonDelete =>
      'Select a reason before deleting your account:';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get pleaseSelectReason => 'Please select a reason';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get email => 'Email';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get enablePushNotifications => 'Enable Push Notifications';

  @override
  String get receiveAlerts => 'Receive real-time alerts and updates';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get reduceEyeStrain => 'Reduce eye strain in low light';

  @override
  String get privacyControls => 'Privacy Controls';

  @override
  String get manageDataSharing => 'Manage data sharing preferences';

  @override
  String get language => 'Language';

  @override
  String get appTitle => 'Nadi Staff';

  @override
  String get welcome => 'Welcome!';

  @override
  String get enterEmail => 'Enter email';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get login => 'Login';

  @override
  String get loginSuccessful => 'Login successful';

  @override
  String get tapAgainToExit => 'Tap again to exit';

  @override
  String get liveChat => 'Live Chat';

  @override
  String get forgotPasswordTitle => 'Forgot password!';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get emailIsRequired => 'Email is required';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get passwordIsRequired => 'Password is required';

  @override
  String get passwordResetLinkSent => 'Password reset link sent';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to log out?';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get languageEnglishShort => 'ENG';

  @override
  String get languageArabicShort => 'BH';

  @override
  String get noInternetTitle => 'No internet connection';

  @override
  String get noInternetMessage =>
      'Please check your internet connection and try again.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get deleteNotificationTitle => 'Delete notification';

  @override
  String get deleteNotificationConfirm =>
      'Are you sure you want to delete this notification?';

  @override
  String get chatsTitle => 'Chats';

  @override
  String get searchMessagesHint => 'Search messages…';

  @override
  String get noChatsFound => 'No chats found';

  @override
  String get qtyLabel => 'Qty:';

  @override
  String get addMedia => 'Add media';

  @override
  String get chat => 'Chat';

  @override
  String get admin => 'Admin';

  @override
  String errorWithDetail(Object detail) {
    return 'Error: $detail';
  }

  @override
  String get microphonePermissionDenied => 'Microphone permission denied';

  @override
  String get voiceNoteOptional => 'Voice note (optional)';

  @override
  String recordingInProgress(Object duration) {
    return 'Recording… $duration';
  }

  @override
  String get voiceNoteReady => 'Voice note ready';

  @override
  String get tapMicToRecord => 'Tap microphone to record';

  @override
  String bhdAmount(Object amount) {
    return 'BHD: $amount';
  }

  @override
  String addressFormatted(Object building, Object floor, Object aptNo) {
    return 'Building $building, floor $floor, apt $aptNo';
  }

  @override
  String distanceKm(Object km) {
    return '$km km';
  }

  @override
  String get locationLabel => 'Location';

  @override
  String get noInventoryFound => 'No inventory found';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get writeMessage => 'Write a message...';

  @override
  String get getUserApproval => 'Get User Approval';

  @override
  String get workCompleted => 'Work completed';

  @override
  String get userApproval => 'User Approval';

  @override
  String get clearAllNotificationsConfirm =>
      'Are you sure you want to clear all notifications?';
}
