import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_provider.dart';
import 'package:provider/provider.dart';
import './model/transaction.dart';
import './services/transaction_services.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),

        
        ),
    ],
    child: MyApp(),
  ));
}


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Mengecek status login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).checkLoginStatus().then((_) {
        if (Provider.of<AuthProvider>(context, listen: false).isAuthenticated) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => financeApp()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MyHomePage()));
        }
        return Scaffold(
          body: Center(child: CircularProgressIndicator(),)
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),  // Tampilkan loading saat pengecekan
    );
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(primary: Color.fromARGB(255,30, 42, 94), secondary: Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState(){
    super.initState();
    Provider.of<AuthProvider>(context,listen: false).checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context);

  if(authProvider.isAuthenticated){
    return financeApp();
  }

  var colorScheme = Theme.of(context).colorScheme;
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

    return  
    Scaffold(
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
      await saveToken(token);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => financeApp()));

    } else {
      print('Login failed with status: ${response.statusCode}');
    }

    } catch (e) {
      print('error : $e');
    }
  }

  Future<void> saveToken(String token)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
}


class financeApp extends StatefulWidget{
  financeApp({super.key});

  @override
  State<financeApp> createState() => _financeAppState();
}

class _financeAppState extends State<financeApp> {
  late Future<List<Transaction>> _transaction;
  final TransactionService _transactionService = TransactionService();

  @override
  void initState(){
    super.initState();
    _transaction = _transactionService.fetchTransaction();
   Provider.of<AuthProvider>(context, listen: false).checkLoginStatus();
  }
  @override
  Widget build(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context);

  if(!authProvider.isAuthenticated){
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));
  });
  }
  
    var colorScheme = Theme.of(context).colorScheme;

    return  
    Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        leading: Icon(Icons.verified_user, color: Colors.white,),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome Back', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w300, color: Colors.white),),
            Text('${authProvider.userData!['data']['username']}', style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white))
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 50,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)
                ),
                child: SizedBox(
                  width: 350,
                  height: 250,
                  child: Column(
                    children: [
                      SizedBox(height: 30,),
                      Text('Total Balance', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 20),),
                      Text('8.000.000', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 40),),
                      SizedBox(height: 30,),
                      Card(
                        color: colorScheme.primary,
                        child: SizedBox(
                          height: 70,
                          width: 250,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                              Row(
                                children: [
                                  Icon(Icons.arrow_downward, color: Colors.green,),
                              Text('Income', style: GoogleFonts.poppins(color: colorScheme.secondary, fontSize: 13),),
                                ],
                              ),
                              Text('1.764.000', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
                                ],
                              ),
                              SizedBox(height: 40,  child: VerticalDivider()),

                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                              Row(
                                children: [
                              Icon(Icons.arrow_upward, color: Colors.red,),
                              Text('Expense', style: GoogleFonts.poppins(color: colorScheme.secondary, fontSize: 13)),
                                ],
                              ),
                              Text('764.000', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 40,),
              Text('Recent Transaction', style: GoogleFonts.poppins(color: colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 100, width: 80,),
              InkWell(child: Text('See All',
              style: GoogleFonts.poppins(color: colorScheme.secondary, fontWeight: FontWeight.w500, fontSize: 18)),
              onTap: () {
                print('ACIKIWIR');
              },               
              ),
            ],
          ),
        FutureBuilder<List<Transaction>>(
        future: _transaction,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No transactions found'));
          } else {
            return SingleChildScrollView(child: 
             Column(
              children: [
                ListView.builder(itemCount: snapshot.data!.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,

                    itemBuilder: (context, index){
                      final transaction = snapshot.data![index];
                      return Align( 
                        child: Card(
                        child: SizedBox(
                          width: 360,
                          height: 100,
                          child: ListTile(
                            leading: Card(
                              color: colorScheme.primary,
                              child: SizedBox(
                                height: 50,
                                width: 50,
                                child: Icon(transaction.type == 'Income' ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white,))),
                            title: Text('${transaction.description}', style: GoogleFonts.poppins()),
                            subtitle: Text('${transaction.type}', style: GoogleFonts.poppins()),
                            trailing: Text('${transaction.amount}', style: GoogleFonts.poppins(fontSize: 15),),
                          ),
                        ),
                      )
                      );
                    },
                )
              ],
            )
            );
          }
        },
      ),
        ],
      )
    );
  }


Future<void> logout() async{
    Provider.of<AuthProvider>(context, listen: false).logout();
  }
}


