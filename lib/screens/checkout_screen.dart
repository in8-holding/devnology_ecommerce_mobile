import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../models/product.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  bool _saving = false;

  Future<void> _sendOrderToBackend(Map<String, dynamic> order) async {
    const String url = 'http://localhost:3001/orders';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(order),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erro ao enviar pedido. Status: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar Compra')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Total: R\$ ${cart.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome Completo'),
                validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Campo obrigatório';
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(val)) return 'E-mail inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Endereço'),
                validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 24),
              _saving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          setState(() => _saving = true);

                          final order = {
                            'name': _nameController.text,
                            'email': _emailController.text,
                            'address': _addressController.text,
                            'total': cart.totalPrice,
                            'products': cart.products.values
                                .map((p) => {
                                      'id': p.id,
                                      'name': p.name,
                                      'price': p.price,
                                      'image': p.image,
                                      'quantity': cart.items[p.id] ?? 1,
                                    })
                                .toList(),
                            'date': DateTime.now().toIso8601String(),
                          };

                          try {
                            await _sendOrderToBackend(order);
                            cart.clear();

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Compra registrada com sucesso!')),
                              );
                              Navigator.popUntil(context, (route) => route.isFirst);
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Erro ao registrar pedido')),
                            );
                          } finally {
                            setState(() => _saving = false);
                          }
                        }
                      },
                      child: const Text('Confirmar Compra'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
