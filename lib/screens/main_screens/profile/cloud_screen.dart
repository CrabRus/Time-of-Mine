import 'package:flutter/material.dart';
import 'package:time_of_mine/services/firestore_service.dart';
import 'package:time_of_mine/services/local_storage_service.dart';
import 'package:time_of_mine/services/sync_service.dart';
import 'package:time_of_mine/widgets/custom_snack_bar.dart';
import 'package:time_of_mine/widgets/simple_app_bar.dart';

class CloudScreen extends StatefulWidget {
  const CloudScreen({super.key});

  @override
  State<CloudScreen> createState() => _CloudScreenState();
}

class _CloudScreenState extends State<CloudScreen> {
  Map<String, dynamic>? stats;
  bool _loading = false;

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    final result = await SyncService.getStats();
    setState(() {
      stats = result;
      _loading = false;
    });
  }

  Future<void> _upload() async {
    setState(() => _loading = true);
    try {
      await SyncService.uploadAll();
      await _loadStats();
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: "Data successfully uploaded to the cloud",
          isError: false,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(context, message: "Error: $e", isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _download() async {
    setState(() => _loading = true);
    try {
      await SyncService.downloadAll();
      await _loadStats();
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: "Data successfully loaded into the application",
          isError: false,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(context, message: "Error: $e", isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: SimpleAppBar(title: "Synchronization"),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : stats == null
          ? const Center(child: Text("Error loading statistics"))
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      color: theme.cardColor,
                      child: ListTile(
                        title: const Text("Local Data"),
                        subtitle: Text(
                          "Tasks: ${stats!['local']['tasks']}\n"
                          "Events: ${stats!['local']['events']}\n"
                          "Unsynced: ${stats!['local']['unsynced']}",
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: theme.cardColor,
                      child: ListTile(
                        title: const Text("Cloud Data"),
                        subtitle: Text(
                          "Tasks: ${stats!['cloud']['tasks']}\n"
                          "Events: ${stats!['cloud']['events']}",
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: _upload,
                              icon: const Icon(Icons.cloud_upload, size: 40),
                            ),
                            const SizedBox(height: 4),
                            const Text("To cloud"),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: _download,
                              icon: const Icon(Icons.cloud_download, size: 40),
                            ),
                            const SizedBox(height: 4),
                            const Text("To app"),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Красные кликабельные тексты
                    Column(
                      children: [
                        TextButton(
                          onPressed: () async {
                            try {
                              await LocalStorageService.clearUserData();
                              if (mounted) {
                                CustomSnackBar.show(
                                  context,
                                  message:
                                      "Local data was successfully deleted",
                                  isError: false,
                                );
                                _loadStats();
                              }
                            } catch (e) {
                              if (mounted) {
                                CustomSnackBar.show(
                                  context,
                                  message: "Error deleting local data: $e",
                                  isError: true,
                                );
                              }
                            }
                          },
                          child: const Text(
                            "Clear local storage",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              await FirestoreService.deleteAllCloudData();
                              if (mounted) {
                                CustomSnackBar.show(
                                  context,
                                  message:
                                      "Cloud data was successfully deleted",
                                  isError: false,
                                );
                                _loadStats();
                              }
                            } catch (e) {
                              if (mounted) {
                                CustomSnackBar.show(
                                  context,
                                  message: "Error deleting cloud data: $e",
                                  isError: true,
                                );
                              }
                            }
                          },
                          child: const Text(
                            "Clear cloud storage",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
