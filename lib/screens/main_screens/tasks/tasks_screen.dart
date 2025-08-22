import 'package:flutter/material.dart';
import 'package:time_of_mine/models/task.dart';
import 'package:time_of_mine/screens/main_screens/tasks/add_task_screen.dart';
import 'package:time_of_mine/services/local_storage_service.dart';
import 'package:time_of_mine/utils/animation.dart';
import 'package:time_of_mine/widgets/custom_app_bar.dart';
import 'package:time_of_mine/widgets/rounded_container.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _error;

  final List<Map<String, dynamic>> _taskTypes = [
    {"name": "Homework", "icon": Icons.book},
    {"name": "Project", "icon": Icons.work},
    {"name": "Exam", "icon": Icons.school},
    {"name": "Lecture", "icon": Icons.menu_book},
    {"name": "Workshop", "icon": Icons.build},
    {"name": "Appointment", "icon": Icons.event},
    {"name": "Chores", "icon": Icons.cleaning_services},
    {"name": "Bill", "icon": Icons.payment},
    {"name": "Study", "icon": Icons.lightbulb},
    {"name": "Entertainment", "icon": Icons.movie},
    {"name": "Other", "icon": Icons.event_note},
  ];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await LocalStorageService.getAllTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Ошибка загрузки заданий";
        _isLoading = false;
      });
    }
  }

  Future<void> _updateTask(Task updatedTask) async {
    await LocalStorageService.updateTask(updatedTask);

    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      setState(() {
        _tasks[index] = updatedTask;
      });
    }
  }

  Future<void> _deleteTask(String taskId) async {
    await LocalStorageService.deleteTask(taskId);
    setState(() {
      _tasks.removeWhere((t) => t.id == taskId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(title: "Tasks"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, style: theme.textTheme.bodyLarge))
          : _tasks.isEmpty
          ? Center(child: Text("No tasks", style: theme.textTheme.bodyLarge))
          : _buildTaskList(theme),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        onPressed: () async {
          await pushAnimatedScale(context, (context) => const AddTaskScreen());
          _loadTasks();
        },
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }

  Widget _buildTaskList(ThemeData theme) {
    final Map<DateTime, List<Task>> groupedTasks = {};
    final List<Task> noDateTasks = [];

    for (var task in _tasks) {
      if (task.deadline == null) {
        noDateTasks.add(task);
        continue;
      }
      final dateKey = DateTime(
        task.deadline!.year,
        task.deadline!.month,
        task.deadline!.day,
      );
      groupedTasks.putIfAbsent(dateKey, () => []).add(task);
    }

    final sortedDates = groupedTasks.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...sortedDates.map((date) {
          final dayTasks = groupedTasks[date]!;
          return _buildTaskGroup(
            theme,
            title:
                "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}",
            tasks: dayTasks,
          );
        }),

        if (noDateTasks.isNotEmpty)
          _buildTaskGroup(theme, title: "No deadline", tasks: noDateTasks),
      ],
    );
  }

  Widget _buildTaskGroup(
    ThemeData theme, {
    required String title,
    required List<Task> tasks,
  }) {
    return RoundedContainer(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.cardColor,
      boxShadow: BoxShadow(
        color: theme.primaryColor,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
      child: ExpansionTile(
        collapsedIconColor: theme.colorScheme.primary,
        iconColor: theme.colorScheme.primary,
        title: Text(
          title,
          style: TextStyle(
            color: theme.textTheme.bodyMedium!.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: tasks.map((task) {
          final typeData = _taskTypes.firstWhere(
            (e) => e["name"] == task.type,
            orElse: () => {"icon": Icons.event_note, "name": "Task"},
          );

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Чекбокс
                Checkbox(
                  activeColor: theme.colorScheme.primary,
                  value: task.isDone,
                  onChanged: (bool? value) async {
                    if (value == null) return;
                    final updatedTask = Task(
                      id: task.id,
                      title: task.title,
                      type: task.type,
                      isDone: value,
                      userID: task.userID,
                      deadline: task.deadline,
                    );
                    await _updateTask(updatedTask);
                  },
                ),

                const SizedBox(width: 8),

                // Время на уровне чекбокса
                if (task.deadline != null) ...[
                  Text(
                    TimeOfDay.fromDateTime(task.deadline!).format(context),
                    style: TextStyle(
                      color: task.deadline!.isBefore(DateTime.now())
                          ? Colors.red
                          : theme.textTheme.bodyMedium!.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // увеличенный размер
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Вертикальная линия
                Container(
                  width: 1,
                  height: 40,
                  color: theme.primaryColor.withOpacity(0.3),
                ),
                const SizedBox(width: 8),

                // Иконка + название + тип
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            typeData["icon"] as IconData,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: theme.textTheme.bodyMedium!.color,
                                  fontWeight: FontWeight.w600,
                                  decoration: task.isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        typeData["name"],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Меню действий
                PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) async {
                    if (value == "edit") {
                      await pushAnimatedScale(
                        context,
                        (context) => AddTaskScreen(task: task),
                      );
                      _loadTasks();
                    } else if (value == "delete") {
                      await _deleteTask(task.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: "edit",
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text("Edit"),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: "delete",
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text("Delete"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
