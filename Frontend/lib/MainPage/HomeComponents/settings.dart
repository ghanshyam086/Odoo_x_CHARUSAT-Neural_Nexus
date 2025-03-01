import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _unitPreference = 'Metric'; // Default to Metric (kg, cm)
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with sample data; in a real app, load from storage or backend
    _heightController.text = '170'; // Example height in cm
    _weightController.text = '70';  // Example weight in kg
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preferences Section
              _buildSectionTitle(context, 'Preferences'),
              _buildSwitchTile(
                context,
                'Notifications',
                'Enable push notifications',
                _notificationsEnabled,
                    (value) {
                  setState(() => _notificationsEnabled = value);
                  // TODO: Save to storage or backend
                },
              ),
              _buildSwitchTile(
                context,
                'Dark Mode',
                'Switch to dark theme',
                _darkModeEnabled,
                    (value) {
                  setState(() => _darkModeEnabled = value);
                  // TODO: Implement theme change logic
                },
              ),
              _buildDropdownTile(
                context,
                'Units',
                'Choose measurement units',
                _unitPreference,
                ['Metric', 'Imperial'],
                    (value) {
                  setState(() => _unitPreference = value!);
                  // TODO: Save unit preference
                },
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.025),

              // Profile Information Section
              _buildSectionTitle(context, 'Profile Information'),
              _buildTextFieldTile(
                context,
                'Height',
                _unitPreference == 'Metric' ? 'Height (cm)' : 'Height (in)',
                _heightController,
                TextInputType.number,
              ),
              _buildTextFieldTile(
                context,
                'Weight',
                _unitPreference == 'Metric' ? 'Weight (kg)' : 'Weight (lb)',
                _weightController,
                TextInputType.number,
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.025),

              // Account Section
              _buildSectionTitle(context, 'Account'),
              _buildActionTile(
                context,
                'Change Password',
                'Update your password',
                Icons.lock,
                    () {
                  // TODO: Navigate to Change Password page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Change Password not implemented yet')),
                  );
                },
              ),
              _buildActionTile(
                context,
                'Delete Account',
                'Permanently delete your account',
                Icons.delete_forever,
                    () {
                  _showDeleteAccountDialog(context);
                },
                color: Colors.red,
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.015),
      child: Text(
        title,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.05,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
      BuildContext context,
      String title,
      String subtitle,
      bool value,
      ValueChanged<bool> onChanged,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.035,
            color: Colors.grey.shade600,
          ),
        ),
        value: value,
        activeColor: Colors.blue.shade800,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownTile(
      BuildContext context,
      String title,
      String subtitle,
      String value,
      List<String> options,
      ValueChanged<String?> onChanged,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.035,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: DropdownButton<String>(
          value: value,
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: onChanged,
          underline: const SizedBox(),
        ),
      ),
    );
  }

  Widget _buildTextFieldTile(
      BuildContext context,
      String title,
      String hint,
      TextEditingController controller,
      TextInputType keyboardType,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: title,
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onTap, {
        Color? color,
      }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          icon,
          color: color ?? Colors.blue.shade800,
          size: MediaQuery.of(context).size.width * 0.06,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w500,
            color: color ?? Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.035,
            color: Colors.grey.shade600,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion not implemented yet')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}