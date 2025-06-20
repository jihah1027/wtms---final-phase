import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wtms/model/user.dart';
import 'package:wtms/myconfig.dart';

class SubmissionHistoryScreen extends StatefulWidget {
  final User user;
  const SubmissionHistoryScreen({super.key, required this.user});

  @override
  State<SubmissionHistoryScreen> createState() => _SubmissionHistoryScreenState();
}

class _SubmissionHistoryScreenState extends State<SubmissionHistoryScreen> {
  List submissions = [];
  List<bool> expandedList = [];
  bool loading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchSubmissions();
  }

  Future<void> fetchSubmissions() async {
    setState(() {
      loading = true;
      errorMessage = "";
    });

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/wtms/php/get_submissions.php"),
        body: {'worker_id': widget.user.userId.toString()},
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'success') {
          setState(() {
            submissions = jsonData['data'];
            expandedList = List<bool>.filled(submissions.length, false);
            loading = false;
          });
        } else {
          setState(() {
            errorMessage = jsonData['message'] ?? 'No submissions found.';
            submissions = [];
            expandedList = [];
            loading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Failed to load submissions.";
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        loading = false;
      });
    }
  }

  void editSubmissionDialog(Map submission) {
    final controller = TextEditingController(text: submission['submission_text']);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Submission'),
        content: SizedBox(
          width: 350,
          child: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              maxLines: 7,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Edit your submission here...',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Submission text cannot be empty';
                }
                return null;
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;

              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm Update"),
                  content: const Text("Are you sure you want to update this submission?"),
                  actions: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    ElevatedButton(
                      child: const Text("Yes"),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;

              final response = await http.post(
                Uri.parse("${MyConfig.myurl}/wtms/php/edit_submission.php"),
                body: {
                  'submission_id': submission['submission_id'].toString(),
                  'updated_text': controller.text.trim(),
                },
              );

              final jsonData = jsonDecode(response.body);
              if (jsonData['status'] == 'success') {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Submission updated successfully')),
                  );
                  Navigator.pop(context);
                  fetchSubmissions();
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(jsonData['message'] ?? 'Update failed')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          errorMessage,
          style: const TextStyle(fontSize: 18, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (submissions.isEmpty || submissions.length != expandedList.length) {
      return const Center(
        child: Text(
          'No submissions found.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        var submission = submissions[index];
        String fullText = submission['submission_text'];
        bool isExpanded = expandedList[index];

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          elevation: 6,
          child: ExpansionTile(
            leading: const Icon(Icons.description, color: Color(0xFF2193b0)),
            title: Text(
              submission['title'],
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.calendar_today, size: 18, color: Colors.black),
                    SizedBox(width: 6),
                    Text(
                      "Submitted on:",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  submission['submitted_at'],
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
            initiallyExpanded: isExpanded,
            onExpansionChanged: (value) {
              setState(() {
                expandedList[index] = value;
              });
            },
            childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              Text(
                fullText,
                style: const TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit"),
                  onPressed: () => editSubmissionDialog(submission),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2193b0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
