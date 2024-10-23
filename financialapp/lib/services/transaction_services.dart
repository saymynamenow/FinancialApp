import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionService{
  final String url = 'http://10.0.2.2:3000/api/transaction';

  Future<List<Transaction>> fetchTransaction() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization' : 'Bearer $token'
      }
      );
      if(response.statusCode == 200){
        List<dynamic> data = json.decode(response.body);
        print(data);
        return data.map((json) => Transaction.fromJson(json)).toList();
      }else{
        throw Exception('Failed To load Transaction');
      }
  }
}
