import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @incomeRequest.
  ///
  /// In en, this message translates to:
  /// **'Service Request'**
  String get incomeRequest;

  /// No description provided for @noRequestFound.
  ///
  /// In en, this message translates to:
  /// **'No request found'**
  String get noRequestFound;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @requestList.
  ///
  /// In en, this message translates to:
  /// **'Request List'**
  String get requestList;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequests;

  /// No description provided for @noRequestsFound.
  ///
  /// In en, this message translates to:
  /// **'No requests found'**
  String get noRequestsFound;

  /// No description provided for @materialInventory.
  ///
  /// In en, this message translates to:
  /// **'Material Inventory'**
  String get materialInventory;

  /// No description provided for @noMaterialFound.
  ///
  /// In en, this message translates to:
  /// **'No Material Found'**
  String get noMaterialFound;

  /// No description provided for @addNewMaterial.
  ///
  /// In en, this message translates to:
  /// **'Add New Material'**
  String get addNewMaterial;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @materialNumber.
  ///
  /// In en, this message translates to:
  /// **'Material {index}'**
  String materialNumber(Object index);

  /// No description provided for @materialName.
  ///
  /// In en, this message translates to:
  /// **'Material Name'**
  String get materialName;

  /// No description provided for @selectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select Product'**
  String get selectProduct;

  /// No description provided for @quantityNeeded.
  ///
  /// In en, this message translates to:
  /// **'Quantity Needed'**
  String get quantityNeeded;

  /// No description provided for @exampleQuantity.
  ///
  /// In en, this message translates to:
  /// **'e.g 25'**
  String get exampleQuantity;

  /// No description provided for @fillAllMaterials.
  ///
  /// In en, this message translates to:
  /// **'Please fill all materials'**
  String get fillAllMaterials;

  /// No description provided for @pleaseSelectProduct.
  ///
  /// In en, this message translates to:
  /// **'Please select product'**
  String get pleaseSelectProduct;

  /// No description provided for @enterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get enterQuantity;

  /// No description provided for @materialRequestSuccess.
  ///
  /// In en, this message translates to:
  /// **'Material requests submitted successfully'**
  String get materialRequestSuccess;

  /// No description provided for @bulkRequest.
  ///
  /// In en, this message translates to:
  /// **'Bulk Request'**
  String get bulkRequest;

  /// No description provided for @optionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Optional Notes'**
  String get optionalNotes;

  /// No description provided for @optionalNotesHint.
  ///
  /// In en, this message translates to:
  /// **'If other issue please mention here'**
  String get optionalNotesHint;

  /// No description provided for @addBulkRequest.
  ///
  /// In en, this message translates to:
  /// **'Add Bulk Request'**
  String get addBulkRequest;

  /// No description provided for @requestMaterial.
  ///
  /// In en, this message translates to:
  /// **'Request Material'**
  String get requestMaterial;

  /// No description provided for @materialRequest.
  ///
  /// In en, this message translates to:
  /// **'Material Request'**
  String get materialRequest;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @countLabel.
  ///
  /// In en, this message translates to:
  /// **'Count:'**
  String get countLabel;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'| Price:'**
  String get priceLabel;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get accepted;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In-progress'**
  String get inProgress;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @rejectReason.
  ///
  /// In en, this message translates to:
  /// **'Reject Reason'**
  String get rejectReason;

  /// No description provided for @rejectReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Why are you rejecting this request?'**
  String get rejectReasonHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @enterReasonError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason'**
  String get enterReasonError;

  /// No description provided for @serviceAccepted.
  ///
  /// In en, this message translates to:
  /// **'Service Accepted'**
  String get serviceAccepted;

  /// No description provided for @serviceRejected.
  ///
  /// In en, this message translates to:
  /// **'Service Rejected'**
  String get serviceRejected;

  /// No description provided for @startWork.
  ///
  /// In en, this message translates to:
  /// **'Start Work'**
  String get startWork;

  /// No description provided for @customerDetails.
  ///
  /// In en, this message translates to:
  /// **'Customer Details'**
  String get customerDetails;

  /// No description provided for @serviceDetails.
  ///
  /// In en, this message translates to:
  /// **'Service Details'**
  String get serviceDetails;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @serviceType.
  ///
  /// In en, this message translates to:
  /// **'Service Type'**
  String get serviceType;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @viewMedia.
  ///
  /// In en, this message translates to:
  /// **'View Media'**
  String get viewMedia;

  /// No description provided for @tapToView.
  ///
  /// In en, this message translates to:
  /// **'Tap to view'**
  String get tapToView;

  /// No description provided for @voiceNote.
  ///
  /// In en, this message translates to:
  /// **'Voice Note'**
  String get voiceNote;

  /// No description provided for @playing.
  ///
  /// In en, this message translates to:
  /// **'Playing...'**
  String get playing;

  /// No description provided for @tapToPlay.
  ///
  /// In en, this message translates to:
  /// **'Tap to play'**
  String get tapToPlay;

  /// No description provided for @dateRequired.
  ///
  /// In en, this message translates to:
  /// **'Date Required'**
  String get dateRequired;

  /// No description provided for @timeWindow.
  ///
  /// In en, this message translates to:
  /// **'Time Window'**
  String get timeWindow;

  /// No description provided for @dateCreated.
  ///
  /// In en, this message translates to:
  /// **'Date Created'**
  String get dateCreated;

  /// No description provided for @mediaFiles.
  ///
  /// In en, this message translates to:
  /// **'Media Files'**
  String get mediaFiles;

  /// No description provided for @pleaseEnterReason.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason'**
  String get pleaseEnterReason;

  /// No description provided for @requestInformation.
  ///
  /// In en, this message translates to:
  /// **'Request Information'**
  String get requestInformation;

  /// No description provided for @requestId.
  ///
  /// In en, this message translates to:
  /// **'Request ID'**
  String get requestId;

  /// No description provided for @clientName.
  ///
  /// In en, this message translates to:
  /// **'Client Name'**
  String get clientName;

  /// No description provided for @scheduledFor.
  ///
  /// In en, this message translates to:
  /// **'Scheduled For'**
  String get scheduledFor;

  /// No description provided for @createdOn.
  ///
  /// In en, this message translates to:
  /// **'Created On'**
  String get createdOn;

  /// No description provided for @sparePartsUsed.
  ///
  /// In en, this message translates to:
  /// **'Spare Parts Used'**
  String get sparePartsUsed;

  /// No description provided for @noSparePartUsed.
  ///
  /// In en, this message translates to:
  /// **'No Spare Part Used'**
  String get noSparePartUsed;

  /// No description provided for @completedService.
  ///
  /// In en, this message translates to:
  /// **'Completed Service'**
  String get completedService;

  /// No description provided for @timeDuration.
  ///
  /// In en, this message translates to:
  /// **'Time duration'**
  String get timeDuration;

  /// No description provided for @fixedMedia.
  ///
  /// In en, this message translates to:
  /// **'Fixed Media'**
  String get fixedMedia;

  /// No description provided for @totalServiceCost.
  ///
  /// In en, this message translates to:
  /// **'Total Service Cost'**
  String get totalServiceCost;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @timer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timer;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @onHold.
  ///
  /// In en, this message translates to:
  /// **'On Hold'**
  String get onHold;

  /// No description provided for @updatedStatus.
  ///
  /// In en, this message translates to:
  /// **'Updated Status'**
  String get updatedStatus;

  /// No description provided for @addNotes.
  ///
  /// In en, this message translates to:
  /// **'Add Notes'**
  String get addNotes;

  /// No description provided for @mediaUploadOptional.
  ///
  /// In en, this message translates to:
  /// **'Media Upload (optional)'**
  String get mediaUploadOptional;

  /// No description provided for @imagesSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} / 10 images selected'**
  String imagesSelectedCount(Object count);

  /// No description provided for @saveUpdates.
  ///
  /// In en, this message translates to:
  /// **'Save Updates'**
  String get saveUpdates;

  /// No description provided for @updateSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Update saved successfully'**
  String get updateSavedSuccessfully;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @sparePartsUsedCount.
  ///
  /// In en, this message translates to:
  /// **'Spare Parts Used ({count})'**
  String sparePartsUsedCount(Object count);

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @noSparePartsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No spare parts available'**
  String get noSparePartsAvailable;

  /// No description provided for @selectedParts.
  ///
  /// In en, this message translates to:
  /// **'Selected parts'**
  String get selectedParts;

  /// No description provided for @proceedToPayment.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Payment'**
  String get proceedToPayment;

  /// No description provided for @availableParts.
  ///
  /// In en, this message translates to:
  /// **'Available Parts'**
  String get availableParts;

  /// No description provided for @paymentSummary.
  ///
  /// In en, this message translates to:
  /// **'Payment Summary'**
  String get paymentSummary;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @profileManagement.
  ///
  /// In en, this message translates to:
  /// **'Profile Management'**
  String get profileManagement;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @accountDelete.
  ///
  /// In en, this message translates to:
  /// **'Account Delete'**
  String get accountDelete;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @selectReasonDelete.
  ///
  /// In en, this message translates to:
  /// **'Select a reason before deleting your account:'**
  String get selectReasonDelete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @pleaseSelectReason.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason'**
  String get pleaseSelectReason;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @enablePushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Push Notifications'**
  String get enablePushNotifications;

  /// No description provided for @receiveAlerts.
  ///
  /// In en, this message translates to:
  /// **'Receive real-time alerts and updates'**
  String get receiveAlerts;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @reduceEyeStrain.
  ///
  /// In en, this message translates to:
  /// **'Reduce eye strain in low light'**
  String get reduceEyeStrain;

  /// No description provided for @privacyControls.
  ///
  /// In en, this message translates to:
  /// **'Privacy Controls'**
  String get privacyControls;

  /// No description provided for @manageDataSharing.
  ///
  /// In en, this message translates to:
  /// **'Manage data sharing preferences'**
  String get manageDataSharing;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Nadi Staff'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccessful;

  /// No description provided for @tapAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Tap again to exit'**
  String get tapAgainToExit;

  /// No description provided for @liveChat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get liveChat;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password!'**
  String get forgotPasswordTitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @emailIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailIsRequired;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @passwordIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordIsRequired;

  /// No description provided for @passwordResetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent'**
  String get passwordResetLinkSent;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmMessage;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @languageEnglishShort.
  ///
  /// In en, this message translates to:
  /// **'ENG'**
  String get languageEnglishShort;

  /// No description provided for @languageArabicShort.
  ///
  /// In en, this message translates to:
  /// **'BH'**
  String get languageArabicShort;

  /// No description provided for @noInternetTitle.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetTitle;

  /// No description provided for @noInternetMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get noInternetMessage;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @deleteNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete notification'**
  String get deleteNotificationTitle;

  /// No description provided for @deleteNotificationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this notification?'**
  String get deleteNotificationConfirm;

  /// No description provided for @chatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatsTitle;

  /// No description provided for @searchMessagesHint.
  ///
  /// In en, this message translates to:
  /// **'Search messages…'**
  String get searchMessagesHint;

  /// No description provided for @noChatsFound.
  ///
  /// In en, this message translates to:
  /// **'No chats found'**
  String get noChatsFound;

  /// No description provided for @qtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty:'**
  String get qtyLabel;

  /// No description provided for @addMedia.
  ///
  /// In en, this message translates to:
  /// **'Add media'**
  String get addMedia;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @errorWithDetail.
  ///
  /// In en, this message translates to:
  /// **'Error: {detail}'**
  String errorWithDetail(Object detail);

  /// No description provided for @microphonePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied'**
  String get microphonePermissionDenied;

  /// No description provided for @voiceNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Voice note (optional)'**
  String get voiceNoteOptional;

  /// No description provided for @recordingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Recording… {duration}'**
  String recordingInProgress(Object duration);

  /// No description provided for @voiceNoteReady.
  ///
  /// In en, this message translates to:
  /// **'Voice note ready'**
  String get voiceNoteReady;

  /// No description provided for @tapMicToRecord.
  ///
  /// In en, this message translates to:
  /// **'Tap microphone to record'**
  String get tapMicToRecord;

  /// No description provided for @bhdAmount.
  ///
  /// In en, this message translates to:
  /// **'BHD: {amount}'**
  String bhdAmount(Object amount);

  /// No description provided for @addressFormatted.
  ///
  /// In en, this message translates to:
  /// **'Building {building}, floor {floor}, apt {aptNo}'**
  String addressFormatted(Object building, Object floor, Object aptNo);

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String distanceKm(Object km);

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @noInventoryFound.
  ///
  /// In en, this message translates to:
  /// **'No inventory found'**
  String get noInventoryFound;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @writeMessage.
  ///
  /// In en, this message translates to:
  /// **'Write a message...'**
  String get writeMessage;

  /// No description provided for @getUserApproval.
  ///
  /// In en, this message translates to:
  /// **'Get User Approval'**
  String get getUserApproval;

  /// No description provided for @workCompleted.
  ///
  /// In en, this message translates to:
  /// **'Work completed'**
  String get workCompleted;

  /// No description provided for @userApproval.
  ///
  /// In en, this message translates to:
  /// **'User Approval'**
  String get userApproval;

  /// No description provided for @clearAllNotificationsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all notifications?'**
  String get clearAllNotificationsConfirm;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
