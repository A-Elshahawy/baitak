class TenantOut {
  const TenantOut({
    required this.id,
    required this.name,
    required this.phone,
    required this.startDate,
    required this.active,
    this.hasUnpaid = false,
  });

  final int id;
  final String name;
  final String phone;
  final DateTime startDate;
  final bool active;
  final bool hasUnpaid;

  factory TenantOut.fromJson(Map<String, dynamic> json) => TenantOut(
        id: json['id'] as int,
        name: json['name'] as String,
        phone: json['phone'] as String,
        startDate: DateTime.parse(json['start_date'] as String),
        active: json['active'] as bool,
        hasUnpaid: json['has_unpaid'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'start_date': startDate.toIso8601String(),
        'active': active,
        'has_unpaid': hasUnpaid,
      };

  TenantOut copyWith({
    int? id,
    String? name,
    String? phone,
    DateTime? startDate,
    bool? active,
    bool? hasUnpaid,
  }) {
    return TenantOut(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      startDate: startDate ?? this.startDate,
      active: active ?? this.active,
      hasUnpaid: hasUnpaid ?? this.hasUnpaid,
    );
  }
}

class TenantWithContext extends TenantOut {
  const TenantWithContext({
    required super.id,
    required super.name,
    required super.phone,
    required super.startDate,
    required super.active,
    this.bedId,
    this.bedLabel,
    this.roomName,
    this.aptId,
    this.aptName,
    this.rentAmount,
  });

  final int? bedId;
  final String? bedLabel;
  final String? roomName;
  final int? aptId;
  final String? aptName;
  final double? rentAmount;

  factory TenantWithContext.fromJson(Map<String, dynamic> json) =>
      TenantWithContext(
        id: json['id'] as int,
        name: json['name'] as String,
        phone: json['phone'] as String,
        startDate: DateTime.parse(json['start_date'] as String),
        active: json['active'] as bool,
        hasUnpaid: json['has_unpaid'] as bool? ?? false,
        bedId: json['bed_id'] as int?,
        bedLabel: json['bed_label'] as String?,
        roomName: json['room_name'] as String?,
        aptId: json['apt_id'] as int?,
        aptName: json['apt_name'] as String?,
        rentAmount: json['rent_amount'] != null
            ? (json['rent_amount'] as num).toDouble()
            : null,
      );

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'bed_id': bedId,
        'bed_label': bedLabel,
        'room_name': roomName,
        'apt_id': aptId,
        'apt_name': aptName,
        'rent_amount': rentAmount,
      };

  TenantWithContext copyWithContext({
    int? id,
    String? name,
    String? phone,
    DateTime? startDate,
    bool? active,
    bool? hasUnpaid,
    int? bedId,
    String? bedLabel,
    String? roomName,
    int? aptId,
    String? aptName,
    double? rentAmount,
  }) {
    return TenantWithContext(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      startDate: startDate ?? this.startDate,
      active: active ?? this.active,
      hasUnpaid: hasUnpaid ?? this.hasUnpaid,
      bedId: bedId ?? this.bedId,
      bedLabel: bedLabel ?? this.bedLabel,
      roomName: roomName ?? this.roomName,
      aptId: aptId ?? this.aptId,
      aptName: aptName ?? this.aptName,
      rentAmount: rentAmount ?? this.rentAmount,
    );
  }

  String get breadcrumb {
    final parts = <String>[
      if (aptName != null) aptName!,
      if (roomName != null) roomName!,
      if (bedLabel != null) bedLabel!,
    ];
    return parts.isEmpty ? '—' : parts.join(' · ');
  }
}
