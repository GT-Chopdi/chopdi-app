import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn() : super(const Locale('en'));

  // ------------------------------------------------------------
  // LOGIN / ONBOARDING
  // ------------------------------------------------------------

  @override
  String get loginLetsGetStarted => "Let's get started";

  @override
  String get loginEnterMobileNumber =>
      "Enter your mobile number to\ncontinue to Chopdi";

  @override
  String get loginYourLendingRecords => "Your lending records,\n";

  @override
  String get loginDigitallyOrganized => "digitally organized.";

  @override
  String get loginTrackLoans =>
      "Track loans, interest and payments\nwith clarity and confidence.";

  @override
  String get loginSecureData => "Your data is secure with us";

  @override
  String get loginContinue => "Continue";

  @override
  String get loginByContinuing =>
      "By continuing, you agree to our\n";

  @override
  String get loginTermsOfService => "Terms of Service";

  @override
  String get loginAnd => " and ";

  @override
  String get loginPrivacyPolicy => "Privacy Policy";

  // ------------------------------------------------------------
  // LOGIN VALIDATION / ERRORS
  // ------------------------------------------------------------

  @override
  String get loginMobileNumberRequired =>
      "Please enter your mobile number";

  @override
  String get loginInvalidMobileNumber =>
      "Please enter a valid 10-digit mobile number";

  @override
  String get loginOtpAlreadySent =>
      "A code was already sent. Please wait a moment.";

  @override
  String get loginNetworkUnavailable =>
      "Can't reach the server. Check your connection.";

  @override
  String get loginDevKeyMissing =>
      "This build has no DEV_KEY compiled in.\n\n"
          "Paste AUTH_DEV_KEY into env/staging.env, then rebuild with\n"
          "--dart-define-from-file=env/staging.env";

  @override
  String get loginDevKeyRejected =>
      "The DEV_KEY in this build was rejected. "
          "Check it matches AUTH_DEV_KEY on the server.";

  @override
  String get loginSomethingWentWrong =>
      "Something went wrong. Please try again.";

  // ------------------------------------------------------------
// HOME
// ------------------------------------------------------------

  @override
  String get homeAddCustomer => "Add Customer";

  @override
  String get homeAddLoan => "Add Loan";

  @override
  String get homeNoCustomersYet => "No customers yet!";

  @override
  String get homeStartAddingCustomer =>
      "Start by adding a customer and\n"
          "keep track of your loans easily";
  // ------------------------------------------------------------
// HOME HEADER
// ------------------------------------------------------------

  @override
  String get homeMyChopdi => "My Chopdi";

  @override
  String get homeTapToChangeChopdi => "Tap to change chopdi";

// ------------------------------------------------------------
// HOME SUMMARY
// ------------------------------------------------------------

  @override
  String get homeTotalOutstandingAmount =>
      "Total Outstanding Amount";

  @override
  String get homeTotalLoanGiven => "Total Loan Given";

  @override
  String get homeTotalInterestEarned =>
      "Total Interest Earned";

// ------------------------------------------------------------
// HOME LOAN TOGGLE
// ------------------------------------------------------------

  @override
  String get homeIGaveLoan => "I Gave Loan";

  @override
  String get homeReceiveInterest => "(Receive Interest)";

  @override
  String get homeITookLoan => "I Took Loan";

  @override
  String get homePayInterest => "(Pay Interest)";
  @override
  String get customersTitle => "Customers";

  @override
  String get manageAllCustomers => "Manage all your customers";

  @override
  String get searchByNameAndPhone =>
      "Search by name and phone number";

  @override
  String get filter => "Filter";

  // @override
  // String get customersCount => "Customers";

  @override
  String get sortBy => "Sort by";

  @override
  String get noCustomersFound => "No customers found";

  @override
  String get sortNameAZ => "Name (A-Z)";

  @override
  String get sortNameZA => "Name (Z-A)";

  @override
  String get sortRecentlyAdded => "Recently Added";

  @override
  String get sortLoanAmountHighToLow =>
      "Loan Amount (High to Low)";

  @override
  String get sortLoanAmountLowToHigh =>
      "Loan Amount (Low to High)";

  @override
  String get addCustomer => "Add Customer";

  @override
  String get allContacts => "All Contacts";

  @override
  String get contactsPermissionRequired =>
      "Contacts permission is required";

  @override
  String get allowContacts => "Allow Contacts";

  @override
  String get noContactsFound => "No contacts found";

  @override
  String get noPhoneNumber => "No phone number";

  @override
  String get unknownContact => "Unknown";

  @override
  String get unableToLoadContacts =>
      "Unable to load contacts";

  @override
  String get youGave => "You Gave ₹";

  @override
  String get youGot => "You Got ₹";

  @override
  String get totalGiven => "Total Given";

  @override
  String get totalInterest => "Total Interest";

  @override
  String get outstanding => "Outstanding";

  @override
  String get addLender => "Add Lender";
  @override
  String get addNewCustomer => "Add New Customer";

  @override
  String get customerDetails => "Customer Details";

  @override
  String get nameRequired => "Name*";

  @override
  String get customerName => "Customer Name";

  @override
  String get enterCustomerName => "Enter customer name";

  @override
  String get phoneNumberOptional => "Phone Number (Optional)";

  @override
  String get mobileNumber => "Mobile Number";

  @override
  String get enterValid10DigitPhone =>
      "Enter a valid 10-digit phone number";



  @override
  String get cancel => "Cancel";

  @override
  String get customerAlreadyExists =>
      "Customer Already Exists";

  @override
  String get duplicateCustomerMessage =>
      "A customer with the same name and phone number is already added.";

  @override
  String get ok => "OK";

  @override
  String get failedToAddCustomer =>
      "Failed to add customer. Please try again.";
  @override
  String get manageCurrentChopdi => "Manage your current chopdi";

  @override
  String get preferences => "Preferences";

  @override
  String get notificationsSettings => "Notifications Settings";

  @override
  String get manageAppNotifications => "Manage app notifications";

  @override
  String get support => "Support";

  @override
  String get helpFaqs => "Help & FAQs";

  @override
  String get getAnswersCommonQuestions =>
      "Get answers to common questions";

  @override
  String get termsPrivacy => "Terms & Privacy";

  @override
  String get readOurPolicies => "Read our policies";

  @override
  String get logout => "Logout";

  @override
  String get signOutOfAccount => "Sign out of your account";

  @override
  String get areYouSureLogout =>
      "Are you sure you want to logout?";

  @override
  String get unableToLogout =>
      "Unable to logout. Please try again.";

  @override
  String get myChopdi => "My Chopdi";

  @override
  String get myPersonalLendingLedger =>
      "My personal lending ledger\nto track loans and interest.";

  @override
  String get createdOn => "Created On";

  @override
  String get totalCustomers => "Total Customers";

  @override
  String get totalLoanGiven => "Total Loan Given";

  @override
  String get totalInterestEarned => "Total Interest Earned";

  @override
  String get totalOutstanding => "Total Outstanding";

  @override
  String get chopdi => "Chopdi";
  @override
  String get unableToLoadChopdiDetails =>
      "Unable to load Chopdi details.";

  @override
  String get pleaseEnterChopdiName =>
      "Please enter a Chopdi name.";

  @override
  String get chopdiNameCannotExceed50 =>
      "Chopdi name cannot exceed 50 characters.";

  @override
  String get descriptionCannotExceed100 =>
      "Description cannot exceed 100 characters.";

  @override
  String get chopdiCouldNotBeFound =>
      "Chopdi could not be found.";

  @override
  String get success => "Success";

  @override
  String get chopdiUpdatedSuccessfully =>
      "Chopdi updated successfully.";

  @override
  String get unableToSaveChanges =>
      "Unable to save changes. Please try again.";

  @override
  String get deleteChopdi => "Delete Chopdi";

  @override
  String get areYouSureDeleteChopdi =>
      "Are you sure you want to delete";

  @override
  String get thisActionCannotBeUndone =>
      "This action cannot be undone.";

  @override
  String get unableToDeleteChopdi =>
      "Unable to delete Chopdi. Please try again.";

  @override
  String get somethingWentWrong =>
      "Something went wrong";

  @override
  String get editChopdi => "Edit Chopdi";

  @override
  String get updateYourChopdiDetails =>
      "Update your chopdi details";

  @override
  String get chopdiName => "Chopdi Name";

  @override
  String get descriptionOptional =>
      "Description (Optional)";

  @override
  String get theseDetailsHelpManageChopdi =>
      "These details help you manage your chopdi better.";

  @override
  String get youCanChangeAnytime =>
      "You can change them anytime.";

  @override
  String get saveChanges => "Save Changes";
  @override
  String get createChopdi => 'Create Chopdi';

  @override
  String get create => 'CREATE';

  @override
  String get enterBusinessName => 'Please enter business name';

  @override
  String get enterShopBusinessName =>
      'Enter shop/business name';


  @override
  String get youWillGive => 'You Will Give';

  @override
  String get youWillGet => 'You Will Get';

  @override
  String get balance => 'Balance';

  @override
  String get noTransactions => 'No Transactions';

  @override
  String get give => 'GIVE';

  @override
  String get get => 'GET';
  @override
  String get addNewLender => 'Add New Lender';

  @override
  String get lenderAlreadyExists =>
      'Lender Already Exists';

  @override
  String get duplicateLenderMessage =>
      'A lender with the same name and phone number is already added.';

  @override
  String get failedToAddLender =>
      'Failed to add lender. Please try again.';

  @override
  String get lenderDetails =>
      'Lender Details';

  @override
  String get lenderName =>
      'Lender Name';

  @override
  String get enterLenderName =>
      'Enter lender name';

  @override
  String get pleaseEnterValidPhoneNumber =>
      'Please enter a valid 10-digit phone number';



  @override
  String get failedToAddLenderWithError =>
      'Failed to add lender';
  @override
  String get totalTaken => 'Total Taken';

  @override
  String get interestDue => 'Interest Due';
  @override
  String get failedToAddCustomerWithError =>
      'Failed to add customer';
  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get amount => 'Amount';

  @override
  String get date => 'Date';

  @override
  String get interestRatePercent => 'Interest Rate (%)';

  @override
  String get interestType => 'Interest Type';

  @override
  String get selectInterestType => 'Select Interest Type';

  @override
  String get interestFrequency => 'Interest Frequency';

  @override
  String get selectInterestFrequency =>
      'Select Interest Frequency';

  @override
  String get description => 'Description';

  @override
  String get paymentModeOptional =>
      'Payment Mode (Optional)';

  @override
  String get selectPaymentMode =>
      'Select Payment Mode';



  @override
  String get enterInterestRate =>
      'Enter Interest Rate';

  @override
  String get interestRateRequired =>
      'Interest rate is required';

  @override
  String get pleaseEnterValidAmount =>
      'Please enter a valid amount';

  @override
  String get customer => 'Customer';

  @override
  String get simpleInterest => 'Simple Interest';

  @override
  String get compoundInterest => 'Compound Interest';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get daily => 'Daily';

  @override
  String get cash => 'Cash';

  @override
  String get upi => 'UPI';

  @override
  String get bankTransfer => 'Bank Transfer';

  @override
  String get other => 'Other';
  String get notifications => 'Notifications';
  String get markAllAsRead => 'Mark all as read';
  String get noNotifications => 'No Notifications';
  String get allCaughtUp => 'You\'re all caught up!';
  String get markAsUnread => 'Mark as unread';
  String get markAsRead => 'Mark as read';
  String get deleteNotification => 'Delete notification';
  String get deleteNotificationTitle => 'Delete Notification?';
  String get confirmDeleteNotification =>
      'Are you sure you want to delete this notification?';
  String get delete => 'Delete';

  String get notificationsEnabled => 'Notifications Enabled';
  String get notificationsDisabled => 'Notifications Disabled';

  String get notificationsEnabledDescription =>
      'You will receive notifications for payment reminders, interest updates and other important alerts.';

  String get notificationsDisabledDescription =>
      'You will no longer receive notifications from Chopdi until you enable them again.';

  String get justNow => 'Just now';
  String get minuteAgo => '1 min ago';
  String minutesAgo(int minutes) => '$minutes mins ago';
  String get hourAgo => '1 hour ago';
  String hoursAgo(int hours) => '$hours hours ago';
  String get yesterday => 'Yesterday';
  String daysAgo(int days) => '$days days ago';
  @override
  String get language => 'Language';

  @override
  String get currentLanguage => 'English';
  @override
  String get addEntry => 'Add Entry';

  @override
  String get recordPayment => 'Record Payment';

  @override
  String get addMoneyGivenOrReceived =>
      'Add money given or received';

  @override
  String get addNote => 'Add Note';

  @override
  String get addNoteOrReminder =>
      'Add a note or reminder';


  @override
  String get enterDetailsManually => 'Enter details manually';
  @override
  String get note => 'Note';

  @override
  String get writeYourNoteHere => 'Write your note here...';

  @override
  String get markAsImportant => 'Mark as Important';

  @override
  String get showNoteOnCustomerPage =>
      'Show this note on the customer page.';

  @override
  String get saveEntry => 'Save Entry';
  @override
  String get currentChopdi => 'Current Chopdi';

  @override
  String get active => 'Active';

  @override
  String get addNewChopdi => 'Add New Chopdi';

  @override
  String get createNewChopdiBook => 'Create a new chopdi book';
  @override
  String get failedToCreateChopdi => 'Failed to create Chopdi';


  @override
  String get loan => 'Loan';

  @override
  String get pending => 'Pending';

  @override
  String get settled => 'Settled';


  @override
  String get status => 'Status';

  @override
  String get allCustomers => 'All Customers';

  @override
  String get showAllYourCustomers => 'Show All your customers';

  @override
  String get customersWithPendingDue => 'Customers with pending due';

  @override
  String get customersWithClearedDue => 'Customers with cleared due';

  @override
  String get loanDate => 'Loan Date';

  @override
  String get thisMonth => 'This Month';

  @override
  String get customersAddedThisMonth => 'Customers added this month';

  @override
  String get reset => 'Reset';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get customDate => 'Custom Date';

  @override
  String get selectStartAndEndDate => 'Select a start and end date';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get selectDate => 'Select Date';
  @override
  String get customerOptions => 'Customer Options';

  @override
  String get editCustomer => 'Edit Customer';

  @override
  String get editNamePhoneOrLoanDetails =>
      'Edit name, phone or loan details';

  @override
  String get accountSummary => 'Account Summary';

  @override
  String get overviewAndSummary => 'Overview and summary';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get downloadLedgerAsPdf => 'Download ledger as PDF';

  @override
  String get deleteCustomer => 'Delete Customer';

  @override
  String get deleteCustomerPermanently =>
      'Delete this customer permanently';

  @override
  String get phoneNumberRequired => 'Phone number is required';

  @override
  String get onlyNumbersAllowed => 'Only numbers are allowed';

  @override
  String get unableToSaveChangesPleaseTryAgain =>
      'Unable to save changes. Please try again.';

  @override
  String get editCustomerDetails => 'Edit Customer Details';

  @override
  String get name => 'Name';

  @override
  String get customerNameRequired => 'Customer name is required';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get overviewOfCustomerAccount =>
      "Overview of this customer's account";

  @override
  String get totalAmountGiven => 'Total Amount Given';

  @override
  String get currentOutstanding => 'Current Outstanding';

  @override
  String get lastPayment => 'Last Payment';

  @override
  String get received => 'Received';

  @override
  String get loanGivenOn => 'Loan Given On';

  @override
  String get given => 'Given';

  @override
  String get took => 'Took';

  @override
  String get paid => 'Paid';
  @override
  String get yourTrustedDigitalLedger => "Your trusted digital ledger";

  @override
  String get accountStatement => "ACCOUNT STATEMENT";

  @override
  String get generatedByChopdi => "Generated by Chopdi";

  @override
  String get tookLoanStatement => "Took Loan Statement";

  @override
  String get customerStatement => "Customer Statement";

  @override
  String get loanSummaryAndRepaymentHistory =>
      "Loan summary and repayment history";

  @override
  String get accountSummaryAndTransactionHistory =>
      "Account summary and transaction history";

  @override
  String get currentBalance => "CURRENT BALANCE";

  @override
  String get accountOverview => "Account Overview";

  @override
  String get youTook => "YOU TOOK";

  @override
  String get totalLoanTaken => "Total loan taken";

  @override
  String get youPaid => "YOU PAID";

  @override
  String get youReceived => "YOU RECEIVED";

  @override
  String get totalRepaid => "Total repaid";

  @override
  String get totalReceived => "Total received";

  @override
  String get interest => "INTEREST";

  @override
  String get calculatedInterest => "Calculated interest";

  @override
  String get transactionHistory => "Transaction History";

  @override
  String get records => "records";

  @override
  String get finalBalance => "FINAL BALANCE";

  @override
  String get totalPaid => "Total Paid";

  @override
  String get outstandingBalance => "Outstanding Balance";

  @override
  String get thankYouForUsingChopdi => "Thank you for using Chopdi";

  @override
  String get keepRecordsSimple =>
      "Keep your records simple. Keep them with Chopdi.";

  @override
  String get noTransactionsAvailable =>
      "No transactions available";

  @override
  String get pdfPreview => "PDF Preview";

  @override
  String get viewPdf => "View PDF";

  @override
  String get downloadPdf => "Download PDF";

  @override
  String customersCount(int count) {
    // TODO: implement customersCount
    throw UnimplementedError();
  }
  @override
  String get allNotes => 'All Notes';

  @override
  String notesCount(int count) => '$count Notes';

  @override
  String get importantNote => 'Important Note';

  @override
  String get editNote => 'Edit Note';

  // @override
  // String get markAsImportant => 'Mark as important';

  @override
  String get deleteNote => 'Delete Note';
  @override
  String get frequentlyAskedQuestions => 'Frequently asked questions';

  @override
  String get searchForHelp => 'Search for help...';

  @override
  String get noQuestionsFound => 'No questions found.';

  @override
  String get noEmailAppAvailable =>
      'No email app is available on this device.';

  @override
  String get unableToOpenEmailApp =>
      'Unable to open email app.';

  @override
  String get stillNeedHelp => 'Still need help?';

  @override
  String get supportTeamIsHere =>
      'Our Support team is here.';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get faqWhatIsChopdiQuestion =>
      'What is Chopdi?';

  @override
  String get faqWhatIsChopdiAnswer =>
      'Chopdi is a digital ledger that helps you keep track of customers, loans, payments and interest in one place. It replaces traditional paper ledgers with an easy-to-manage digital record.';

  @override
  String get faqHowAddCustomerQuestion =>
      'How do I add a new customer?';

  @override
  String get faqHowAddCustomerAnswer =>
      'Tap Add Customer from the Home screen. You can either select a customer from your phone contacts or add a new customer manually. After adding the customer, you can start recording loan and payment entries.';

  @override
  String get faqEditCustomerDetailsQuestion =>
      'Can I edit customer details?';

  @override
  String get faqEditCustomerDetailsAnswer =>
      "Yes. Open the customer's profile, tap the three-dot menu (⋮) in the top-right corner and select Edit Customer to update the customer's name or phone number.";

  @override
  String get faqRecordPaymentQuestion =>
      'How do I record a payment?';

  @override
  String get faqRecordPaymentAnswer =>
      "Open the customer's ledger and tap You Gave ₹ to record a loan or You Got ₹ to record a payment. Enter the required details and save the entry.";

  @override
  String get faqEditDeleteTransactionQuestion =>
      'Can I edit or delete a transaction?';

  @override
  String get faqEditDeleteTransactionAnswer =>
      "Yes. Tap any transaction in the customer's ledger to open its details. From there, you can Edit Transaction or Delete Transaction.";

  @override
  String get faqInterestCalculatedQuestion =>
      'How is interest calculated?';

  @override
  String get faqInterestCalculatedAnswer =>
      "Interest is calculated using the interest rate you enter while creating or editing a customer's loan. Each customer can have a different interest rate and calculation method (Simple Interest / Compound Interest).";

  @override
  String get faqExportLedgerQuestion =>
      'Can I export my ledger?';

  @override
  String get faqExportLedgerAnswer =>
      "Yes. Open any customer's ledger, tap the three dots on the top-right corner, and and tap Export PDF. You can share, print or save the ledger as a PDF file.";

  @override
  String get faqChangeChopdiDetailsQuestion =>
      'Can I change my Chopdi details?';

  @override
  String get faqChangeChopdiDetailsAnswer =>
      'Yes. Go to My Chopdi > Edit (pencil icon) to update your Chopdi name, description or ledger type.';

  @override
  String get faqChangePhoneQuestion =>
      'Will my data be lost if I change my phone?';

  @override
  String get faqChangePhoneAnswer =>
      'No. Your data is safe. As long as you are signed in with your account, you can restore it on your new phone.';
  @override
  String get searchCustomer => 'Search customer';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get createCustomerAndTrackTransactions =>
      'Create a customer and start tracking transactions.';
  @override
  String get secureSimple => 'SECURE • SIMPLE';

  @override
  String get yourLedgerAlwaysSafe => 'YOUR LEDGER, ALWAYS SAFE';
  @override
  String get yourTrustIsImportant =>
      'Your trust is important to us.';

  @override
  String get pleaseReadTermsAndPrivacy =>
      'Please read our Terms & Conditions and Privacy Policy.';

  @override
  String get termsAgreementIntro =>
      'By using Chopdi, you agree to the following terms:';

  @override
  String get termsBulletLedger =>
      'Chopdi is a digital ledger app to help you record and manage loans, payments, interest and related notes.';

  @override
  String get termsBulletAccuracy =>
      'You are responsible for the accuracy of the information you enter.';

  @override
  String get termsBulletAsIs =>
      'Chopdi is provided “as is” without any warranties.';

  @override
  String get termsBulletLiability =>
      'We are not liable for any loss or damage.';

  @override
  String get termsBulletUpdates =>
      'We may update these terms from time to time. Continued use means you accept the updated terms.';

  @override
  String get privacyIntro =>
      'We are committed to protecting your privacy:';

  @override
  String get privacyBulletDataCollection =>
      'We collect only the data needed to provide and improve our services.';

  @override
  String get privacyBulletSecureData =>
      'Your data is securely stored and encrypted.';

  @override
  String get privacyBulletNoSelling =>
      'We never sell or share your personal information with third parties.';

  @override
  String get privacyBulletDataControl =>
      'You are in control of your data and can export or delete it anytime.';

  @override
  String get questionsContactUs =>
      'If you have any questions, feel free to contact us at';

  @override
  String get lastUpdatedOn =>
      'Last Updated on';
  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get chooseNotificationAbout =>
      'Choose what you want to be notified about.';

  @override
  String get changeSettingsAnytime =>
      'You can change these settings anytime.';

  @override
  String get paymentDueReminders => 'Payment Due Reminders';

  @override
  String get paymentDueRemindersDescription =>
      'Get notified when a customer’s payment due date is approaching.';

  @override
  String get remindMe => 'Remind Me';

  @override
  String get onDueDate => 'On the due date';

  @override
  String get onDueDateDescription =>
      'Notify me on the same day the payment is due.';

  @override
  String get oneDayBefore => '1 day before';

  @override
  String get oneDayBeforeDescription =>
      'Notify me 1 day before the due date.';

  @override
  String get threeDaysBefore => '3 days before';

  @override
  String get threeDaysBeforeDescription =>
      'Notify me 3 days before the due date.';

  @override
  String get howItWorks => 'How it works?';

  @override
  String get dailyUpcomingPayments =>
      'You will receive a notification once a day for all upcoming due payments.';

  @override
  String get dailyReminder => 'Daily Reminder';

  @override
  String get dailyReminderDescription =>
      'Get a daily reminder to review today’s pending collections.';

  @override
  String get dataSafeWithUs => 'Your data is safe with us.';

  @override
  String get neverShareInfo =>
      'We never share your information with anyone.';

  @override
  String get notificationSettingsSavedSuccessfully =>
      'Notification settings saved successfully.';

  @override
  String get unableToSaveNotificationSettings =>
      'Unable to save notification settings.';

  @override
  String get error => 'Error';
  @override
  String get weekly => 'Weekly';

  @override
  String get enterAmount => 'Enter Amount';

  // @override
  // String get enterInterestRate => 'Enter Interest rate';

  @override
  String get enterDescriptionHere => 'Enter Description here...';
  String get loanSummary => 'Loan Summary';
  // String get loanGivenOn => 'Loan Given On';
  String get loanType => 'Loan Type';
  String get iGaveLoan => 'I Gave Loan';
  String get loanDuration => 'Loan Duration';
  String get loanTook => 'Loan Took';
  String get amountPaid => 'Amount Paid';
  String get loanGiven => 'Loan Given';
  String get paymentReceived => 'Payment received';
  String get transactionDetails => 'Transaction Details';
  String get interestDetails => 'Interest Details';



  String get paymentMethod => 'Payment Method';
  String get notSpecified => 'Not specified';

  String get loanGivenDescription => 'Loan given.';
  String get paymentReceivedDescription => 'Payment received.';
  String get loanTakenDescription => 'Loan taken.';
  String get amountPaidDescription => 'Amount paid.';

  String get deleteTransaction => 'Delete Transaction';
  String get deleteTransactionQuestion => 'Delete Transaction?';
  String get deleteChopdiDescription =>
      'This will permanently delete "My Chopdi"';

  String get deleteChopdiDescriptionData =>
      'and all its data.';

  String get deleteChopdiWarningCustomers =>
      'All customers, transactions and records will be deleted.';

  String get deleteChopdiWarningLoans =>
      'All loans, payments and interest data will be removed.';

  String get deleteChopdiWarningNotes =>
      'Notes and settings will be lost forever.';

  String get deleteChopdiConfirmation =>
      'I understand this action cannot be undone.';
  String get deleteConfirmation =>
      'I understand this action cannot be undone.';

  String get failedToDeleteTransaction =>
      'Failed to delete transaction';
  String get saveNote => 'Save Note';
  String get editTransactionDetails =>
      'Edit Transaction Details';


  @override
  String get type => 'Type';

  @override
  String get moneyReceived => 'Money Received';

  @override
  String get moneyGiven => 'Money Given';

  @override
  String get cheque => 'Cheque';



  // String get lastPayment => 'Last Payment';
  // String get received => 'received';

  // @override
  // String get youTook => 'You Took';

}