import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mashrou3i/core/theme/color.dart';
import '../../../../../../core/theme/icons_broken.dart';
import 'items_get_cubit.dart';
import 'items_git_states.dart';

class RatingWidget extends StatefulWidget {
  final double initialRating;
  final int reviewCount;
  final int userId;
  final int creatorId;

  const RatingWidget({
    super.key,
    this.initialRating = 0.0,
    required this.reviewCount,
    required this.userId,
    required this.creatorId,
  });

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  late double _currentRating;
  late int _reviewCount;

  final TextEditingController _commentController = TextEditingController();
  double _selectedRating = 0.0;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
    _reviewCount = widget.reviewCount;
    _selectedRating = _currentRating;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showRatingDialog(BuildContext context) {
    _commentController.clear();
    _selectedRating = _currentRating;

    showDialog(
      context: context,
      builder: (ctx) {
        return BlocConsumer<UserItemsCubit, UserItemsState>(
          listener: (ctx, state) {
            if (state is UserItemsRatingSuccess) {
              if (mounted) {
                setState(() {
                  _currentRating = _selectedRating;
                  _reviewCount += 1;
                });
              }
              Navigator.pop(ctx);

              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                    backgroundColor: textColor,
                    content: Text('Thank you for your rating!', style: TextStyle(color: Colors.black),)),
              );
            } else if (state is UserItemsRatingError) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(state.message.tr())),
              );
            }
          },
          builder: (ctx, state) {
            return AlertDialog(
              title: Text('Rate this store'.tr()),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              content: _RatingDialogContent(
                initialRating: _selectedRating,
                commentController: _commentController,
                onRatingChanged: (val) {
                  _selectedRating = val;
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel'.tr() , style: TextStyle(color: Colors.black),),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.amber),
                  ),
                  onPressed:
                      () {
                    context.read<UserItemsCubit>().submitItemRating(
                      userId: widget.userId,
                      creatorId: widget.creatorId,
                      rating: _selectedRating,
                    );
                  },
                  child: state is UserItemsRatingLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : Text('Submit'.tr() , style: TextStyle(color: Colors.black),),
                ),
              ],
            );
          },
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showRatingDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: textColor,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(FontAwesomeIcons.solidStar, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text(
              _currentRating.toStringAsFixed(1),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            if (_reviewCount > 0) ...[
              const SizedBox(width: 4),
              Text(
                '(+$_reviewCount)',
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
            const SizedBox(width: 8),
            Icon(Icons.edit_outlined, color: textColor, size: 18),
          ],
        ),
      ),
    );
  }
}

class _RatingDialogContent extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double> onRatingChanged;
  final TextEditingController commentController;

  const _RatingDialogContent({
    required this.initialRating,
    required this.onRatingChanged,
    required this.commentController,
  });

  @override
  State<_RatingDialogContent> createState() => _RatingDialogContentState();
}

class _RatingDialogContentState extends State<_RatingDialogContent> {
  late double _selectedRating;
  @override
  void initState() {
    super.initState();
    _selectedRating = widget.initialRating;
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  index < _selectedRating ? FontAwesomeIcons.solidStar : IconBroken.Star,
                  color: Colors.amber,
                  size: 30,
                ),
                onPressed: () {
                  setState(() {
                    _selectedRating = index + 1.0;
                    widget.onRatingChanged(_selectedRating);
                  });
                },
              );
            }),
          ),

        ],
      ),
    );
  }
}