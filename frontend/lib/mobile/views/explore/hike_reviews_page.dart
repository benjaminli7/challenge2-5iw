import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/models/review.dart';
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HikeReviewsPage extends StatelessWidget {
  final int hikeId;

  const HikeReviewsPage({Key? key, required this.hikeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.hikeReviews),
      ),
      body: FutureBuilder<List<Review>>(
        future: Provider.of<HikeProvider>(context, listen: false)
            .fetchReviewsByHike(hikeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return  Center(child: Text(AppLocalizations.of(context)!.noReviewsFound));
          } else {
            final reviews = snapshot.data!;
            return ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return ListTile(
                  title: Text(AppLocalizations.of(context)!.ratingHike(review.rating)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.comment.isNotEmpty
                          ? review.comment
                          : AppLocalizations.of(context)!.noCommentProvided),
                      Text('by ${review.user.email}'),
                      Text('on ${DateFormat('dd/MM/yyyy').format(review.createdAt)}'),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
