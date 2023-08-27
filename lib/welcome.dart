import 'package:flutter/material.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: SafeArea(
          top: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenSize.height * 0.01),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.all(screenSize.width * 0.04),
                          child: Container(
                            width: screenSize.width * 2,
                            height: screenSize.height * 0.45,
                            decoration: BoxDecoration(
                              color: Color(0xBFEE8B60),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(0),
                              child: Image.asset(
                                'assets/InventarIO.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: screenSize.height * 0.06),
                        child: Text(
                          'Bienvenido',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Readex Pro',
                            fontSize: screenSize.width * 0.1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        'Inicia sesión',
                        style: TextStyle(
                          fontFamily: 'Readex Pro',
                          fontSize: screenSize.width * 0.1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: screenSize.height * 0.06),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                            );
                          },
                          child: Text(
                              'Iniciar Sesión'), // Cambié el texto del botón para que esté en español
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFFEF5339),
                            textStyle: TextStyle(
                              fontFamily: 'Readex Pro',
                              fontSize: screenSize.width * 0.05,
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.30,
                              vertical: screenSize.height * 0.025,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.15),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
