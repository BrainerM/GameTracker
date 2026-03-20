// lib/screens/my_tracker_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_game.dart';

class MyTrackerScreen extends StatefulWidget {
  const MyTrackerScreen({Key? key}) : super(key: key);

  @override
  _MyTrackerScreenState createState() => _MyTrackerScreenState();
}

class _MyTrackerScreenState extends State<MyTrackerScreen> {
  List<UserGame> _myGames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyGames();
  }

  void _loadMyGames() async {
    setState(() => _isLoading = true);
    final games = await ApiService.fetchMyTrackedGames();
    if (mounted) {
      setState(() {
        _myGames = games;
        _isLoading = false;
      });
    }
  }

  void _updateStatus(int id, String newStatus) async {
    final success = await ApiService.updateStatus(id, newStatus);
    if (success) {
      _loadMyGames();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status diperbarui ke $newStatus'),
          backgroundColor: Colors.blueAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _deleteGame(int id) async {
    final success = await ApiService.deleteGame(id);
    if (success) {
      _loadMyGames();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Game dihapus dari tracker'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF000000);
    const accentBlue = Color(0xFF2979FF);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        title: const Text(
          'MY TRACKER',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: accentBlue))
          : _myGames.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              physics: const BouncingScrollPhysics(),
              itemCount: _myGames.length,
              itemBuilder: (context, index) {
                return TrackerItemCard(
                  userGame: _myGames[index],
                  onUpdate: _updateStatus,
                  onDelete: _deleteGame,
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SUDAH DIPERBAIKI JADI HURUF KECIL
          Icon(Icons.search_off, size: 80, color: Colors.grey[800]),
          const SizedBox(height: 16),
          const Text(
            "Tracker kamu masih kosong!",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Ayo tambah game favorit lu di Home.",
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class TrackerItemCard extends StatelessWidget {
  final UserGame userGame;
  final Function(int, String) onUpdate;
  final Function(int) onDelete;

  const TrackerItemCard({
    Key? key,
    required this.userGame,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const accentBlue = Color(0xFF2979FF);

    return FutureBuilder<Map<String, dynamic>?>(
      future: ApiService.fetchGameDetails(userGame.gameId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Shimmer/Loading Effect
          return Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
          );
        }

        final gameData = snapshot.data!;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white10),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                gameData['background_image'] ??
                    'https://via.placeholder.com/150',
                width: 70,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 70,
                  color: Colors.grey[900],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
            title: Text(
              gameData['name'] ?? 'Unknown Game',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildStatusBadge(userGame.status),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              color: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (val) => val == 'delete'
                  ? onDelete(userGame.id)
                  : onUpdate(userGame.id, val),
              itemBuilder: (context) => [
                _buildPopupItem(
                  'wishlist',
                  'Wishlist',
                  Icons.bookmark_border,
                  Colors.blueAccent,
                ),
                _buildPopupItem(
                  'playing',
                  'Playing',
                  Icons.play_arrow,
                  Colors.orangeAccent,
                ),
                _buildPopupItem(
                  'completed',
                  'Completed',
                  Icons.check_circle_outline,
                  Colors.greenAccent,
                ),
                const PopupMenuDivider(height: 1),
                _buildPopupItem(
                  'delete',
                  'Remove',
                  Icons.delete_outline,
                  Colors.redAccent,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String value,
    String text,
    IconData icon,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'playing':
        color = Colors.orangeAccent;
        break;
      case 'completed':
        color = Colors.greenAccent;
        break;
      default:
        color = Colors.blueAccent;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
