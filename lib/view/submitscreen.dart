import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wtms/model/user.dart';
import 'package:wtms/myconfig.dart';

class SubmitCompletionScreen extends StatefulWidget {
  final User user;
  final Map task;

  const SubmitCompletionScreen({
    super.key,
    required this.user,
    required this.task,
  });

  @override
  State<SubmitCompletionScreen> createState() => _SubmitCompletionScreenState();
}

class _SubmitCompletionScreenState extends State<SubmitCompletionScreen> {
  final TextEditingController _completionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool submitting = false;

  final Color primaryColor = const Color(0xFF2193b0);
  final Color secondaryColor = const Color(0xFF6dd5ed);

  Future<bool> _onWillPop() async {
    if (_completionController.text.isNotEmpty) {
      bool? discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text('Are you sure you want to cancel? Your changes will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white),
              child: const Text('Yes'),
            ),
          ],
        ),
      );
      return discard ?? false;
    }
    return true;
  }

  void _submitWork() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid: show red border through validation
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: const Text('Are you sure you want to submit your work completion?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      submitting = true;
    });

    final response = await http.post(
      Uri.parse("${MyConfig.myurl}/wtms/php/submit_work.php"),
      body: {
        'work_id': widget.task['work_id'].toString(),
        'worker_id': widget.user.userId.toString(),
        'submission_text': _completionController.text.trim(),
      },
    );

    setState(() {
      submitting = false;
    });

    var jsonData = jsonDecode(response.body);
    if (jsonData['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission successful')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonData['message'] ?? 'Submission failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Submit Work Completion'),
          backgroundColor: secondaryColor,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 6,
            shadowColor: Colors.grey.shade200,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task title with icon
                  Row(
                    children: [
                      const Icon(Icons.task_alt,
                          color: Color(0xFF2193b0), size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.task['title'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2193b0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Your Completion Notes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _completionController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Describe what you have done...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        // The red border when invalid happens automatically
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter what you completed';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  submitting
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _submitWork,
                            icon: const Icon(Icons.send, size: 24),
                            label: const Text(
                              'Submit',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
