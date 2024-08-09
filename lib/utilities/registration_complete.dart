import 'package:flutter/material.dart';
import 'package:truitrak2/utilities/dialogs/generic_dialog.dart';

Future<void> showRegistrationCompleteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Registration Complete.',
    content:
        'Now Login!',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}