import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CarritoPage_cliente extends StatefulWidget {
  Map<dynamic, dynamic>? user;
  CarritoPage_cliente({super.key, required this.user});
  @override
  CarritoPageState createState() => CarritoPageState(user);
}

class CarritoPageState extends State<StatefulWidget> {
  StreamSubscription<DatabaseEvent>? subCarrito;
  Map<dynamic, dynamic>? user;
  List<Map<dynamic, dynamic>> carritoList = [];
  double _precioTotal = 0;
  DatabaseReference? carritoRef;

  CarritoPageState(this.user);

  @override
  void initState() {
    super.initState();
    carritoRef = FirebaseDatabase.instance
        .ref('users/clientes/${user!['carrito']['id']}/carrito/products');
    subCarrito = carritoRef?.onValue.listen((DatabaseEvent event) {
      if (!mounted) return;
      setState(() {
        carritoList.clear();
        _precioTotal = 0;
        if (event.snapshot.value == null) return;
        final cartData = event.snapshot.value as Map<dynamic, dynamic>;
        cartData.forEach((key, value) {
          value['productId'] = key;
          _precioTotal += (value['precioUnitario'] / 100) * value['cantidad'];
          carritoList.add(value);
        });
      });
    });
  }

  void clearCarrito() async {
    DatabaseReference temp = FirebaseDatabase.instance
        .ref('users/clientes/${user!['carrito']['id']}/carrito');
    await temp.update({"/products": {}});
  }

  @override
  void dispose() {
    subCarrito?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: carritoList.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == carritoList.length) {
            if (carritoList.isEmpty) return const SizedBox();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Divider(
                  height: 15,
                  thickness: 2,
                  indent: 10,
                  endIndent: 10,
                  color: Colors.grey,
                ),
                Text(
                  'Sub-Total: '
                  r'$'
                  '${_precioTotal.toStringAsFixed(2)}${' ' * 3}',
                  //style: TextStyle(),
                ),
                const SizedBox(width: 10),
              ],
            );
          }
          return Card(
            color: Colors.blueGrey.shade200,
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Icon(
                    Icons.cake,
                    size: 50,
                  ),
                  SizedBox(
                    width: 130,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 5.0,
                        ),
                        RichText(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          text: TextSpan(
                            text: carritoList[index]['descripcion'],
                            style: TextStyle(
                                color: Colors.blueGrey.shade800,
                                fontSize: 16.0),
                          ),
                        ),
                        RichText(
                          maxLines: 1,
                          text: TextSpan(
                              text: 'Precio unit.: ',
                              style: TextStyle(
                                  color: Colors.blueGrey.shade800,
                                  fontSize: 16.0),
                              children: [
                                TextSpan(
                                  text: r"$"
                                      '${(carritoList[index]['precioUnitario'] / 100).toString()}\n',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ]),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () async {
                          if ((carritoList[index]['cantidad']) - 1 < 1) return;
                          await carritoRef?.update({
                            "/${carritoList[index]['productId']}/cantidad":
                                (carritoList[index]['cantidad']) - 1,
                          });
                        },
                        iconSize: 15,
                      ),
                      RichText(
                        maxLines: 1,
                        text: TextSpan(
                          text:
                              '${(carritoList[index]['cantidad']).toString()}\n',
                          style: TextStyle(
                            color: Colors.blueGrey.shade800,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          await carritoRef?.update({
                            "/${carritoList[index]['productId']}/cantidad":
                                (carritoList[index]['cantidad']) + 1,
                          });
                        },
                        iconSize: 15,
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () async {
                      await carritoRef
                          ?.update({"/${carritoList[index]['productId']}": {}});
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red.shade800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: InkWell(
        onTap: () {
          clearCarrito();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("¡Pago exitoso!"),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: carritoList.isNotEmpty
            ? Container(
                color: Colors.blueAccent,
                alignment: Alignment.center,
                height: 50.0,
                child: const Text(
                  "Proceder a pagar",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            : const SizedBox(),
      ),
    );
  }
}
