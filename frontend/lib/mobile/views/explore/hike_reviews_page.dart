import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/models/review.dart';
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/mobile/views/explore/widgets/review_widget.dart';

class HikeReviewsPage extends StatefulWidget {
  final int hikeId;

  const HikeReviewsPage({Key? key, required this.hikeId}) : super(key: key);

  @override
  _HikeReviewsPageState createState() => _HikeReviewsPageState();
}

class _HikeReviewsPageState extends State<HikeReviewsPage> {
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    setState(() {
      _reviewsFuture = Provider.of<HikeProvider>(context, listen: false)
          .fetchReviewsByHike(widget.hikeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.hikeReviews),
      ),
      body: FutureBuilder<List<Review>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final reviews = snapshot.data ?? [];
            return Column(
              children: [
                Expanded(
                  child: reviews.isEmpty
                      ? Center(child: Text(AppLocalizations.of(context)!.noReviewsFound))
                      : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return Card(
                        elevation: 4.0,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber),
                                  SizedBox(width: 4.0),
                                  Text(
                                    '${AppLocalizations.of(context)!.ratingHike(review.rating)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                review.comment.isNotEmpty
                                    ? review.comment
                                    : AppLocalizations.of(context)!.noCommentProvided,
                                style: TextStyle(fontSize: 14.0),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'by ${review.user.username}',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'on ${DateFormat('dd/MM/yyyy').format(review.createdAt)}',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ReviewWidget(hikeId: widget.hikeId, onReviewSubmitted: _loadReviews),
              ],
            );
          }
        },
      ),
    );
  }
}
