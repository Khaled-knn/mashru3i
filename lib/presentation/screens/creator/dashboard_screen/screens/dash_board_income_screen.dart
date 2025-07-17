import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mashrou3i/core/theme/color.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../logic/dashboard_cibit.dart';

class DashBoardIncomeScreen extends StatefulWidget {
  @override
  _DashBoardIncomeScreenState createState() => _DashBoardIncomeScreenState();
}

class _DashBoardIncomeScreenState extends State<DashBoardIncomeScreen> {
  String selectedPeriod = 'Month';
  String selectedMonth = DateTime.now().month.toMonthAbbreviation();

  @override
  void initState() {
    super.initState();
    final cubit = BlocProvider.of<DashBoardCubit>(context);
    cubit.getProfileData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cubit = context.read<DashBoardCubit>();
    final currentIncome = cubit.creatorProfile?.income ?? 0.0;
    final now = DateTime.now();
    final last6MonthsData = List.generate(6, (index) {
      final month = now.subtract(Duration(days: 30 * (5 - index))).month;
      return IncomeData(
        month: month.toMonthAbbreviation(),
        income: currentIncome,
      );
    });

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Income Overview'.tr(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              // Current income amount
              Text(
                'Current ${selectedPeriod.toLowerCase()}'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${NumberFormat.currency(symbol: '\$ ').format(currentIncome)}'.tr(),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              SizedBox(height: 24),

              // Time period selector
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['Day', 'Week', 'Month', 'Year'].map((period) {
                    bool isSelected = selectedPeriod == period;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPeriod = period;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          period.tr(),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.black
                                : theme.colorScheme.onBackground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 24),

              // Chart container
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Income Trend'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Last 6 months'.tr(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(
                            labelStyle: TextStyle(
                              color: isDarkMode ? Colors.white70 : Colors.grey[700],
                            ),
                          ),
                          primaryYAxis: NumericAxis(
                            labelStyle: TextStyle(
                              color: isDarkMode ? Colors.white70 : Colors.grey[700],
                            ),
                            numberFormat: NumberFormat.currency(
                              symbol: '\$ ',
                              decimalDigits: 0,
                            ),
                          ),
                          series: <CartesianSeries<dynamic, dynamic>>[
                            ColumnSeries<IncomeData, String>(
                              dataSource: last6MonthsData,
                              xValueMapper: (IncomeData data, _) => data.month,
                              yValueMapper: (IncomeData data, _) => data.income,
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                              animationDuration: 2000,
                              animationDelay: 500,
                            ),
                          ],
                          tooltipBehavior: TooltipBehavior(
                            enable: true,
                            format: 'point.x: \$ point.y',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IncomeData {
  final String month;
  final double income;

  IncomeData({required this.month, required this.income});
}

extension MonthExtension on int {
  String toMonthAbbreviation() {
    switch (this) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '';
    }
  }
}