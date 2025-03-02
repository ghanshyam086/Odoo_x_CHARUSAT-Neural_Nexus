import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import '../../PortSection/ConfigFile.dart';

class AnalyzingLabReportPage extends StatefulWidget {
  final String userId;
  const AnalyzingLabReportPage({super.key, required this.userId});

  @override
  _AnalyzingLabReportPageState createState() => _AnalyzingLabReportPageState();
}

class _AnalyzingLabReportPageState extends State<AnalyzingLabReportPage> {
  List<dynamic> reports = [];
  bool isLoading = true;
  Map<String, String> predictions = {};
  List<String> precautions = [];

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final response = await http.get(Uri.parse('$getBloodReports${widget.userId}'));
      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body);
        setState(() {
          reports = (rawData is List ? rawData : rawData['data'] as List? ?? []).toList()
            ..sort((a, b) {
              final aDate = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.now();
              final bDate = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.now();
              return aDate.compareTo(bDate);
            });
          isLoading = false;
          _analyzeReports();
        });
      } else {
        throw Exception('Failed to load reports: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching reports: $e', style: const TextStyle(fontSize: 14))),
      );
    }
  }

  void _analyzeReports() {
    if (reports.isEmpty) return;

    final latestReport = reports.last;
    predictions.clear();
    precautions.clear();

    // Reference ranges (example for adult males; adjust for gender/age)
    const ranges = {
      'Hemoglobin': {'min': 13.8, 'max': 17.2}, // Men; women: 12.1-15.1
      'RBC_Count': {'min': 4.5, 'max': 5.9},
      'WBC_Count': {'min': 4000, 'max': 11000},
      'Platelet_Count': {'min': 150000, 'max': 450000},
      'Hematocrit': {'min': 40, 'max': 50}, // Men; women: 36-46
      'MCV': {'min': 80, 'max': 100},
      'MCH': {'min': 27, 'max': 34},
      'MCHC': {'min': 32, 'max': 36},
      'ESR': {'min': 0, 'max': 20},
    };

    ranges.forEach((key, range) {
      final value = latestReport[key] as num?;
      if (value != null) {
        if (value < range['min']!) {
          predictions[key] = 'Low ($value < ${range['min']})';
          _addPrecaution(key, 'low');
        } else if (value > range['max']!) {
          predictions[key] = 'High ($value > ${range['max']})';
          _addPrecaution(key, 'high');
        } else {
          predictions[key] = 'Normal';
        }
      } else {
        predictions[key] = 'Data missing';
      }
    });

    if (predictions['Hemoglobin']!.startsWith('Low') &&
        predictions['RBC_Count']!.startsWith('Low') &&
        predictions['Hematocrit']!.startsWith('Low')) {
      final mcv = latestReport['MCV'] as num?;
      if (mcv != null) {
        if (mcv < 80) {
          predictions['Condition'] = 'Microcytic Anemia';
          precautions.add('Possible iron deficiency. Increase iron-rich foods (e.g., spinach, red meat) and consult a doctor for iron studies.');
        } else if (mcv > 100) {
          predictions['Condition'] = 'Macrocytic Anemia';
          precautions.add('Possible B12/folate deficiency. Consider supplements and medical evaluation.');
        } else {
          predictions['Condition'] = 'Normocytic Anemia';
          precautions.add('Could be chronic disease-related. Seek medical advice for further tests (e.g., CRP, ferritin).');
        }
      }
    }
    if (predictions['WBC_Count']!.startsWith('High') || predictions['ESR']!.startsWith('High')) {
      predictions['Inflammation'] = 'Possible infection or inflammation';
      precautions.add('Monitor symptoms (fever, fatigue) and consult a doctor to check for infection or autoimmune issues.');
    }
  }

  void _addPrecaution(String key, String status) {
    switch (key) {
      case 'Hemoglobin':
        if (status == 'low') precautions.add('Low hemoglobin: Avoid strenuous activity; increase iron intake.');
        if (status == 'high') precautions.add('High hemoglobin: Stay hydrated; consult a doctor for polycythemia check.');
        break;
      case 'WBC_Count':
        if (status == 'high') precautions.add('High WBC: Rest and hydrate; see a doctor if fever persists.');
        if (status == 'low') precautions.add('Low WBC: Avoid infections; consult a doctor for immune evaluation.');
        break;
      case 'Platelet_Count':
        if (status == 'low') precautions.add('Low platelets: Avoid injury; seek medical advice for bleeding risk.');
        if (status == 'high') precautions.add('High platelets: Monitor for clotting risks; consult a doctor.');
        break;
      case 'ESR':
        if (status == 'high') precautions.add('High ESR: Investigate inflammation source with a healthcare provider.');
        break;
    }
  }

  List<FlSpot> _getSpots(String field) {
    return reports.asMap().entries.map((entry) {
      final dateStr = entry.value['createdAt'] as String?;
      final date = dateStr != null ? DateTime.tryParse(dateStr) ?? DateTime.now() : DateTime.now();
      final value = entry.value[field] as num? ?? 0.0;
      return FlSpot(date.millisecondsSinceEpoch.toDouble(), value.toDouble());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lab Report Analysis", style: TextStyle(fontSize: 16, color: Colors.white)),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Lab Report Analytics",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (reports.isEmpty)
                Center(
                  child: Text(
                    "No lab reports available for analysis",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChartSection(context),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    _buildPredictionsSection(context),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    _buildPrecautionsSection(context),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Trends Over Time",
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        _buildChart(context, "Hemoglobin (g/dL)", _getSpots('Hemoglobin'), 13.8, 17.2),
        _buildChart(context, "RBC Count (million/µL)", _getSpots('RBC_Count'), 4.5, 5.9),
        _buildChart(context, "WBC Count (/µL)", _getSpots('WBC_Count'), 4000, 11000),
        _buildChart(context, "Platelet Count (/µL)", _getSpots('Platelet_Count'), 150000, 450000),
        _buildChart(context, "Hematocrit (%)", _getSpots('Hematocrit'), 40, 50),
        _buildChart(context, "MCV (fL)", _getSpots('MCV'), 80, 100),
        _buildChart(context, "MCH (pg)", _getSpots('MCH'), 27, 34),
        _buildChart(context, "MCHC (%)", _getSpots('MCHC'), 32, 36),
        _buildChart(context, "ESR (mm/hr)", _getSpots('ESR'), 0, 20),
      ],
    );
  }

  Widget _buildChart(BuildContext context, String title, List<FlSpot> spots, double minRange, double maxRange) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.01),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(show: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: spots.isNotEmpty && spots.length > 1 ? (spots.last.x - spots.first.x) / 5 : null,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                          return Text('${date.day}/${date.month}', style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: spots.isNotEmpty ? spots.first.x : 0,
                  maxX: spots.isNotEmpty ? spots.last.x : 1,
                  minY: 0,
                  maxY: spots.isNotEmpty
                      ? (spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.2).clamp(minRange, maxRange * 1.2)
                      : maxRange * 1.2,
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(y: minRange, color: Colors.green, strokeWidth: 1, dashArray: [5, 5]),
                      HorizontalLine(y: maxRange, color: Colors.green, strokeWidth: 1, dashArray: [5, 5]),
                    ],
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue.shade800,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionsSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Predictions",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            ...predictions.entries.map(
                  (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Text(entry.value)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrecautionsSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Precautions",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            if (precautions.isEmpty)
              const Text("No specific precautions needed based on current data.")
            else
              ...precautions.map(
                    (precaution) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• ", style: TextStyle(fontSize: 16)),
                      Expanded(child: Text(precaution)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}   