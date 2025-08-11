// facility_model.dart
// 시설 타입 열거형
enum FacilityType {
  fireStation, // 소방서
  hospital, // 병원
  shelter, // 대피소
  policeStation, // 경찰서
  emergencyExit, // 비상구
}

// 시설 타입별 정보
extension FacilityTypeExtension on FacilityType {
  String get displayName {
    switch (this) {
      case FacilityType.fireStation:
        return '소방서';
      case FacilityType.hospital:
        return '병원';
      case FacilityType.shelter:
        return '대피소';
      case FacilityType.policeStation:
        return '경찰서';
      case FacilityType.emergencyExit:
        return '비상구';
    }
  }

  String get iconPath {
    switch (this) {
      case FacilityType.fireStation:
        return 'assets/icons/fire_station.png';
      case FacilityType.hospital:
        return 'assets/icons/hospital.png';
      case FacilityType.shelter:
        return 'assets/icons/shelter.png';
      case FacilityType.policeStation:
        return 'assets/icons/police.png';
      case FacilityType.emergencyExit:
        return 'assets/icons/exit.png';
    }
  }
}

// 시설 모델 클래스
class FacilityModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final FacilityType type;
  final String description;
  final bool isAvailable;
  final DateTime lastUpdated;

  FacilityModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.type,
    this.description = '',
    this.isAvailable = true,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  // JSON에서 객체로 변환
  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    return FacilityModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      phone: json['phone']?.toString() ?? '', // <- 기본값 처리
      type: json['type'] != null
          ? FacilityType.values.firstWhere(
              (e) => e.toString().split('.').last == json['type'],
              orElse: () => FacilityType.shelter,
            )
          : FacilityType.shelter, // <- shelter로 기본값 처리
      description: json['description'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      lastUpdated:
          DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }

  // 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'type': type.toString().split('.').last,
      'description': description,
      'isAvailable': isAvailable,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // 거리 계산을 위한 복사본 생성
  FacilityModel copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    FacilityType? type,
    String? description,
    bool? isAvailable,
    DateTime? lastUpdated,
  }) {
    return FacilityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'FacilityModel(id: $id, name: $name, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FacilityModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
