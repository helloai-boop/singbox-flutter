class ServerModel {
  final String id;
  final String name;
  final String address;
  final int port;
  final String type;
  final String status;
  final String flag; // Emoji or asset path
  final bool isSelected;

  ServerModel({
    required this.id,
    required this.name,
    required this.address,
    required this.port,
    required this.type,
    this.status = 'Idle',
    required this.flag,
    this.isSelected = false,
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
    );
  }
}
