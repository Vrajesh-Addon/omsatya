import 'package:flutter/material.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/build_box_decoration.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerHelper {
  Widget buildBasicShimmer({
    double height = double.infinity,
    double width = double.infinity,
    double radius = 6,
  }) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlighted,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecorations.buildBoxDecoration_1(radius: radius),
      ),
    );
  }

  Widget buildBasicShimmerCustomRadius(
      {double height = double.infinity,
      double? width = double.infinity,
      BorderRadius radius = BorderRadius.zero,}) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlighted,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: radius,
          color: AppColors.shimmerBase,
        ),
      ),
    );
  }

  buildListShimmer({itemCount = 10, itemHeight = 100.0}) {
    return ListView.builder(
      itemCount: itemCount,
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 0.0,
            left: AppDimen.paddingSmall,
            right: AppDimen.paddingSmall,
            bottom: AppDimen.paddingSmall,
          ),
          child: ShimmerHelper().buildBasicShimmer(height: itemHeight, radius: AppDimen.textRadius,),
        );
      },
    );
  }

  buildProductGridShimmer({controller, itemCount = 10}) {
    return GridView.builder(
        controller: controller,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.72,
        ),
        itemCount: itemCount,
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 20.0, bottom: 10, left: 18, right: 18),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: AppColors.shimmerBase,
            highlightColor: AppColors.shimmerHighlighted,
            child: Container(
              height: (index + 1) % 2 != 0 ? 250 : 300,
              width: double.infinity,
              decoration: BoxDecorations.buildBoxDecoration_1(radius: 16),
            ),
          );
        });
  }

  buildSquareGridShimmer({controller, itemCount = 10}) {
    return GridView.builder(
      itemCount: itemCount,
      controller: controller,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      padding: const EdgeInsets.all(AppDimen.paddingSmall),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: AppColors.shimmerBase,
            highlightColor: AppColors.shimmerHighlighted,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecorations.buildBoxDecoration_1(),
            ),
          ),
        );
      },
    );
  }

  buildHorizontalGridShimmerWithAxisCount({
    itemCount = 10,
    int crossAxisCount = 2,
    crossAxisSpacing = 10.0,
    mainAxisSpacing = 10.0,
    mainAxisExtent = 100.0,
    controller,
  }) {
    return GridView.builder(
        padding: const EdgeInsets.all(16),
        scrollDirection: Axis.horizontal,
        controller: controller,
        itemCount: itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: 10,
            mainAxisExtent: mainAxisExtent),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: AppColors.shimmerBase,
            highlightColor: AppColors.shimmerHighlighted,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecorations.buildBoxDecoration_1(),
            ),
          );
        });
  }

  buildSeparatedHorizontalListShimmer({
    double separationWidth = 16.0,
    int itemCount = 10,
    double itemHeight = 120,
  }) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      separatorBuilder: (context, index) => SizedBox(
        width: separationWidth,
      ),
      itemCount: itemCount,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.shimmerBase,
          highlightColor: AppColors.shimmerHighlighted,
          child: Container(
            height: itemHeight,
            width: double.infinity,
            decoration: BoxDecorations.buildBoxDecoration_1(),
          ),
        );
      },
    );
  }
}
