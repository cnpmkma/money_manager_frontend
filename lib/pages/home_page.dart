import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:money_manager_frontend/pages/wallet_page.dart';
import 'package:money_manager_frontend/services/wallet_service.dart';
import 'package:money_manager_frontend/widgets/gradient_scaffold.dart';

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

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Color(0xFFF6F5F2),
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
                  onPressed: () => setState(() => _showBalance = !_showBalance),
                ),
                subtitle: const Text("Tổng số dư"),
              ),
            ),
            const SizedBox(height: 16),
            WalletCard(
              wallets: _wallets,
              totalBalance: totalBalance,
              showBalance: _showBalance,
              toggleBalance: () => setState(() => _showBalance = !_showBalance),
              onViewAll: widget.onViewAllWallets,
              refreshWallets: _fetchWallets,
            ),
            const SizedBox(height: 20),
            const TextSection(
              title: "Báo cáo tháng này",
              actionText: "Xem báo cáo",
            ),
            const SizedBox(height: 8),
            const ChartCard(child: PieChartSample2()),
            const SizedBox(height: 16),
            const ChartCard(child: SpendingLineChart()),
            const SizedBox(height: 20),
            const TextSection(
              title: "Giao dịch gần đây",
              actionText: "Xem tất cả",
            ),
            const SizedBox(height: 8),
            const TransactionCard(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text("Tổng quan"),
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
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  const TransactionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFFF6F5F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        children: const [
          ListTile(
            leading: Icon(Icons.shopping_cart, color: Colors.red),
            title: Text("Mua sắm siêu thị"),
            subtitle: Text("8/9/2025"),
            trailing: Text("-\$45.90", style: TextStyle(color: Colors.red)),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.work, color: Colors.green),
            title: Text("Lương tháng 9"),
            subtitle: Text("6/9/2025"),
            trailing: Text("+\$2000.00", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}

class SpendingLineChart extends StatelessWidget {
  const SpendingLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1000,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        "${value ~/ 1000}k",
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 1:
                          return const Text("Jan");
                        case 2:
                          return const Text("Feb");
                        case 3:
                          return const Text("Mar");
                        case 4:
                          return const Text("Apr");
                        default:
                          return const Text("");
                      }
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
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey),
              ),
              minX: 0,
              maxX: 4,
              minY: 0,
              maxY: 5000,
              lineBarsData: [
                // Thu nhập (Income)
                LineChartBarData(
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  spots: const [
                    FlSpot(1, 3000),
                    FlSpot(2, 3500),
                    FlSpot(3, 2800),
                    FlSpot(4, 4000),
                  ],
                  dotData: const FlDotData(show: true),
                ),
                // Chi tiêu (Expense)
                LineChartBarData(
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  spots: const [
                    FlSpot(1, 1200),
                    FlSpot(2, 2500),
                    FlSpot(3, 1800),
                    FlSpot(4, 3000),
                  ],
                  dotData: const FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.circle, size: 10, color: Colors.green),
            SizedBox(width: 4),
            Text("Thu nhập"),
            SizedBox(width: 16),
            Icon(Icons.circle, size: 10, color: Colors.red),
            SizedBox(width: 4),
            Text("Chi tiêu"),
          ],
        ),
      ],
    );
  }
}

class AppColors {
  static const contentColorBlue = Colors.blue;
  static const contentColorYellow = Colors.yellow;
  static const contentColorPurple = Colors.purple;
  static const contentColorGreen = Colors.green;
  static const mainTextColor1 = Colors.white;
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;

  const Indicator({
    super.key,
    required this.color,
    required this.text,
    this.isSquare = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class PieChartSample2 extends StatefulWidget {
  const PieChartSample2({super.key});

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartSample2> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: <Widget>[
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Legend
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Indicator(color: Colors.green, text: 'Thu nhập', isSquare: true),
              SizedBox(height: 8),
              Indicator(color: Colors.red, text: 'Chi tiêu', isSquare: true),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    final isTouchedIncome = touchedIndex == 0;
    final isTouchedExpense = touchedIndex == 1;

    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

    return [
      // Thu nhập
      PieChartSectionData(
        color: Colors.green,
        value: 65,
        title: '65%',
        radius: isTouchedIncome ? 60.0 : 50.0,
        titleStyle: TextStyle(
          fontSize: isTouchedIncome ? 22.0 : 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      ),
      // Chi tiêu
      PieChartSectionData(
        color: Colors.red,
        value: 35,
        title: '35%',
        radius: isTouchedExpense ? 60.0 : 50.0,
        titleStyle: TextStyle(
          fontSize: isTouchedExpense ? 22.0 : 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      ),
    ];
  }
}
