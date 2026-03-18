import 'tenant.dart';

class Bed {
  const Bed({
    required this.id,
    required this.label,
    required this.priceMonthly,
    this.tenant,
  });

  final int id;
  final String label;
  final int priceMonthly;
  final TenantOut? tenant;

  bool get isOccupied => tenant != null;

  factory Bed.fromJson(Map<String, dynamic> json) => Bed(
        id: json['id'] as int,
        label: json['label'] as String,
        priceMonthly: json['price_monthly'] as int,
        tenant: json['tenant'] != null
            ? TenantOut.fromJson(json['tenant'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'price_monthly': priceMonthly,
        'tenant': tenant?.toJson(),
      };

  Bed copyWith({
    int? id,
    String? label,
    int? priceMonthly,
    TenantOut? tenant,
  }) {
    return Bed(
      id: id ?? this.id,
      label: label ?? this.label,
      priceMonthly: priceMonthly ?? this.priceMonthly,
      tenant: tenant ?? this.tenant,
    );
  }
}

class Room {
  const Room({
    required this.id,
    required this.name,
    required this.orderIndex,
    required this.beds,
  });

  final int id;
  final String name;
  final int orderIndex;
  final List<Bed> beds;

  int get totalBeds => beds.length;
  int get occupiedBeds => beds.where((b) => b.isOccupied).length;
  int get vacantBeds => totalBeds - occupiedBeds;

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        id: json['id'] as int,
        name: json['name'] as String,
        orderIndex: json['order_index'] as int? ?? 0,
        beds: (json['beds'] as List<dynamic>? ?? [])
            .map((b) => Bed.fromJson(b as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'order_index': orderIndex,
        'beds': beds.map((b) => b.toJson()).toList(),
      };

  Room copyWith({
    int? id,
    String? name,
    int? orderIndex,
    List<Bed>? beds,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      orderIndex: orderIndex ?? this.orderIndex,
      beds: beds ?? this.beds,
    );
  }
}

class Apartment {
  const Apartment({
    required this.id,
    required this.name,
    required this.area,
    required this.address,
    required this.floor,
    required this.rooms,
  });

  final int id;
  final String name;
  final String area;
  final String address;
  final int floor;
  final List<Room> rooms;

  int get totalBeds =>
      rooms.fold(0, (sum, r) => sum + r.totalBeds);
  int get occupiedBeds =>
      rooms.fold(0, (sum, r) => sum + r.occupiedBeds);
  int get vacantBeds => totalBeds - occupiedBeds;
  double get revenueMonthly => rooms.fold(
        0.0,
        (sum, r) => sum +
            r.beds.where((b) => b.isOccupied).fold(
                  0.0,
                  (s, b) => s + b.priceMonthly,
                ),
      );

  factory Apartment.fromJson(Map<String, dynamic> json) => Apartment(
        id: json['id'] as int,
        name: json['name'] as String,
        area: json['area'] as String,
        address: json['address'] as String,
        floor: json['floor'] as int,
        rooms: (json['rooms'] as List<dynamic>? ?? [])
            .map((r) => Room.fromJson(r as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'area': area,
        'address': address,
        'floor': floor,
        'rooms': rooms.map((r) => r.toJson()).toList(),
      };

  Apartment copyWith({
    int? id,
    String? name,
    String? area,
    String? address,
    int? floor,
    List<Room>? rooms,
  }) {
    return Apartment(
      id: id ?? this.id,
      name: name ?? this.name,
      area: area ?? this.area,
      address: address ?? this.address,
      floor: floor ?? this.floor,
      rooms: rooms ?? this.rooms,
    );
  }
}
