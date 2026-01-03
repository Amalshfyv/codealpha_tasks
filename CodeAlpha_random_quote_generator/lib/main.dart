import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


void main() {
  runApp(const QuoteGeneratorApp());
}

class QuoteGeneratorApp extends StatelessWidget {
  const QuoteGeneratorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Quote Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const QuoteScreen(),
    );
  }
}

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({Key? key}) : super(key: key);

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  // API information
  final String _apiUrl = 'https://api.apileague.com/retrieve-random-quote';
  final String _apiKey = '91c5480b172746ac834c3327cfc153bd ';

  // Quote data
  String _quoteText = 'Loading...';
  String _quoteAuthor = '';
  bool _isLoading = false;
  bool _hasError = false;

  // Dark mode state
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    // Load first quote
    _fetchRandomQuote();
  }

  // Fetch random quote from API
  Future<void> _fetchRandomQuote() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'x-api-key': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _quoteText = data['quote'] ?? 'Quote not found';
          _quoteAuthor = data['author'] ?? 'Unknown author';
          _isLoading = false;
        });
      } else {
        setState(() {
          _quoteText = 'Error occurred';
          _quoteAuthor = 'Status code: ${response.statusCode}';
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _quoteText = 'Error: Check your internet connection';
        _quoteAuthor = e.toString();
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // Toggle dark mode
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Random Quote Generator',
          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: _isDarkMode ? Colors.grey[850] : Colors.blue,
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: _isDarkMode ? Colors.yellow : Colors.white,
            ),
            onPressed: _toggleTheme,
            tooltip: _isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Quote card
              Card(
                color: _isDarkMode ? Colors.grey[850] : Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: HexColor("#D3D3D3"), width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      // Quote icon or loading indicator
                      _isLoading
                          ? CircularProgressIndicator(
                            color:
                                _isDarkMode ? Colors.blueAccent : Colors.blue,
                          )
                          : Icon(
                            _hasError
                                ? Icons.error_outline
                                : Icons.format_quote,
                            size: 48,
                            color:
                                _hasError
                                    ? Colors.red
                                    : (_isDarkMode
                                        ? Colors.blueAccent
                                        : Colors.blue),
                          ),
                      const SizedBox(height: 24),

                      // Quote text
                      Text(
                        _quoteText,
                        style: TextStyle(
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                          color: _isDarkMode ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Author name
                      if (_quoteAuthor.isNotEmpty)
                        Text(
                          '— $_quoteAuthor',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                _isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // New Quote button
              ElevatedButton(
                onPressed: _isLoading ? null : _fetchRandomQuote,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isDarkMode ? Colors.blueAccent : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  _isLoading ? 'Loading...' : 'New Quote',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
