import 'package:flutter/material.dart';
import 'package:time_of_mine/config/types.dart';
import 'package:time_of_mine/models/event.dart';
import 'package:time_of_mine/models/task.dart';
import 'package:time_of_mine/services/local_storage_service.dart';
import 'package:time_of_mine/widgets/custom_app_bar.dart';
import 'package:time_of_mine/widgets/rounded_container.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Task> _tasks = [];
  List<Event> _events = [];
  List<Task> _filteredTasks = [];
  List<Event> _filteredEvents = [];

  String _searchQuery = '';
  String? _selectedType;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tasks = await LocalStorageService.getAllTasks();
    final events = await LocalStorageService.getAllEvents();
    setState(() {
      _tasks = tasks;
      _events = events;
      _filteredTasks = tasks;
      _filteredEvents = events;
    });
  }

  void _filterData() {
    setState(() {
      _filteredTasks = _tasks.where((task) {
        final matchesQuery = task.title.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
        final matchesType = _selectedType == null || task.type == _selectedType;
        final matchesDate =
            _selectedDate == null ||
            (task.deadline != null &&
                task.deadline!.year == _selectedDate!.year &&
                task.deadline!.month == _selectedDate!.month &&
                task.deadline!.day == _selectedDate!.day);
        return matchesQuery && matchesType && matchesDate;
      }).toList();

      _filteredEvents = _events.where((event) {
        final matchesQuery = event.title.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
        final matchesType =
            _selectedType == null || event.type == _selectedType;
        final matchesDate =
            _selectedDate == null ||
            (event.dateTime != null &&
                event.dateTime!.year == _selectedDate!.year &&
                event.dateTime!.month == _selectedDate!.month &&
                event.dateTime!.day == _selectedDate!.day);
        return matchesQuery && matchesType && matchesDate;
      }).toList();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _filterData();
    }
  }

  Widget _buildTaskCard(Task task) {
    final theme = Theme.of(context);
    final typeData = TypesConfig.taskTypes.firstWhere(
      (e) => e["name"] == task.type,
      orElse: () => {"name": "Task", "icon": Icons.event_note},
    );

    return RoundedContainer(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Чекбокс
          Checkbox(
            activeColor: theme.colorScheme.primary,
            value: task.isDone,
            onChanged: (value) async {
              if (value == null) return;
              final updatedTask = Task(
                id: task.id,
                title: task.title,
                type: task.type,
                isDone: value,
                userID: task.userID,
                deadline: task.deadline,
              );
              await LocalStorageService.updateTask(updatedTask);
              _loadData();
            },
          ),
          const SizedBox(width: 12),
          // Время
          if (task.deadline != null)
            Text(
              TimeOfDay.fromDateTime(task.deadline!).format(context),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: task.deadline!.isBefore(DateTime.now())
                    ? Colors.red
                    : theme.textTheme.bodyMedium!.color,
              ),
            ),
          if (task.deadline != null) const SizedBox(width: 12),
          // Иконка + текст
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      typeData["icon"] as IconData,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(typeData["name"], style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    final theme = Theme.of(context);
    final typeData = TypesConfig.eventTypes.firstWhere(
      (e) => e["name"] == event.type,
      orElse: () => {"name": "Other", "icon": Icons.event_note},
    );

    return RoundedContainer(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          if (event.dateTime != null)
            Text(
              TimeOfDay.fromDateTime(event.dateTime!).format(context),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          if (event.dateTime != null) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      typeData["icon"] as IconData,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(typeData["name"], style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final types = <String>{};
    types.addAll(_tasks.map((t) => t.type).whereType<String>());
    types.addAll(_events.map((e) => e.type).whereType<String>());

    return Scaffold(
      appBar: CustomAppBar(title: "Search"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Поиск
            TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _filterData();
              },
            ),
            const SizedBox(height: 12),
            // Фильтры: тип и дата
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedType,
                    hint: const Text("Select type"),
                    items: [null, ...types].map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type ?? "All"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedType = value);
                      _filterData();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _pickDate,
                  child: Text(
                    _selectedDate != null
                        ? "${_selectedDate!.day.toString().padLeft(2, '0')}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.year}"
                        : "Pick date",
                  ),
                ),
                if (_selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() => _selectedDate = null);
                      _filterData();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  ExpansionTile(
                    title: const Text(
                      "Tasks",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    initiallyExpanded: true,
                    children: _filteredTasks.map(_buildTaskCard).toList(),
                  ),
                  const SizedBox(height: 12),
                  ExpansionTile(
                    title: const Text(
                      "Events",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    initiallyExpanded: true,
                    children: _filteredEvents.map(_buildEventCard).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
