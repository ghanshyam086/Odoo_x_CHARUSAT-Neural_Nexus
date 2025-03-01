import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIChatbotPage extends StatefulWidget {
  const AIChatbotPage({super.key});

  @override
  _AIChatbotPageState createState() => _AIChatbotPageState();
}

class _AIChatbotPageState extends State<AIChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  String _selectedChatType = 'General'; // Default chat type
  String? _selectedIssue; // Selected issue
  bool _isLoading = false; // Track loading state

  // Comprehensive list of physical and mental health issues
  final List<String> _physicalIssues = [
    "Back Pain",
    "Joint Pain",
    "Muscle Strain",
    "Obesity",
    "Diabetes",
    "Hypertension",
    "Asthma",
    "Cold",
    "Fever",
    "Headache",
    "Flu",
    "Cough",
    "Stomach Ache",
    "Allergies",
    "Fatigue",
    "Dizziness",
    "Arthritis",
    "Heart Disease",
    "Chronic Pain",
    "Injury Recovery",
  ];

  final List<String> _mentalIssues = [
    "Anxiety",
    "Depression",
    "Stress",
    "Insomnia",
    "Burnout",
    "Panic Attacks",
    "Mood Swings",
    "Irritability",
    "Low Self-Esteem",
    "Phobias",
    "Trauma",
    "Eating Disorders",
    "Addiction",
    "OCD",
    "PTSD",
  ];

  // Separate message lists for each chat type
  final List<Map<String, String>> _physicalMessages = [];
  final List<Map<String, String>> _mentalMessages = [];
  final List<Map<String, String>> _generalMessages = [];

  List<Map<String, String>> get _currentMessages {
    switch (_selectedChatType) {
      case 'Physical':
        return _physicalMessages;
      case 'Mental':
        return _mentalMessages;
      default:
        return _generalMessages;
    }
  }

  Future<void> _getBotResponse(String message) async {
    try {
      setState(() => _isLoading = true); // Show loading indicator
      const apiKey = 'AIzaSyCeVAcIB9H0WtOW6oNNRH7f1NQdjXBgc74';
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
      );

      // Prefix the message based on the selected chat type and issue
      String prefixedMessage;
      switch (_selectedChatType) {
        case 'Physical':
          prefixedMessage =
          "Focus on physical health - ${_selectedIssue ?? 'General'}: $message";
          break;
        case 'Mental':
          prefixedMessage =
          "Focus on mental health - ${_selectedIssue ?? 'General'}: $message";
          break;
        default:
          prefixedMessage = message; // General chat with no prefix
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{
            'parts': [{'text': prefixedMessage}]
          }]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = _extractResponse(data) ?? 'Could not understand response';
        setState(() {
          _currentMessages.add({"bot": botResponse});
          _isLoading = false; // Hide loading indicator
        });
      } else {
        setState(() {
          _currentMessages.add({"bot": 'Error: API request failed (${response.statusCode})'});
          _isLoading = false; // Hide loading indicator on error
        });
      }
    } catch (e) {
      setState(() {
        _currentMessages.add({"bot": 'Error: ${e.toString()}'});
        _isLoading = false; // Hide loading indicator on error
      });
    }
  }

  String? _extractResponse(Map<String, dynamic> data) {
    try {
      return data['candidates']?[0]['content']['parts']?[0]['text'] as String?;
    } catch (e) {
      return null;
    }
  }

  void _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    _controller.clear();
    setState(() => _currentMessages.add({"user": message}));

    await _getBotResponse(message);
  }

  void _sendMessageWithPredefinedQuery(String issue) async {
    final predefinedQuery = "Provide advice for $issue.";
    setState(() => _currentMessages.add({"user": predefinedQuery})); // Show issue as user input
    await _getBotResponse(predefinedQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Chatbot',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade900,
        elevation: 2,

      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Chat Type Selection (Three Buttons)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildChatOption('Physical', 'Physical Chat'),
                        const SizedBox(width: 8),
                        _buildChatOption('Mental', 'Mental Chat'),
                        const SizedBox(width: 8),
                        _buildChatOption('General', 'General Chat'),
                      ],
                    ),
                  ),
                ),
              ),
              // Issue Selection Dropdown (Only for Physical/Mental)
              if (_selectedChatType != 'General')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DropdownButton<String>(
                      value: _selectedIssue,
                      hint: Text(
                        'Select a ${_selectedChatType.toLowerCase()} issue',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedIssue = newValue;
                          if (newValue != null) {
                            _sendMessageWithPredefinedQuery(newValue);
                          }
                        });
                      },
                      items: (_selectedChatType == 'Physical'
                          ? _physicalIssues
                          : _mentalIssues)
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      underline: Container(),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              // Chat Messages with Loading Indicator on AI Bot Side
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _currentMessages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isLoading && index == _currentMessages.length) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(14),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'AI Bot: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontSize: 12,
                                ),
                              ),
                              CircularProgressIndicator(
                                color: Colors.blue.shade800,
                                strokeWidth: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final entry = _currentMessages[index];
                    final isUser = entry.containsKey("user");

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(14),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue.shade800 : Colors.blue.shade800,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUser ? "You:" : "AI Bot:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.values.first,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Input Field (No Loading Indicator Here)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Type your message...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _sendMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.send, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Send',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatOption(String type, String label) {
    return ElevatedButton(
      onPressed: () => setState(() {
        _selectedChatType = type;
        _selectedIssue = null; // Reset issue selection when chat type changes
      }),
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedChatType == type
            ? Colors.blue.shade900
            : Colors.grey.shade300,
        foregroundColor: _selectedChatType == type
            ? Colors.white
            : Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: _selectedChatType == type ? 4 : 0,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: _selectedChatType == type ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}