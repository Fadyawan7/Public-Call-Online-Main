import 'package:flutter/material.dart';
import 'package:flutter_restaurant/features/chat/domain/models/chat_model.dart';
import 'package:flutter_restaurant/helper/date_converter_helper.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';

class ChatItemWidget extends StatelessWidget {
  final ChatModel chats;

  const ChatItemWidget({
    super.key,
    required this.chats,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        RouterHelper.getConversationScreen(chat: chats);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: const Color(0xFFE9EDEF),
              backgroundImage: chats.userImage != null
                  ? NetworkImage(chats.userImage!)
                  : null,
              onBackgroundImageError:
                  chats.userImage != null ? (_, __) {} : null,
              child: chats.userImage == null
                  ? Text(
                      chats.userName!.isNotEmpty
                          ? chats.userName![0].toUpperCase()
                          : '?',
                      style: rubikMedium.copyWith(
                        color: const Color(0xFF54656F),
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE9EDEF), width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            chats.userName ?? 'Unknown User',
                            style: rubikMedium.copyWith(
                              color: const Color(0xFF111B21),
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          DateConverterHelper.chatTimeOnly(
                              chats.createdAt, context),
                          style: rubikRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: const Color(0xFF667781),
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chats.lastMessage?.isNotEmpty == true
                                ? chats.lastMessage!
                                : '',
                            style: rubikRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: const Color(0xFF667781),
                              height: 1.25,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: Color(0xFFB3B9BD),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
