import 'package:flutter/material.dart';
import 'package:time_of_mine/config/types.dart'; // Contains event type configurations
import 'package:time_of_mine/models/event.dart'; // Event model
import 'package:time_of_mine/screens/main_screens/calendar/add_event_screen.dart'; // Screen to add/edit events
import 'package:time_of_mine/screens/main_screens/calendar/custom_calendar.dart'; // Custom calendar widget
import 'package:time_of_mine/services/api/holiday_api_service.dart'; // API to fetch holidays
import 'package:time_of_mine/services/api/holiday_cache_service.dart'; // Service to cache holidays locally
import 'package:time_of_mine/services/local_storage_service.dart'; // Local DB for events
import 'package:time_of_mine/services/sync_service.dart'; // Sync status handler
import 'package:time_of_mine/utils/animation.dart'; // Custom animation utilities
import 'package:time_of_mine/widgets/custom_app_bar.dart'; // Reusable app bar
import 'package:time_of_mine/widgets/rounded_container.dart'; // Reusable styled container

// Main calendar screen
class CalendarScreen extends StatefulWidget {
  final bool showHolidays; // Determines if holiday events should be displayed
  const CalendarScreen({super.key, required this.showHolidays});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

// State of CalendarScreen
class _CalendarScreenState extends State<CalendarScreen>
    with AutomaticKeepAliveClientMixin { // Keeps state alive when switching tabs
  late Future<List<Event>> _eventsFuture; // Future for async loading of events
  Map<DateTime, List<Event>> _eventMap = {}; // Map events by date for easy access
  DateTime? _selectedDay = DateTime.now(); // Currently selected day
  double _opacity = 0.0; // For fade-in animation

  final HolidayApiService _holidayApiService = HolidayApiService(); // API client
  final HolidayCacheService _holidayCache = HolidayCacheService(); // Cache service

  @override
  bool get wantKeepAlive => true; // Ensures widget state is preserved

  @override
  void initState() {
    super.initState();
    _loadAllEventsAndHolidays(); // Load events and holidays on init

    // Slight delay for fade-in animation
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) setState(() => _opacity = 1.0);
    });
  }

  // Load events from local storage and optionally holidays from API
  void _loadAllEventsAndHolidays() {
    _eventsFuture = LocalStorageService.getAllEvents()
        .then((localEvents) async {
          List<Event> holidayEvents = [];
          if (widget.showHolidays) {
            // Fetch holidays if enabled
            holidayEvents = await _holidayApiService.fetchHolidays(
              country: 'UA',
            );
            _holidayCache.saveHolidays(holidayEvents); // Save to cache
          }

          final allEvents = [...localEvents, ...holidayEvents];

          setState(() {
            _eventMap = _mapEvents(allEvents); // Convert to date-event map
          });

          return allEvents; // Return for FutureBuilder
        })
        .catchError((e) => <Event>[]); // On error, return empty list
  }

  // Convert list of events into a map keyed by date
  Map<DateTime, List<Event>> _mapEvents(List<Event> events) {
    final eventMap = <DateTime, List<Event>>{};
    for (var event in events) {
      if (event.dateTime != null) {
        // Normalize date (ignore time)
        final date = DateTime.utc(
          event.dateTime!.year,
          event.dateTime!.month,
          event.dateTime!.day,
        );
        eventMap.putIfAbsent(date, () => []).add(event);
      }
    }

    // Sort events: holidays first, then by time
    for (var entry in eventMap.entries) {
      entry.value.sort((a, b) {
        if (a.type == 'Holiday' && b.type != 'Holiday') return -1;
        if (b.type == 'Holiday' && a.type != 'Holiday') return 1;
        return a.dateTime!.compareTo(b.dateTime!);
      });
    }

    return eventMap;
  }

  // Get all events for a specific day
  List<Event> _getEventsForDay(DateTime day) {
    final normalized = DateTime.utc(day.year, day.month, day.day);
    return _eventMap[normalized] ?? [];
  }

  // Builds a card widget for a single event
  Widget _buildEventCard(Event event) {
    final theme = Theme.of(context);
    final isHoliday = event.type == 'Holiday';
    final time = event.dateTime != null
        ? TimeOfDay.fromDateTime(event.dateTime!)
        : null;

    // Get icon and name for the event type
    final typeData = TypesConfig.eventTypes.firstWhere(
      (e) => e["name"] == event.type,
      orElse: () => {"name": "Other", "icon": Icons.event_note},
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: isHoliday
            ? null
            : Text(
                time!.format(context),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
        title: Row(
          children: [
            Icon(typeData["icon"] as IconData, color: theme.primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(event.title, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
        subtitle: Text(
          typeData["name"],
          style: TextStyle(
            color: theme.textTheme.bodySmall?.color,
            fontSize: 14,
          ),
        ),
        // Popup menu for editing/deleting event
        trailing: isHoliday
            ? null
            : PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) async {
                  if (value == "edit") {
                    await pushAnimatedScale(
                      context,
                      (context) => AddEventScreen(
                        selectedDay: _selectedDay!,
                        event: event,
                      ),
                    );
                    _loadAllEventsAndHolidays();
                  } else if (value == "delete") {
                    await LocalStorageService.deleteEvent(event.id);
                    _loadAllEventsAndHolidays();
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final theme = Theme.of(context);

    final showRefreshBanner = SyncState.shouldShowRefreshHint;

    return Scaffold(
      appBar: const CustomAppBar(title: "Calendar"),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final selectedEvents = _selectedDay != null
              ? _getEventsForDay(_selectedDay!)
              : [];

          return AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: Column(
              children: [
                if (showRefreshBanner)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Material(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          _loadAllEventsAndHolidays();
                          setState(() => SyncState.lastSync = null);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.refresh, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                "Refresh",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: RoundedContainer(
                            color: theme.cardColor,
                            borderRadius: 24,
                            padding: const EdgeInsets.all(12),
                            boxShadow: BoxShadow(
                              color: theme.primaryColor,
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                            child: CustomCalendar(
                              eventMap: _eventMap,
                              selectedDay: _selectedDay,
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() => _selectedDay = selectedDay);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (selectedEvents.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              "No events",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true, // allows ListView inside Column
                            physics: const NeverScrollableScrollPhysics(), // disable scroll
                            itemCount: selectedEvents.length,
                            itemBuilder: (context, index) {
                              final event = selectedEvents[index];
                              return _buildEventCard(event); // Show event cards
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      // Floating button to add a new event
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await pushAnimatedScale(
            context,
            (context) =>
                AddEventScreen(selectedDay: _selectedDay ?? DateTime.now()),
          );
          _loadAllEventsAndHolidays(); // Reload after adding
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
