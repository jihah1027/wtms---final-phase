class User {
  String? userId;
  String? userName;
  String? userEmail;
  String? userPassword;
  String? userPhone;
  String? userAddress;
  String? userImage; // Add this

  User({
    this.userId,
    this.userName,
    this.userEmail,
    this.userPassword,
    this.userPhone,
    this.userAddress,
    this.userImage, // Add to constructor
  });

  User.fromJson(Map<String, dynamic> json) {
    userId = json['worker_id'];
    userName = json['full_name'];
    userEmail = json['email'];
    userPassword = json['password'];
    userPhone = json['phone'];
    userAddress = json['address'];
    userImage = json['image']; // Adjust key based on your API
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['worker_id'] = userId;
    data['full_name'] = userName;
    data['email'] = userEmail;
    data['password'] = userPassword;
    data['phone'] = userPhone;
    data['address'] = userAddress;
    data['image'] = userImage;
    return data;
  }
}
