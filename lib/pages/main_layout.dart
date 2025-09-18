import 'package:flutter/material.dart';
import 'package:money_manager_frontend/pages/account_page.dart';
import 'package:money_manager_frontend/pages/transaction_add_page.dart';
import 'package:money_manager_frontend/pages/budget_page.dart';
import 'package:money_manager_frontend/pages/transaction_page.dart';
import 'package:money_manager_frontend/pages/wallet_page.dart';
import 'home_page.dart';

enum MainPage { home, transactions, budget, account, walletList }

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  MainPage _currentPage = MainPage.home;
  late final PageController _pageController;

  // key để gọi hàm trong TransactionPage
  final GlobalKey<TransactionPageState> _transactionKey =
      GlobalKey<TransactionPageState>();

  late final Map<MainPage, Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _pages = {
      MainPage.home: Home(),
      MainPage.transactions: TransactionPage(key: _transactionKey),
      MainPage.budget: const BudgetPage(),
      MainPage.account: const AccountPage(),
      MainPage.walletList: WalletListPage(),
    };
  }

  void _goTo(MainPage page) {
    setState(() => _currentPage = page);
    if (page != MainPage.walletList && _pageController.hasClients) {
      _pageController.jumpToPage(_mainPageIndex(page));
    }
  }

  Future<void> _openAddTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionPage()),
    );
    if (result == true) {
      _transactionKey.currentState?.reload();
    }
  }

  int _mainPageIndex(MainPage page) {
    switch (page) {
      case MainPage.home:
        return 0;
      case MainPage.transactions:
        return 1;
      case MainPage.budget:
        return 2;
      case MainPage.account:
        return 3;
      default:
        return 0;
    }
  }

  MainPage _pageFromIndex(int index) {
    switch (index) {
      case 0:
        return MainPage.home;
      case 1:
        return MainPage.transactions;
      case 2:
        return MainPage.budget;
      case 3:
        return MainPage.account;
      default:
        return MainPage.home;
    }
  }

  int _bottomNavIndex() {
    switch (_currentPage) {
      case MainPage.home:
        return 0;
      case MainPage.transactions:
        return 1;
      case MainPage.budget:
        return 3; // skip placeholder
      case MainPage.account:
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPage == MainPage.walletList
          ? _pages[MainPage.walletList]
          : PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                final page = _pageFromIndex(index);
                setState(() => _currentPage = page);
              },
              children: [
                _pages[MainPage.home]!,
                _pages[MainPage.transactions]!,
                _pages[MainPage.budget]!,
                _pages[MainPage.account]!,
              ],
            ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFFF81879),
        onPressed: _openAddTransaction,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex(),
        onTap: (index) {
          if (index == 2) {
            _openAddTransaction(); // nút giữa
          } else {
            final page = [
              MainPage.home,
              MainPage.transactions,
              MainPage.budget,
              MainPage.account,
            ][index > 2 ? index - 1 : index];
            _goTo(page);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Tổng quan"),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Giao dịch"),
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
