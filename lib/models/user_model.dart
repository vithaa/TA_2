class UserModel {
  final String id;
  final String name;
  final String nikKtp;
  final String address;
  final String phone;
  final String role;
  final String? parentId; // untuk balita, ini adalah ID orang tua
  final DateTime? birthDate; // untuk balita
  final String? gender; // untuk balita
  final List<IMTRecord>? imtRecords; // untuk balita

  UserModel({
    required this.id,
    required this.name,
    required this.nikKtp,
    required this.address,
    required this.phone,
    required this.role,
    this.parentId,
    this.birthDate,
    this.gender,
    this.imtRecords,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      nikKtp: map['nikKtp'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
      parentId: map['parentId'],
      birthDate: map['birthDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['birthDate']) 
          : null,
      gender: map['gender'],
      imtRecords: map['imtRecords'] != null
          ? (map['imtRecords'] as List)
              .map((record) => IMTRecord.fromMap(record))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nikKtp': nikKtp,
      'address': address,
      'phone': phone,
      'role': role,
      'parentId': parentId,
      'birthDate': birthDate?.millisecondsSinceEpoch,
      'gender': gender,
      'imtRecords': imtRecords?.map((record) => record.toMap()).toList(),
    };
  }
}

class IMTRecord {
  final DateTime date;
  final double weight; // berat dalam kg
  final double height; // tinggi dalam cm
  final double imt;
  final String status; // normal, kurang, berlebih
  final String? notes;

  IMTRecord({
    required this.date,
    required this.weight,
    required this.height,
    required this.imt,
    required this.status,
    this.notes,
  });

  factory IMTRecord.fromMap(Map<String, dynamic> map) {
    return IMTRecord(
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      weight: map['weight'].toDouble(),
      height: map['height'].toDouble(),
      imt: map['imt'].toDouble(),
      status: map['status'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'weight': weight,
      'height': height,
      'imt': imt,
      'status': status,
      'notes': notes,
    };
  }
}
