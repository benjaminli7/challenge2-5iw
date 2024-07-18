import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/shared/models/review.dart';
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReviewWidget extends StatefulWidget {
  final int hikeId;
  final Function() onReviewSubmitted;

  const ReviewWidget({super.key, required this.hikeId, required this.onReviewSubmitted});

  @override
  _ReviewWidgetState createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 0;
  Review? _existingReview;
  bool _isSubmitting = false;

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

  String _sanitizeInput(String value) {
    final sanitized = value.replaceAll(RegExp(r'[<>]'), '');
    return sanitized;
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate() && !_isSubmitting) {
      setState(() {
        _isSubmitting = true;
      });
      final user = Provider.of<UserProvider>(context, listen: false).user;
      final now = DateTime.now().toUtc();
      final sanitizedComment = _sanitizeInput(_commentController.text);
      final review = Review(
        id: _existingReview?.id ?? 0,
        userId: user!.id,
        user: user,
        hikeId: widget.hikeId,
        rating: _rating,
        comment: sanitizedComment,
        createdAt: _existingReview?.createdAt ?? now,
        updatedAt: now,
      );

      if (_existingReview == null) {
        await Provider.of<HikeProvider>(context, listen: false)
            .createReview(review, user.token);
      } else {
        await Provider.of<HikeProvider>(context, listen: false)
            .updateReview(review, user.token);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.reviewSubmit)),
      );

      widget.onReviewSubmitted();

      setState(() {
        _existingReview = review;
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.rateHike,
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.comment,
                  border: OutlineInputBorder(),
                ),
                maxLength: 280,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (value.length > 280) {
                      return AppLocalizations.of(context)!.commentLonger;
                    }
                    if (!_isValidInput(value)) {
                      return AppLocalizations.of(context)!.invalidComment;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  child: _isSubmitting
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : Text(AppLocalizations.of(context)!.submitReview),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
