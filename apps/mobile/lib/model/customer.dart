// import 'package:isar_community/isar.dart';
// part 'customer.g.dart';
// @collection
// class Customer {

//   Id id = Isar.autoIncrement;

//   late String name;
//   late String phone;
//   late double amount;
//   late double interest;
//   late String status;
//   late bool received;
//   late String loan;

// }

import 'package:isar_community/isar.dart';

part 'customer.g.dart';

@collection
class Customer {

  Id id = Isar.autoIncrement;

  late String name;

  late String phone;

  late String status;

  late bool received;

  late int chopdiId;

  late String loanType;
}