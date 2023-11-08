import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as myHttp;
import 'package:project/homePage.dart';
import 'package:project/models/login-response.dart';
import 'package:project/tabbar/master.dart';
import 'package:project/telladmin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late Future<String> _name, _token;

  @override
  void initState() {
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });

    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });
    checkToken(_token, _name);
  }

  checkToken(token, name) async {
    String tokenStr = await token;
    String nameStr = await name;
    if (tokenStr != "" && nameStr != "") {
      Future.delayed(const Duration(seconds: 1), () async {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MasterTabbar())).then((value) {
          setState(() {});
        });
      });
    }
  }

  Future login(email, password) async {
    LoginResponseModel? loginResponseModel;
    Map<String, String> body = {"email": email, "password": password};
    var response = await myHttp.post(Uri.parse('http://10.0.2.2:8000/api/login'), body: body);
    if (response.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email atau password salah")));
    } else {
      loginResponseModel = LoginResponseModel.fromJson(json.decode(response.body));
      print('HASIL ' + response.body);
      saveUser(loginResponseModel.data.token, loginResponseModel.data.name);
    }
  }

  Future saveUser(token, name) async {
    try {
      final SharedPreferences pref = await _prefs;
      pref.setString("name", name);
      pref.setString("token", token);
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MasterTabbar())).then((value) {
        setState(() {});
      });
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString())));
    }
  }

  bool _isPasswordObscured = true;
  bool _isTextVisible = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    "assets/enter.png",
                    height: size.height * 0.31,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: const Text(
                      "Selamat Datang Kembali, Silahkan Login! ",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Color(0xFF688E4E)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                //email
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8F9),
                      border: Border.all(
                        color: const Color(0xFFE8ECF4),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      child: TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'masukkan email',
                          hintStyle: TextStyle(
                            color: Color(0xFF8391A1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                //password
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8F9),
                      border: Border.all(
                        color: const Color(0xFFE8ECF4),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: _isPasswordObscured && !_isTextVisible,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'masukkan password',
                          hintStyle: const TextStyle(
                            color: Color(0xFF8391A1),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordObscured = !_isPasswordObscured;
                                _isTextVisible = !_isTextVisible;
                              });
                            },
                            icon: Icon(
                              _isPasswordObscured ? Icons.visibility : Icons.visibility_off,
                              color: const Color(0xFF8391A1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: MaterialButton(
                          color: const Color(0xFF1E232C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: () {
                            login(emailController.text, passwordController.text);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Lupa password? ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const TellAdmin()));
                        },
                        child: const Text(
                          "Laporkan ke Admin",
                          style: TextStyle(
                            color: Color(0xFF688E4E),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
