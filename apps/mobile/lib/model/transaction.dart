import 'package:isar_community/isar.dart';

part 'transaction.g.dart';

enum TransactionType {
  gave,
  received,
  took,
  paid,
}

// @collection
// class Transaction {
//   Id id = Isar.autoIncrement;

//   late int customerId;

//   late double amount;

//   late double interest;

//   late DateTime date;

//   late double interestRate;

//   @enumerated
//   late TransactionType type;

//   String description = "";

//   String paymentMode = "";
  

//   String interestType = "";
//   String interestFrequency = "";
// }

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  late int customerId;

  double amount = 0;

  // Calculated interest amount in ₹
  double interest = 0;

  // Interest entered by the user in %
  double interestRate = 0;

  late DateTime date;
  late int chopdiId;

  @enumerated
  late TransactionType type;

  String description = "";
  String paymentMode = "";
  String interestType = "";
  String interestFrequency = "";
}