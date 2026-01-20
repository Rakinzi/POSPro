class BusinessSettingModel {
  final String? message;
  final String? pictureUrl;

  BusinessSettingModel({required this.message, required this.pictureUrl});

  factory BusinessSettingModel.fromJson(Map<String, dynamic> json) {
    return BusinessSettingModel(
      message: json['message'],
      pictureUrl: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': pictureUrl,
    };
  }
}
