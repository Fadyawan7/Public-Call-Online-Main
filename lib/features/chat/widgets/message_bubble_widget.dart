import 'package:flutter/material.dart';
import 'package:flutter_restaurant/features/chat/domain/models/conversation_model.dart';
import 'package:flutter_restaurant/features/chat/providers/chat_provider.dart';
import 'package:flutter_restaurant/features/profile/providers/profile_provider.dart';
import 'package:flutter_restaurant/helper/date_converter_helper.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:provider/provider.dart';

class MessageBubbleWidget extends StatefulWidget {
  final ConversationModel? messages;
  final bool? isMe;
  const MessageBubbleWidget({super.key, this.messages, this.isMe});

  @override
  State<MessageBubbleWidget> createState() => _MessageBubbleWidgetState();
}

class _MessageBubbleWidgetState extends State<MessageBubbleWidget> {
  bool _initialFetchDone = false;
  final profileProvider =
      Provider.of<ProfileProvider>(Get.context!, listen: false);

  Future<void> _showImagePreview(String imageUrl) async {
    await showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    child: FadeInImage.assetNetwork(
                      placeholder: Images.placeholderImage,
                      image: imageUrl,
                      fit: BoxFit.contain,
                      imageErrorBuilder: (c, o, s) => Image.asset(
                        Images.placeholderImage,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Close',
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialFetchDone) {
      _initialFetchDone = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final userId = profileProvider.loggedInUserId;
        final senderId = widget.messages?.senderId;
        final bool isMe = userId == senderId;
        final String? attachmentPath = widget.messages?.attachment?.filePath;
        final String msg = widget.messages?.message ?? '';
        final bool isShortSingleLine =
            msg.isNotEmpty && !msg.contains('\n') && msg.length <= 40;

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            margin: EdgeInsets.only(
              left: isMe ? 54 : 4,
              right: isMe ? 4 : 54,
              top: 3,
              bottom: 3,
            ),
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 5),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFD9FDD3) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isMe ? 12 : 3),
                topRight: Radius.circular(isMe ? 3 : 12),
                bottomLeft: const Radius.circular(12),
                bottomRight: const Radius.circular(12),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.messages?.message != null &&
                    widget.messages!.message!.isNotEmpty)
                  Builder(builder: (_) {
                    if (isShortSingleLine) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              msg,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: rubikRegular.copyWith(
                                color: const Color(0xFF111B21),
                                fontSize: Dimensions.fontSizeDefault,
                                height: 1.35,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // timestamp + ticks for outgoing messages
                          if (isMe) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateConverterHelper.chatTimeOnly(
                                      widget.messages?.createdAt, context),
                                  style: rubikRegular.copyWith(
                                    color: const Color(0xFF667781),
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Builder(builder: (_) {
                                  final bool isRead =
                                      widget.messages?.isRead == true ||
                                          (widget.messages?.status != null &&
                                              widget.messages!.status!
                                                      .toLowerCase() ==
                                                  'read');
                                  final bool isDelivered = !isRead &&
                                      (widget.messages?.status != null &&
                                          widget.messages!.status!
                                                  .toLowerCase() ==
                                              'delivered');

                                  if (isRead) {
                                    return Icon(
                                      Icons.done_all,
                                      size: 16,
                                      color: const Color(0xFF34B7F1),
                                    );
                                  } else if (isDelivered) {
                                    return Icon(
                                      Icons.done_all,
                                      size: 16,
                                      color: const Color(0xFF667781),
                                    );
                                  } else {
                                    return Icon(
                                      Icons.done,
                                      size: 16,
                                      color: const Color(0xFF667781),
                                    );
                                  }
                                }),
                              ],
                            ),
                          ] else ...[
                            // for incoming messages show only timestamp inline
                            Text(
                              DateConverterHelper.chatTimeOnly(
                                  widget.messages?.createdAt, context),
                              style: rubikRegular.copyWith(
                                color: const Color(0xFF667781),
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                          ]
                        ],
                      );
                    }

                    // fallback: multi-line or long message -> show as block with timestamp below
                    return Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          msg,
                          style: rubikRegular.copyWith(
                            color: const Color(0xFF111B21),
                            fontSize: Dimensions.fontSizeDefault,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                    );
                  }),
                if (attachmentPath != null) ...[
                  if (widget.messages?.message != null &&
                      widget.messages!.message!.isNotEmpty)
                    const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _showImagePreview(
                      '${AppConstants.baseUrl}/storage/$attachmentPath',
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FadeInImage.assetNetwork(
                        placeholder: Images.placeholderImage,
                        height: 190,
                        width: 190,
                        fit: BoxFit.cover,
                        image:
                            '${AppConstants.baseUrl}/storage/$attachmentPath',
                        imageErrorBuilder: (c, o, s) => Image.asset(
                          Images.placeholderImage,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
                // show bottom timestamp/ticks only for non-short messages
                if (!isShortSingleLine) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Text(
                        DateConverterHelper.chatTimeOnly(
                            widget.messages?.createdAt, context),
                        style: rubikRegular.copyWith(
                          color: const Color(0xFF667781),
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        Builder(builder: (_) {
                          // Determine status: use isRead or status field if available
                          final bool isRead = widget.messages?.isRead == true ||
                              (widget.messages?.status != null &&
                                  widget.messages!.status!.toLowerCase() ==
                                      'read');
                          final bool isDelivered = !isRead &&
                              (widget.messages?.status != null &&
                                  widget.messages!.status!.toLowerCase() ==
                                      'delivered');

                          if (isRead) {
                            return Icon(
                              Icons.done_all,
                              size: 16,
                              color: const Color(0xFF34B7F1),
                            );
                          } else if (isDelivered) {
                            return Icon(
                              Icons.done_all,
                              size: 16,
                              color: const Color(0xFF667781),
                            );
                          } else {
                            return Icon(
                              Icons.done,
                              size: 16,
                              color: const Color(0xFF667781),
                            );
                          }
                        }),
                      ]
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
