class Transaction {
  final int id;
  final int userId;
  final String type;
  final int categoryId;
  final int amount;
  final String description;

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.categoryId,
    required this.amount,
    required this.description,
  });
  
  factory Transaction.fromJson(Map<String, dynamic> json){
    return Transaction(id: json['id'], userId: json['userId'], type: json['type'], categoryId: json['categoryId'], amount: json['amount'], description: json['description']);
  }
}