import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_provider.dart';
import 'package:provider/provider.dart';
import './model/transaction.dart';
import './services/transaction_services.dart';
import './services/categroy_service.dart';
import 'model/categroyModel.dart';

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
            Text('${authProvider.userData?['data']['username']}', style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white))
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
                ListView.builder(
                  itemCount: snapshot.data!.length >= 3 ? 3: snapshot.data!.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,

                    itemBuilder: (context, index){
                      final int startIndex = snapshot.data!.length - 3;
                      final transaction = snapshot.data!.sublist(startIndex < 0 ? 0 : startIndex)[index];
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
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary,
              spreadRadius: 10.0,
            )
          ]
        ),
        child: SizedBox(
          height: 70,
          width: 70,
          child: FloatingActionButton(
            splashColor: Colors.black,
            onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => addTransaction()));
          }, child: Icon(Icons.add),elevation: 5.0,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),),
        ),
      ),

      bottomNavigationBar: SizedBox(
        height: 60,
        child: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: IconButton(onPressed: (){print('1');}, icon: Icon(Icons.home))),
              Expanded(child: Text(' ')),
              Expanded(child: IconButton(onPressed: (){print('1');}, icon: Icon(Icons.history))),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

    );
  }



Future<void> logout() async{
    Provider.of<AuthProvider>(context, listen: false).logout();
  }
}

class addTransaction extends StatefulWidget{
  addTransaction({super.key});

  @override
  State<addTransaction> createState() => _addTransactionState();
}

class _addTransactionState extends State<addTransaction> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    var colorScehme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: colorScehme.primary,
      ),
      backgroundColor: colorScehme.primary,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('RP.',style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),),
              SizedBox(width: 10,),
              SizedBox(
                width: 300,
                child: TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 2.0,
                      ),
                      

                    ),
                    disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2.0,
                      )
                    ),
                    hintText: 'Please Input',
                  ),
                  controller: textController,
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
          categoryList(),
          numericKeyPad(
            controller: textController,
          )

        ],
      )
    );
  }
}


class numericKeyPad extends StatefulWidget{
  final TextEditingController controller;
  const numericKeyPad({super.key, required this.controller});

  @override
  State<numericKeyPad> createState() => _numericKeyPadState();
}

class _numericKeyPadState extends State<numericKeyPad> {
  late TextEditingController _controller;

  @override
  void initState(){
    super.initState();
    _controller = widget.controller;
  }

    @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildButton('1'),
            _buildButton('2'),
            _buildButton('3')
          ],
        ),
        Row(
          children: [
            _buildButton('4'),
            _buildButton('5'),
            _buildButton('6')
          ],
        ),
        Row(
          children: [
            _buildButton('7'),
            _buildButton('8'),
            _buildButton('9')
          ],
        ),
        Row(
          children: [
            _buildButton(''),
            _buildButton('0'),
            _buildButton('⌫', onPressed: _backspace)
          ],
        ),

      ],
    );
  }

  Widget _buildButton(String text, {VoidCallback ? onPressed}){
    return Expanded(child: SizedBox(
      height: 80,
      child: TextButton(onPressed: onPressed ?? () => _inputString(text), child: Text(text, style: GoogleFonts.poppins(fontSize: 20,color: Colors.white),))));
  }

  void _inputString(String text){
    final value = _controller.text + text;
    _controller.text = value;
  }

  void _backspace() {
    final value = _controller.text;
    if(value.isNotEmpty){
      _controller.text = value.substring(0, value.length - 1);
    }
  }
}

class categoryList extends StatefulWidget{
  categoryList({super.key});

  @override
  State<categoryList> createState() => _categoryListState();
}

class _categoryListState extends State<categoryList> {
  late Future<List<categoryModel>> _category;
  final CategroyService _categroyService = CategroyService();
  @override
  void initState(){
    super.initState();
    _category = _categroyService.fetchCategory();
  }
  @override
  Widget build(BuildContext context) {
      return Column(
        children: [
              FutureBuilder<List<categoryModel>>(
                
              future: _category, 
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator());
                }else if(snapshot.hasError){
                  return Center(child: Text('Error: ${snapshot.error}'));
                }else if(!snapshot.hasData || snapshot.data!.isEmpty){
                  return Center(child: Text('No Category found'));
                }else{
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(

                          itemCount: snapshot.data!.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (context, index){
                            final category = snapshot.data![index];
                            return Align(
                              child: Card(
                                child: SizedBox(
                                  width: 50,
                                  height: 100,
                                  child: Text(
                                    '${category.name}'
                                  ),
                                ),
                              ),
                            );
                          }
                          )
                      ],
                    ),
                  );
                }
              }
              )
        ],
      );
  }
}

