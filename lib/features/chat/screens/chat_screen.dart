import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/gradient_button_widget.dart';
import 'package:flutter_restaurant/common/widgets/no_data_widget.dart';
import 'package:flutter_restaurant/features/chat/providers/chat_provider.dart';
import 'package:flutter_restaurant/features/chat/widgets/chat_item_widget.dart';
import 'package:flutter_restaurant/helper/custom_snackbar_helper.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    _loadMessage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(builder: (context, chatProvider, _) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          toolbarHeight: 68,
          backgroundColor: const Color(0xFF5C6CFF).withAlpha(240),
          automaticallyImplyLeading: !ResponsiveHelper.isMobile(),
          iconTheme: const IconThemeData(color: Colors.white),
          titleSpacing: ResponsiveHelper.isMobile() ? 20 : 0,
          title: Text(
            getTranslated('Chat screen', context) ?? 'Messages',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: Consumer<ChatProvider>(builder: (context, chatProvider, _) {
          return const MessageListWidget();
        }),
      );
    });
  }

  void _loadMessage() async {
    final ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);

    await chatProvider.getChatList();
  }
}

class MessageListWidget extends StatelessWidget {
  const MessageListWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return ColoredBox(
        color: Colors.white,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await Provider.of<ChatProvider>(context, listen: false)
                          .getChatList();
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    color: Theme.of(context).cardColor,
                    child: chatProvider.chatList == null
                        ? _ChatListShimmerWidget(
                            isEnabled: chatProvider.chatList == null)
                        : chatProvider.chatList!.isNotEmpty
                            ? ListView.builder(
                                padding:
                                    const EdgeInsets.only(top: 6, bottom: 16),
                                itemCount: chatProvider.chatList?.length ?? 0,
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final chatItem =
                                      chatProvider.chatList![index];
                                  return Dismissible(
                                    key: Key(chatItem.id
                                        .toString()), // Each item needs a unique key
                                    direction: DismissDirection
                                        .endToStart, // Only allow swipe from right to left
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      padding: const EdgeInsets.only(right: 22),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE53935),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.delete,
                                          color: Colors.white),
                                    ),
                                    confirmDismiss: (direction) async {
                                      // Show confirmation dialog
                                      return await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Delete Message"),
                                          content: const Text(
                                              "Are you sure you want to delete this message?"),
                                          actions: [
                                            GradientButtonWidget(
                                              onTap: () => Navigator.of(context)
                                                  .pop(false),
                                              height: 36,
                                              borderRadius: 8,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              child: const Text(
                                                "Cancel",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            GradientButtonWidget(
                                              onTap: () => Navigator.of(context)
                                                  .pop(true),
                                              height: 36,
                                              borderRadius: 8,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              child: const Text(
                                                "Delete",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    onDismissed: (direction) {
                                      // Remove the item from the data source
                                      chatProvider
                                          .deleteChat(chatItem.id!, index)
                                          .then((chat) {
                                        showCustomSnackBarHelper(
                                            'Chat Deleted Successfully !',
                                            status: SnackBarStatus.success);
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        bottom: index ==
                                                (chatProvider
                                                            .chatList?.length ??
                                                        0) -
                                                    1
                                            ? 42
                                            : 0,
                                      ),
                                      child: ChatItemWidget(chats: chatItem),
                                    ),
                                  );
                                },
                              )
                            : SizedBox(
                                height: size.height,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    NoDataWidget(isFooter: false, isChat: true),
                                  ],
                                )),
                  );
                },
              ),
            ),
          ],
        ));
  }
}

class _ChatListShimmerWidget extends StatelessWidget {
  const _ChatListShimmerWidget({required this.isEnabled});
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 5,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFF0F2F5),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        clipBehavior: Clip.hardEdge,
        child: Shimmer(
            enabled: isEnabled,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Row(children: [
                Container(
                    width: 52, height: 52, color: const Color(0xFFE1E6E8)),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(
                          Dimensions.paddingSizeExtraSmall),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 150,
                              height: 16,
                              color: const Color(0xFFE1E6E8)),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          Container(
                              width: 200,
                              height: 14,
                              color: const Color(0xFFE1E6E8)),
                        ],
                      )),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Container(
                    width: 44, height: 12, color: const Color(0xFFE1E6E8)),
              ]),
            )),
      ),
    );
  }
}
