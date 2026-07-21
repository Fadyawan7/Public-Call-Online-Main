import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_image_widget.dart';
import 'package:flutter_restaurant/features/freelancer/domain/models/freelancer_model.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';

class FreelancerPortfolioWidget extends StatelessWidget {
  const FreelancerPortfolioWidget({
    super.key,
    required this.freelancer,
  });

  final FreelancerModel freelancer;

  void _openPortfolioImage(BuildContext context, String imageUrl) {
    if (imageUrl.trim().isEmpty) {
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (dialogContext) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 48,
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: 260,
      child: ListView.builder(
        key: PageStorageKey(freelancer.id),
        shrinkWrap: true,
        itemCount: (freelancer.portfolio!.length / 3).ceil(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          int startIndex = index * 3;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeExtraSmall,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (startIndex < freelancer.portfolio!.length)
                  GestureDetector(
                    onTap: () => _openPortfolioImage(
                      context,
                      '${freelancer.portfolio![startIndex].image_url}',
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CustomImageWidget(
                        containerHeight: 250,
                        containerWidth: 260,
                        fit: BoxFit.cover,
                        image: '${freelancer.portfolio![startIndex].image_url}',
                      ),
                    ),
                  ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                if (startIndex + 1 < freelancer.portfolio!.length)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _openPortfolioImage(
                          context,
                          '${freelancer.portfolio![startIndex + 1].image_url}',
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CustomImageWidget(
                            containerHeight: 235 / 2,
                            containerWidth: 255 / 2,
                            fit: BoxFit.cover,
                            image:
                                '${freelancer.portfolio![startIndex + 1].image_url}',
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      if (startIndex + 2 < freelancer.portfolio!.length)
                        GestureDetector(
                          onTap: () => _openPortfolioImage(
                            context,
                            '${freelancer.portfolio![startIndex + 2].image_url}',
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CustomImageWidget(
                              containerHeight: 235 / 2,
                              containerWidth: 255 / 2,
                              fit: BoxFit.cover,
                              image:
                                  '${freelancer.portfolio![startIndex + 2].image_url}',
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
