// dashboard_section.dart

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardSection extends StatefulWidget {
  @override
  _DashboardSectionState createState() => _DashboardSectionState();
}

class _DashboardSectionState extends State<DashboardSection> {
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<DatabaseEvent>? subSensores;
  StreamSubscription<DatabaseEvent>? subVendedor;
  DatabaseReference? databaseReference;
  Map<dynamic, dynamic>? userData = {};
  Map<dynamic, dynamic>? userData2 = {};
  List<Map<String, dynamic>> sensorInfoList = [];

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) async {
      try {
        user = user!;
        databaseReference = FirebaseDatabase.instance.ref();

        // Listen for changes to the user data
        subVendedor = databaseReference!
            .child('users/vendedores/${user.uid}')
            .onValue
            .listen((event) {
          if (!mounted) return;
          setState(() {
            userData = event.snapshot.value as Map<dynamic, dynamic>;
          });
        });

        subSensores =
            databaseReference!.child('sensores').onValue.listen((event) {
          setState(() {
            userData2 = event.snapshot.value as Map<dynamic, dynamic>;
            sensorInfoList.clear();
            userData2?.forEach((sensorKey, sensorData) {
              if (sensorData.containsKey("idVendedor") &&
                  sensorData["idVendedor"] == user?.uid) {
                Map<String, dynamic> sensorInfo = {
                  sensorKey: {
                    "Peso": sensorData["peso"],
                    "idProduct": sensorData["idProducto"],
                  }
                };
                sensorInfoList.add(sensorInfo);
              }
            });
          });
        });
      } catch (e) {}
    });
  }

  @override
  void dispose() {
    subSensores?.cancel();
    subVendedor?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          height: 450,
          margin: const EdgeInsets.all(10),
          child: BarChart(
            BarChartData(
              maxY: 600,
              barGroups: sensorInfoList.map((sensorInfo) {
                final sensorKey = sensorInfo.keys.first;
                final sensorValue = sensorInfo.values.first;
                final peso = sensorValue['Peso'] ?? 0.0;

                final sensorNumber = int.parse(sensorKey.split('_').last);
                return BarChartGroupData(
                  x: sensorNumber,
                  barRods: [
                    BarChartRodData(y: peso.toDouble(), colors: [Colors.cyan]),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                leftTitles: SideTitles(showTitles: true),
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTextStyles: (value, _) => const TextStyle(fontSize: 10),
                ),
              ),
              borderData: FlBorderData(show: true),
              gridData: FlGridData(show: false),
            ),
          ),
        ),
      ),
    );
  }
}
