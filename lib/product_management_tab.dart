import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart'; // นำเข้า package สำหรับเลือกภาพ
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermission() async {
  var status = await Permission.photos.request();
  if (status.isGranted) {
    // สิทธิ์ได้รับอนุญาตแล้ว
  } else {
    // ไม่ได้รับสิทธิ์
  }
}

class ProductManagementTab extends StatefulWidget {
  @override
  _ProductManagementTabState createState() => _ProductManagementTabState();
}

class _ProductManagementTabState extends State<ProductManagementTab> {
  List<dynamic> _products = [];
  List<String> categories = [
    "Electronics",
    "Clothing",
    "Home",
    "Toys"
  ]; // รายการกลุ่มสินค้า
  String? selectedCategory; // ตัวแปรสำหรับเก็บกลุ่มสินค้าที่เลือก
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _imagePathController =
      TextEditingController(); // New controller for image name
  final TextEditingController _categoryController = TextEditingController();
  final String apiUrl = 'https://web.mini-map.shop/products';

  // สำหรับเก็บไฟล์ภาพ
  XFile? _image;

  @override
  void initState() {
    super.initState();
    requestPermission();
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

  // ฟังก์ชันเลือกภาพจากแกลเลอรี่
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? selectedImage =
          await picker.pickImage(source: ImageSource.gallery);

      if (selectedImage != null) {
        setState(() {
          _image = selectedImage;
        });

        // Show confirmation dialog after picking the image
        _showImageConfirmationDialog();
      } else {
        print('Image selection was cancelled');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _showImageConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ยืนยันการเลือกภาพ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(
                File(_image!.path),
                height: 300,
              ),
              SizedBox(height: 10),
              Text('คุณต้องการยืนยันภาพนี้หรือไม่?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog when canceling
              },
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _imagePathController.text =
                      _image!.path; // Store file name in controller
                });
                Navigator.of(context).pop(); // Close the dialog when confirming
              },
              child: Text('ยืนยัน'),
            ),
          ],
        );
      },
    );
  }

Future<void> _addProduct() async {
  if (_productController.text.isEmpty ||
      _priceController.text.isEmpty ||
      _stockController.text.isEmpty ||
      // _categoryController.text.isEmpty ||
      _imagePathController.text.isEmpty) {
    return;
  }

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': _productController.text,
        'price': _priceController.text,
        'stock': _stockController.text,
        // 'category': _categoryController.text,
        'category': selectedCategory!,
        
        'image_url': _imagePathController.text, // URL ของภาพ
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        _products.add({
          'name': _productController.text,
          'price': _priceController.text,
          'stock': _stockController.text,
          'category': _categoryController.text, // เพิ่มกลุ่มสินค้าในรายการสินค้า
          'image_url': _imagePathController.text, // URL ของภาพ
        });
      });

      // เคลียร์ฟอร์มหลังจากเพิ่มสินค้า
      _productController.clear();
      _priceController.clear();
      _stockController.clear();
      _categoryController.clear();
      _imagePathController.clear();
      setState(() {
        _image = null; // เคลียร์รูปภาพหลังจากเพิ่มสินค้า
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('เพิ่มสินค้าสำเร็จ')));
    } else {
      print('Failed to add product: ${response.statusCode}');
    }
  } catch (e) {
    print('Error adding product: $e');
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
              TextField(
                controller: _stockController,
                decoration: InputDecoration(labelText: 'url ภาพ'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _stockController,
                decoration: InputDecoration(labelText: 'กลุ่มสินค้า'),
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
        'category': _categoryController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _products[index] = {
          'name': _productController.text,
          'price': _priceController.text,
          'stock': _stockController.text,
          'category': _categoryController.text,
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
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _productController,
                  decoration: InputDecoration(labelText: 'เพิ่มสินค้า'),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'ราคา'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _stockController,
                  decoration: InputDecoration(labelText: 'จำนวนสินค้า'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _imagePathController,
                  decoration: InputDecoration(labelText: 'url ภาพ'),
                  keyboardType: TextInputType.text,
                ),
              ),
            ),
            // ฟิลด์สำหรับเลือกกลุ่มสินค้า
            Expanded(
              child:
                  // ใน UI เพิ่ม TextField หรือ Dropdown สำหรับเลือก category
              //     Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: TextField(
              //     controller: _categoryController,
              //     decoration: InputDecoration(labelText: 'หมวดหมู่สินค้า'),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  value: selectedCategory,
                  hint: Text("เลือกกลุ่มสินค้า"),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                  },
                  items:
                      categories.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _addProduct,
              child: Text('เพิ่มสินค้า'),
            ),
          ],
        ),

        // เพิ่มปุ่มสำหรับการอัพโหลดรูปภาพ

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
                                  '${_products[index]['name']}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text('ราคา: ฿${_products[index]['price']}'),
                                SizedBox(height: 4),
                                Text('จำนวน: ${_products[index]['stock']}'),
                                SizedBox(height: 4),
                                Text(
                                    'กลุ่มสินค้า: ${_products[index]['category']}'), // แสดงกลุ่มสินค้า
                              ],
                            ), // รูปภาพสินค้า
                            Positioned(
                              left: 0,
                              bottom: 0,
                              right: 0,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  // กำหนดค่าความสูงของรูปภาพตามขนาดหน้าจอ
                                  double imageHeight = 100; // ค่าเริ่มต้น
                                  if (MediaQuery.of(context).size.width >
                                      1200) {
                                    imageHeight =
                                        220; // เมื่อหน้าจอกว้างกว่า 1200px ความสูงของรูปภาพเป็น 200
                                  } else if (MediaQuery.of(context).size.width >
                                      800) {
                                    imageHeight =
                                        140; // เมื่อหน้าจอกว้างกว่า 640px แต่ไม่เกิน 1200px ความสูงของรูปภาพเป็น 150
                                  } else if (MediaQuery.of(context).size.width >
                                      640) {
                                    imageHeight =
                                        115; // เมื่อหน้าจอกว้างกว่า 640px แต่ไม่เกิน 1200px ความสูงของรูปภาพเป็น 150
                                  }

                                  return ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(8), // ขอบมน
                                    child:
                                        // Image.asset(
                                        //   'assets/images/0.png',
                                        //   fit: BoxFit.cover, // ครอบเต็มพื้นที่
                                        //   height: imageHeight,
                                        // ),
                                        Image.network(
                                      // URL ของรูปภาพสินค้า
                                      _products[index]['image_url'] ??
                                          'https://th-live-01.slatic.net/p/2eef7784122b97bba719a8efbfa1ba65.png',
                                      fit: BoxFit.cover, // ครอบเต็มพื้นที่
                                      height:
                                          imageHeight, // กำหนดความสูงของรูปภาพ
                                    ),
                                  );
                                },
                              ),
                            ),
                            // ปุ่มแก้ไข, ลบ และ ติดดาวอยู่มุมขวาบนของการ์ด
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      _products[index]['is_favorite']
                                      =='Y' ? Icons.star : Icons.star_border,
                                      color:
                                          _products[index]['is_favorite']

                                          =='Y' ? Colors.yellow : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _products[index]['is_favorite'] =
                                            !_products[index]['is_favorite'];
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => _editProduct(index),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () =>
                                        _showDeleteConfirmationDialog(index),
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
