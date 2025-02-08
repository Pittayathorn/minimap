import 'package:flutter/material.dart';

class SalesReportTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('รายงานยอดขาย', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Text('ยอดรวม: ฿5000', style: TextStyle(fontSize: 20)),
          Text('จำนวนรายการ: 50', style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}
