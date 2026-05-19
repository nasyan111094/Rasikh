// features/help_center/data/models/help_center_models.dart

// ── Social Link ───────────────────────────────────────────────────────────────

class SocialLinkModel {
  final String id;
  final String platform;
  final String url;

  const SocialLinkModel({
    required this.id,
    required this.platform,
    required this.url,
  });

  factory SocialLinkModel.fromJson(Map<String, dynamic> json) {
    return SocialLinkModel(
      id: json['_id']?.toString() ?? '',
      platform: json['platform']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }
}

// ── Contact Model ─────────────────────────────────────────────────────────────

class ContactModel {
  final String id;
  final String email;
  final String phone;
  final String whatsapp;
  final List<SocialLinkModel> socialLinks;
  final String createdAt;
  final String updatedAt;

  const ContactModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.whatsapp,
    required this.socialLinks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    final links = (json['socialLinks'] as List<dynamic>? ?? [])
        .map((e) => SocialLinkModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return ContactModel(
      id: json['_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      whatsapp: json['whatsapp']?.toString() ?? '',
      socialLinks: links,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}

// ── Content Model  (shared by privacy-policy & terms) ────────────────────────

class ContentModel {
  final String id;

  /// Raw HTML string returned from the API
  final String content;
  final String createdAt;
  final String updatedAt;

  const ContentModel({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['_id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}
