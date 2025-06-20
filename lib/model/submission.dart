class Submission {
  String? id;
  String? workId;
  String? workerId;
  String? submissionText;
  String? submittedAt;

  Submission({
    this.id,
    this.workId,
    this.workerId,
    this.submissionText,
    this.submittedAt,
  });

  Submission.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    workId = json['work_id'];
    workerId = json['worker_id'];
    submissionText = json['submission_text'];
    submittedAt = json['submitted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['work_id'] = workId;
    data['worker_id'] = workerId;
    data['submission_text'] = submissionText;
    data['submitted_at'] = submittedAt;
    return data;
  }
}
