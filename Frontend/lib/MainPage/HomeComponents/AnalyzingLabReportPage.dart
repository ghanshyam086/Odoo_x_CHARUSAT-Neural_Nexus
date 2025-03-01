// lib/analyzinglabreport.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class AnalyzingLabReportPage extends StatefulWidget {
  const AnalyzingLabReportPage({super.key});

  @override
  _AnalyzingLabReportPageState createState() => _AnalyzingLabReportPageState();
}

class _AnalyzingLabReportPageState extends State<AnalyzingLabReportPage> {
  List<dynamic> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final response = await http.get(Uri.parse('http://172.16.218.120:3000/api/blood-reports/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          reports = (data['data'] as List).toList()
            ..sort((a, b) => DateTime.parse(a['createdAt']).compareTo(DateTime.parse(b['createdAt'])));
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load reports');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching reports: $e', style: const TextStyle(fontSize: 14))),
      );
    }
  }

  List<FlSpot> _getSpots(String field) {
    return reports.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value[field];
      final date = DateTime.parse(entry.value['createdAt']);
      return FlSpot(date.millisecondsSinceEpoch.toDouble(), value is num ? value.toDouble() : 0.0);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lab Report Analysis", style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03), // Reduced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Lab Report Analytics",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04, // Reduced from 0.05
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01), // Reduced height
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (reports.isEmpty)
                Center(
                  child: Text(
                    "No lab reports available for analysis",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.035, // Reduced from 0.045
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    _buildChart(context, "Hemoglobin (g/dL)", _getSpots('Hemoglobin')),
                    _buildChart(context, "RBC Count (million/µL)", _getSpots('RBC_Count')),
                    _buildChart(context, "WBC Count (/µL)", _getSpots('WBC_Count')),
                    _buildChart(context, "Platelet Count (/µL)", _getSpots('Platelet_Count')),
                    _buildChart(context, "Hematocrit (%)", _getSpots('Hematocrit')),
                    _buildChart(context, "MCV (fL)", _getSpots('MCV')),
                    _buildChart(context, "MCH (pg)", _getSpots('MCH')),
                    _buildChart(context, "MCHC (%)", _getSpots('MCHC')),
                    _buildChart(context, "ESR (mm/hr)", _getSpots('ESR')),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.015), // Reduced height
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context, String title, List<FlSpot> spots) {
    return Card(
      elevation: 2, // Reduced elevation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Slightly smaller radius
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.01), // Reduced margin
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.035, // Reduced from 0.045
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01), // Reduced height
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15, // Reduced height from 0.2
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  minX: spots.isNotEmpty ? spots.first.x : 0,
                  maxX: spots.isNotEmpty ? spots.last.x : 1,
                  minY: 0,
                  maxY: spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue.shade800,
                      dotData: FlDotData(show: false), // Removed dots to reduce complexity
                      belowBarData: BarAreaData(show: false), // Removed filled area
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
}