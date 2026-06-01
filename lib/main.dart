import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My To-Do',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          surface: const Color(0xFFF6F3FA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F3FA),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Box<Task> _taskBox;
  final List<Task> _tasks = [];
  final List<dynamic> _taskKeys = [];
  final TextEditingController _controller = TextEditingController();
  bool _initialized = false;
  bool _sortNewestFirst = true;

  static const List<Color> _pastelColors = [
    Color(0xFFE8E0F0),
    Color(0xFFFCE4EC),
    Color(0xFFE0F7FA),
    Color(0xFFFFF3E0),
    Color(0xFFE8F5E9),
    Color(0xFFF3E5F5),
  ];

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _taskBox = await Hive.openBox<Task>('tasks');
    setState(() {
      _tasks.addAll(_taskBox.values);
      _taskKeys.addAll(_taskBox.keys);
      _applySort();
      _initialized = true;
    });
  }

  void _addTask(String title) {
    if (title.trim().isEmpty) return;
    final task = Task(title: title.trim(), createdAt: DateTime.now());
    final key = _taskBox.add(task);
    setState(() {
      _tasks.add(task);
      _taskKeys.add(key);
      _applySort();
    });
  }

  void _setSortOrder(bool newestFirst) {
    setState(() {
      _sortNewestFirst = newestFirst;
      _applySort();
    });
  }

  void _applySort() {
    final combined = <MapEntry<dynamic, Task>>[
      for (var i = 0; i < _tasks.length; i++) MapEntry(_taskKeys[i], _tasks[i]),
    ];
    combined.sort((a, b) => _sortNewestFirst
        ? b.value.createdAt.compareTo(a.value.createdAt)
        : a.value.createdAt.compareTo(b.value.createdAt));
    for (var i = 0; i < combined.length; i++) {
      _taskKeys[i] = combined[i].key;
      _tasks[i] = combined[i].value;
    }
  }

  void _removeTask(int index) {
    _taskBox.delete(_taskKeys[index]);
    setState(() {
      _tasks.removeAt(index);
      _taskKeys.removeAt(index);
    });
  }

  void _toggleTask(int index) {
    final task = _tasks[index];
    task.isCompleted = !task.isCompleted;
    _taskBox.put(_taskKeys[index], task);
    setState(() {});
  }

  void _showCreateDialog() {
    _controller.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('New Task'),
          content: TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'What do you need to do?',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                _addTask(_controller.text);
                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  String _formatDateTime(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = date.hour < 12 ? 'AM' : 'PM';
    return '${months[date.month - 1]} ${date.day}, ${date.year}  $hour:$minute $amPm';
  }

  @override
  void dispose() {
    _controller.dispose();
    _taskBox.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'My To-Do',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '${_tasks.length} task${_tasks.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Newest'),
                    selected: _sortNewestFirst,
                    onSelected: (_) => _setSortOrder(true),
                    shape: const StadiumBorder(),
                    selectedColor: const Color(0xFF7C4DFF),
                    labelStyle: TextStyle(
                      color: _sortNewestFirst ? Colors.white : Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Oldest'),
                    selected: !_sortNewestFirst,
                    onSelected: (_) => _setSortOrder(false),
                    shape: const StadiumBorder(),
                    selectedColor: const Color(0xFF7C4DFF),
                    labelStyle: TextStyle(
                      color: !_sortNewestFirst ? Colors.white : Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: !_initialized
                  ? const Center(child: CircularProgressIndicator())
                  : _tasks.isEmpty
                      ? Center(
                          child: Text(
                            'No tasks yet',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.black38,
                            ),
                          ),
                        )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        final pastel = _pastelColors[index % _pastelColors.length];
                        final completed = task.isCompleted;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: pastel,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                completed
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline,
                                color: completed
                                    ? Colors.green
                                    : const Color(0xFF7C4DFF),
                              ),
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: completed ? Colors.black38 : Colors.black87,
                                decoration: completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              _formatDateTime(task.createdAt),
                              style: TextStyle(
                                fontSize: 13,
                                color: completed ? Colors.black26 : Colors.black45,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    completed
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: const Color(0xFF7C4DFF),
                                  ),
                                  onPressed: () => _toggleTask(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.black38,
                                  onPressed: () => _removeTask(index),
                                ),
                              ],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: const Color(0xFF7C4DFF),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
