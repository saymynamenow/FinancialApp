import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(primary: Color.fromARGB(255,30, 42, 94), secondary: Color.fromARGB(255, 225, 215, 183)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
                        checkLoginStatus(context);
    var colorScheme = Theme.of(context).colorScheme;
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
    return Scaffold(
      backgroundColor: colorScheme.primary,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 100,),
            Icon(Icons.money, size: 120, color: colorScheme.secondary,),
            Text('Welcome To Finance APP', style: GoogleFonts.poppins(color: colorScheme.secondary, fontSize: 20),),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: username,
                      style: GoogleFonts.poppins(color: colorScheme.secondary),
                      decoration: InputDecoration(
                        
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)
                        ),
                        border: UnderlineInputBorder(
                        ),
                        labelText: 'Input Username',
                        labelStyle: GoogleFonts.poppins(color: colorScheme.secondary)
                        
                      ),
                    ),

                ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: password,
                      style: GoogleFonts.poppins(color: colorScheme.secondary),
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)
                        ),
                        border: UnderlineInputBorder(
                        ),
                        labelText: 'Input Password',
                        labelStyle: GoogleFonts.poppins(color: colorScheme.secondary)
                        
                      ),
                    ),

                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 190,
                      child: ElevatedButton(onPressed: () =>{
                        loginFetchApi(username.text, password.text),
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                        )
                      ),
                       child: Text('Login')),
                    ),

                  ],
                ),
                SizedBox(height: 350,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't Have Account? ", style: GoogleFonts.poppins(color: colorScheme.secondary),),
                  InkWell(
                    onTap: (){
                      print('TAPPs');
                    },
                    child: Padding(padding: EdgeInsets.all(1.0),
                    child: Text('Click Here', style: GoogleFonts.poppins(color: colorScheme.secondary)),),
                  ),
                ],
              )
          ],
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> loginFetchApi(String username, String password)async{
    final url = Uri.parse('http://10.0.2.2:3000/api/login');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-type': 'application/json',
        },
      body: 
        jsonEncode({'username': username, 'password': password})
        );

    if (response.statusCode == 200) {
      // Jika sukses, ambil data token misalnya
      var responseData = jsonDecode(response.body);
      var token = responseData['token'];
      saveToken(token);
    } else {
      print('Login failed with status: ${response.statusCode}');
    }

    } catch (e) {
      print('error : $e');
    }
  }

  Future<void> saveToken(String token)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }


}
  Future<void> checkLoginStatus(BuildContext context)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    if(token != null){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => financeApp()));
    }else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => financeApp()));
    }
  }

class financeApp extends StatelessWidget{
  financeApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('CENTER'),
    );
  }

}