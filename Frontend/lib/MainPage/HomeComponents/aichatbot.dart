import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AIChatbotPage extends StatefulWidget {
  const AIChatbotPage({super.key});

  @override
  _AIChatbotPageState createState() => _AIChatbotPageState();
}

class _AIChatbotPageState extends State<AIChatbotPage> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  String _selectedChatType = 'General';
  String? _selectedIssue;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _physicalIssues = [
    "Back Pain", "Joint Pain", "Muscle Strain", "Obesity", "Diabetes", "Hypertension",
    "Asthma", "Cold", "Fever", "Headache", "Flu", "Cough", "Stomach Ache", "Allergies",
    "Fatigue", "Dizziness", "Arthritis", "Heart Disease", "Chronic Pain", "Injury Recovery",
  ];

  final List<String> _mentalIssues = [
    "Anxiety", "Depression", "Stress", "Insomnia", "Burnout", "Panic Attacks",
    "Mood Swings", "Irritability", "Low Self-Esteem", "Phobias", "Trauma",
    "Eating Disorders", "Addiction", "OCD", "PTSD",
  ];

  final List<Map<String, dynamic>> _physicalMessages = []; // Changed to dynamic for RichText
  final List<Map<String, dynamic>> _mentalMessages = [];
  final List<Map<String, dynamic>> _generalMessages = [];

  List<Map<String, dynamic>> get _currentMessages {
    switch (_selectedChatType) {
      case 'Physical': return _physicalMessages;
      case 'Mental': return _mentalMessages;
      default: return _generalMessages;
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _getBotResponse(String message) async {
    setState(() => _isLoading = true);
    const apiKey = 'AIzaSyCeVAcIB9H0WtOW6oNNRH7f1NQdjXBgc74';
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    // Enhanced prompt for useful, concise content with bold formatting
    String prefixedMessage = _selectedChatType == 'General'
        ? "Provide a concise, useful response to: $message. Use **bold** for key terms."
        : "Focus on ${_selectedChatType.toLowerCase()} health - ${_selectedIssue ?? 'General'}: $message. Provide practical, concise advice and use **bold** for key terms.";

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prefixedMessage}]}],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = _extractResponse(data) ?? 'Sorry, I couldn’t process that.';
        setState(() {
          _currentMessages.add({"bot": _parseMarkdownToRichText(botResponse)});
          _isLoading = false;
        });
      } else {
        throw Exception('API failed with status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        _currentMessages.add({"bot": _parseMarkdownToRichText('Oops! Something went wrong: $e')});
        _isLoading = false;
      });
    }
  }

  // Parse markdown (**text**) to RichText with bold formatting
  Widget _parseMarkdownToRichText(String text) {
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    List<TextSpan> spans = [];
    int lastEnd = 0;

    for (Match match in boldPattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1), // Text inside ** **
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: const TextStyle(color: Colors.white, fontSize: 16), // Medium size
      ),
    );
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

  void _sendPredefinedQuery(String issue) async {
    final query = "Provide advice for $issue.";
    setState(() => _currentMessages.add({"user": query}));
    await _getBotResponse(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Health Companion',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.purple.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.purple.shade100, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildChatButton('Physical', Icons.fitness_center),
                    _buildChatButton('Mental', Icons.psychology),
                    _buildChatButton('General', Icons.chat),
                  ],
                ),
              ),
              if (_selectedChatType != 'General')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: _buildIssueDropdown(),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _currentMessages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isLoading && index == _currentMessages.length) {
                      return _buildLoadingBubble();
                    }
                    final entry = _currentMessages[index];
                    final isUser = entry.containsKey("user");
                    return _buildMessageBubble(entry, isUser);
                  },
                ),
              ),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatButton(String type, IconData icon) {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedChatType = type;
        _selectedIssue = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _selectedChatType == type
                ? [Colors.blue.shade700, Colors.purple.shade600]
                : [Colors.grey.shade200, Colors.grey.shade300],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (_selectedChatType == type)
              BoxShadow(
                color: Colors.blue.shade900.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: _selectedChatType == type ? Colors.white : Colors.black87, size: 20),
            const SizedBox(width: 8),
            Text(
              type,
              style: TextStyle(
                color: _selectedChatType == type ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: _selectedIssue,
        hint: Text('Pick a ${_selectedChatType.toLowerCase()} issue'),
        onChanged: (String? value) {
          setState(() {
            _selectedIssue = value;
            if (value != null) _sendPredefinedQuery(value);
          });
        },
        items: (_selectedChatType == 'Physical' ? _physicalIssues : _mentalIssues)
            .map((issue) => DropdownMenuItem<String>(
          value: issue,
          child: Text(issue, style: const TextStyle(fontSize: 14)),
        ))
            .toList(),
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.blue),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> entry, bool isUser) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isUser
                  ? [Colors.blue.shade600, Colors.blue.shade800]
                  : [Colors.purple.shade600, Colors.purple.shade800],
            ),
            borderRadius: BorderRadius.circular(20).copyWith(
              topLeft: isUser ? const Radius.circular(20) : Radius.zero,
              topRight: isUser ? Radius.zero : const Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUser ? 'You' : 'AI Companion',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              isUser
                  ? Text(
                entry["user"],
                style: const TextStyle(color: Colors.white, fontSize: 16),
              )
                  : entry["bot"], // RichText for bot response
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpinKitWave(
              color: Colors.purple.shade700,
              size: 30,
            ),
            const SizedBox(width: 10),
            const Text(
              'AI Companion is thinking...',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ask me anything...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendMessage,
            backgroundColor: Colors.blue.shade900,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}