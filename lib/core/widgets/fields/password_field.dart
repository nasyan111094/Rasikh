import 'package:flutter/material.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:rasikh/core/widgets/fields/prefix_text_filed_icon.dart';
import 'package:size_config/size_config.dart';

import '../../utils/vaildData/valid_data.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.focusNode,
    this.confirm,
    this.onValidated,
    this.label,
    this.confirmedPassword,
    this.onChange,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? confirm;
  final ValueChanged<bool>? onValidated;
  final String? label;
  final String? confirmedPassword;
  final ValueChanged<String>? onChange ;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool isFocused = false;
  late FocusNode _focusNode;
  Color borderColor = colorSBTn;
  Color iconColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() {
        if (_focusNode.hasFocus) {
          borderColor = primary;
          iconColor = primary;
          isFocused = true;
        } else {
          borderColor = colorSBTn.withOpacity(.5);
          isFocused = false;
        }
      });
    });
    // Listen to text changes for real-time validation
    widget.controller.addListener(() {
      setState(() {
        widget.onValidated?.call(validate(widget.controller.text) == null);
      });
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool obscurePass = true;
 
    return StatefulBuilder(
      builder: (context, setState) => TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        textDirection: TextDirection.ltr,
        onTapOutside: (event) => FocusScope.of(context).unfocus(),
        onFieldSubmitted: widget.confirm,
        obscureText: obscurePass,

        textAlign: TextAlign.start,
        textInputAction: widget.confirm == null
            ? TextInputAction.next
            : TextInputAction.done,
        autofillHints: const [
          AutofillHints.password,
          AutofillHints.newPassword,
        ],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: widget.onChange,
        validator: validate,
        decoration: InputDecoration(
          hintText: widget.label ?? 'كلمة المرور',
          errorMaxLines: 3,
          hintStyle:  TextStyle(color: Color(0xFF808080)),
          errorStyle: const TextStyle(color: Colors.red),
          suffixIcon: ExcludeFocus(
            child: IconButton(
              onPressed: () => setState.call(() => obscurePass = !obscurePass),
              icon: Icon(
                obscurePass
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: isFocused ? primary : grey80,
              ),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor),
            borderRadius: BorderRadius.all(Radius.circular(12.w)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor),
            borderRadius: BorderRadius.all(Radius.circular(12.w)),
          ),
          labelStyle: getRegularBlack14Style(),
          prefixIcon: PrefixTextFiledIcon(
            icon: 'assets/icons/lock.svg',
            colorBorer: isFocused ? primary.withOpacity(.6) : colorSBTn,
            colorIcon: isFocused ? primary : grey80,
          ),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  String? validate(String? value) {
    if (!validString(value)) {
      return 'كلمة المرور غير صالحة أو فارغة';
    }
    if (validString(widget.confirmedPassword)) {
      if (value != widget.confirmedPassword) {
        return 'كلمة المرور غير متطابقة';
      }
    } else {
      if (value != null && !isStrongPassword(value)) 
      {
        return 'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل، حرف كبير، حرف صغير، رقم، وحرف خاص';
      }
    }
    return null;
  }

  bool isStrongPassword(String value) {
    // Strong password: at least 8 characters, 1 uppercase, 1 lowercase, 1 digit, 1 special character
    const minLength = 8;
    const uppercasePattern = r'(?=.*[A-Z])';
    const lowercasePattern = r'(?=.*[a-z])';
    const digitPattern = r'(?=.*\d)';
    const specialCharPattern = r'(?=.*[!@#$%^&*(),.?":{}|<>])';

    return value.length >= minLength &&
        RegExp(uppercasePattern).hasMatch(value) &&
        RegExp(lowercasePattern).hasMatch(value) &&
        RegExp(digitPattern).hasMatch(value) &&
        RegExp(specialCharPattern).hasMatch(value);
  }
}
