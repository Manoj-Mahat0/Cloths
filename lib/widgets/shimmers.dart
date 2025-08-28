import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBlock extends StatelessWidget {
  const ShimmerBlock({super.key, this.height, this.width, this.borderRadius = 8});

  final double? height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE9EDF5),
      highlightColor: const Color(0xFFF5F7FB),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key, this.itemCount = 6, this.itemHeight = 80});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (int i) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: <Widget>[
              const ShimmerBlock(height: 60, width: 60, borderRadius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    ShimmerBlock(height: 16, width: 160),
                    SizedBox(height: 8),
                    ShimmerBlock(height: 14, width: 120),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class ShimmerGrid extends StatelessWidget {
  const ShimmerGrid({super.key, this.crossAxisCount = 2, this.items = 6});

  final int crossAxisCount;
  final int items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.70,
      ),
      itemCount: items,
      itemBuilder: (BuildContext context, int i) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            Expanded(child: ShimmerBlock()),
            SizedBox(height: 8),
            ShimmerBlock(height: 14, width: 120),
          ],
        );
      },
    );
  }
}

class ShimmerChips extends StatelessWidget {
  const ShimmerChips({super.key, this.itemCount = 6, this.height = 58});

  final int itemCount;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (BuildContext context, int i) => const ShimmerBlock(height: 40, width: 90, borderRadius: 14),
      ),
    );
  }
}


