import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_of_mine/models/task.dart';
import 'package:time_of_mine/services/auth_service.dart';
import 'package:time_of_mine/services/local_storage_service.dart';
import 'package:time_of_mine/widgets/custom_snack_bar.dart';
import 'package:time_of_mine/widgets/simple_app_bar.dart';
import 'package:uuid/uuid.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;

  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late TextEditingController _titleController;
  bool _isLoading = false;
  bool _titleError = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedType;

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

    _titleController = TextEditingController(text: widget.task?.title ?? "");
    _selectedType = widget.task?.type;

    _selectedType = widget.task?.type ?? "Other";
    final deadline = widget.task?.deadline;
    if (deadline != null) {
      _selectedDate = DateTime(deadline.year, deadline.month, deadline.day);
      _selectedTime = TimeOfDay(hour: deadline.hour, minute: deadline.minute);
    } else {
      final now = TimeOfDay.now();
      final nextHour = (now.hour + 1) % 24;
      _selectedTime = TimeOfDay(hour: nextHour, minute: 0);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedTime ??= const TimeOfDay(hour: 0, minute: 0);
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked;
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        Duration initial = Duration(
          hours: _selectedTime?.hour ?? 0,
          minutes: _selectedTime?.minute ?? 0,
        );
        return SizedBox(
          height: 250,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hm,
            initialTimerDuration: initial,
            onTimerDurationChanged: (duration) {
              picked = TimeOfDay(
                hour: duration.inHours,
                minute: duration.inMinutes % 60,
              );
            },
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveTask(String title) async {
    setState(() => _isLoading = true);

    final typeToSave = _selectedType ?? "Other";

    DateTime? deadline;
    if (_selectedDate != null && _selectedTime != null) {
      deadline = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }

    final task = Task(
      id: widget.task?.id ?? const Uuid().v4(),
      title: title,
      type: typeToSave,
      deadline: deadline,
      userID: widget.task?.userID ?? AuthService.currentUser!.uid,
      isDone: widget.task?.isDone ?? false,
      isSynced: false
    );

    try {
      if (widget.task == null) {
        await LocalStorageService.addTask(task);
      } else {
        await LocalStorageService.updateTask(task);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(context, message: "Error: $e", isError: true);
      }
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = false);

    if (mounted) {
      CustomSnackBar.show(
        context,
        message: widget.task == null ? 'Task was created' : 'Task was edited',
        isError: false,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.task != null;
    return Scaffold(
      appBar: SimpleAppBar(title: isEditing ? "Edit task" : "New task"),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Title",
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium!.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: theme.cardColor,
                    hintText: "Enter title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.textTheme.bodyMedium!.color!,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _titleError
                            ? Colors.red
                            : theme.textTheme.bodyMedium!.color!,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _titleError
                            ? Colors.red
                            : theme.colorScheme.primary,
                        width: 1,
                      ),
                    ),
                  ),
                  style: theme.textTheme.bodyLarge,
                  onChanged: (value) {
                    if (value.trim().isNotEmpty && _titleError) {
                      setState(() => _titleError = false);
                    }
                  },
                ),

                const SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.only(left: 6, right: 6),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.textTheme.bodyMedium!.color!,
                      width: 1,
                    ),
                  ),
                  child: ExpansionTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Row(
                      children: [
                        Icon(
                          _taskTypes.firstWhere(
                                (e) => e["name"] == _selectedType,
                                orElse: () => {"icon": Icons.event_note},
                              )["icon"]
                              as IconData,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Type: $_selectedType",
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium!.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _taskTypes.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                        itemBuilder: (context, index) {
                          final type = _taskTypes[index];
                          final isSelected = _selectedType == type["name"];

                          return _buildGridItem(
                            type: type,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedType = type["name"];
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _selectedDate == null
                        ? "Date"
                        : "${_selectedDate!.day.toString().padLeft(2, '0')}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.year}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  onPressed: _pickDate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}",
                  ),
                  onPressed: _pickTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: Text(isEditing ? "Save changes" : "Save"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          final title = _titleController.text.trim();
                          if (title.isNotEmpty) {
                            _saveTask(title);
                          } else {
                            setState(() {
                              _titleError = true;
                            });
                            CustomSnackBar.show(
                              context,
                              message: "Enter title",
                              isError: true,
                            );
                          }
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem({
    required Map<String, dynamic> type,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.2)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(type["icon"], color: theme.iconTheme.color, size: 28),
            const SizedBox(height: 8),
            AutoSizeText(
              type["name"],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodyMedium!.color,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 8,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
