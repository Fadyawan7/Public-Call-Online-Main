import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';


class CustomPopScopeWidget extends StatefulWidget {
  final Widget child;
  final Function()? onPopInvoked;
  final bool isExit;

  const CustomPopScopeWidget({super.key, required this.child, this.onPopInvoked, this.isExit = true});

  @override
  State<CustomPopScopeWidget> createState() => _CustomPopScopeWidgetState();
}

class _CustomPopScopeWidgetState extends State<CustomPopScopeWidget> {

  void _showExitDialog() {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'exit_dialog',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Theme.of(dialogContext).cardColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x40000000),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 62,
                      width: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(dialogContext).colorScheme.error.withOpacity(0.12),
                      ),
                      child: Icon(
                        Icons.power_settings_new_rounded,
                        color: Theme.of(dialogContext).colorScheme.error,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      getTranslated('close_the_app', dialogContext) ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      getTranslated('do_you_want_to_close_and', dialogContext) ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(dialogContext).hintColor,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(getTranslated('no', dialogContext) ?? 'No'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              SystemNavigator.pop();
                            },
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: Theme.of(dialogContext).colorScheme.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(getTranslated('exit', dialogContext) ?? 'Exit'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: ResponsiveHelper.isDesktop(context),
      onPopInvokedWithResult: (didPop, result) {

        if (widget.onPopInvoked != null) {
          widget.onPopInvoked!();
        }

        if(didPop) {
          return;
        }

        if(!Navigator.canPop(context) && widget.isExit) {
          _showExitDialog();
        }else {
          if(Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }



      },
      child: widget.child,
    );
  }
}
