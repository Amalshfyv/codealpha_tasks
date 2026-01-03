import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const FlashcardQuizApp());
}

class FlashcardQuizApp extends StatefulWidget {
  const FlashcardQuizApp({Key? key}) : super(key: key);

  @override
  State<FlashcardQuizApp> createState() => _FlashcardQuizAppState();
}

class _FlashcardQuizAppState extends State<FlashcardQuizApp> {
  // Theme mode state - light or dark
  ThemeMode themeMode = ThemeMode.light;

  // Method to toggle theme
  void toggleTheme() {
    setState(() {
      themeMode =
          themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard Quiz App',
      themeMode: themeMode,
      // Light theme
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        cardColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
      ),
      // Dark theme - improved colors
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
      ),
      home: FlashcardHomePage(onToggleTheme: toggleTheme, themeMode: themeMode),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Model class to represent a flashcard
class Flashcard {
  String question;
  String answer;

  Flashcard({required this.question, required this.answer});
}

class FlashcardHomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const FlashcardHomePage({
    Key? key,
    required this.onToggleTheme,
    required this.themeMode,
  }) : super(key: key);

  @override
  State<FlashcardHomePage> createState() => _FlashcardHomePageState();
}

class _FlashcardHomePageState extends State<FlashcardHomePage>
    with SingleTickerProviderStateMixin {
  // List to store all flashcards
  List<Flashcard> flashcards = [
    Flashcard(
      question: 'What is Flutter?',
      answer:
          'Flutter is an open-source UI software development kit created by Google.',
    ),
    Flashcard(
      question: 'What is a Widget in Flutter?',
      answer:
          'A widget is a basic building block of Flutter UI. Everything in Flutter is a widget.',
    ),
    Flashcard(
      question:
          'What is the difference between StatelessWidget and StatefulWidget?',
      answer:
          'StatelessWidget is immutable and doesn\'t change, while StatefulWidget can change its state during runtime.',
    ),
  ];

  // Current flashcard index
  int currentIndex = 0;

  // Flag to track if answer is visible (card is flipped)
  bool isFlipped = false;

  // Animation controller for flip animation
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Method to flip the card
  void flipCard() {
    if (isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  // Method to go to next flashcard
  void nextFlashcard() {
    if (currentIndex < flashcards.length - 1) {
      setState(() {
        currentIndex++;
        if (isFlipped) {
          _controller.reset();
          isFlipped = false;
        }
      });
    }
  }

  // Method to go to previous flashcard
  void previousFlashcard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        if (isFlipped) {
          _controller.reset();
          isFlipped = false;
        }
      });
    }
  }

  // Method to add a new flashcard
  void addFlashcard(String question, String answer) {
    setState(() {
      flashcards.add(Flashcard(question: question, answer: answer));
    });
  }

  // Method to edit an existing flashcard
  void editFlashcard(int index, String question, String answer) {
    setState(() {
      flashcards[index].question = question;
      flashcards[index].answer = answer;
    });
  }

  // Method to delete a flashcard
  void deleteFlashcard(int index) {
    setState(() {
      flashcards.removeAt(index);
      if (currentIndex >= flashcards.length && flashcards.isNotEmpty) {
        currentIndex = flashcards.length - 1;
      } else if (flashcards.isEmpty) {
        currentIndex = 0;
      }
      if (isFlipped) {
        _controller.reset();
        isFlipped = false;
      }
    });
  }

  // Show dialog to add a new flashcard
  void showAddFlashcardDialog() {
    final questionController = TextEditingController();
    final answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(
                  labelText: 'Answer',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (questionController.text.isNotEmpty &&
                    answerController.text.isNotEmpty) {
                  addFlashcard(questionController.text, answerController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Show dialog to edit an existing flashcard
  void showEditFlashcardDialog(int index) {
    final questionController =
        TextEditingController(text: flashcards[index].question);
    final answerController =
        TextEditingController(text: flashcards[index].answer);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(
                  labelText: 'Answer',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (questionController.text.isNotEmpty &&
                    answerController.text.isNotEmpty) {
                  editFlashcard(
                      index, questionController.text, answerController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Show confirmation dialog before deleting
  void showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Flashcard'),
          content:
              const Text('Are you sure you want to delete this flashcard?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteFlashcard(index);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Quiz App'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Theme toggle button
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: flashcards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.style,
                    size: 80,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No flashcards yet!',
                    style: TextStyle(
                      fontSize: 20,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button below to add your first flashcard',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: showAddFlashcardDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Flashcard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? Colors.blue[700] : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Flashcard counter
                  Text(
                    'Flashcard ${currentIndex + 1} of ${flashcards.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Flashcard display area with flip animation
                  Expanded(
                    child: GestureDetector(
                      onTap: flipCard,
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          final angle = _animation.value * math.pi;
                          final transform = Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle);

                          return Transform(
                            transform: transform,
                            alignment: Alignment.center,
                            child: angle < math.pi / 2
                                ? _buildQuestionCard(isDarkMode)
                                : Transform(
                                    transform: Matrix4.identity()
                                      ..rotateY(math.pi),
                                    alignment: Alignment.center,
                                    child: _buildAnswerCard(isDarkMode),
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Flip button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: flipCard,
                      icon: Icon(
                          isFlipped ? Icons.flip_to_front : Icons.flip_to_back),
                      label: Text(
                        isFlipped ? 'Show Question' : 'Show Answer',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? Colors.blue[700] : Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Navigation buttons (Previous and Next)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed:
                                currentIndex > 0 ? previousFlashcard : null,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode ? Colors.grey[800] : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: currentIndex < flashcards.length - 1
                                ? nextFlashcard
                                : null,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Next'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode ? Colors.grey[800] : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Edit, Delete and Add buttons
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                showEditFlashcardDialog(currentIndex),
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDarkMode ? Colors.blue[300] : Colors.blue,
                              side: BorderSide(
                                color: isDarkMode ? Colors.blue[300]! : Colors.blue,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                showDeleteConfirmationDialog(currentIndex),
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDarkMode ? Colors.red[300] : Colors.red,
                              side: BorderSide(
                                color: isDarkMode ? Colors.red[300]! : Colors.red,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: showAddFlashcardDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add New'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode ? Colors.green[700] : Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // Build question side of the card
  Widget _buildQuestionCard(bool isDarkMode) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.blue[50],
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? Colors.blue[700]! : Colors.blue[200]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline,
              size: 48,
              color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
            ),
            const SizedBox(height: 24),
            Text(
              'Question',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              flashcards[currentIndex].question,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.grey[100] : Colors.grey[900],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Tap to flip',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build answer side of the card
  Widget _buildAnswerCard(bool isDarkMode) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.green[50],
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? Colors.green[700]! : Colors.green[200]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: isDarkMode ? Colors.green[300] : Colors.green[700],
            ),
            const SizedBox(height: 24),
            Text(
              'Answer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.green[300] : Colors.green[700],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              flashcards[currentIndex].answer,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[100] : Colors.grey[900],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Tap to flip back',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}