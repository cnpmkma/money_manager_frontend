import 'package:flutter/material.dart';
import 'package:money_manager_frontend/pages/account_page.dart';
import 'package:money_manager_frontend/pages/add_transaction_page.dart';
import 'package:money_manager_frontend/pages/budget_page.dart';
import 'package:money_manager_frontend/pages/transaction_page.dart';
import 'package:money_manager_frontend/pages/wallet_list_page.dart';
import 'home_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _current_index = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      Home(
        onViewAllWallets: () {
          setState(() {
            _current_index = 5; // chuyển sang WalletListPage
          });
        },
      ),
      const TransactionPage(),
      const Placeholder(),
      const BudgetPage(),
      const AccountPage(),
      WalletListPage(
        onBack: () {
          setState(() {
            _current_index = 0; // quay về Home
          });
        },
      ), // index 5
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_current_index],
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddTransactionPage(),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _current_index > 4 ? 0 : _current_index, // ẩn index 5
        onTap: (index) {
          if (index == 2) {
            return;
          } else {
            setState(() {
              _current_index = index;
            });
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Tổng quan"),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: "Sổ giao dịch",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.transparent),
            label: "",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Ngân sách"),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: "Tài khoản",
          ),
        ],
      ),
    );
  }
}
