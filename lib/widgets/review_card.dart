import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../theme/app_colors.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final String? userName;

  const ReviewCard({super.key, required this.review, this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.dryadBark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.lightCharcoal.withOpacity(.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.blackKite,
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.gold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  userName ?? 'BookNest Reader',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.gold,
                    size: 18,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    review.rating,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (review.reviewText.isNotEmpty)
            Text(
              review.reviewText,
              style: const TextStyle(
                color: AppColors.ashes,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          const SizedBox(height: 10),
          Text(
            review.createdAt,
            style: const TextStyle(
              color: AppColors.lightCharcoal,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
