import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi() : super(const Locale('hi'));

  // ------------------------------------------------------------
  // LOGIN / ONBOARDING
  // ------------------------------------------------------------
  @override
  String get yourTrustedDigitalLedger =>
      "आपकी भरोसेमंद डिजिटल लेजर";

  @override
  String get accountStatement =>
      "खाता विवरण";
  @override
  String get settings => 'सेटिंग्स';
  
  @override
  String get manageAppSettings => 'ऐप की सेटिंग्स प्रबंधित करें';

  @override
  String get generatedByChopdi =>
      "Chopdi द्वारा जनरेट किया गया";

  @override
  String get tookLoanStatement =>
      "लिए गए लोन का विवरण";
  @override
  String get LenderAlreadyExists =>
      "लेंडर पहले से मौजूद है";

  @override
  String get customerStatement =>
      "ग्राहक विवरण";

  @override
  String get loanSummaryAndRepaymentHistory =>
      "लोन सारांश और भुगतान इतिहास";

  @override
  String get accountSummaryAndTransactionHistory =>
      "खाता सारांश और लेन-देन इतिहास";

  @override
  String get currentBalance =>
      "वर्तमान बैलेंस";

  @override
  String get accountOverview =>
      "खाता अवलोकन";

  @override
  String get youTook =>
      "आपको मिले";

  @override
  String get totalLoanTaken =>
      "कुल लिया गया लोन";

  @override
  String get youPaid =>
      "आपने दिए";

  @override
  String get youReceived =>
      "आपको प्राप्त हुआ";

  @override
  String get totalRepaid =>
      "कुल चुकाया गया";

  @override
  String get totalReceived =>
      "कुल प्राप्त राशि";

  @override
  String get interest =>
      "ब्याज";

  @override
  String get calculatedInterest =>
      "गणना किया गया ब्याज";

  @override
  String get transactionHistory =>
      "लेन-देन इतिहास";

  @override
  String get records =>
      "रिकॉर्ड";

  @override
  String get finalBalance =>
      "अंतिम बैलेंस";

  @override
  String get totalPaid =>
      "कुल भुगतान";

  @override
  String get outstandingBalance =>
      "बकाया बैलेंस";

  @override
  String get thankYouForUsingChopdi =>
      "Chopdi इस्तेमाल करने के लिए धन्यवाद";

  @override
  String get keepRecordsSimple =>
      "अपने रिकॉर्ड सरल रखें। उन्हें Chopdi के साथ सुरक्षित रखें।";

  @override
  String get noTransactionsAvailable =>
      "कोई लेन-देन उपलब्ध नहीं है";

  @override
  String get pdfPreview =>
      "PDF प्रीव्यू";

  @override
  String get viewPdf =>
      "PDF देखें";

  @override
  String get downloadPdf =>
      "PDF डाउनलोड करें";

  // @override
  // String get loginLetsGetStarted => "शुरू करते हैं";

  // @override
  // String get loginEnterMobileNumber =>
  //     "Chopdi पर जारी रखने के लिए\nअपना मोबाइल नंबर दर्ज करें";

  // @override
  // String get loginYourLendingRecords => "आपके उधार के रिकॉर्ड,\n";

  // @override
  // String get loginDigitallyOrganized => "अब डिजिटल रूप से व्यवस्थित।";

  // @override
  // String get loginTrackLoans =>
  //     "लोन, ब्याज और भुगतान को\nआसानी और भरोसे के साथ ट्रैक करें।";

  // @override
  // String get loginSecureData => "आपका डेटा हमारे साथ सुरक्षित है";

  // @override
  // String get loginContinue => "जारी रखें";

  // @override
  // String get loginByContinuing =>
  //     "जारी रखकर, आप हमारी\n";

  // @override
  // String get loginTermsOfService => "सेवा की शर्तों";

  // @override
  // String get loginAnd => " और ";

  // @override
  // String get loginPrivacyPolicy => "गोपनीयता नीति";

  // ------------------------------------------------------------
  // LOGIN / ONBOARDING
  // ------------------------------------------------------------

  @override
  String get loginLetsGetStarted => "शुरू करते हैं";

  @override
  String get loginEnterMobileNumber =>
      "जारी रखने के लिए अपना मोबाइल नंबर दर्ज करें";

  @override
  String get loginYourLendingRecords =>
      "आपके उधार के रिकॉर्ड,\n";

  @override
  String get loginDigitallyOrganized =>
      "डिजिटल रूप से व्यवस्थित।";

  @override
  String get loginTrackLoans =>
      "ऋण, ब्याज और भुगतान को\nस्पष्टता और आसानी से ट्रैक करें।";

  @override
  String get loginSecureData =>
      "आपका डेटा हमारे पास सुरक्षित है";

  @override
  String get loginContinue =>
      "जारी रखें";

  @override
  String get loginByContinuing =>
      "जारी रखकर, आप हमारी\n";

  @override
  String get loginTermsOfService =>
      "सेवा की शर्तों";

  @override
  String get loginAnd =>
      " और ";

  @override
  String get loginPrivacyPolicy =>
      "गोपनीयता नीति";

  // ------------------------------------------------------------
  // LOGIN VALIDATION / ERRORS
  // ------------------------------------------------------------

  // @override
  // String get loginMobileNumberRequired =>
  //     "कृपया अपना मोबाइल नंबर दर्ज करें";

  // @override
  // String get loginInvalidMobileNumber =>
  //     "कृपया मान्य 10 अंकों का मोबाइल नंबर दर्ज करें";

  // @override
  // String get loginOtpAlreadySent =>
  //     "एक कोड पहले ही भेजा जा चुका है। कृपया कुछ समय प्रतीक्षा करें।";

  // @override
  // String get loginNetworkUnavailable =>
  //     "सर्वर से कनेक्ट नहीं हो पा रहा है। अपना इंटरनेट कनेक्शन जांचें।";

  // @override
  // String get loginDevKeyMissing =>
  //     "इस बिल्ड में DEV_KEY उपलब्ध नहीं है।\n\n"
  //         "AUTH_DEV_KEY को env/staging.env में जोड़ें और फिर\n"
  //         "--dart-define-from-file=env/staging.env के साथ बिल्ड करें।";

  // @override
  // String get loginDevKeyRejected =>
  //     "इस बिल्ड की DEV_KEY अस्वीकार कर दी गई है। "
  //         "जांचें कि यह सर्वर की AUTH_DEV_KEY से मेल खाती है।";

  // @override
  // String get loginSomethingWentWrong =>
  //     "कुछ गलत हो गया। कृपया फिर से प्रयास करें।";
  @override
  String get loginMobileNumberRequired =>
      "कृपया अपना मोबाइल नंबर दर्ज करें";

  @override
  String get loginInvalidMobileNumber =>
      "कृपया मान्य 10 अंकों का मोबाइल नंबर दर्ज करें";

  @override
  String get loginOtpAlreadySent =>
      "कोड पहले ही भेजा जा चुका है। कृपया कुछ समय प्रतीक्षा करें।";

  @override
  String get loginNetworkUnavailable =>
      "सर्वर से कनेक्ट नहीं हो पा रहा है। अपना इंटरनेट कनेक्शन जांचें।";

  @override
  String get loginDevKeyMissing =>
      "इस बिल्ड में DEV_KEY उपलब्ध नहीं है।\n\n"
      "AUTH_DEV_KEY को env/staging.env में जोड़ें, फिर\n"
      "--dart-define-from-file=env/staging.env के साथ दोबारा बिल्ड करें।";

  @override
  String get loginDevKeyRejected =>
      "इस बिल्ड में DEV_KEY अस्वीकार कर दी गई है। "
      "जांचें कि यह सर्वर पर मौजूद AUTH_DEV_KEY से मेल खाती है।";

  @override
  String get loginSomethingWentWrong =>
      "कुछ गलत हो गया। कृपया पुनः प्रयास करें।";
  
  @override
  String get loginEnterMobileToContinue =>
    "चोपड़ी पर आगे बढ़ने के लिए\nअपना मोबाइल नंबर दर्ज करें";

  // ------------------------------------------------------------
// HOME
// ------------------------------------------------------------

  @override
  String get homeAddCustomer => "ग्राहक जोड़ें";

  @override
  String get homeAddLoan => "लोन जोड़ें";

  @override
  String get homeNoCustomersYet => "अभी तक कोई ग्राहक नहीं है!";

  @override
  String get homeNoLendersYet => "अभी तक कोई उधारदाता नहीं है!";

  @override
  String get homeStartAddingCustomer =>
      "ग्राहक जोड़कर शुरुआत करें और\n"
          "अपने लोन को आसानी से ट्रैक करें";

  @override
  String get homeStartAddingLender =>
      "उधारदाता जोड़कर शुरुआत करें और\n"
        "अपने ऋणों का आसानी से हिसाब रखें";

  // ------------------------------------------------------------
// HOME HEADER
// ------------------------------------------------------------

  @override
  String get homeMyChopdi => "मेरी चोपड़ी";

  @override
  String get homeTapToChangeChopdi =>
      "चोपड़ी बदलने के लिए टैप करें";

// ------------------------------------------------------------
// HOME SUMMARY
// ------------------------------------------------------------

  @override
  String get homeTotalOutstandingAmount =>
      "कुल बकाया राशि";

  @override
  String get homeTotalLoanGiven =>
      "दिया गया कुल लोन";

  @override
  String get homeTotalInterestEarned =>
      "कुल अर्जित ब्याज";

// ------------------------------------------------------------
// HOME LOAN TOGGLE
// ------------------------------------------------------------

  @override
  String get homeIGaveLoan => "मैंने लोन दिया";

  @override
  String get homeReceiveInterest => "(ब्याज प्राप्त करें)";

  @override
  String get homeITookLoan => "मैंने लोन लिया";

  @override
  String get homePayInterest => "(ब्याज चुकाएं)";
  @override
  String get customersTitle => "ग्राहक";

  @override
  String get manageAllCustomers => "अपने सभी ग्राहकों को प्रबंधित करें";

  @override
  String get searchByNameAndPhone =>
      "नाम और फोन नंबर से खोजें";

  @override
  String get filter => "फ़िल्टर";

  // @override
  // String get customersCount => "Customers";

  @override
  String get sortBy => "क्रमबद्ध करें";

  @override
  String get noCustomersFound => "कोई ग्राहक नहीं मिला";

  @override
  String get sortNameAZ => "नाम (अ-ह)";

  @override
  String get sortNameZA => "नाम (ह-अ)";

  @override
  String get sortRecentlyAdded => "हाल ही में जोड़े गए";

  @override
  String get sortLoanAmountHighToLow =>
      "लोन राशि (अधिक से कम)";

  @override
  String get sortLoanAmountLowToHigh =>
      "लोन राशि (कम से अधिक)";

  @override
  String get addCustomer => "ग्राहक जोड़ें";

  @override
  String get allContacts => "सभी संपर्क";

  @override
  String get contactsPermissionRequired =>
      "संपर्क अनुमति आवश्यक है";

  @override
  String get allowContacts => "संपर्कों की अनुमति दें";

  @override
  String get noContactsFound => "कोई संपर्क नहीं मिला";

  @override
  String get noPhoneNumber => "कोई फोन नंबर नहीं है";

  @override
  String get unknownContact => "अज्ञात";

  @override
  String get unableToLoadContacts =>
      "संपर्क लोड नहीं हो सके";
  @override
  String get youGave => "आपने दिए ₹";

  @override
  String get youGot => "आपको मिले ₹";

  @override
  String get totalGiven => "कुल दी गई राशि";

  @override
  String get totalInterest => "कुल ब्याज";

  @override
  String get outstanding => "बकाया राशि";

  @override
  String get addLender => "उधारदाता जोड़ें";
  @override
  String get addNewCustomer => "नया ग्राहक जोड़ें";

  @override
  String get customerDetails => "ग्राहक विवरण";

  @override
  String get nameRequired => "नाम*";

  @override
  String get customerName => "ग्राहक का नाम";

  @override
  String get enterCustomerName =>
      "ग्राहक का नाम दर्ज करें";

  @override
  String get phoneNumberOptional =>
      "फोन नंबर (वैकल्पिक)";

  @override
  String get mobileNumber => "मोबाइल नंबर";

  @override
  String get enterValid10DigitPhone =>
      "मान्य 10 अंकों का फोन नंबर दर्ज करें";



  @override
  String get cancel => "रद्द करें";

  @override
  String get customerAlreadyExists =>
      "ग्राहक पहले से मौजूद है";

  @override
  String get duplicateCustomerMessage =>
      "समान नाम और फोन नंबर वाला ग्राहक पहले से जोड़ा गया है।";

  @override
  String get ok => "ठीक है";

  @override
  String get failedToAddCustomer =>
      "ग्राहक जोड़ने में समस्या हुई। कृपया फिर से प्रयास करें।";
  @override
  String get manageCurrentChopdi =>
      "अपनी वर्तमान चोपड़ी मैनेज करें";

  @override
  String get preferences => "प्राथमिकताएं";

  @override
  String get notificationsSettings =>
      "नोटिफिकेशन सेटिंग्स";

  @override
  String get manageAppNotifications =>
      "ऐप नोटिफिकेशन मैनेज करें";

  @override
  String get support => "सहायता";

  @override
  String get helpFaqs => "सहायता और सामान्य प्रश्न";

  @override
  String get getAnswersCommonQuestions =>
      "सामान्य प्रश्नों के उत्तर पाएं";

  @override
  String get termsPrivacy => "नियम और गोपनीयता";

  @override
  String get readOurPolicies =>
      "हमारी नीतियां पढ़ें";

  @override
  String get logout => "लॉगआउट";

  @override
  String get signOutOfAccount =>
      "अपने अकाउंट से साइन आउट करें";

  @override
  String get areYouSureLogout =>
      "क्या आप वाकई लॉगआउट करना चाहते हैं?";

  @override
  String get unableToLogout =>
      "लॉगआउट नहीं हो सका। कृपया फिर से प्रयास करें।";

  @override
  String get myChopdi => "मेरी चोपड़ी";

  @override
  String get myPersonalLendingLedger =>
      "लोन और ब्याज को ट्रैक करने के लिए\nमेरी व्यक्तिगत उधार बही।";

  @override
  String get createdOn => "बनाया गया";

  @override
  String get totalCustomers => "कुल ग्राहक";

  @override
  String get totalLoanGiven => "कुल दिया गया लोन";

  @override
  String get totalInterestEarned => "कुल अर्जित ब्याज";

  @override
  String get totalOutstanding => "कुल बकाया";

  @override
  String get chopdi => "चोपड़ी";
  @override
  String get unableToLoadChopdiDetails =>
      "चोपड़ी का विवरण लोड नहीं हो सका।";

  @override
  String get pleaseEnterChopdiName =>
      "कृपया चोपड़ी का नाम दर्ज करें।";

  @override
  String get chopdiNameCannotExceed50 =>
      "चोपड़ी का नाम 50 अक्षरों से अधिक नहीं हो सकता।";

  @override
  String get descriptionCannotExceed100 =>
      "विवरण 100 अक्षरों से अधिक नहीं हो सकता।";

  @override
  String get chopdiCouldNotBeFound =>
      "चोपड़ी नहीं मिली।";

  @override
  String get success => "सफलता";

  @override
  String get chopdiUpdatedSuccessfully =>
      "चोपड़ी सफलतापूर्वक अपडेट हो गई।";

  @override
  String get unableToSaveChanges =>
      "बदलाव सेव नहीं हो सके। कृपया फिर से प्रयास करें।";

  @override
  String get deleteChopdi =>
      "चोपड़ी हटाएं";

  @override
  String get areYouSureDeleteChopdi =>
      "क्या आप वाकई इस चोपड़ी को हटाना चाहते हैं";

  @override
  String get thisActionCannotBeUndone =>
      "यह कार्रवाई पूर्ववत नहीं की जा सकती।";

  @override
  String get unableToDeleteChopdi =>
      "चोपड़ी हटाई नहीं जा सकी। कृपया फिर से प्रयास करें।";

  @override
  String get somethingWentWrong =>
      "कुछ गलत हो गया";

  @override
  String get editChopdi =>
      "चोपड़ी संपादित करें";

  @override
  String get updateYourChopdiDetails =>
      "अपनी चोपड़ी का विवरण अपडेट करें";

  @override
  String get chopdiName =>
      "चोपड़ी का नाम";

  @override
  String get descriptionOptional =>
      "विवरण (वैकल्पिक)";

  @override
  String get theseDetailsHelpManageChopdi =>
      "ये विवरण आपकी चोपड़ी को बेहतर तरीके से मैनेज करने में मदद करते हैं।";

  @override
  String get youCanChangeAnytime =>
      "आप इन्हें कभी भी बदल सकते हैं।";

  @override
  String get saveChanges =>
      "बदलाव सेव करें";
  @override
  String get createChopdi => 'चोपड़ी बनाएं';

  @override
  String get create => 'बनाएं';

  @override
  String get enterBusinessName =>
      'कृपया व्यवसाय का नाम दर्ज करें';

  @override
  String get enterShopBusinessName =>
      'दुकान/व्यवसाय का नाम दर्ज करें';



  @override
  String get youWillGive => 'आप देंगे';

  @override
  String get youWillGet => 'आपको मिलेगा';

  @override
  String get balance => 'शेष राशि';

  @override
  String get noTransactions => 'कोई लेन-देन नहीं';

  @override
  String get give => 'दें';

  @override
  String get get => 'लें';
  @override
  String get addNewLender =>
      'नया उधारदाता जोड़ें';

  @override
  String get lenderAlreadyExists =>
      'उधारदाता पहले से मौजूद है';

  @override
  String get duplicateLenderMessage =>
      'समान नाम और फोन नंबर वाला उधारदाता पहले से जोड़ा गया है।';

  @override
  String get failedToAddLender =>
      'उधारदाता जोड़ने में समस्या हुई। कृपया फिर से प्रयास करें।';

  @override
  String get lenderDetails =>
      'उधारदाता विवरण';

  @override
  String get lenderName =>
      'उधारदाता का नाम';

  @override
  String get enterLenderName =>
      'उधारदाता का नाम दर्ज करें';

  @override
  String get totalTaken => 'कुल लिया गया';

  @override
  String get interestDue => 'कुल देय ब्याज';
  @override
  String get failedToAddCustomerWithError =>
      'ग्राहक जोड़ने में समस्या हुई';
  @override
  String get editTransaction => 'लेन-देन संपादित करें';

  @override
  String get amount => 'राशि';

  @override
  String get date => 'तारीख';

  @override
  String get interestRatePercent =>
      'ब्याज दर (%)';

  @override
  String get interestType => 'ब्याज का प्रकार';

  @override
  String get selectInterestType =>
      'ब्याज का प्रकार चुनें';

  @override
  String get interestFrequency =>
      'ब्याज की अवधि';

  @override
  String get selectInterestFrequency =>
      'ब्याज की अवधि चुनें';

  @override
  String get description => 'विवरण';

  @override
  String get paymentModeOptional =>
      'भुगतान का माध्यम (वैकल्पिक)';

  @override
  String get selectPaymentMode =>
      'भुगतान का माध्यम चुनें';


  @override
  String get enterInterestRate =>
      'ब्याज दर दर्ज करें';

  @override
  String get interestRateRequired =>
      'ब्याज दर आवश्यक है';

  @override
  String get pleaseEnterValidAmount =>
      'कृपया मान्य राशि दर्ज करें';

  @override
  String get customer => 'ग्राहक';

  @override
  String get simpleInterest => 'साधारण ब्याज';

  @override
  String get compoundInterest => 'चक्रवृद्धि ब्याज';

  @override
  String get monthly => 'मासिक';

  @override
  String get yearly => 'वार्षिक';

  @override
  String get daily => 'दैनिक';

  @override
  String get cash => 'नकद';

  @override
  String get upi => 'UPI';

  @override
  String get bankTransfer => 'बैंक ट्रांसफर';

  @override
  String get contactSupportMessage =>
      "यदि आपके कोई प्रश्न हैं, तो बेझिझक हमसे संपर्क करें";

  @override
  String get validAmountRequired =>
      "कृपया मान्य राशि दर्ज करें";

  @override
  String get customerNoLongerAvailable =>
      "यह ग्राहक अब उपलब्ध नहीं है। कृपया ग्राहक को दोबारा खोलकर प्रयास करें।";

  @override
  String get deletedCustomerCannotAddEntry =>
      "यह ग्राहक हटा दिया गया है। आप नई एंट्री नहीं जोड़ सकते।";

  @override
  String get unableToSaveTransaction =>
      "लेन-देन सेव नहीं हो सका। कृपया पुनः प्रयास करें।";

  @override
  String get other => 'अन्य';
  @override
  String get notifications => 'सूचनाएं';
  @override
  String get markAllAsRead => 'सभी को पढ़ा हुआ चिह्नित करें';
  @override
  String get noNotifications => 'कोई सूचना नहीं';
  @override
  String get allCaughtUp => 'आप सभी सूचनाएं देख चुके हैं!';
  @override
  String get markAsUnread => 'अपठित चिह्नित करें';
  @override
  String get markAsRead => 'पढ़ा हुआ चिह्नित करें';
  @override
  String get deleteNotification => 'सूचना हटाएं';
  @override
  String get deleteNotificationTitle => 'सूचना हटाएं?';
  @override
  String get confirmDeleteNotification =>
      'क्या आप वाकई इस सूचना को हटाना चाहते हैं?';
  @override
  String get delete => 'हटाएं';

  @override
  String get notificationsEnabled => 'सूचनाएं चालू हैं';
  @override
  String get notificationsDisabled => 'सूचनाएं बंद हैं';

  @override
  String get notificationsEnabledDescription =>
      'आपको भुगतान रिमाइंडर, ब्याज अपडेट और अन्य महत्वपूर्ण अलर्ट की सूचनाएं मिलेंगी।';

  @override
  String get notificationsDisabledDescription =>
      'जब तक आप इन्हें दोबारा चालू नहीं करते, तब तक आपको Chopdi की सूचनाएं नहीं मिलेंगी।';

  @override
  String get justNow => 'अभी';
  @override
  String get minuteAgo => '1 मिनट पहले';
  @override
  String minutesAgo(int minutes) => '$minutes मिनट पहले';
  @override
  String get hourAgo => '1 घंटे पहले';
  @override
  String hoursAgo(int hours) => '$hours घंटे पहले';
  @override
  String get yesterday => 'कल';
  @override
  String daysAgo(int days) => '$days दिन पहले';
  @override
  String get pleaseEnterValidPhoneNumber =>
      'कृपया मान्य 10 अंकों का फोन नंबर दर्ज करें';

  @override
  String get failedToAddLenderWithError =>
      'उधारदाता जोड़ने में समस्या हुई';
  @override
  String get language => 'भाषा';

  @override
  String get currentLanguage => 'हिंदी';
  @override
  String get addEntry => 'एंट्री जोड़ें';

  @override
  String get recordPayment => 'भुगतान दर्ज करें';

  @override
  String get addMoneyGivenOrReceived =>
      'दिए या प्राप्त किए गए पैसे जोड़ें';

  @override
  String get addNote => 'नोट जोड़ें';

  @override
  String get addNoteOrReminder =>
      'नोट या रिमाइंडर जोड़ें';
  @override
  String get enterDetailsManually => 'विवरण मैन्युअल रूप से दर्ज करें';
  @override
  String get note => 'नोट';

  @override
  String get writeYourNoteHere =>
      'अपना नोट यहां लिखें...';

  @override
  String get markAsImportant =>
      'महत्वपूर्ण के रूप में चिह्नित करें';

  @override
  String get showNoteOnCustomerPage =>
      'यह नोट ग्राहक के पेज पर दिखाएं।';

  @override
  String get saveEntry => 'एंट्री सेव करें';
  @override
  String get currentChopdi => 'वर्तमान चोपड़ी';

  @override
  String get active => 'सक्रिय';

  @override
  String get addNewChopdi => 'नई चोपड़ी जोड़ें';

  @override
  String get createNewChopdiBook => 'नई चोपड़ी बनाएं';
  @override
  String get failedToCreateChopdi => 'चोपड़ी बनाने में समस्या हुई';


  @override
  String get loan => 'लोन';

  @override
  String get pending => 'बकाया';

  @override
  String get settled => 'निपटाया गया';


  @override
  String get status => 'स्थिति';

  @override
  String get allCustomers => 'सभी ग्राहक';

  @override
  String get showAllYourCustomers => 'अपने सभी ग्राहक दिखाएं';

  @override
  String get customersWithPendingDue => 'जिन ग्राहकों का भुगतान बकाया है';

  @override
  String get customersWithClearedDue => 'जिन ग्राहकों का भुगतान पूरा हो चुका है';

  @override
  String get loanDate => 'लोन की तारीख';

  @override
  String get thisMonth => 'इस महीने';

  @override
  String get customersAddedThisMonth => 'इस महीने जोड़े गए ग्राहक';

  @override
  String get reset => 'रीसेट';

  @override
  String get applyFilters => 'फ़िल्टर लागू करें';

  @override
  String get customDate => 'कस्टम तारीख';

  @override
  String get selectStartAndEndDate => 'शुरुआत और समाप्ति तारीख चुनें';

  @override
  String get from => 'से';

  @override
  String get to => 'तक';

  @override
  String get selectDate => 'तारीख चुनें';
  @override
  String get customerOptions => 'ग्राहक विकल्प';

  @override
  String get lenderOptions => 'उधारदाता विकल्प';

  @override
  String get editCustomer => 'ग्राहक संपादित करें';

  @override
  String get editNamePhoneOrLoanDetails =>
      'नाम, फोन की जानकारी संपादित करें';

  @override
  String get accountSummary => 'खाता सारांश';

  @override
  String get overviewAndSummary => 'अवलोकन और सारांश';

  @override
  String get exportPdf => 'PDF एक्सपोर्ट करें';

  @override
  String get downloadLedgerAsPdf => 'लेजर को PDF के रूप में डाउनलोड करें';

  @override
  String get deleteCustomer => 'ग्राहक हटाएं';

  @override
  String get deleteCustomerPermanently =>
      'इस ग्राहक को स्थायी रूप से हटाएं';

  @override
  String get phoneNumberRequired => 'फोन नंबर आवश्यक है';

  @override
  String get onlyNumbersAllowed => 'केवल नंबर दर्ज करें';

  @override
  String get unableToSaveChangesPleaseTryAgain =>
      'बदलाव सेव नहीं हो सके। कृपया फिर से प्रयास करें।';

  @override
  String get editCustomerDetails => 'ग्राहक विवरण संपादित करें';

  @override
  String get name => 'नाम';

  @override
  String get customerNameRequired => 'ग्राहक का नाम आवश्यक है';

  @override
  String get phoneNumber => 'फोन नंबर';

  @override
  String get overviewOfCustomerAccount =>
      'इस ग्राहक के खाते का अवलोकन';

  @override
  String get totalAmountGiven => 'कुल दी गई राशि';

  @override
  String get currentOutstanding => 'वर्तमान बकाया';

  @override
  String get lastPayment => 'अंतिम भुगतान';

  @override
  String get received => 'प्राप्त';

  @override
  String get loanGivenOn => 'लोन देने की तारीख';

  @override
  String get given => 'दिया';

  @override
  String get took => 'लिया';

  @override
  String get paid => 'भुगतान किया';
  @override
  String get allNotes => 'सभी नोट्स';

  @override
  String notesCount(int count) => '$count नोट्स';

  @override
  String get importantNote => 'महत्वपूर्ण नोट';

  @override
  String get editNote => 'नोट संपादित करें';

  // @override
  // String get markAsImportant => 'महत्वपूर्ण के रूप में चिह्नित करें';

  @override
  String get deleteNote => 'नोट हटाएं';
  @override
  String get frequentlyAskedQuestions =>
      'अक्सर पूछे जाने वाले प्रश्न';

  @override
  String get searchForHelp =>
      'मदद के लिए खोजें...';

  @override
  String get noQuestionsFound =>
      'कोई प्रश्न नहीं मिला।';

  @override
  String get noEmailAppAvailable =>
      'इस डिवाइस पर कोई ईमेल ऐप उपलब्ध नहीं है।';

  @override
  String get unableToOpenEmailApp =>
      'ईमेल ऐप खोलने में असमर्थ।';

  @override
  String get stillNeedHelp =>
      'अभी भी मदद चाहिए?';

  @override
  String get supportTeamIsHere =>
      'हमारी सपोर्ट टीम आपकी मदद के लिए यहां है।';

  @override
  String get contactSupport =>
      'सपोर्ट से संपर्क करें';

  @override
  String get faqWhatIsChopdiQuestion =>
      'Chopdi क्या है?';

  @override
  String get faqWhatIsChopdiAnswer =>
      'Chopdi एक डिजिटल लेजर है जो आपको ग्राहकों, लोन, भुगतान और ब्याज का रिकॉर्ड एक ही जगह रखने में मदद करता है। यह पारंपरिक कागजी लेजर की जगह एक आसान डिजिटल रिकॉर्ड प्रदान करता है।';

  @override
  String get faqHowAddCustomerQuestion =>
      'नया ग्राहक कैसे जोड़ें?';

  @override
  String get faqHowAddCustomerAnswer =>
      'होम स्क्रीन से ग्राहक जोड़ें पर टैप करें। आप अपने फोन के कॉन्टैक्ट्स से ग्राहक चुन सकते हैं या नया ग्राहक मैन्युअली जोड़ सकते हैं। ग्राहक जोड़ने के बाद आप लोन और भुगतान की एंट्री रिकॉर्ड कर सकते हैं।';

  @override
  String get faqEditCustomerDetailsQuestion =>
      'क्या मैं ग्राहक की जानकारी संपादित कर सकता हूं?';

  @override
  String get faqEditCustomerDetailsAnswer =>
      'हां। ग्राहक की प्रोफाइल खोलें, ऊपर दाईं ओर तीन डॉट वाले मेन्यू (⋮) पर टैप करें और ग्राहक का नाम या फोन नंबर बदलने के लिए ग्राहक संपादित करें चुनें।';

  @override
  String get faqRecordPaymentQuestion =>
      'भुगतान कैसे रिकॉर्ड करें?';

  @override
  String get faqRecordPaymentAnswer =>
      'ग्राहक की लेजर खोलें और लोन रिकॉर्ड करने के लिए आपने दिए ₹ या भुगतान रिकॉर्ड करने के लिए आपको मिले ₹ पर टैप करें। आवश्यक जानकारी दर्ज करके एंट्री सेव करें।';

  @override
  String get faqEditDeleteTransactionQuestion =>
      'क्या मैं लेन-देन को संपादित या हटा सकता हूं?';

  @override
  String get faqEditDeleteTransactionAnswer =>
      'हां। ग्राहक की लेजर में किसी भी लेन-देन पर टैप करके उसका विवरण खोलें। वहां से आप लेन-देन संपादित या हटा सकते हैं।';

  @override
  String get faqInterestCalculatedQuestion =>
      'ब्याज की गणना कैसे होती है?';

  @override
  String get faqInterestCalculatedAnswer =>
      'ब्याज की गणना ग्राहक का लोन बनाते या संपादित करते समय दर्ज की गई ब्याज दर के आधार पर होती है। प्रत्येक ग्राहक के लिए अलग ब्याज दर और गणना विधि (साधारण ब्याज / चक्रवृद्धि ब्याज) हो सकती है।';

  @override
  String get faqExportLedgerQuestion =>
      'क्या मैं अपनी लेजर एक्सपोर्ट कर सकता हूं?';

  @override
  String get faqExportLedgerAnswer =>
      'हां। किसी भी ग्राहक की लेजर खोलें, ऊपर दाईं ओर तीन डॉट पर टैप करें और PDF एक्सपोर्ट करें पर टैप करें। आप लेजर को शेयर, प्रिंट या PDF के रूप में सेव कर सकते हैं।';

  @override
  String get faqChangeChopdiDetailsQuestion =>
      'क्या मैं अपनी Chopdi की जानकारी बदल सकता हूं?';

  @override
  String get faqChangeChopdiDetailsAnswer =>
      'हां। अपनी Chopdi का नाम, विवरण या लेजर प्रकार बदलने के लिए My Chopdi > Edit (पेंसिल आइकन) पर जाएं।';

  @override
  String get faqChangePhoneQuestion =>
      'क्या फोन बदलने पर मेरा डेटा खो जाएगा?';

  @override
  String get faqChangePhoneAnswer =>
      'नहीं। आपका डेटा सुरक्षित है। जब तक आप अपने अकाउंट से साइन इन हैं, आप इसे अपने नए फोन पर दोबारा प्राप्त कर सकते हैं।';
  @override
  String get searchCustomer => 'ग्राहक खोजें';

  @override
  String get quickActions => 'त्वरित कार्य';

  @override
  String get createCustomerAndTrackTransactions =>
      'ग्राहक बनाएं और लेन-देन को ट्रैक करना शुरू करें।';
  @override
  String get secureSimple => 'सुरक्षित • सरल';

  @override
  String get yourLedgerAlwaysSafe => 'आपकी लेजर, हमेशा सुरक्षित';
  @override
  String get yourTrustIsImportant =>
      'आपका भरोसा हमारे लिए महत्वपूर्ण है।';

  @override
  String get pleaseReadTermsAndPrivacy =>
      'कृपया हमारी नियम एवं शर्तें और गोपनीयता नीति पढ़ें।';

  @override
  String get termsAgreementIntro =>
      'Chopdi का उपयोग करके, आप निम्नलिखित नियमों से सहमत होते हैं:';

  @override
  String get termsBulletLedger =>
      'Chopdi एक डिजिटल लेजर ऐप है जो आपको लोन, भुगतान, ब्याज और संबंधित नोट्स को रिकॉर्ड और मैनेज करने में मदद करता है।';

  @override
  String get termsBulletAccuracy =>
      'आपके द्वारा दर्ज की गई जानकारी की सटीकता की जिम्मेदारी आपकी है।';

  @override
  String get termsBulletAsIs =>
      'Chopdi बिना किसी वारंटी के “जैसा है” आधार पर प्रदान किया जाता है।';

  @override
  String get termsBulletLiability =>
      'किसी भी नुकसान या क्षति के लिए हम जिम्मेदार नहीं हैं।';

  @override
  String get termsBulletUpdates =>
      'हम समय-समय पर इन नियमों को अपडेट कर सकते हैं। ऐप का उपयोग जारी रखने का अर्थ है कि आप अपडेट किए गए नियमों को स्वीकार करते हैं।';

  @override
  String get privacyIntro =>
      'हम आपकी गोपनीयता की सुरक्षा के लिए प्रतिबद्ध हैं:';

  @override
  String get privacyBulletDataCollection =>
      'हम केवल वही डेटा एकत्र करते हैं जो हमारी सेवाएं प्रदान करने और उन्हें बेहतर बनाने के लिए आवश्यक है।';

  @override
  String get privacyBulletSecureData =>
      'आपका डेटा सुरक्षित रूप से स्टोर और एन्क्रिप्ट किया जाता है।';

  @override
  String get privacyBulletNoSelling =>
      'हम आपकी व्यक्तिगत जानकारी को कभी भी तीसरे पक्ष के साथ बेचते या साझा नहीं करते हैं।';

  @override
  String get privacyBulletDataControl =>
      'आप अपने डेटा पर नियंत्रण रखते हैं और इसे कभी भी एक्सपोर्ट या डिलीट कर सकते हैं।';

  @override
  String get questionsContactUs =>
      'यदि आपके कोई प्रश्न हैं, तो आप हमसे यहां संपर्क कर सकते हैं';

  @override
  String get lastUpdatedOn =>
      'अंतिम अपडेट';
  @override
  String get notificationSettings => 'नोटिफिकेशन सेटिंग्स';

  @override
  String get chooseNotificationAbout =>
      'चुनें कि आप किन चीज़ों के बारे में नोटिफिकेशन पाना चाहते हैं।';

  @override
  String get changeSettingsAnytime =>
      'आप इन सेटिंग्स को कभी भी बदल सकते हैं।';

  @override
  String get paymentDueReminders => 'भुगतान देय रिमाइंडर';

  @override
  String get paymentDueRemindersDescription =>
      'ग्राहक की भुगतान देय तारीख नज़दीक आने पर आपको नोटिफिकेशन मिलेगा।';

  @override
  String get remindMe => 'मुझे याद दिलाएं';

  @override
  String get onDueDate => 'देय तारीख पर';

  @override
  String get onDueDateDescription =>
      'भुगतान की देय तारीख वाले दिन मुझे नोटिफिकेशन दें।';

  @override
  String get oneDayBefore => '1 दिन पहले';

  @override
  String get oneDayBeforeDescription =>
      'भुगतान की देय तारीख से 1 दिन पहले मुझे नोटिफिकेशन दें।';

  @override
  String get threeDaysBefore => '3 दिन पहले';

  @override
  String get threeDaysBeforeDescription =>
      'भुगतान की देय तारीख से 3 दिन पहले मुझे नोटिफिकेशन दें।';

  @override
  String get howItWorks => 'यह कैसे काम करता है?';

  @override
  String get dailyUpcomingPayments =>
      'सभी आने वाले देय भुगतानों के लिए आपको दिन में एक बार नोटिफिकेशन मिलेगा।';

  @override
  String get dailyReminder => 'दैनिक रिमाइंडर';

  @override
  String get dailyReminderDescription =>
      'आज के लंबित कलेक्शन की समीक्षा करने के लिए रोज़ाना रिमाइंडर पाएं।';

  @override
  String get dataSafeWithUs => 'आपका डेटा हमारे पास सुरक्षित है।';

  @override
  String get neverShareInfo =>
      'हम आपकी जानकारी किसी के साथ साझा नहीं करते हैं।';

  @override
  String get notificationSettingsSavedSuccessfully =>
      'नोटिफिकेशन सेटिंग्स सफलतापूर्वक सेव हो गईं।';

  @override
  String get unableToSaveNotificationSettings =>
      'नोटिफिकेशन सेटिंग्स सेव नहीं हो सकीं।';

  @override
  String get error => 'त्रुटि';
  @override
  String get weekly => 'साप्ताहिक';

  @override
  String get enterAmount => 'राशि दर्ज करें';

  // @override
  // String get enterInterestRate => 'ब्याज दर दर्ज करें';

  @override
  String get enterDescriptionHere => 'यहां विवरण दर्ज करें...';
  @override
  String get transactionDetails => 'लेन-देन का विवरण';
  @override
  String get interestDetails => 'ब्याज का विवरण';

  @override
  String get loanGiven => 'लोन दिया';
  @override
  String get paymentReceived => 'भुगतान प्राप्त';
  @override
  String get loanTook => 'लोन लिया';
  @override
  String get itookloan => 'मैंने लोन लिया';
  @override
  String get amountPaid => 'भुगतान किया';
  @override
  String get manageAllLender => 'अपने सभी उधारदाताओं को प्रबंधित करें';

  @override
  String get paymentMethod => 'भुगतान का माध्यम';
  @override
  String get lender1 => 'उधारदाता';

  @override
  String get notSpecified => 'उल्लेख नहीं किया गया';

  @override
  String get loanGivenDescription => 'लोन दिया गया।';
  @override
  String get paymentReceivedDescription => 'भुगतान प्राप्त हुआ।';
  @override
  String get loanTakenDescription => 'लोन लिया गया।';
  @override
  String get amountPaidDescription => 'भुगतान किया गया।';

  @override
  String get deleteTransaction => 'लेन-देन हटाएं';
  @override
  String get deleteTransactionQuestion => 'लेन-देन हटाएं?';
  //
  // @override
  // String get youTook => 'आपने लिया';
  @override
  String get loanSummary => 'लोन सारांश';
  // String get loanGivenOn => 'लोन दिया गया';
  @override
  String get loanType => 'लोन का प्रकार';
  @override
  String get iGaveLoan => 'मैंने लोन दिया';
  @override
  String get loanDuration => 'लोन की अवधि';
  @override
  String get deleteChopdiDescription =>
      'यह "My Chopdi" को स्थायी रूप से हटा देगा';

  @override
  String get deleteChopdiDescriptionData =>
      'और इसका सारा डेटा भी हटा दिया जाएगा।';

  @override
  String get deleteChopdiWarningCustomers =>
      'सभी ग्राहक, लेन-देन और रिकॉर्ड हटा दिए जाएंगे।';

  @override
  String get deleteChopdiWarningLoans =>
      'सभी लोन, भुगतान और ब्याज का डेटा हटा दिया जाएगा।';

  @override
  String get deleteChopdiWarningNotes =>
      'नोट्स और सेटिंग्स हमेशा के लिए खो जाएंगी।';

  @override
  String get deleteChopdiConfirmation =>
      'मैं समझता हूं कि यह कार्रवाई पूर्ववत नहीं की जा सकती।';
  @override
  String get deleteConfirmation =>
      'मैं समझता हूं कि यह कार्रवाई पूर्ववत नहीं की जा सकती।';

  @override
  String get failedToDeleteTransaction =>
      'लेन-देन हटाने में समस्या हुई';
  @override
  String get saveNote => 'नोट सेव करें';
  @override
  String get editTransactionDetails =>
      'लेन-देन का विवरण संपादित करें';


  @override
  String get type => 'प्रकार';

  @override
  String get moneyReceived => 'पैसे प्राप्त हुए';

  @override
  String get moneyGiven => 'पैसे दिए';

  @override
  String get cheque => 'चेक';

  // String get lastPayment => 'अंतिम भुगतान';
  // String get received => 'प्राप्त';


  @override
  String get iTookLoan => 'मैंने लिया';

  @override
  String get moneyToReceive => 'प्राप्त होने वाला पैसा';

  @override
  String get moneyToPay => 'देने वाला पैसा';

  @override
  String customersCount(int count) => "ग्राहक ($count)";

  @override
  String lendersCount(int count) => "उधारदाता ($count)";

  @override
  String get bottomHome => "होम";

  @override
  String get bottomMyChopdi => "मेरी चोपड़ी";

  @override
  String get loggingOut => "लॉग आउट हो रहा है...";

  @override
  String get pleaseWait => "कृपया प्रतीक्षा करें";

  @override
  String get otpVerifyYourNumber => "अपना नंबर सत्यापित करें";

  @override
  String get otpSentTo => "हमने 6 अंकों का OTP इस नंबर पर भेजा है";

  @override
  String get otpResend => "OTP दोबारा भेजें";

  @override
  String get otpResendIn => "OTP दोबारा भेजें ";

  @override
  String get otpVerify => "OTP सत्यापित करें";

  @override
  String get otpChangeMobileNumber => "मोबाइल नंबर बदलें";

  @override
  String get otpRequired => "कृपया OTP दर्ज करें";

  @override
  String get otpInvalid => "कृपया मान्य 6 अंकों का OTP दर्ज करें";

  @override
  String get otpIncorrect => "गलत OTP। कृपया पुनः प्रयास करें।";

  @override
  String get otpExpired =>
      "इस कोड की समय सीमा समाप्त हो गई है। नया कोड अनुरोध करें।";

  @override
  String get otpTooManyAttempts =>
      "बहुत अधिक गलत प्रयास हुए हैं। नया कोड अनुरोध करें।";

  @override
  String get otpPleaseWait =>
      "कृपया पुनः प्रयास करने से पहले कुछ समय प्रतीक्षा करें।";

  @override
  String get otpNetworkUnavailable =>
      "सर्वर से कनेक्ट नहीं हो पा रहा है। अपना इंटरनेट कनेक्शन जांचें।";

  @override
  String get otpSomethingWentWrong =>
      "कुछ गलत हो गया। कृपया पुनः प्रयास करें।";

  @override
  String createProfessionalStatement(String customerName) =>
      '$customerName के लिए एक पेशेवर विवरण बनाएं';

  @override
  String pdfIncludesCustomerDetails(String customerName) =>
      "PDF में $customerName का विवरण, पूरी लेन-देन की हिस्ट्री और खाते का सारांश शामिल है।";

  @override
  String deleteCustomerConfirmation(String customerName) =>
      '$customerName को हटाएं?';

  @override
  String get allCustomerDataWillBePermanentlyDeletedIncluding =>
      'ग्राहक का सभी डेटा स्थायी रूप से हटा दिया जाएगा, जिसमें शामिल हैं:';

  @override
  String get ledgerAndTransactions =>
      'खाता और लेन-देन';

  @override
  String get notesAndReminders =>
      'नोट्स और रिमाइंडर';

  @override
  String get loanInformation =>
      'लोन की जानकारी';

  @override
  String get iUnderstandThisActionCannotBeUndone =>
      'मैं समझता/समझती हूँ कि इस कार्रवाई को पूर्ववत नहीं किया जा सकता।';


  @override
  String pageOf(int page, int totalPages) =>
      'पृष्ठ $page / $totalPages';

  @override
  String asOf(String date) =>
      '$date तक';

  @override
  String transactionCount(int count) =>
      '$count लेन-देन';

  @override
  String recordsCount(int count) =>
      '$count रिकॉर्ड';

  @override
  String get mode =>
      'भुगतान का तरीका';

  @override
  String get transactionTypeGiven =>
      'दिया';

  @override
  String get transactionTypeReceived =>
      'प्राप्त';

  @override
  String get transactionTypeTook =>
      'लिया';

  @override
  String get transactionTypePaid =>
      'भुगतान किया';

  @override
  String unableToGeneratePdf(String error) =>
      'PDF बनाने में असमर्थ: $error';

  @override
  String unableToExportPdf(String error) =>
      'PDF निर्यात करने में असमर्थ: $error';

  @override
  String get lender => 'उधारदाता';

  @override
  String get lenderStatement => 'उधारदाता विवरण';

  @override
  String get lenderLoanSummaryAndRepaymentHistory =>
      'लोन का सारांश और भुगतान इतिहास';

  @override
  String get editLender => 'उधारदाता संपादित करें';

  @override
  String get editLenderDetails => 'उधारदाता का विवरण संपादित करें';

  @override
  String get lenderNameRequired => 'उधारदाता का नाम आवश्यक है';

  @override
  String get lenderAccountSummary => 'उधारदाता का खाता सारांश';

  @override
  String get overviewOfLenderAccount =>
      'इस उधारदाता के खाते का अवलोकन';

  @override
  String get downloadLenderLedgerAsPdf =>
      'उधारदाता की खाता-बही PDF में डाउनलोड करें';

  @override
  String get deleteLender => 'उधारदाता हटाएं';

  @override
  String get deleteLenderPermanently =>
      'इस उधारदाता को स्थायी रूप से हटाएं';

  @override
  String deleteLenderConfirmation(String name) =>
      'क्या आप "$name" उधारदाता को हटाना चाहते हैं?';

  @override
  String get interestCalculatedNotificationTitle =>
      'ब्याज की गणना की गई';

  @override
  String get interestCalculatedNotificationSubtitle =>
      'आपके खाते के लिए ब्याज की गणना की गई है।';

  @override
  String get interestUpdatedNotificationTitle =>
      'ब्याज अपडेट किया गया';

  @override
  String get interestUpdatedNotificationSubtitle =>
      'ब्याज की राशि अपडेट की गई है।';

  @override
  String get appUpdateNotificationTitle =>
      'ऐप अपडेट';

  @override
  String get appUpdateNotificationSubtitle =>
      'Chopdi के लिए नया अपडेट उपलब्ध है।';

  @override
  String get paymentReminderNotificationTitle =>
      'भुगतान अनुस्मारक';

  @override
  String get paymentReminderNotificationSubtitle =>
      'आपके लिए भुगतान का एक अनुस्मारक है।';

  @override
  String get tookLoanNotificationTitle =>
      'लोन लिया गया';

  @override
  String get tookLoanNotificationSubtitle =>
      'आपने एक नया लिया गया लोन दर्ज किया है।';

  @override
  String get editYourName => 'अपना नाम संपादित करें';

  @override
  String get addYourNameTitle => 'अपना नाम जोड़ें';

  @override
  String get enterYourName => 'अपना नाम दर्ज करें';

  @override
  String get updateName => 'नाम अपडेट करें';

  @override
  String get saveName => 'नाम सहेजें';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get edit => 'संपादित करें';

  @override
  String get addYourName => 'अपना नाम जोड़ें';

  @override
  String get amountRequired => 'राशि आवश्यक है';

  @override
  String get amountCannotBeZero => 'राशि शून्य नहीं हो सकती';

  @override
  String get filterBy => 'से फ़िल्टर करें';
  
  @override
  String get filterAll => 'सभी';

  @override
  String get mostRecent => 'सबसे नया';

  @override
  String get highestAmount => 'अधिकतम राशि';

  @override
  String get byNameAZ => 'नाम से (अ-ज्ञ)';

  @override
  String get oldest => 'सबसे पुराना';

  @override
  String get leastAmount => 'न्यूनतम राशि';

  @override
  String get totalAmountTaken =>
      'कुल लिया गया लोन';

  @override
  String get loanTakenOn =>
      'लोन लेने की तारीख';

  @override
  String get paymentPaid =>
      'भुगतान किया';

  @override
  String get statement =>
      'खाता विवरण';

  @override
  String get generatedDate =>
      'बनाने की तारीख';

  @override
  String get trustedDigitalLedger =>
      'आपकी भरोसेमंद डिजिटल खाता-बही';

  @override
  String pdfIncludesLenderDetails(String name) =>
      'PDF में $name का विवरण, पूरी लेन-देन की हिस्ट्री और खाते का सारांश शामिल है।';

  @override
  String deleteLenderTitle(String name) =>
      '$name को हटाएं?';

  @override
  String get deleteActionCannotBeUndone =>
      'यह कार्रवाई वापस नहीं की जा सकती';

  @override
  String get allLenderDataDeleted =>
      'उधारदाता का सभी डेटा स्थायी रूप से हटा दिया जाएगा, जिसमें शामिल हैं:';

  @override
  String get understandDeleteAction =>
      'मैं समझता/समझती हूं कि यह कार्रवाई वापस नहीं की जा सकती।';

  @override
  String get phoneNumberNotAvailable => 'फ़ोन नंबर उपलब्ध नहीं है';

  @override
  String get phoneNumberNotAvailableForCustomer =>
      'इस ग्राहक का फ़ोन नंबर उपलब्ध नहीं है।';

  @override
  String get phoneNumberNotAvailableForLender =>
      'इस उधारदाता का फ़ोन नंबर उपलब्ध नहीं है।';

  @override
  String get phonePermissionRequired => 'फ़ोन अनुमति आवश्यक है';

  @override
  String get phonePermissionRequiredToMakeCall =>
      'कॉल करने के लिए फ़ोन की अनुमति आवश्यक है।';

  @override
  String get phonePermissionDeniedOpenSettings =>
      'फ़ोन की अनुमति अस्वीकार कर दी गई है। '
      'कॉल करने के लिए कृपया ऐप की सेटिंग्स में जाकर अनुमति सक्षम करें।';

  @override
  String get unableToOpenDialer => 'डायलर खोलने में असमर्थ';

  @override
  String get unableToOpenPhoneDialer =>
      'इस डिवाइस पर फ़ोन डायलर खोलने में असमर्थ।';

  @override
  String get openSettings => 'सेटिंग्स खोलें';
}