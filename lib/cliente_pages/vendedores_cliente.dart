import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class VendedoresPage_cliente extends StatefulWidget {
  Map<dynamic, dynamic>? user;
  VendedoresPage_cliente({super.key, required this.user});

  @override
  VendedoresPageState createState() => VendedoresPageState(user);
}

class VendedoresPageState extends State<VendedoresPage_cliente> {
  Map<dynamic, dynamic>? user;
  StreamSubscription<DatabaseEvent>? subVendedores;
  List<Map<dynamic, dynamic>> productos = [];

  VendedoresPageState(this.user);

  @override
  void initState() {
    super.initState();
    DatabaseReference vendedoresRef =
        FirebaseDatabase.instance.ref('users/vendedores');
    subVendedores = vendedoresRef.onValue.listen((DatabaseEvent event) {
      if (!mounted) return;
      setState(() {
        productos.clear();
        if (event.snapshot.value == null) return;
        final vendedoresData = event.snapshot.value as Map<dynamic, dynamic>;
        vendedoresData.forEach((vendedorKey, vendedorValue) {
          (vendedorValue['productos'] as Map<dynamic, dynamic>)
              .forEach((productoKey, value) {
            value['vendedor'] = vendedorValue['nombreEmpresa'];
            value['vendedorId'] = vendedorKey;
            value['productId'] = productoKey;
            productos.add(value);
          });
        });
      });
    });
  }

  void unsub() {
    subVendedores?.cancel();
  }

  @override
  void dispose() {
    unsub();
    super.dispose();
  }

  void addToCart(String idProducto, String idVendedor) {
    print(idProducto);
    print(idVendedor);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: productos.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            color: Colors.blueGrey.shade200,
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Icon(Icons.local_dining, size: 70),
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
                              text: '${productos[index]['descripcion']}\n',
                              style: TextStyle(
                                color: Colors.blueGrey.shade800,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        RichText(
                          maxLines: 1,
                          text: TextSpan(
                            text: '${productos[index]['vendedor']}\n',
                            style: TextStyle(
                                color: Colors.blueGrey.shade800,
                                fontSize: 16.0),
                          ),
                        ),
                        RichText(
                          maxLines: 1,
                          text: TextSpan(
                              text: 'P. Unit.: ',
                              style: TextStyle(
                                  color: Colors.blueGrey.shade800,
                                  fontSize: 16.0),
                              children: [
                                TextSpan(
                                    text: r"$"
                                        '${(productos[index]['precioUnidad'] / 100).toString()}\n',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ]),
                        ),
                        RichText(
                          maxLines: 1,
                          text: TextSpan(
                              text: 'Cantidad: ',
                              style: TextStyle(
                                  color: Colors.blueGrey.shade800,
                                  fontSize: 16.0),
                              children: [
                                TextSpan(
                                    text:
                                        '${(productos[index]['cantidad']).toString()}\n',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ]),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade900),
                      onPressed: () {
                        addToCart(productos[index]['productId'],
                            productos[index]['vendedorId']);
                      },
                      child: const Text('Añadir al carrito')),
                ],
              ),
            ),
          );
        });
  }
}
