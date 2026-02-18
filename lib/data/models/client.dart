class Client {
  final int? id;
  final String uuid;
  final String name;
  final String? phone;
  final String? address;
  final String? photoPath;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Client({
    this.id,
    required this.uuid,
    required this.name,
    this.phone,
    this.address,
    this.photoPath,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Client copyWith({
    int? id,
    String? uuid,
    String? name,
    String? phone,
    String? address,
    String? photoPath,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'phone': phone,
      'address': address,
      'photoPath': photoPath,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      photoPath: map['photoPath'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Client.fromJson(Map<String, dynamic> json) => Client.fromMap(json);
}
