import 'package:flutter/material.dart';

class SalesTab extends StatefulWidget {
  @override
  _SalesTabState createState() => _SalesTabState();
}

class _SalesTabState extends State<SalesTab> {
  final List<String> _products = ['Product 1', 'Product 2', 'Product 3'];
  final List<int> _cart = [];

  // ฟังก์ชันเพิ่มสินค้าในตะกร้า
  void _addToCart(int index) {
    setState(() {
      _cart.add(index);
    });
  }

  // ฟังก์ชันชำระเงิน
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
    int columns = 2;

    if (MediaQuery.of(context).size.width > 1200) {
      columns = 5;
    } else if (MediaQuery.of(context).size.width > 800) {
      columns = 4;
    } else if (MediaQuery.of(context).size.width > 640) {
      columns = 3;
    }

    return Column(
      children: [
        // Product List
        Expanded(
          child: _products.isEmpty
              ? Center(child: CircularProgressIndicator())
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.all(8),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _products[index],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text('ราคา: ฿100'),  // Example static price
                                SizedBox(height: 4),
                                Text('จำนวน: 10'), // Example static stock
                                SizedBox(height: 8),
                              ],
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.add_shopping_cart),
                                    onPressed: () => _addToCart(index),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        // Checkout Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _cart.isEmpty ? null : _checkout, // disable if cart is empty
            child: Text('ชำระเงิน'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15),
              textStyle: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
