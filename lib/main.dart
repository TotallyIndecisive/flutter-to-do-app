import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/task.dart';
import 'widgets/task_card.dart';

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
      title: 'My Tasks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          surface: const Color(0xFFF5F5F7),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
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
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late Box<Task> _taskBox;
  final List<Task> _tasks = [];
  final List<dynamic> _taskKeys = [];
  final TextEditingController _controller = TextEditingController();
  bool _initialized = false;
  bool _sortNewestFirst = true;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _taskBox = await Hive.openBox<Task>('tasks');
    _tasks.addAll(_taskBox.values);
    _taskKeys.addAll(_taskBox.keys);
    _applySort();
    _initialized = true;
    if (mounted) setState(() {});
  }

  void _addTask(String title) {
    if (title.trim().isEmpty) return;
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      createdAt: DateTime.now(),
    );
    final key = _taskBox.add(task);
    _tasks.add(task);
    _taskKeys.add(key);
    _applySort();
    _listKey.currentState?.insertItem(
      _tasks.indexOf(task),
    );
    setState(() {});
  }

  void _removeTask(int index) {
    final removedTask = _tasks[index];
    _taskBox.delete(_taskKeys[index]);
    _tasks.removeAt(index);
    _taskKeys.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeIn),
        child: TaskCard(
          task: removedTask,
          onToggle: () {},
          onDelete: () {},
        ),
      ),
    );
    setState(() {});
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _removeTask(index);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleTask(int index) {
    final task = _tasks[index];
    task.isCompleted = !task.isCompleted;
    _taskBox.put(_taskKeys[index], task);
    setState(() {});
  }

  void _toggleSort() {
    setState(() {
      _sortNewestFirst = !_sortNewestFirst;
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

  void _showCreateDialog() {
    _controller.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Create Task'),
          content: TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Task Name',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              _addTask(value);
              Navigator.pop(context);
            },
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

  @override
  void dispose() {
    _controller.dispose();
    _taskBox.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Tasks',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1C1B1F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_tasks.length} ${_tasks.length == 1 ? 'Task' : 'Tasks'}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      _sortNewestFirst ? Icons.arrow_downward : Icons.arrow_upward,
                    ),
                    tooltip: _sortNewestFirst ? 'Newest first' : 'Oldest first',
                    color: const Color(0xFF6750A4),
                    onPressed: _toggleSort,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: !_initialized
                  ? const Center(child: CircularProgressIndicator())
                  : _tasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 64,
                                color: const Color(0xFF6B7280).withOpacity(0.4),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No Tasks Yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1C1B1F),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to create your first task',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xFF6B7280).withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      : AnimatedList(
                          key: _listKey,
                          initialItemCount: _tasks.length,
                          padding: const EdgeInsets.only(bottom: 80),
                          itemBuilder: (context, index, animation) {
                            return SizeTransition(
                              sizeFactor: animation,
                              child: TaskCard(
                                task: _tasks[index],
                                onToggle: () => _toggleTask(index),
                                onDelete: () => _confirmDelete(index),
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
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
