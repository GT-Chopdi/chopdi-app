class CustomerModel {
  final String name;
  final String loan;
  final String interest;
  final String amount;
  final bool received;
  final String status;
  final String phone;

  CustomerModel({
    required this.name,
    required this.loan,
    required this.interest,
    required this.amount,
    required this.received,
    required this.phone,
    required this.status,
  });
}