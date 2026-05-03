import 'package:flutter/material.dart';

class AlertMessage {
  showAlert(BuildContext context, dynamic message, bool status) {
    final Color primaryColor =
        status ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F);
    final Color backgroundColor =
        status ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    SnackBar snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      duration: const Duration(seconds: 4),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                status ? Icons.check_circle_rounded : Icons.error_rounded,
                color: primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status ? "Success" : "Error",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    message.toString(),
                    style: const TextStyle(
                      color: Color(0xFF455A64),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () =>
                  ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              icon: Icon(
                Icons.close_rounded,
                color: primaryColor.withValues(alpha: 0.5),
                size: 18,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

Future showAlertDialog(BuildContext context) {
  Widget cancelButton = MaterialButton(
    shape: const BeveledRectangleBorder(side: BorderSide()),
    onPressed: () {
      Navigator.of(context).pop({'status': false});
    },
    child: const Text("Cancel"),
  );
  Widget continueButton = MaterialButton(
    onPressed: () {
      Navigator.of(context).pop({'status': true});
    },
    child: const Text("Continue"),
  );

  AlertDialog alert = AlertDialog(
    title: const Text("AlertDialog"),
    content: const Text(
        "Would you like to continue learning how to use Flutter alerts?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}