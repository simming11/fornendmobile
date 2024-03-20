// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lab10/showproduct.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController =
      TextEditingController(text: "sim");
  final TextEditingController _passwordController =
      TextEditingController(text: "123456");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;

      // Define your http Laravel API location
      var url = Uri.parse('https://642021164.pungpingcoding.online/api/login');

      // Prepare the request body
      var json = jsonEncode({
        'name': username, // Assuming the username is the email
        'password': password,
      });

      // Send POST request
      var response = await http.post(
        url,
        body: json,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Parse the response JSON
        // ignore: unused_local_variable
        var responseData = jsonDecode(response.body);
        // Store user data and token to local storage (Shared Preferences)

        SharedPreferences prefs = await SharedPreferences.getInstance();
        var userjson = jsonDecode(response.body)['user'];
        var tokenjson = jsonDecode(response.body)['token'];
        // ignore: unused_local_variable
        var Idjson = jsonDecode(response.body)['ID'];
        await prefs.setStringList('user', [
          userjson['name'],
          userjson['email'],
          userjson['role'].toString(),
        ]);
        await prefs.setString('token', tokenjson);

        // Navigate to the next screen
        // ignore: use_build_context_synchronously
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'login successfully',
          showConfirmBtn: false,
          autoCloseDuration: const Duration(seconds: 0),
        ).then((value) async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ShowProductPage()),
          );
        });
      } else {
        // Show a SnackBar indicating login failure
        // ignore: use_build_context_synchronously
        QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'loin faill',
        showConfirmBtn: false,
        autoCloseDuration: const Duration(seconds: 0),
      );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username (Email)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
