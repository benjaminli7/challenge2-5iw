import 'package:flutter/material.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/services/config_service.dart';

class HikeCard extends StatefulWidget {
  final Hike hike;

  const HikeCard({super.key, required this.hike});

  @override
  _HikeCardState createState() => _HikeCardState();
}

class _HikeCardState extends State<HikeCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      bool contain = widget.hike.subscriptions
          .any((element) => element.userId == user?.id);
      if (user != null && contain) {
        setState(() {
          isFavorite = true;
        });
      }
    });
  }

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
      final hikeProvider = Provider.of<HikeProvider>(context, listen: false);
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user != null) {
        hikeProvider.userSubscribeToHike(widget.hike.id, user.id, user.token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String baseUrl = ConfigService.baseUrl;

    return GestureDetector(
      onTap: () {
        GoRouter.of(context).push('/hike/${widget.hike.id}');
      },
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Image.network(
                    Uri.parse("$baseUrl${widget.hike.image}").toString(),
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: GestureDetector(
                      onTap: toggleFavorite,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                              scale: animation, child: child);
                        },
                        child: Icon(
                          isFavorite
                              ? Icons.notifications_active
                              : Icons.notifications_off,
                          color: isFavorite ? Colors.redAccent : Colors.black26,
                          size: 24.0,
                          key: ValueKey<bool>(isFavorite),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.hike.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.yellow[700], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.hike.averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 13.0, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
