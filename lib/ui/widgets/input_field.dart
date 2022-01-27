//d
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme.dart';

class InputField extends StatelessWidget {
  const InputField({
    Key? key,
    required this.title,
    required this.hint,
    this.controller,
    this.widget,
    this.autofocus,
  }) : super(key: key);
  final bool? autofocus;
  final String title;
  final String hint;
  final TextEditingController? controller;
  final Widget? widget;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: titleStyle,
              ),
              const SizedBox(
                width: 5,
              ),
              if (widget == null)
                Text('Required'.tr,
                    style:
                        titleStyle.copyWith(color: Colors.red.withOpacity(0.9)))
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            focusNode: FocusNode(canRequestFocus: false),
            textAlign: Get.locale.toString() == 'ar'
                ? TextAlign.right
                : TextAlign.left,
            maxLines: null,
            controller: controller,
            style: subTitleStyle,
            autofocus: autofocus ?? false,
            readOnly: widget != null ? true : false,
            cursorColor: Get.isDarkMode ? Colors.grey[100] : Colors.grey[700],
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10),
              suffixIcon: widget,
              hintText: hint,
              hintStyle: subTitleStyle,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(width: 1, color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(width: 1, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
