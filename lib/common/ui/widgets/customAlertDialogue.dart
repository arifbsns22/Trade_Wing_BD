import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../uitls/constants/app_colors.dart';

customAlertDialogue({
  required BuildContext context,
  required String title,
  required IconData greetingsIcon,
  required String greetings,
  bool? isErrorDialogue,
  List<Widget>? actions,
}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
          backgroundColor: Colors.white,
          shadowColor: Colors.black54,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 30, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isErrorDialogue == true
                            ? Colors.red
                            : AppColors.primaryColor,
                        width: 1)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                          color: isErrorDialogue == true
                              ? Colors.red
                              : AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(
                        greetingsIcon,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Text(greetings,
                          style: TextStyle(
                              overflow: TextOverflow.visible,
                              fontSize: 15,
                              color: isErrorDialogue == true
                                  ? Colors.red
                                  : AppColors.primaryColor)),
                    )
                  ],
                ),
              ),
            ],
          ),
          actions: actions);
    },
  );
}
