import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void dispose() {
    _apiKeyController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getSettings();
  }

  Future<void> getSettings() async {
    final apiKey = await storage.read(key: "apiKey");
    if (apiKey != null) {
      _apiKeyController.text = apiKey;
    }
    final language = await storage.read(key: "language");
    if (language != null) {
      _languageController.text = language;
    }
  }

  Future<void> saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isNotEmpty) {
      // Write value
      await storage.write(key: "apiKey", value: apiKey);
    }

    final language = _languageController.text.trim();
    if (language.isNotEmpty) {
      // Write value
      await storage.write(key: "language", value: language);
    }

    setState(() {
      _isLoading = false;
    });
    if (apiKey.isNotEmpty) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your API key:',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      hintText: 'API key',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    'Enter your language (ex : french)',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: _languageController,
                    decoration: const InputDecoration(
                      hintText: 'language',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () async {
                      await saveSettings();
                    },
                    child: const Text('Save'),
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    'You can get your API key from the following link:',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  const SizedBox(height: 10.0),
                  GestureDetector(
                    onTap: () => launchUrl(Uri.parse(
                        "https://platform.openai.com/account/api-keys")),
                    child: const Text(
                      'https://platform.openai.com/account/api-keys',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
