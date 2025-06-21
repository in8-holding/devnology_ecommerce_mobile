import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List orders = [];
  bool loading = true;

  Future<void> fetchOrders() async {
    try {
      const url = 'http://localhost:3001/orders';
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        setState(() {
          orders = json.decode(res.body);
          loading = false;
        });
      } else {
        throw Exception('Erro ao buscar pedidos');
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar pedidos')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos Realizados')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('Nenhum pedido registrado.'))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final name = order['name'];
                    final email = order['email'];
                    final products = List.from(order['products']);

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(email),
                            const SizedBox(height: 8),
                            ...products.map((p) => Text('${p['name']} (x${p['quantity']})')).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
