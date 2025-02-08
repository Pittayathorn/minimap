import 'package:flutter/material.dart';
import 'sales_tab.dart'; // นำเข้าไฟล์ SalesTab
import 'product_management_tab.dart'; // นำเข้าไฟล์ ProductManagementTab
import 'sales_report_tab.dart'; // นำเข้าไฟล์ SalesReportTab

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // จำนวนแท็บ 3 แท็บ
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose TabController เมื่อไม่ใช้งาน
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('POS System'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'ขายสินค้า'),
            Tab(text: 'จัดการสินค้า'),
            Tab(text: 'รายงานยอดขาย'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SalesTab(),  // แท็บการขายสินค้า
          ProductManagementTab(),  // แท็บการจัดการสินค้า
          SalesReportTab(),  // แท็บรายงานยอดขาย
        ],
      ),
    );
  }
}
