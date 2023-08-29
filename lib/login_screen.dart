// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'cliente_pages/home_screen_cliente.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisibility = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    String email = _usernameController.text;
    String password = _passwordController.text;

    try {
      UserCredential authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (authResult.user != null) {
        String uid = authResult.user!.uid;
        DatabaseReference ref =
            FirebaseDatabase.instance.ref("users/clientes/$uid");
        DatabaseEvent event = await ref.once();
        dynamic data = event.snapshot
            .value; // Almacenar el valor en una variable llamada "data"
        DatabaseReference ref2 =
            FirebaseDatabase.instance.ref("users/vendedores/$uid");
        DatabaseEvent event2 = await ref2.once();
        dynamic data2 = event2.snapshot
            .value; // Almacenar el valor en una variable llamada "data"
        if (data != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen_cliente()),
          );
        }
        if (data2 != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
        // Search for the user in the "clientes" section
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al iniciar sesión. Inténtalo de nuevo.'),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al iniciar sesión. Inténtalo de nuevo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 14, top: 75),
                  child: Text(
                    'Hola',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: 'Readex Pro',
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 14, top: 10),
                  child: Text(
                    'Inicia Sesión!',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: 'Readex Pro',
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 90),
                  child: Container(
                    width: 450,
                    height: 900,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 15, top: 50),
                          child: Text(
                            'Usuario',
                            style: TextStyle(
                              fontFamily: 'Readex Pro',
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: TextFormField(
                            controller: _usernameController,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'Usuario',
                              labelStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                  width: 5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: const TextStyle(
                              fontFamily: 'Readex Pro',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 15, top: 30),
                          child: Text(
                            'Contraseña',
                            style: TextStyle(
                              fontFamily: 'Readex Pro',
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: !_passwordVisibility,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              labelStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                  width: 5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    _passwordVisibility = !_passwordVisibility;
                                  });
                                },
                                child: Icon(
                                  _passwordVisibility
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            style: const TextStyle(
                              fontFamily: 'Readex Pro',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
