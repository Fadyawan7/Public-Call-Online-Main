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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomImageWidget(
                      containerHeight: 250,
                      containerWidth: 260,
                      fit: BoxFit.cover,
                      image:
                      '${freelancer.portfolio![startIndex].imageUrl}',
                    ),
                  ),
                const SizedBox(
                    width: Dimensions.paddingSizeSmall),
                if (startIndex + 1 < freelancer.portfolio!.length)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CustomImageWidget(
                          containerHeight: 235 / 2,
                          containerWidth: 255 / 2,
                          fit: BoxFit.cover,
                          image:
                          '${freelancer.portfolio![startIndex + 1].imageUrl}',
                        ),
                      ),
                      const SizedBox(
                          height: Dimensions.paddingSizeSmall),
                      if (startIndex + 2 <
                          freelancer.portfolio!.length)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CustomImageWidget(
                            containerHeight: 235 / 2,
                            containerWidth: 255 / 2,
                            fit: BoxFit.cover,
                            image:
                            '${freelancer.portfolio![startIndex + 2].imageUrl}',
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
