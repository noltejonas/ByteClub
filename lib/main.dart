import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (context) => CompanyModel(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'St. Galler Management Model App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var companyModel = Provider.of<CompanyModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('St. Galler Management Model'),
        backgroundColor: Colors.indigo[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children:
                    companyModel.areas.map((area) {
                      return Card(
                        elevation: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              area.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Impact: ${area.impact.toStringAsFixed(2)}%',
                              style: TextStyle(fontSize: 14),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Open details page or perform action
                              },
                              child: Text('Details'),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            companyModel.areas[value.toInt()].name,
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups:
                      companyModel.areas.map((area) {
                        return BarChartGroupData(
                          x: companyModel.areas.indexOf(area),
                          barRods: [
                            BarChartRodData(
                              toY: area.impact,
                              color: area.color,
                              width: 20,
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String recommendation = companyModel.getRecommendation();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Strategic Recommendation'),
                      content: Text(recommendation),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Get Strategic Recommendation'),
            ),
          ],
        ),
      ),
    );
  }
}

class CompanyModel extends ChangeNotifier {
  List<CompanyArea> areas = [
    CompanyArea(name: 'Strategie', color: Colors.indigo, impact: 0.0),
    CompanyArea(name: 'Struktur', color: Colors.redAccent, impact: 0.0),
    CompanyArea(name: 'Kultur', color: Colors.greenAccent, impact: 0.0),
    CompanyArea(name: 'Prozesse', color: Colors.blueAccent, impact: 0.0),
    CompanyArea(name: 'Umwelt', color: Colors.orangeAccent, impact: 0.0),
  ];

  void updateArea(String areaName, double impactChange) {
    var area = areas.firstWhere((area) => area.name == areaName);
    area.impact += impactChange;
    notifyListeners();
  }

  String getRecommendation() {
    var highestImpactArea = areas.reduce((a, b) => a.impact > b.impact ? a : b);
    return 'Focus on ${highestImpactArea.name} for strategic improvement.';
  }
}

class CompanyArea {
  String name;
  Color color;
  double impact;

  CompanyArea({required this.name, required this.color, this.impact = 0.0});
}
