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

enum FilterType { all, active, completed }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Box<Task> _taskBox;
  final List<Task> _tasks = [];
  final Map<String, dynamic> _taskKeyMap = {};
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _menuKey = GlobalKey();
  bool _initialized = false;
  bool _sortNewestFirst = true;
  bool _isSearching = false;
  String _searchQuery = '';
  FilterType _currentFilter = FilterType.all;
  double _fabScale = 1.0;

  List<Task> get _filteredTasks {
    return _tasks.where((task) {
      if (_searchQuery.isNotEmpty &&
          !task.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_currentFilter == FilterType.active && task.isCompleted) return false;
      if (_currentFilter == FilterType.completed && !task.isCompleted) return false;
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
    _initHive();
  }

  Future<void> _initHive() async {
    _taskBox = await Hive.openBox<Task>('tasks');
    for (final key in _taskBox.keys) {
      final task = _taskBox.get(key);
      if (task != null) {
        _tasks.add(task);
        _taskKeyMap[task.id] = key;
      }
    }
    _applySort();
    _initialized = true;
    if (mounted) setState(() {});
  }

  void _addTask(String title, {
    TaskCategory category = TaskCategory.other,
    String? customCategory,
    TaskColor taskColor = TaskColor.purple,
  }) {
    if (title.trim().isEmpty) return;
    final task = Task(
      id: _generateId(),
      title: title.trim(),
      createdAt: DateTime.now(),
      category: category,
      customCategory: customCategory,
      taskColor: taskColor,
    );
    final key = _taskBox.add(task);
    _tasks.add(task);
    _taskKeyMap[task.id] = key;
    _applySort();
    setState(() {});
  }

  String _generateId() {
    final now = DateTime.now();
    return '${now.millisecondsSinceEpoch}_${now.microsecondsSinceEpoch}';
  }

  void _deleteWithUndo(Task task) {
    final hiveKey = _taskKeyMap.remove(task.id);
    _tasks.remove(task);
    if (hiveKey != null) _taskBox.delete(hiveKey);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            final newKey = _taskBox.add(task);
            _taskKeyMap[task.id] = newKey;
            _tasks.add(task);
            _applySort();
            setState(() {});
          },
        ),
      ),
    );
  }

  void _toggleTask(Task task) {
    task.isCompleted = !task.isCompleted;
    _taskBox.put(_taskKeyMap[task.id], task);
    setState(() {});
  }

  void _toggleSort() {
    setState(() {
      _sortNewestFirst = !_sortNewestFirst;
      _applySort();
    });
  }

  void _applySort() {
    _tasks.sort((a, b) => _sortNewestFirst
        ? b.createdAt.compareTo(a.createdAt)
        : a.createdAt.compareTo(b.createdAt));
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _markAllComplete() {
    for (final task in _tasks) {
      task.isCompleted = true;
      _taskBox.put(_taskKeyMap[task.id], task);
    }
    setState(() {});
  }

  void _clearCompleted() {
    final completed = _tasks.where((t) => t.isCompleted).toList();
    for (final task in completed) {
      _taskBox.delete(_taskKeyMap[task.id]);
      _taskKeyMap.remove(task.id);
    }
    _tasks.removeWhere((t) => t.isCompleted);
    setState(() {});
  }

  void _showOverflowMenu() {
    final buttonCtx = _menuKey.currentContext;
    if (buttonCtx == null) return;

    final RenderBox button = buttonCtx.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);
    final Size size = button.size;

    const double menuWidth = 220;
    final double right = offset.dx + size.width;
    final double top = offset.dy + size.height + 12;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        right - menuWidth,
        top,
        right,
        top,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'mark_all',
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: SizedBox(
            width: menuWidth - 16,
            child: Row(
              children: [
                const SizedBox(
                  width: 40,
                  child: Icon(Icons.done_all_rounded, size: 22, color: Color(0xFF6750A4)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Mark All Complete',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1C1B1F),
                  ),
                ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(height: 4),
        PopupMenuItem<String>(
          value: 'clear_completed',
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: SizedBox(
            width: menuWidth - 16,
            child: Row(
              children: [
                const SizedBox(
                  width: 40,
                  child: Icon(Icons.cleaning_services_rounded, size: 22, color: Color(0xFF6750A4)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Clear Completed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1C1B1F),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white.withOpacity(0.95),
      elevation: 4,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.15),
    ).then((value) {
      if (value == null) return;
      switch (value) {
        case 'mark_all':
          _markAllComplete();
          break;
        case 'clear_completed':
          if (_tasks.where((t) => t.isCompleted).isNotEmpty) _clearCompleted();
          break;
      }
    });
  }

  void _showCreateDialog() {
    _controller.clear();
    TaskColor selectedColor = TaskColor.purple;
    final customCatController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: const EdgeInsets.all(24),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              title: const Text(
                'Create Task',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1B1F),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Enter task name…',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onSubmitted: (value) {
                      _addTask(
                        value,
                        customCategory: customCatController.text,
                        taskColor: selectedColor,
                      );
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: TaskColor.values.map((c) {
                      final selected = selectedColor == c;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedColor = c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: c.color,
                            shape: BoxShape.circle,
                            border: selected
                                ? Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  )
                                : null,
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: c.color.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: selected
                              ? const Icon(Icons.check, color: Colors.white, size: 22)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: customCatController,
                    maxLength: 20,
                    decoration: const InputDecoration(
                      hintText: 'Custom category (optional)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      counterText: '',
                      isDense: true,
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                  ),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    _addTask(
                      _controller.text,
                      customCategory: customCatController.text,
                      taskColor: selectedColor,
                    );
                    Navigator.pop(ctx);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6750A4),
                  ),
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _taskBox.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _tasks.length;
    final completedCount = _tasks.where((t) => t.isCompleted).length;
    final activeCount = total - completedCount;
    final displayed = _filteredTasks;

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
                        '$total ${total == 1 ? 'Task' : 'Tasks'}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isSearching ? Icons.close : Icons.search,
                        ),
                        tooltip: 'Search',
                        color: const Color(0xFF6750A4),
                        onPressed: _toggleSearch,
                      ),
                      IconButton(
                        icon: Icon(
                          _sortNewestFirst ? Icons.arrow_downward : Icons.arrow_upward,
                        ),
                        tooltip: _sortNewestFirst ? 'Newest first' : 'Oldest first',
                        color: const Color(0xFF6750A4),
                        onPressed: _toggleSort,
                      ),
                      IconButton(
                        key: _menuKey,
                        icon: const Icon(Icons.more_vert),
                        color: const Color(0xFF6750A4),
                        onPressed: _showOverflowMenu,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip('All', FilterType.all),
                  const SizedBox(width: 8),
                  _buildFilterChip('Active', FilterType.active),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', FilterType.completed),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Row(
                children: [
                  _buildStatItem('Total', total, const Color(0xFF6750A4)),
                  const SizedBox(width: 24),
                  _buildStatItem('Active', activeCount, const Color(0xFF4CAF50)),
                  const SizedBox(width: 24),
                  _buildStatItem('Completed', completedCount, const Color(0xFF2196F3)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: !_initialized
                  ? const Center(child: CircularProgressIndicator())
                  : displayed.isEmpty
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
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: displayed.length,
                          itemBuilder: (context, index) {
                            final task = displayed[index];
                            return Dismissible(
                              key: ValueKey(task.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD32F2F),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (_) => _deleteWithUndo(task),
                              child: TaskCard(
                                task: task,
                                onToggle: () => _toggleTask(task),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTapDown: (_) => setState(() => _fabScale = 0.92),
        onTapUp: (_) => setState(() => _fabScale = 1.0),
        onTapCancel: () => setState(() => _fabScale = 1.0),
        child: AnimatedScale(
          scale: _fabScale,
          duration: const Duration(milliseconds: 100),
          child: SizedBox(
            width: 64,
            height: 64,
            child: FloatingActionButton(
              onPressed: _showCreateDialog,
              backgroundColor: const Color(0xFF6750A4),
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 28),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, FilterType type) {
    final selected = _currentFilter == type;
    return FilterChip(
      label: SizedBox(
        width: 56,
        child: Text(
          label,
          textAlign: TextAlign.center,
        ),
      ),
      selected: selected,
      onSelected: (_) => setState(() => _currentFilter = type),
      showCheckmark: false,
      selectedColor: const Color(0xFF6750A4),
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF6B7280),
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: BorderSide(
        color: selected
            ? const Color(0xFF6750A4)
            : const Color(0xFF6B7280).withOpacity(0.3),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $count',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
