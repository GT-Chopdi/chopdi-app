import 'package:mychopdi/model/customer.dart';
import 'package:mychopdi/model/transaction.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar_community/isar.dart';
import '../model/user_session.dart';

class IsarService {
  static late final Isar isar;

  static Null get instance => null;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    isar = await Isar.open(
      [
        CustomerSchema,
        TransactionSchema,
        UserSessionSchema,
      ],
      directory: dir.path,
    );
  }

  static Future<List<Customer>> getCustomers() async {
    return await isar.customers.where().findAll();
  }

  static Future<Customer?> getCustomerByPhone(String phone) async {
    return await isar.customers
        .filter()
        .phoneEqualTo(phone)
        .findFirst();
  }

  static Future<SummaryData> getSummary() async {
    final customers = await getCustomers();

    double totalOutstanding = 0;
    double totalLoanGiven = 0;
    double totalInterestEarned = 0;

    for (final customer in customers) {
      // totalOutstanding += customer.amount;

      // totalLoanGiven += customer.amount;

      // totalInterestEarned += customer.interest; // change according to your model
    }

    return SummaryData(
      outstanding: totalOutstanding,
      loanGiven: totalLoanGiven,
      interest: totalInterestEarned,
    );
  }
}

class SummaryData {
  final double outstanding;
  final double loanGiven;
  final double interest;

  SummaryData({
    required this.outstanding,
    required this.loanGiven,
    required this.interest,
  });
}