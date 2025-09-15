import 'package:flutter/material.dart';
import 'package:money_manager_frontend/pages/account_page.dart';
import 'package:money_manager_frontend/pages/add_transaction_page.dart';
import 'package:money_manager_frontend/pages/budget_page.dart';
import 'package:money_manager_frontend/pages/transaction_page.dart';
import 'package:money_manager_frontend/pages/wallet_list_page.dart';
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

  late final Map<MainPage, Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 0);

    _pages = {
      MainPage.home: Home(onViewAllWallets: () => _goTo(MainPage.walletList)),
      MainPage.transactions: const TransactionPage(),
      MainPage.budget: const BudgetPage(),
      MainPage.account: const AccountPage(),
      MainPage.walletList: WalletListPage(onBack: () => _goTo(MainPage.home)),
    };
  }

  void _goTo(MainPage page) {
    setState(() => _currentPage = page);

    if (page != MainPage.walletList && _pageController.hasClients) {
      _pageController.jumpToPage(_mainPageIndex(page));
    }
  }

  void _openAddTransaction() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddTransactionPage(),
    );
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
        backgroundColor: Color(0xFFF81879),
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
            // BottomNav index → MainPage
            final page = [MainPage.home, MainPage.transactions, MainPage.budget, MainPage.account]
                [index > 2 ? index - 1 : index];
            _goTo(page);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Tổng quan"),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Giao dịch"),
          BottomNavigationBarItem(icon: Icon(Icons.add, color: Colors.transparent), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Ngân sách"),
          BottomNavigationBarItem(icon: Icon(Icons.manage_accounts), label: "Tài khoản"),
        ],
      ),
    );
  }
}
