// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get incomeRequest => 'طلب خدمة';

  @override
  String get noRequestFound => 'لم يتم العثور على أي طلب';

  @override
  String get home => 'الرئيسية';

  @override
  String get inventory => 'المخزون';

  @override
  String get requestList => 'قائمة الطلبات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get myRequests => 'طلباتي';

  @override
  String get noRequestsFound => 'لا توجد طلبات';

  @override
  String get materialInventory => 'مخزون المواد';

  @override
  String get noMaterialFound => 'لا توجد مواد';

  @override
  String get addNewMaterial => 'إضافة مادة جديدة';

  @override
  String get submitRequest => 'إرسال الطلب';

  @override
  String materialNumber(Object index) {
    return 'المادة $index';
  }

  @override
  String get materialName => 'اسم المادة';

  @override
  String get selectProduct => 'اختر المنتج';

  @override
  String get quantityNeeded => 'الكمية المطلوبة';

  @override
  String get exampleQuantity => 'مثال 25';

  @override
  String get fillAllMaterials => 'يرجى ملء جميع المواد';

  @override
  String get pleaseSelectProduct => 'يرجى اختيار المنتج';

  @override
  String get enterQuantity => 'أدخل الكمية';

  @override
  String get materialRequestSuccess => 'تم إرسال طلبات المواد بنجاح';

  @override
  String get bulkRequest => 'طلب جماعي';

  @override
  String get optionalNotes => 'ملاحظات اختيارية';

  @override
  String get optionalNotesHint => 'إذا كانت هناك مشكلة أخرى يرجى ذكرها هنا';

  @override
  String get addBulkRequest => 'إضافة طلب جماعي';

  @override
  String get requestMaterial => 'طلب المواد';

  @override
  String get materialRequest => 'طلب المواد';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get profileUpdatedSuccessfully => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get countLabel => 'الكمية:';

  @override
  String get priceLabel => '| السعر:';

  @override
  String get all => 'الكل';

  @override
  String get accepted => 'مُكَلَّف';

  @override
  String get inProgress => 'قيد التنفيذ';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get completed => 'مكتمل';

  @override
  String get rejected => 'مرفوض';

  @override
  String get accept => 'قبول';

  @override
  String get reject => 'رفض';

  @override
  String get rejectReason => 'سبب الرفض';

  @override
  String get rejectReasonHint => 'لماذا تقوم برفض هذا الطلب؟';

  @override
  String get save => 'حفظ';

  @override
  String get enterReasonError => 'يرجى إدخال سبب';

  @override
  String get serviceAccepted => 'تم قبول الخدمة';

  @override
  String get serviceRejected => 'تم رفض الخدمة';

  @override
  String get startWork => 'بدء العمل';

  @override
  String get customerDetails => 'تفاصيل العميل';

  @override
  String get serviceDetails => 'تفاصيل الخدمة';

  @override
  String get name => 'الاسم';

  @override
  String get phone => 'الهاتف';

  @override
  String get address => 'العنوان';

  @override
  String get distance => 'المسافة';

  @override
  String get serviceType => 'نوع الخدمة';

  @override
  String get description => 'الوصف';

  @override
  String get status => 'الحالة';

  @override
  String get viewMedia => 'عرض الوسائط';

  @override
  String get tapToView => 'اضغط للعرض';

  @override
  String get voiceNote => 'ملاحظة صوتية';

  @override
  String get playing => 'يتم التشغيل...';

  @override
  String get tapToPlay => 'اضغط للتشغيل';

  @override
  String get dateRequired => 'التاريخ المطلوب';

  @override
  String get timeWindow => 'الوقت';

  @override
  String get dateCreated => 'تاريخ الإنشاء';

  @override
  String get mediaFiles => 'ملفات الوسائط';

  @override
  String get pleaseEnterReason => 'يرجى إدخال السبب';

  @override
  String get requestInformation => 'معلومات الطلب';

  @override
  String get requestId => 'معرف الطلب';

  @override
  String get clientName => 'اسم العميل';

  @override
  String get scheduledFor => 'مجدول لـ';

  @override
  String get createdOn => 'تاريخ الإنشاء';

  @override
  String get sparePartsUsed => 'قطع الغيار المستخدمة';

  @override
  String get noSparePartUsed => 'لم يتم استخدام قطع غيار';

  @override
  String get completedService => 'الخدمة المكتملة';

  @override
  String get timeDuration => 'مدة الوقت';

  @override
  String get fixedMedia => 'الوسائط الثابتة';

  @override
  String get totalServiceCost => 'إجمالي تكلفة الخدمة';

  @override
  String get totalAmount => 'المبلغ الإجمالي';

  @override
  String get timer => 'المؤقت';

  @override
  String get start => 'ابدأ';

  @override
  String get onHold => 'قيد الانتظار';

  @override
  String get updatedStatus => 'الحالة المحدثة';

  @override
  String get addNotes => 'إضافة ملاحظات';

  @override
  String get mediaUploadOptional => 'رفع الوسائط (اختياري)';

  @override
  String imagesSelectedCount(Object count) {
    return '$count / 10 صور تم اختيارها';
  }

  @override
  String get saveUpdates => 'حفظ التحديثات';

  @override
  String get updateSavedSuccessfully => 'تم حفظ التحديث بنجاح';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String sparePartsUsedCount(Object count) {
    return 'تم استخدام قطع الغيار ($count)';
  }

  @override
  String get error => 'خطأ';

  @override
  String get noSparePartsAvailable => 'لا توجد قطع غيار متاحة';

  @override
  String get selectedParts => 'الأجزاء المختارة';

  @override
  String get proceedToPayment => 'المتابعة إلى الدفع';

  @override
  String get availableParts => 'الأجزاء المتاحة';

  @override
  String get paymentSummary => 'ملخص الدفع';

  @override
  String get total => 'الإجمالي';

  @override
  String get profileManagement => 'إدارة الملف الشخصي';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get accountDelete => 'حذف الحساب';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get selectReasonDelete => 'اختر سببًا قبل حذف حسابك:';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get pleaseSelectReason => 'يرجى اختيار سبب';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get mobileNumber => 'رقم الهاتف';

  @override
  String get enablePushNotifications => 'تمكين الإشعارات الفورية';

  @override
  String get receiveAlerts => 'تلقي التنبيهات والتحديثات الفورية';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get reduceEyeStrain => 'تقليل إجهاد العين في الضوء المنخفض';

  @override
  String get privacyControls => 'إعدادات الخصوصية';

  @override
  String get manageDataSharing => 'إدارة تفضيلات مشاركة البيانات';

  @override
  String get language => 'اللغة';

  @override
  String get appTitle => 'طاقم نادي';

  @override
  String get welcome => 'مرحباً!';

  @override
  String get enterEmail => 'أدخل البريد الإلكتروني';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get loginSuccessful => 'تم تسجيل الدخول بنجاح';

  @override
  String get tapAgainToExit => 'اضغط مرة أخرى للخروج';

  @override
  String get liveChat => 'محادثة مباشرة';

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور!';

  @override
  String get sendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get emailIsRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get enterValidEmail => 'أدخل بريداً إلكترونياً صالحاً';

  @override
  String get passwordIsRequired => 'كلمة المرور مطلوبة';

  @override
  String get passwordResetLinkSent => 'تم إرسال رابط إعادة تعيين كلمة المرور';

  @override
  String get logoutConfirmMessage => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get languageEnglishShort => 'ENG';

  @override
  String get languageArabicShort => 'BH';

  @override
  String get noInternetTitle => 'لا يوجد اتصال بالإنترنت';

  @override
  String get noInternetMessage =>
      'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get deleteNotificationTitle => 'حذف الإشعار';

  @override
  String get deleteNotificationConfirm =>
      'هل أنت متأكد أنك تريد حذف هذا الإشعار؟';

  @override
  String get chatsTitle => 'المحادثات';

  @override
  String get searchMessagesHint => 'ابحث في الرسائل…';

  @override
  String get noChatsFound => 'لا توجد محادثات';

  @override
  String get qtyLabel => 'الكمية:';

  @override
  String get addMedia => 'إضافة وسائط';

  @override
  String get chat => 'محادثة';

  @override
  String get admin => 'المسؤول';

  @override
  String errorWithDetail(Object detail) {
    return 'خطأ: $detail';
  }

  @override
  String get microphonePermissionDenied => 'تم رفض إذن الميكروفون';

  @override
  String get voiceNoteOptional => 'ملاحظة صوتية (اختياري)';

  @override
  String recordingInProgress(Object duration) {
    return 'جاري التسجيل… $duration';
  }

  @override
  String get voiceNoteReady => 'الملاحظة الصوتية جاهزة';

  @override
  String get tapMicToRecord => 'اضغط على الميكروفون للتسجيل';

  @override
  String bhdAmount(Object amount) {
    return 'د.ب: $amount';
  }

  @override
  String addressFormatted(Object building, Object floor, Object aptNo) {
    return 'المبنى $building، الطابق $floor، الشقة $aptNo';
  }

  @override
  String distanceKm(Object km) {
    return '$km كم';
  }

  @override
  String get locationLabel => 'الموقع';

  @override
  String get noInventoryFound => 'لا يوجد مخزون';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get writeMessage => 'اكتب رسالة...';

  @override
  String get getUserApproval => 'الحصول على موافقة المستخدم';

  @override
  String get workCompleted => 'تم إكمال العمل';
}
