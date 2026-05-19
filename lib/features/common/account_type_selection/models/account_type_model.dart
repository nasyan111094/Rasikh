






import '../../Auth/models/auth_model.dart';

class AccountTypeModel {
  final VendorType type;
  final String title;
  final String subtitle;
  final String icon;

  const AccountTypeModel({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}