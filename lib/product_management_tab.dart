import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductManagementTab extends StatefulWidget {
  @override
  _ProductManagementTabState createState() => _ProductManagementTabState();
}

class _ProductManagementTabState extends State<ProductManagementTab> {
  List<dynamic> _products = [];
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  final String apiUrl = 'https://web.mini-map.shop/products';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);

      if (responseBody is Map && responseBody['status'] == 'success') {
        // ดึงข้อมูลสินค้าออกมาจาก 'data'
        setState(() {
          _products = responseBody['data'] ?? [];
        });
      }
    } else {
      print('Failed to load products');
    }
  }

  void _addProduct() async {
    if (_productController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _stockController.text.isEmpty) {
      return;
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': _productController.text,
        'price': _priceController.text,
        'stock': _stockController.text,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        _products.add({
          'name': _productController.text,
          'price': _priceController.text,
          'stock': _stockController.text,
        });
      });
      _productController.clear();
      _priceController.clear();
      _stockController.clear();
    } else {
      print('Failed to add product');
    }
  }

  void _deleteProduct(int index) async {
    final productId =
        _products[index]['product_id']; // ใช้ product_id แทนชื่อสินค้า
    final response = await http.delete(
      Uri.parse('$apiUrl/$productId'), // ใช้ product_id ใน URL
    );

    if (response.statusCode == 200) {
      setState(() {
        _products.removeAt(index); // ลบสินค้าออกจาก list
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('ลบสินค้าสำเร็จ')));
      });
    } else {
      print('Failed to delete product');
    }
  }

  // ฟังก์ชันสำหรับการแก้ไขสินค้า
  void _editProduct(int index) async {
    _productController.text = _products[index]['name'];
    _priceController.text = _products[index]['price'].toString();
    _stockController.text = _products[index]['stock'].toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('แก้ไขสินค้า'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _productController,
                decoration: InputDecoration(labelText: 'ชื่อสินค้า'),
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'ราคา'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _stockController,
                decoration: InputDecoration(labelText: 'จำนวนสินค้า'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                _updateProduct(index); // เรียกใช้ฟังก์ชันอัปเดตสินค้า
                Navigator.of(context).pop();
              },
              child: Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันสำหรับการอัปเดตสินค้า
  void _updateProduct(int index) async {
    if (_productController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _stockController.text.isEmpty) {
      return;
    }

    final response = await http.put(
      Uri.parse('$apiUrl/${_products[index]['name']}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': _productController.text,
        'price': _priceController.text,
        'stock': _stockController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _products[index] = {
          'name': _productController.text,
          'price': _priceController.text,
          'stock': _stockController.text,
        };
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('สินค้าอัปเดตสำเร็จ')));
      _productController.clear();
      _priceController.clear();
      _stockController.clear();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('การอัปเดตสินค้าล้มเหลว')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _productController,
          decoration: InputDecoration(labelText: 'เพิ่มสินค้า'),
        ),
        TextField(
          controller: _priceController,
          decoration: InputDecoration(labelText: 'ราคา'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: _stockController,
          decoration: InputDecoration(labelText: 'จำนวนสินค้า'),
          keyboardType: TextInputType.number,
        ),
        ElevatedButton(
          onPressed: _addProduct,
          child: Text('เพิ่มสินค้า'),
        ),
        Expanded(
          child: _products.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                          '${_products[index]['name']} - ฿${_products[index]['price']} - จำนวน: ${_products[index]['stock']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () =>
                                _editProduct(index), // เรียกใช้ฟังก์ชันแก้ไข
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () =>
                                _showDeleteConfirmationDialog(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ยืนยันการลบสินค้า'),
          content: Text('คุณแน่ใจว่าจะลบสินค้านี้หรือไม่?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(index); // เรียกฟังก์ชันลบ
                Navigator.of(context).pop(); // ปิด Dialog
              },
              child: Text('ยืนยัน'),
            ),
          ],
        );
      },
    );
  }
}
