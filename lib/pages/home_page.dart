import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:money_manager_frontend/pages/wallet_page.dart';
import 'package:money_manager_frontend/services/wallet_service.dart';
import 'package:money_manager_frontend/services/transaction_service.dart';
import 'package:money_manager_frontend/widgets/gradient_scaffold.dart';
import 'transaction_page.dart';
import 'dart:math' as math;
import '../constants/category_icons.dart';

class Home extends StatefulWidget {
  final VoidCallback? onViewAllWallets;
  const Home({super.key, this.onViewAllWallets});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _showBalance = true;
  double totalBalance = 0;
  List<dynamic> _wallets = [];

  final currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _fetchWallets();
  }

  Future<void> _fetchWallets() async {
    try {
      final wallets = await WalletService.getWallets();
      if (!mounted) return;
      setState(() {
        _wallets = wallets;
        totalBalance = _wallets.fold(
          0,
          (sum, w) => sum + (double.tryParse(w['balance'].toString()) ?? 0),
        );
      });
    } catch (e) {
      debugPrint("Error fetching wallets: $e");
    }
  }

  Future<Map<String, dynamic>> _fetchTransactionsSummary() async {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    double totalIncome = 0;
    double totalExpense = 0;

    final dailyIncome = <int, double>{};
    final dailyExpense = <int, double>{};

    try {
      final transactions = await TransactionService.getTransactions();

      for (var t in transactions) {
        final date = DateTime.parse(t['transaction_date']);
        final amount = double.tryParse(t['amount'].toString()) ?? 0;
        final type = t['category']['type'];

        if (type == 'thu') {
          totalIncome += amount;
        } else if (type == 'chi') {
          totalExpense += amount;
        }

        if (date.month == currentMonth && date.year == currentYear) {
          final day = date.day;
          if (type == 'thu') {
            dailyIncome[day] = (dailyIncome[day] ?? 0) + amount;
          } else if (type == 'chi') {
            dailyExpense[day] = (dailyExpense[day] ?? 0) + amount;
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
    }

    // Build spots for line chart
    double cumulativeIncome = 0;
    double cumulativeExpense = 0;

    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];

    final daysInMonth = DateUtils.getDaysInMonth(currentYear, currentMonth);

    for (int day = 1; day <= daysInMonth; day++) {
      cumulativeIncome += dailyIncome[day] ?? 0;
      cumulativeExpense += dailyExpense[day] ?? 0;

      incomeSpots.add(FlSpot(day.toDouble(), cumulativeIncome));
      expenseSpots.add(FlSpot(day.toDouble(), cumulativeExpense));
    }

    return {
      "income": totalIncome,
      "expense": totalExpense,
      "incomeSpots": incomeSpots,
      "expenseSpots": expenseSpots,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchWallets(); // refresh ví
          setState(
            () {},
          ); // trigger rebuild, FutureBuilder sẽ gọi lại _fetchTransactionsSummary()
        },
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // quan trọng để có thể vuốt ngay cả khi ít nội dung
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: const Color(0xFFF6F5F2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: ListTile(
                  title: Text(
                    _showBalance
                        ? currencyFormatter.format(totalBalance)
                        : "********",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      _showBalance ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _showBalance = !_showBalance),
                  ),
                  subtitle: const Text("Tổng số dư"),
                ),
              ),
              const SizedBox(height: 16),
              WalletCard(
                wallets: _wallets,
                totalBalance: totalBalance,
                showBalance: _showBalance,
                toggleBalance: () =>
                    setState(() => _showBalance = !_showBalance),
                onViewAll: widget.onViewAllWallets,
                refreshWallets: _fetchWallets,
              ),
              const SizedBox(height: 20),
              TextSection(
                title: "Báo cáo tháng này",
                actionText: "Xem báo cáo",
                onAction: () {},
              ),
              const SizedBox(height: 8),

              // phần FutureBuilder chart vẫn giữ nguyên
              FutureBuilder<Map<String, dynamic>>(
                future: _fetchTransactionsSummary(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Text("Lỗi khi tải dữ liệu");
                  }

                  final data = snapshot.data!;
                  final income = data['income'] as double;
                  final expense = data['expense'] as double;
                  final incomeSpots = data['incomeSpots'] as List<FlSpot>;
                  final expenseSpots = data['expenseSpots'] as List<FlSpot>;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                        child: Text(
                          "Thu nhập vs Chi tiêu",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ChartCard(
                        child: IncomeExpensePieChart(
                          income: income,
                          expense: expense,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                        child: Text(
                          "Diễn biến trong tháng",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ChartCard(
                        child: MonthlyLineChart(
                          incomeSpots: incomeSpots,
                          expenseSpots: expenseSpots,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),
              TextSection(
                title: "Giao dịch gần đây",
                actionText: "Xem tất cả",
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TransactionPage(), // trang danh sách giao dịch
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              const TransactionCard(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Tổng quan"),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      actions: const [
        Icon(Icons.search, color: Colors.black),
        SizedBox(width: 16),
        Icon(Icons.notifications_none, color: Colors.black),
        SizedBox(width: 16),
      ],
    );
  }
}

class WalletCard extends StatelessWidget {
  final List<dynamic> wallets;
  final double totalBalance;
  final bool showBalance;
  final VoidCallback? toggleBalance;
  final VoidCallback? onViewAll;
  final Future<void> Function()? refreshWallets;

  const WalletCard({
    super.key,
    required this.wallets,
    required this.totalBalance,
    required this.showBalance,
    this.toggleBalance,
    this.onViewAll,
    this.refreshWallets,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Color(0xFFF6F5F2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Ví của tôi",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () async {
                    final changed = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WalletListPage(),
                      ),
                    );

                    if (changed == true) {
                      await refreshWallets!();
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                  ),
                  child: const Text("Xem tất cả"),
                ),
              ],
            ),
            const Divider(height: 1),
            Column(
              children: wallets.take(3).map((wallet) {
                return Column(
                  children: [
                    ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image(
                          image: AssetImage(
                            "assets/skin_${wallet['skin_index'] ?? 1}.png",
                          ),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(wallet['wallet_name']),
                      trailing: Text(
                        currencyFormatter.format(
                          double.tryParse(wallet['balance'].toString()) ?? 0,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    const Divider(height: 1),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartCard extends StatelessWidget {
  final Widget child;
  const ChartCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFFF6F5F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: SizedBox(
        height: 200,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}

class TextSection extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback? onAction;

  const TextSection({
    super.key,
    required this.title,
    required this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }
}

class TransactionCard extends StatefulWidget {
  const TransactionCard({super.key});

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  bool _loading = true;
  List<dynamic> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchRecentTransactions();
  }

  Future<void> _fetchRecentTransactions() async {
    try {
      final txs = await TransactionService.getTransactions();
      txs.sort(
        (a, b) => DateTime.parse(
          b['transaction_date'],
        ).compareTo(DateTime.parse(a['transaction_date'])),
      );
      if (!mounted) return;
      setState(() {
        _transactions = txs.take(5).toList(); 
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_transactions.isEmpty) {
      return const Center(child: Text("Chưa có giao dịch nào"));
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return Card(
      color: const Color(0xFFF6F5F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        children: _transactions.map((tx) {
          final isIncome = tx['category']['type'] == 'thu';
          final amount = double.tryParse(tx['amount'].toString()) ?? 0;

          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: isIncome
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  child: Icon(
                    categoryIcons[tx['category']['category_name']] ??
                        Icons.category,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(tx['category']['category_name']),
                subtitle: Text(
                  DateFormat(
                    "dd/MM/yyyy",
                  ).format(DateTime.parse(tx['transaction_date'])),
                ),
                trailing: Text(
                  "${isIncome ? '+' : '-'}${currencyFormatter.format(amount)}",
                  style: TextStyle(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class MonthlyLineChart extends StatelessWidget {
  final List<FlSpot> incomeSpots;
  final List<FlSpot> expenseSpots;

  const MonthlyLineChart({
    super.key,
    required this.incomeSpots,
    required this.expenseSpots,
  });

  @override
  Widget build(BuildContext context) {
    final allValues = [
      ...incomeSpots,
      ...expenseSpots,
    ].map((e) => e.y).toList();
    final double maxY = allValues.isNotEmpty
        ? (allValues.reduce(math.max) * 1.2)
        : 1000;

    final daysInMonth = DateUtils.getDaysInMonth(
      DateTime.now().year,
      DateTime.now().month,
    );

    return Column(
      children: [
        Expanded(
          child: SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: daysInMonth.toDouble(),
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text("0");
                        if (value >= 1000) {
                          return Text(
                            "${(value / 1000).round()}k",
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          "${value.toInt()}",
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: incomeSpots,
                    isCurved: true,
                    curveSmoothness: 0.01,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    gradient: const LinearGradient(
                      colors: [Colors.green, Colors.lightGreen],
                    ),
                  ),
                  LineChartBarData(
                    spots: expenseSpots,
                    isCurved: true,
                    curveSmoothness: 0.01,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    gradient: const LinearGradient(
                      colors: [Colors.red, Colors.orange],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _LegendItem(color: Colors.green, text: "Thu nhập"),
            SizedBox(width: 8),
            _LegendItem(color: Colors.red, text: "Chi tiêu"),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class IncomeExpensePieChart extends StatelessWidget {
  final double income;
  final double expense;

  const IncomeExpensePieChart({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final total = income + expense;

    if (total == 0) {
      return const Center(
        child: Text(
          "Chưa có dữ liệu giao dịch",
          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        ),
      );
    }

    final incomePercent = income / total * 100.0;
    final expensePercent = expense / total * 100.0;

    return Row(
      children: [
        // Chart bên trái
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              borderData: FlBorderData(show: false),
              sections: [
                PieChartSectionData(
                  value: income,
                  color: Colors.green,
                  title: "${incomePercent.toStringAsFixed(0)}%",
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: expense,
                  color: Colors.red,
                  title: "${expensePercent.toStringAsFixed(0)}%",
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Legend bên phải
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLegendItem(Colors.green, "Thu nhập"),
            const SizedBox(height: 8),
            _buildLegendItem(Colors.red, "Chi tiêu"),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
