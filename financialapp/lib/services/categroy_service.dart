import 'package:http/http.dart' as http;
import '../model/categroyModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CategroyService {
  final String url = 'http://10.0.2.2:3000/api/category';
  Future<List<categoryModel>> fetchCategory() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(Uri.parse(url),
    headers: {
      'Authorization' : 'Bearer $token'
    }
    );
    if(response.statusCode == 200){ 
      List<dynamic> data = json.decode(response.body);
      print(data);
      return data.map((json) => categoryModel.fromJson(json)).toList();
    }else{
        throw Exception('Failed To Load');
    }
  }
}