class UserGame {
  final int id;
  final int gameId;
  final String status;
  final DateTime addedAt;

  UserGame({
    required this.id,
    required this.gameId,
    required this.status,
    required this.addedAt,
  });

  factory UserGame.fromJson(Map<String, dynamic> json) {
    return UserGame(
      id: json['id'],
      gameId: json['game_id'],
      status: json['status'],
      addedAt: DateTime.parse(json['added_at']),
    );
  }
}
