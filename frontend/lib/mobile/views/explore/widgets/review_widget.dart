import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/models/review.dart';
import 'package:frontend/shared/models/user.dart';
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';

class ReviewWidget extends StatefulWidget {
  final int hikeId;

  const ReviewWidget({super.key, required this.hikeId});

  @override
  _ReviewWidgetState createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 0;
  Review? _existingReview;

  @override
  void initState() {
    super.initState();
    _loadReview();
  }

  Future<void> _loadReview() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      final review = await Provider.of<HikeProvider>(context, listen: false)
          .fetchReviewByUser(user.id, widget.hikeId);
      if (review != null) {
        setState(() {
          _existingReview = review;
          _rating = review.rating;
          _commentController.text = review.comment;
        });
      } else {
        setState(() {
          _existingReview = null;
          _rating = 0;
          _commentController.text = '';
        });
      }
    }
  }


  bool _isValidInput(String value) {
    final regex = RegExp(r'[<>]');
    return !regex.hasMatch(value);
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate()) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      final now = DateTime.now().toUtc();
      final review = Review(
        id: _existingReview?.id ?? 0,
        userId: user!.id,
        user: user,
        hikeId: widget.hikeId,
        rating: _rating,
        comment: _commentController.text,
        createdAt: _existingReview?.createdAt ?? now,
        updatedAt: now,
      );

      if (_existingReview == null) {
        await Provider.of<HikeProvider>(context, listen: false)
            .createReview(review);
      } else {
        await Provider.of<HikeProvider>(context, listen: false)
            .updateReview(review);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted')),
      );

      setState(() {
        _existingReview = review;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rate this hike:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Comment (optional)',
              border: OutlineInputBorder(),
            ),
            maxLength: 280,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (value.length > 280) {
                  return 'Comment cannot be longer than 280 characters';
                }
                if (!_isValidInput(value)) {
                  return 'Invalid characters in comment';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: _submitReview,
              child: const Text('Submit Review'),
            ),
          ),
        ],
      ),
    );
  }
}
