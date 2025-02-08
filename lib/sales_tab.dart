import 'package:flutter/material.dart';

class SalesTab extends StatefulWidget {
  @override
  _SalesTabState createState() => _SalesTabState();
}

class _SalesTabState extends State<SalesTab> {
  final List<String> _products = ['Product 1', 'Product 2', 'Product 3'];
  final List<int> _cart = [];

  void _addToCart(int index) {
    setState(() {
      _cart.add(index);
    });
  }

  void _checkout() {
    int totalItems = _cart.length;
    double totalAmount = totalItems * 100.0; // สมมุติว่า ราคาสินค้า = 100
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('ชำระเงิน'),
        content: Text('ยอดรวม: ฿$totalAmount\nจำนวนสินค้า: $totalItems'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('ยืนยัน'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _products.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_products[index]),
                trailing: IconButton(
                  icon: Icon(Icons.add_shopping_cart),
                  onPressed: () => _addToCart(index),
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: _checkout,
          child: Text('ชำระเงิน'),
        ),
      ],
    );
  }
}
