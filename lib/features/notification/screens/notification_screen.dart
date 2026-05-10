import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_loader_widget.dart';
import 'package:flutter_restaurant/common/widgets/gradient_card_widget.dart';
import 'package:flutter_restaurant/common/widgets/no_data_widget.dart';
import 'package:flutter_restaurant/features/notification/providers/notification_provider.dart';
import 'package:flutter_restaurant/features/notification/widgets/notification_dialog_widget.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<NotificationProvider>(context, listen: false)
        .getNotificationList(context);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBarWidget(
        context: context,
        leading: InkWell(
          onTap: () {
            if (Get.context!.canPop()) {
              Get.context!.pop();
            }
          },
          child: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: getTranslated('notification', context),
        titleColor: Colors.white,
      ) as PreferredSizeWidget?,
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          return notificationProvider.notificationList != null
              ? notificationProvider.notificationList!.isNotEmpty
                  ? RefreshIndicator(
                      onRefresh: () async {
                        await notificationProvider.getNotificationList(context);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        itemCount:
                            notificationProvider.notificationList!.length,
                        itemBuilder: (context, index) {
                          final item =
                              notificationProvider.notificationList![index];

                          return InkWell(
                            onTap: () =>
                                ResponsiveHelper.showDialogOrBottomSheet(
                              context,
                              NotificationDialogWidget(notificationModel: item),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              child: GradientCardWidget(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                borderRadius: 10,
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        Images.pcosplash,
                                        height: 32,
                                        width: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        item.title ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(fontSize: 13),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      item.createdAt ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const NoDataWidget(isNotification: true)
              : Center(
                  child: CustomLoaderWidget(
                    color: Theme.of(context).primaryColor,
                  ),
                );
        },
      ),
    );
  }
}
