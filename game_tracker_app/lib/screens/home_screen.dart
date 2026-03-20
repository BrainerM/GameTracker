import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'my_tracker_screen.dart';
import 'login_screen.dart';
import 'dart:async'; // WAJIB ada buat Timer Debounce

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _games = [];
  bool _isLoading = true;

  // Controller buat Scroll & Search
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  int _currentPage = 1;
  bool _isFetchingMore = false;
  String _currentSearch = "";

  @override
  void initState() {
    super.initState();
    _fetchGames();

    // Sensor Scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        _loadMoreGames();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Fungsi ambil data fleksibel
  void _fetchGames({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _games = [];
      });
    }

    final String url = _currentSearch.isEmpty
        ? '${ApiService.rawgBaseUrl}/games?key=${ApiService.rawgApiKey}&page_size=15&page=$_currentPage'
        : '${ApiService.rawgBaseUrl}/games?key=${ApiService.rawgApiKey}&page_size=15&page=$_currentPage&search=$_currentSearch';

    final response = await ApiService.fetchGamesByUrl(url);

    if (mounted) {
      setState(() {
        _games.addAll(response);
        _isLoading = false;
        _isFetchingMore = false;
      });
    }
  }

  void _loadMoreGames() {
    if (_isFetchingMore) return;
    setState(() => _isFetchingMore = true);
    _currentPage++;
    _fetchGames();
  }

  // Logika Nunggu Berhenti Ngetik (Debounce)
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _currentSearch = query;
      _fetchGames(isRefresh: true);
    });
  }

  void _addGameToMyList(int gameId, String gameName) async {
    final success = await ApiService.addGameToTracker(gameId, 'wishlist');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? '$gameName ditambahkan!' : 'Gagal menambahkan.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkBackground = Color(0xFF000000);
    const accentBlue = Color(0xFF2979FF);

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: darkBackground,
        elevation: 0,
        title: const Text(
          'EXPLORE',
          style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyTrackerScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
            onPressed: () async {
              await ApiService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search games...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: accentBlue),
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: accentBlue),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _games.length + (_isFetchingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _games.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(color: accentBlue),
                          ),
                        );
                      }

                      final game = _games[index];
                      return Container(
                        height: 240,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  game['background_image'] ??
                                      'https://via.placeholder.com/400x250',
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) =>
                                      Container(color: Colors.grey[900]),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.9),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 15,
                              left: 15,
                              right: 15,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          game['name'] ?? 'Unknown',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "Rating: ${game['rating'] ?? 'N/A'}",
                                          style: const TextStyle(
                                            color: Colors.amber,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Material(
                                    color: accentBlue,
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      onTap: () => _addGameToMyList(
                                        game['id'] as int,
                                        game['name']?.toString() ?? 'Unknown',
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
