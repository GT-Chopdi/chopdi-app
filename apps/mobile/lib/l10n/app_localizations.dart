import 'package:flutter/widgets.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

abstract class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    ) ??
        AppLocalizationsEn();
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
  ];

  // ------------------------------------------------------------
  // LOGIN / ONBOARDING
  // ------------------------------------------------------------

  String get loginLetsGetStarted;

  String get loginEnterMobileNumber;

  String get loginYourLendingRecords;

  String get loginDigitallyOrganized;

  String get loginTrackLoans;

  String get loginSecureData;

  String get loginContinue;

  String get loginByContinuing;

  String get loginTermsOfService;

  String get loginAnd;

  String get loginPrivacyPolicy;

  // ------------------------------------------------------------
  // LOGIN VALIDATION / ERRORS
  // ------------------------------------------------------------

  String get loginMobileNumberRequired;

  String get loginInvalidMobileNumber;

  String get loginOtpAlreadySent;

  String get loginNetworkUnavailable;

  String get loginDevKeyMissing;

  String get loginDevKeyRejected;

  String get loginSomethingWentWrong;
  String get homeNoCustomersYet;

  String get homeStartAddingCustomer;
  String get homeAddCustomer;

  String get homeAddLoan;
  // ------------------------------------------------------------
// HOME HEADER
// ------------------------------------------------------------

  String get homeMyChopdi;

  String get homeTapToChangeChopdi;
  String get iGaveLoan;
  String get iTookLoan;
  String get moneyToReceive;
  String get moneyToPay;

// ------------------------------------------------------------
// HOME SUMMARY
// ------------------------------------------------------------

  String get homeTotalOutstandingAmount;

  String get homeTotalLoanGiven;

  String get homeTotalInterestEarned;

// ------------------------------------------------------------
// HOME LOAN TOGGLE
// ------------------------------------------------------------

  String get homeIGaveLoan;

  String get homeReceiveInterest;

  String get homeITookLoan;

  String get homePayInterest;
  // CUSTOMER LIST
  String get customersTitle;
  String get manageAllCustomers;
  String get manageAllLender;
  String get lender1;
  String get searchByNameAndPhone;
  String get filter;
  String customersCount(int count);
  String get sortBy;
  String get noCustomersFound;
  String get allNotes;
  String notesCount(int count);
  String get importantNote;
  String get editNote;
  String get markAsImportant;
  String get deleteNote;

// SORT OPTIONS - display text
  String get sortNameAZ;
  String get sortNameZA;
  String get sortRecentlyAdded;
  String get sortLoanAmountHighToLow;
  String get sortLoanAmountLowToHigh;

// ADD CUSTOMER
  String get addCustomer;
  String get allContacts;
  String get contactsPermissionRequired;
  String get allowContacts;
  String get noContactsFound;
  String get noPhoneNumber;
  String get unknownContact;
  String get unableToLoadContacts;

// CUSTOMER DETAILS
  String get youGave;
  String get youGot;
  String get totalGiven;
  String get totalInterest;
  String get outstanding;

// TOOK LOAN / ADD LENDER
  String get addLender;
  String get addNewCustomer;
  String get customerDetails;
  String get nameRequired;
  String get customerName;
  String get enterCustomerName;
  String get phoneNumberOptional;
  String get mobileNumber;
  String get enterValid10DigitPhone;

  String get cancel;

// DUPLICATE CUSTOMER
  String get customerAlreadyExists;
  String get duplicateCustomerMessage;
  String get ok;

// ERROR
  String get failedToAddCustomer;
  String get manageCurrentChopdi;
  String get preferences;
  String get notificationsSettings;
  String get manageAppNotifications;
  String get support;
  String get helpFaqs;
  String get getAnswersCommonQuestions;
  String get termsPrivacy;
  String get readOurPolicies;
  String get logout;
  String get signOutOfAccount;
  String get areYouSureLogout;
  String get unableToLogout;
  String get myChopdi;
  String get myPersonalLendingLedger;
  String get createdOn;
  String get totalCustomers;
  String get totalLoanGiven;
  String get totalInterestEarned;
  String get totalOutstanding;
  String get chopdi;
  String get unableToLoadChopdiDetails;
  String get pleaseEnterChopdiName;
  String get chopdiNameCannotExceed50;
  String get descriptionCannotExceed100;
  String get chopdiCouldNotBeFound;
  String get success;
  String get chopdiUpdatedSuccessfully;
  String get unableToSaveChanges;
  String get deleteChopdi;
  String get areYouSureDeleteChopdi;
  String get thisActionCannotBeUndone;
  String get unableToDeleteChopdi;
  String get somethingWentWrong;
  String get editChopdi;
  String get updateYourChopdiDetails;
  String get chopdiName;
  String get descriptionOptional;
  String get theseDetailsHelpManageChopdi;
  String get youCanChangeAnytime;
  String get saveChanges;
  String get createChopdi;
  String get create;
  String get enterBusinessName;
  String get enterShopBusinessName;

  String get youWillGive;
  String get youWillGet;
  String get balance;
  String get noTransactions;
  String get give;
  String get get;
  String get addNewLender;
  String get lenderAlreadyExists;
  String get duplicateLenderMessage;
  String get failedToAddLender;
  String get lenderDetails;
  String get lenderName;
  String get enterLenderName;
  String get pleaseEnterValidPhoneNumber;
  String get failedToAddLenderWithError;
  String get totalTaken;
  String get interestDue;
  String get failedToAddCustomerWithError;
  String get editTransaction;
  String get amount;
  String get date;
  String get interestRatePercent;
  String get interestType;
  String get selectInterestType;
  String get interestFrequency;
  String get selectInterestFrequency;
  String get description;
  String get paymentModeOptional;
  String get selectPaymentMode;
  String get settings;
  String get manageAppSettings;

  String get enterInterestRate;
  String get interestRateRequired;
  String get pleaseEnterValidAmount;
  String get customer;
  String get simpleInterest;
  String get compoundInterest;
  String get monthly;
  String get yearly;
  String get daily;
  String get cash;
  String get upi;
  String get bankTransfer;
  String get other;
  String get notifications;
  String get markAllAsRead;
  String get noNotifications;
  String get allCaughtUp;
  String get markAsUnread;
  String get markAsRead;
  String get deleteNotification;
  String get deleteNotificationTitle;
  String get confirmDeleteNotification;
  String get delete;
  String get notificationsEnabled;
  String get notificationsDisabled;
  String get notificationsEnabledDescription;
  String get notificationsDisabledDescription;
  String get justNow;
  String get minuteAgo;
  String minutesAgo(int minutes);
  String get hourAgo;
  String hoursAgo(int hours);
  String get yesterday;
  String daysAgo(int days);
  String get language;
  String get currentLanguage;
  String get addEntry;
  String get recordPayment;
  String get addMoneyGivenOrReceived;
  String get addNote;
  String get addNoteOrReminder;

  String get enterDetailsManually;
  String get note;
  String get writeYourNoteHere;
  // String get markAsImportant;
  String get showNoteOnCustomerPage;
  String get saveEntry;
  String get currentChopdi;
  String get active;
  String get addNewChopdi;
  String get createNewChopdiBook;
  String get failedToCreateChopdi;
  String get itookloan;

  String get loan;
  String get pending;
  String get settled;

  String get status;
  String get allCustomers;
  String get showAllYourCustomers;
  String get customersWithPendingDue;
  String get customersWithClearedDue;
  String get loanDate;
  String get thisMonth;
  String get customersAddedThisMonth;
  String get reset;
  String get applyFilters;
  String get customDate;
  String get selectStartAndEndDate;
  String get from;
  String get to;
  String get selectDate;
  String get customerOptions;
  String get editCustomer;
  String get editNamePhoneOrLoanDetails;
  String get accountSummary;
  String get overviewAndSummary;
  String get exportPdf;
  String get downloadLedgerAsPdf;
  String get deleteCustomer;
  String get deleteCustomerPermanently;

  String get phoneNumberRequired;
  String get onlyNumbersAllowed;
  String get unableToSaveChangesPleaseTryAgain;
  String get editCustomerDetails;
  String get name;
  String get customerNameRequired;
  String get phoneNumber;

  String get overviewOfCustomerAccount;
  String get totalAmountGiven;
  String get currentOutstanding;
  String get lastPayment;
  String get received;
  String get loanGivenOn;

  String get given;
  String get took;
  String get paid;

  String get yourTrustedDigitalLedger;
  String get accountStatement;
  String get generatedByChopdi;
  String get tookLoanStatement;
  String get customerStatement;
  String get loanSummaryAndRepaymentHistory;
  String get accountSummaryAndTransactionHistory;
  String get currentBalance;
  // String get outstanding;
  String get accountOverview;
  String get youTook;
  // String get youGave;
  String get totalLoanTaken;
  // String get totalGiven;
  String get youPaid;
  String get youReceived;
  String get totalRepaid;
  String get totalReceived;
  String get interest;
  String get calculatedInterest;
  String get transactionHistory;
  String get records;
  String get finalBalance;
  // String get totalTaken;
  String get totalPaid;
  String get outstandingBalance;
  String get thankYouForUsingChopdi;
  String get keepRecordsSimple;
  String get noTransactionsAvailable;
  String get pdfPreview;
  String get viewPdf;
  String get downloadPdf;
  String get frequentlyAskedQuestions;
  String get searchForHelp;
  String get noQuestionsFound;
  String get noEmailAppAvailable;
  String get unableToOpenEmailApp;
  String get stillNeedHelp;
  String get supportTeamIsHere;
  String get contactSupport;

  String get faqWhatIsChopdiQuestion;
  String get faqWhatIsChopdiAnswer;
  String get faqHowAddCustomerQuestion;
  String get faqHowAddCustomerAnswer;
  String get faqEditCustomerDetailsQuestion;
  String get faqEditCustomerDetailsAnswer;
  String get faqRecordPaymentQuestion;
  String get faqRecordPaymentAnswer;
  String get faqEditDeleteTransactionQuestion;
  String get faqEditDeleteTransactionAnswer;
  String get faqInterestCalculatedQuestion;
  String get faqInterestCalculatedAnswer;
  String get faqExportLedgerQuestion;
  String get faqExportLedgerAnswer;
  String get faqChangeChopdiDetailsQuestion;
  String get faqChangeChopdiDetailsAnswer;
  String get faqChangePhoneQuestion;
  String get faqChangePhoneAnswer;
  String get searchCustomer;
  String get quickActions;
  String get createCustomerAndTrackTransactions;
  String get secureSimple;
  String get yourLedgerAlwaysSafe;
  String get yourTrustIsImportant;
  String get pleaseReadTermsAndPrivacy;

  String get termsAgreementIntro;
  String get termsBulletLedger;
  String get termsBulletAccuracy;
  String get termsBulletAsIs;
  String get termsBulletLiability;
  String get termsBulletUpdates;

  String get privacyIntro;
  String get privacyBulletDataCollection;
  String get privacyBulletSecureData;
  String get privacyBulletNoSelling;
  String get privacyBulletDataControl;

  String get questionsContactUs;
  String get lastUpdatedOn;
  String get notificationSettings;
  String get chooseNotificationAbout;
  String get changeSettingsAnytime;
  String get paymentDueReminders;
  String get paymentDueRemindersDescription;
  String get remindMe;
  String get onDueDate;
  String get onDueDateDescription;
  String get oneDayBefore;
  String get oneDayBeforeDescription;
  String get threeDaysBefore;
  String get threeDaysBeforeDescription;
  String get howItWorks;
  String get dailyUpcomingPayments;
  String get dailyReminder;
  String get dailyReminderDescription;
  String get dataSafeWithUs;
  String get neverShareInfo;
  String get notificationSettingsSavedSuccessfully;
  String get unableToSaveNotificationSettings;
  String get error;
  String get weekly;
  String get enterAmount;
  // String get enterInterestRate;
  String get enterDescriptionHere;
  // String get youTook;
  String get loanSummary;
  // String get loanGivenOn;
  String get loanType;
  // String get iGaveLoan;
  String get loanDuration;
  // String get lastPayment;
  // String get received;
  String get loanTook;
  String get amountPaid;
  String get loanGiven;
  String get paymentReceived;
  String get transactionDetails;
  String get interestDetails;

  String get paymentMethod;
  String get notSpecified;

  String get loanGivenDescription;
  String get paymentReceivedDescription;
  String get loanTakenDescription;
  String get amountPaidDescription;

  String get deleteTransaction;
  String get deleteTransactionQuestion;
  String get deleteChopdiDescription;
  String get deleteChopdiDescriptionData;
  String get deleteChopdiWarningCustomers;
  String get deleteChopdiWarningLoans;
  String get deleteChopdiWarningNotes;
  String get deleteChopdiConfirmation;
  String get deleteConfirmation;
  String get failedToDeleteTransaction;
  // String get editNote;
  String get saveNote;
  String get editTransactionDetails;
  // String get recordPayment;
  // String get addMoneyGivenOrReceived;
  String get type;
  String get moneyReceived;
  String get moneyGiven;
  String get cheque;


  Null get at => null;

  // String get interestRate => null;

  // String get interestRate => null;



}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'hi':
        return AppLocalizationsHi();

      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) {
    return false;
  }
}