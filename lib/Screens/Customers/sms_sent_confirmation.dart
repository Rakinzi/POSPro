import 'package:flutter/material.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

class SmsConfirmationPopup extends StatefulWidget {
  final String customerName;
  final String phoneNumber;
  final Function onSendSms;
  final VoidCallback onCancel;

  const SmsConfirmationPopup({
    super.key,
    required this.customerName,
    required this.phoneNumber,
    required this.onSendSms,
    required this.onCancel,
  });

  @override
  SmsConfirmationPopupState createState() => SmsConfirmationPopupState();
}

class SmsConfirmationPopupState extends State<SmsConfirmationPopup> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final scale = _animationController.value;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                // 'Confirm SMS to ${widget.customerName}',
                '${lang.S.of(context).confirmSMSTo} ${widget.customerName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8.0),
              Text(
                //'An SMS will be sent to the following number: ${widget.phoneNumber}',
                '${lang.S.of(context).anSMSWillBeSentToTheFollowingNumber} ${widget.phoneNumber}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: widget.onCancel,
                      child: Text(
                        lang.S.of(context).cancel,
                        //'Cancel'
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Flexible(
                    child: ElevatedButton(
                      style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(kMainColor)),
                      onPressed: () {
                        widget.onSendSms();
                        Navigator.pop(context);
                      },
                      child: Text(
                        lang.S.of(context).sendSMS,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        // 'Send SMS',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animationController.forward();
  }
}
