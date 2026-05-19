import 'package:flutter/material.dart';
import 'package:rasikh/config/theme/colors.dart';
import 'package:rasikh/config/theme/styles_manager.dart';
import 'package:rasikh/core/widgets/fields/prefix_text_filed_icon.dart';
import 'package:size_config/size_config.dart';

class NationalIdField extends StatefulWidget {
  const NationalIdField({
    super.key,
    required this.controller,
    this.focusNode,
    this.showPreFixIcon = true,
    this.confirm,
    this.onValidated,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? confirm;
  final ValueChanged<bool>? onValidated;
  final bool? showPreFixIcon;

  @override
  State<NationalIdField> createState() => _NationalIdFieldState();
}

class _NationalIdFieldState extends State<NationalIdField> {
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
          borderColor = colorSBTn.withOpacity(0.5);
          iconColor = grey80;
          isFocused = false;
        }
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: TextFormField(
        controller: widget.controller,
        maxLength: 10,
        
        focusNode: _focusNode,
        onFieldSubmitted: widget.confirm,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.start,
        keyboardType: TextInputType.number, // Use number keyboard for digits
        textInputAction: widget.confirm == null
            ? TextInputAction.next
            : TextInputAction.done,
        validator: validate,
        decoration: InputDecoration(
          hintStyle:  const TextStyle(color: Color(0xFF808080)),
          counterText: '',
          hintText: "رقم الهوية الوطنية/الإقامة",
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor),
            borderRadius: BorderRadius.all(Radius.circular(12.w)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor),
            borderRadius: BorderRadius.all(Radius.circular(12.w)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.all(Radius.circular(12.w)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.all(Radius.circular(12.w)),
          ),
          labelStyle: getRegularBlack14Style(),
          prefixIcon: widget.showPreFixIcon == false
              ? null
              : PrefixTextFiledIcon(
            icon: 'assets/icons/identification.svg',
            colorBorer: isFocused ? primary.withOpacity(0.6) : colorSBTn,
            colorIcon: isFocused ? primary : grey80,
          ),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم الهوية الوطنية أو الإقامة';
    }

    // Saudi National ID/Iqama: 10 digits, starting with 1 (citizen) or 2 (resident)
    final idRegex = RegExp(r'^[1-2]\d{9}$');

    if (!idRegex.hasMatch(value)) {
      return 'رقم الهوية/الإقامة يجب أن يكون 10 أرقام ويبدأ بـ 1 أو 2';
    }

    widget.onValidated?.call(true); // Notify validation success
    return null;
  }
}
