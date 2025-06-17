import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';

/// Shimmer betöltő komponensek különböző UI elemekhez
class ShimmerWidgets {
  ShimmerWidgets._();

  static Widget baseShimmer(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.getPrimaryColor(context).withOpacity(0.08),
    highlightColor: AppColors.getCardColor(context).withOpacity(0.9),
    period: const Duration(milliseconds: 2500),
    child: Container(),
  );

  /// Ultra smooth kártya shimmer betöltő
  static Widget cardShimmer({
    double? height,
    double? width,
    BuildContext? context,
  }) {
    return Builder(
      builder: (builderContext) {
        final ctx = context ?? builderContext;
        return Shimmer.fromColors(
          baseColor: AppColors.getPrimaryColor(ctx).withOpacity(0.08),
          highlightColor: AppColors.getCardColor(ctx).withOpacity(0.9),
          period: const Duration(milliseconds: 2500),
          child: Container(
            height: height ?? 140,
            width: width,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.getCardColor(ctx),
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppColors.getCardShadow(ctx),
              border: Border.all(
                color: AppColors.getPrimaryColor(ctx).withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Lista elem shimmer
  static Widget listItemShimmer({BuildContext? context}) {
    return Builder(
      builder: (builderContext) {
        final ctx = context ?? builderContext;
        return Shimmer.fromColors(
          baseColor: AppColors.getPrimaryColor(ctx).withOpacity(0.08),
          highlightColor: AppColors.getCardColor(ctx).withOpacity(0.9),
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.getCardColor(ctx),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.getCardColor(ctx),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 150,
                        decoration: BoxDecoration(
                          color: AppColors.getCardColor(ctx),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Gyors hozzáférés gombok shimmer (3 gomb)
  static Widget quickAccessShimmer({BuildContext? context}) {
    return Builder(
      builder: (builderContext) {
        final ctx = context ?? builderContext;
        return Shimmer.fromColors(
          baseColor: AppColors.getPrimaryColor(ctx).withOpacity(0.08),
          highlightColor: AppColors.getCardColor(ctx).withOpacity(0.9),
          period: const Duration(milliseconds: 2500),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              3,
              (index) => Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.getCardColor(ctx),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.getCardShadow(ctx),
                      border: Border.all(
                        color: AppColors.getPrimaryColor(ctx).withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 60,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.getCardColor(ctx),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 45,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.getCardColor(ctx),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Menetrend shimmer
  static Widget timetableShimmer({BuildContext? context}) {
    return Builder(
      builder: (builderContext) {
        final ctx = context ?? builderContext;
        return Shimmer.fromColors(
          baseColor: AppColors.getPrimaryColor(ctx).withOpacity(0.08),
          highlightColor: AppColors.getCardColor(ctx).withOpacity(0.9),
          child: Column(
            children: List.generate(
              5,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.getCardColor(ctx),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.getPrimaryColor(ctx).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.getPrimaryColor(
                                ctx,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 12,
                            width: 100,
                            decoration: BoxDecoration(
                              color: AppColors.getPrimaryColor(
                                ctx,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.getPrimaryColor(ctx).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Térkép shimmer
  static Widget mapShimmer({BuildContext? context}) {
    return Builder(
      builder: (builderContext) {
        final ctx = context ?? builderContext;
        return Shimmer.fromColors(
          baseColor: AppColors.getPrimaryColor(ctx).withOpacity(0.08),
          highlightColor: AppColors.getCardColor(ctx).withOpacity(0.9),
          child: Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: AppColors.getCardColor(ctx),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Térkép alap
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.getPrimaryColor(ctx).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                // Markerek szimulálása
                Positioned(
                  top: 50,
                  left: 100,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.getPrimaryColor(ctx),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 150,
                  right: 80,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Hírek banner shimmer
  static Widget newsBannerShimmer({BuildContext? context}) {
    return Builder(
      builder: (builderContext) {
        final ctx = context ?? builderContext;
        return Shimmer.fromColors(
          baseColor: AppColors.getPrimaryColor(ctx).withOpacity(0.08),
          highlightColor: AppColors.getCardColor(ctx).withOpacity(0.9),
          child: Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.getCardColor(ctx),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.getPrimaryColor(ctx).withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.getPrimaryColor(
                              ctx,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 12,
                          width: 150,
                          decoration: BoxDecoration(
                            color: AppColors.getPrimaryColor(
                              ctx,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
