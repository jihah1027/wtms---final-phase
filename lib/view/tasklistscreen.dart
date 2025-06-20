import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wtms/model/user.dart';
import 'package:wtms/myconfig.dart';
import 'package:wtms/view/submitscreen.dart';

class TaskListScreen extends StatefulWidget {
  final User user;
  const TaskListScreen({super.key, required this.user});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List tasks = [];
  bool loading = true;
  String errorMessage = "";

  final Color primaryColor = const Color(0xFF2193b0);
  final Color secondaryColor = const Color(0xFF6dd5ed);

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() {
      loading = true;
      errorMessage = "";
    });

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/wtms/php/get_works.php"),
        body: {'worker_id': widget.user.userId.toString()},
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData is Map && jsonData['status'] == 'success') {
          setState(() {
            tasks = jsonData['data'];
            loading = false;
          });
        } else {
          setState(() {
            loading = false;
            errorMessage = "No tasks found or invalid response.";
          });
        }
      } else {
        setState(() {
          loading = false;
          errorMessage = "Failed to fetch tasks. Server error.";
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = "An error occurred: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        loading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : tasks.isEmpty
                    ? const Center(child: Text("No tasks assigned."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          var task = tasks[index];
                          String status = task['status'].toString().toLowerCase();
                          bool isCompleted = status == 'success';

                          Color statusColor;
                          Icon statusIcon;
                          if (status == 'success') {
                            statusColor = Colors.green;
                            statusIcon = const Icon(Icons.check_circle, color: Colors.white, size: 18);
                          } else if (status == 'pending') {
                            statusColor = Colors.orange;
                            statusIcon = const Icon(Icons.pending, color: Colors.white, size: 18);
                          } else {
                            statusColor = primaryColor;
                            statusIcon = const Icon(Icons.info, color: Colors.white, size: 18);
                          }

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.assignment, color: Colors.blue, size: 28),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 6.0), // Move title slightly down
                                          child: Text(
                                            task['title'],
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Chip(
                                        backgroundColor: statusColor,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            statusIcon,
                                            const SizedBox(width: 6),
                                            Text(
                                              status.toUpperCase(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    task['description'],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Due Date: ${task['due_date']}",
                                        style: const TextStyle(fontSize: 14, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: ElevatedButton.icon(
                                      onPressed: isCompleted
                                          ? null
                                          : () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => SubmitCompletionScreen(
                                                    user: widget.user,
                                                    task: task,
                                                  ),
                                                ),
                                              );
                                              _fetchTasks(); // Refresh after return
                                            },
                                      icon: Icon(
                                        isCompleted ? Icons.check_circle : Icons.upload,
                                        size: 20,
                                      ),
                                      label: Text(
                                        isCompleted ? 'Submitted' : 'Submit Work',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            isCompleted ? Colors.grey : primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
        Positioned(
          bottom: 20,
          right: 20,
          child: ElevatedButton.icon(
            onPressed: _fetchTasks,
            icon: const Icon(Icons.refresh, size: 24),
            label: const Text("Refresh", style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2193b0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }
}
