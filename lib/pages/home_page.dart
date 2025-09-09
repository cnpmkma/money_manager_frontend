import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tổng quan"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.account_circle, size: 28),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card số dư
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              color: Colors.pinkAccent,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Số dư hiện tại",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "\$12,340.50",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Biểu đồ
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Container(
                height: 180,
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: Text(
                    "Biểu đồ chi tiêu ở đây",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Giao dịch gần đây
            Text(
              "Giao dịch gần đây",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.shopping_cart, color: Colors.red),
                    title: Text("Mua sắm siêu thị"),
                    subtitle: Text("8/9/2025"),
                    trailing: Text(
                      "-\$45.90",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.work, color: Colors.green),
                    title: Text("Lương tháng 9"),
                    subtitle: Text("6/9/2025"),
                    trailing: Text(
                      "+\$2000.00",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
