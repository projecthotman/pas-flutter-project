import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TellAdmin extends StatefulWidget {
  const TellAdmin({super.key});

  @override
  State<TellAdmin> createState() => _TellAdminState();
}

class _TellAdminState extends State<TellAdmin> {
  TextEditingController emailController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Call the method to retrieve the user's email when the widget initializes.
    getUserEmail();
  }

  // Method to retrieve the user's email from shared preferences.
  Future<void> getUserEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userEmail = prefs.getString("email") ?? "";
    setState(() {
      // Set the initial value of the email TextField.
      emailController.text = userEmail;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text("Forgot Password"),
        backgroundColor: const Color(0xFF1E232C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Forgot your password?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Kirimkan request maka kami akan mengirimkan passwordnya",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: "Email",
              ),
            ),
            const SizedBox(height: 20),
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
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                          "Send Request",
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
          ],
        ),
      ),
    );
  }
}
