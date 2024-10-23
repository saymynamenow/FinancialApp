import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthProvider extends ChangeNotifier{
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? get userData => _userData;

  Future<void> checkLoginStatus() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print('CheckLogin');
    if(token != null){
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/',),
        headers: {
          'Authorization' : 'Bearer $token',
        }
      );

      if(response.statusCode == 200){
        _isAuthenticated = true;
        _userData = JwtDecoder.decode(token);
        print('True');
      }else{
    print('False');
        await prefs.remove('token');
        _isAuthenticated = false;
      }
    } else{
    print('False Else');
      _isAuthenticated = false;
    }
    notifyListeners();
  }


  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _isAuthenticated = false;
    _userData = null;
    notifyListeners();
  }

}