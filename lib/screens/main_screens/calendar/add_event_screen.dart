import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_of_mine/config/types.dart';
import 'package:time_of_mine/models/event.dart';
import 'package:time_of_mine/services/auth_service.dart';
import 'package:time_of_mine/services/local_storage_service.dart';
import 'package:time_of_mine/widgets/custom_snack_bar.dart';
import 'package:time_of_mine/widgets/simple_app_bar.dart';
import 'package:uuid/uuid.dart';

class AddEventScreen extends StatefulWidget {
  final DateTime selectedDay;
  final Event? event;

  const AddEventScreen({super.key, required this.selectedDay, this.event});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  late TextEditingController _titleController;
  bool _isLoading = false;
  TimeOfDay? _selectedTime;
  String? _selectedType;
  bool _titleError = false;

  final List<Map<String, dynamic>> _eventTypes = [
    {"name": "Birthday", "icon": Icons.cake},
    {"name": "Anniversary", "icon": Icons.favorite},
    {"name": "Meeting", "icon": Icons.people},
    {"name": "Deadline", "icon": Icons.timer},
    {"name": "Reminder", "icon": Icons.notifications},
    {"name": "Holiday", "icon": Icons.celebration},
    {"name": "Travel", "icon": Icons.flight_takeoff},
    {"name": "Workout", "icon": Icons.fitness_center},
    {"name": "Health", "icon": Icons.local_hospital},
    {"name": "Shopping", "icon": Icons.shopping_cart},
    {"name": "Other", "icon": Icons.event_note},
  ];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.event?.title ?? "");
    _selectedType = widget.event?.type;

    if (widget.event?.dateTime != null) {
      final dt = widget.event!.dateTime!;
      _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
    } else {
      final now = TimeOfDay.now();
      int nextHour = (now.hour + 1) % 24;
      _selectedTime = TimeOfDay(hour: nextHour, minute: 0);
    }

    _selectedType ??= "Other";
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
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

  Future<void> _saveEvent(String title) async {
    setState(() => _isLoading = true);

    final typeToSave = _selectedType ?? "Other";

    DateTime dateTime = DateTime(
      widget.selectedDay.year,
      widget.selectedDay.month,
      widget.selectedDay.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final event = Event(
      id: widget.event?.id ?? const Uuid().v4(),
      title: title,
      type: typeToSave,
      dateTime: dateTime,
      userID: widget.event?.userID ?? AuthService.currentUser!.uid,
      isSynced: false,
    );

    try {
      if (widget.event == null) {
        await LocalStorageService.addEvent(event);
      } else {
        await LocalStorageService.updateEvent(event);
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
        message: widget.event == null
            ? 'Event was created'
            : 'Event was edited',
        isError: false,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.event != null;

    return Scaffold(
      appBar: SimpleAppBar(title: isEditing ? "Edit event" : "New event"),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// Title
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
                          _eventTypes.firstWhere(
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
                        itemCount: TypesConfig.eventTypes.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                        itemBuilder: (context, index) {
                          final type = TypesConfig.eventTypes[index];
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
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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

                /// Save Button
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
                            _saveEvent(title);
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
