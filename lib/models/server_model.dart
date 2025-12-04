class ServerModel {
  final String id;
  final String name;
  final String address;
  final int port;
  final String type;
  final String status;
  final String flag; // Emoji or asset path
  final bool isSelected;
  final String? url;

  ServerModel({
    required this.id,
    required this.name,
    required this.address,
    required this.port,
    required this.type,
    this.status = 'Idle',
    required this.flag,
    this.isSelected = false,
    this.url,
  });

  ServerModel copyWith({
    String? id,
    String? name,
    String? address,
    int? port,
    String? type,
    String? status,
    String? flag,
    bool? isSelected,
    String? url,
  }) {
    return ServerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      port: port ?? this.port,
      type: type ?? this.type,
      status: status ?? this.status,
      flag: flag ?? this.flag,
      isSelected: isSelected ?? this.isSelected,
      url: url ?? this.url,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'port': port,
      'type': type,
      'status': status,
      'flag': flag,
      'isSelected': isSelected,
      'url': url,
    };
  }

  factory ServerModel.fromJson(Map<String, dynamic> json) {
    return ServerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      port: json['port'] as int,
      type: json['type'] as String,
      status: json['status'] as String? ?? 'Idle',
      flag: json['flag'] as String,
      isSelected: json['isSelected'] as bool? ?? false,
      url: json['url'] as String?,
    );
  }
}
