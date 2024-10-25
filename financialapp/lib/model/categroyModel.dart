class categoryModel {
  final int id;
  final String name;
  final String description;

  categoryModel({
    required this.id,
    required this.name,
    required this.description,
  });
  
factory categoryModel.fromJson(Map<String, dynamic> json){
    return categoryModel(id: json['id'], name: json['name'], description: json['description']);
  }
} 