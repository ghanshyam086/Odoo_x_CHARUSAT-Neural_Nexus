import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'AnalyzingLabReportPage.dart';

class LabReportPage extends StatefulWidget {
  const LabReportPage({super.key});

  @override
  _LabReportPageState createState() => _LabReportPageState();
}

class _LabReportPageState extends State<LabReportPage> {
  List<dynamic> reports = [];
  bool isLoading = true;
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  // Fetch all reports from the API
  Future<void> _fetchReports() async {
    try {
      final response = await http.get(Uri.parse('http://172.16.218.120:3000/api/blood-reports/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          reports = data['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load reports');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Error fetching reports: $e')),
      );
    }
  }

  // Add a new report via API
  Future<void> _addReport(Map<String, dynamic> reportData) async {
    try {
      final response = await http.post(
        Uri.parse('http://172.16.218.120:3000/api/blood-reports/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reportData),
      );
      if (response.statusCode == 201) {
        _fetchReports(); // Refresh the list after adding
      } else {
        throw Exception('Failed to add report');
      }
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Error adding report: $e')),
      );
    }
  }

  void _showAddReportDialog() {
    final formKey = GlobalKey<FormState>();
    final reportIdController = TextEditingController();
    final userIdController = TextEditingController();
    final bloodGroupController = TextEditingController();
    final hemoglobinController = TextEditingController();
    final rbcCountController = TextEditingController();
    final wbcCountController = TextEditingController();
    final plateletCountController = TextEditingController();
    final hematocritController = TextEditingController();
    final mcvController = TextEditingController();
    final mchController = TextEditingController();
    final mchcController = TextEditingController();
    final esrController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Add Blood Report"),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: reportIdController,
                    decoration: const InputDecoration(labelText: "Report ID"),
                    validator: (value) => value!.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: userIdController,
                    decoration: const InputDecoration(labelText: "User ID"),
                    validator: (value) => value!.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: bloodGroupController,
                    decoration: const InputDecoration(labelText: "Blood Group"),
                    validator: (value) => value!.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: hemoglobinController,
                    decoration: const InputDecoration(labelText: "Hemoglobin"),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: rbcCountController,
                    decoration: const InputDecoration(labelText: "RBC Count"),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: wbcCountController,
                    decoration: const InputDecoration(labelText: "WBC Count"),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: plateletCountController,
                    decoration: const InputDecoration(labelText: "Platelet Count"),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: hematocritController,
                    decoration: const InputDecoration(labelText: "Hematocrit"),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: mcvController,
                    decoration: const InputDecoration(labelText: "MCV"),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: mchController,
                    decoration: const InputDecoration(labelText: "MCH"),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: mchcController,
                    decoration: const InputDecoration(labelText: "MCHC"),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: esrController,
                    decoration: const InputDecoration(labelText: "ESR"),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? "Required" : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final reportData = {
                    "ReportId": reportIdController.text,
                    "UserId": userIdController.text,
                    "BloodGroup": bloodGroupController.text,
                    "Hemoglobin": double.parse(hemoglobinController.text),
                    "RBC_Count": double.parse(rbcCountController.text),
                    "WBC_Count": int.parse(wbcCountController.text),
                    "Platelet_Count": int.parse(plateletCountController.text),
                    "Hematocrit": double.parse(hematocritController.text),
                    "MCV": double.parse(mcvController.text),
                    "MCH": double.parse(mchController.text),
                    "MCHC": double.parse(mchcController.text),
                    "ESR": int.parse(esrController.text),
                    "createdAt": DateTime.now().toIso8601String(),
                  };
                  _addReport(reportData);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
              ),
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Lab Reports"),
          backgroundColor: Colors.blue.shade800,
          actions: [
            IconButton(
              icon: const Icon(Icons.analytics, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnalyzingLabReportPage(),
                  ),
                );
              },
              tooltip: "Analyze Reports",
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Lab Reports",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (reports.isEmpty)
                  Center(
                    child: Text(
                      "No lab reports yet",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        color: Colors.grey,
                      ),
                    ),
                  )
                else
                  Column(
                    children: reports.map((report) => LabReportCard(report: report)).toList(),
                  ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                ElevatedButton.icon(
                  onPressed: _showAddReportDialog,
                  icon: Icon(Icons.add, size: MediaQuery.of(context).size.width * 0.06),
                  label: Text(
                    "Add Blood Report",
                    style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.045),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                      vertical: MediaQuery.of(context).size.height * 0.015,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LabReportCard extends StatelessWidget {
  final dynamic report;

  const LabReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(report['createdAt']);
    final formattedDate = "${_getMonthName(date.month)} ${date.day}, ${date.year}";

    return Card(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.015),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(
          Icons.assignment,
          size: MediaQuery.of(context).size.width * 0.07,
          color: Colors.blue.shade800,
        ),
        title: Text(
          "Blood Report (${report['ReportId']})",
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "Date: $formattedDate\nBlood Group: ${report['BloodGroup']}",
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
        ),
        trailing: Text(
          "Completed", // Since our API doesn't track status, assuming completed
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.04,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          if (context.mounted) { // Ensure context is valid
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BloodReportDetailPage(report: report),
              ),
            );
          }
        },
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }
}

class BloodReportDetailPage extends StatelessWidget {
  final dynamic report;

  const BloodReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(report['createdAt']);
    final formattedDate = "${_getMonthName(date.month)} ${date.day}, ${date.year}";

    return Scaffold(
      appBar: AppBar(
        title: Text("Blood Report Details (${report['ReportId']})"),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Report Details",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              _buildDetailRow(context, "Report ID", report['ReportId'].toString()),
              _buildDetailRow(context, "User ID", report['UserId'].toString()),
              _buildDetailRow(context, "Blood Group", report['BloodGroup'].toString()),
              _buildDetailRow(context, "Hemoglobin", "${report['Hemoglobin']} g/dL"),
              _buildDetailRow(context, "RBC Count", "${report['RBC_Count']} million/µL"),
              _buildDetailRow(context, "WBC Count", "${report['WBC_Count']} /µL"),
              _buildDetailRow(context, "Platelet Count", "${report['Platelet_Count']} /µL"),
              _buildDetailRow(context, "Hematocrit", "${report['Hematocrit']}%"),
              _buildDetailRow(context, "MCV", "${report['MCV']} fL"),
              _buildDetailRow(context, "MCH", "${report['MCH']} pg"),
              _buildDetailRow(context, "MCHC", "${report['MCHC']}%"),
              _buildDetailRow(context, "ESR", "${report['ESR']} mm/hr"),
              _buildDetailRow(context, "Date", formattedDate),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.045,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }
}