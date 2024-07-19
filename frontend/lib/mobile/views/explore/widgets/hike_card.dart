import 'package:flutter/material.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
                        child: Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFavorite ? Colors.white : Colors.grey[200],
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.notifications_active
                                : Icons.notifications_off,
                            color: isFavorite ? Colors.redAccent : Colors.black26,
                            size: 20.0,
                            key: ValueKey<bool>(isFavorite),
                          ),
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
                  RichText(
                    text: TextSpan(
                      text: widget.hike.difficulty,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                      children: <TextSpan>[
                        const TextSpan(text: ' - '),
                        TextSpan(
                          text: "${widget.hike.duration} hrs",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: widget.hike.averageRating == 0
                            ? Colors.grey
                            : Colors.yellow[700],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      if (widget.hike.averageRating != 0)
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
