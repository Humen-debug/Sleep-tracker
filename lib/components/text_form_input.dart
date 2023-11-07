import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sleep_tracker/utils/style.dart';

const double _inputDecorationVerticalPadding = 12.0;
const double _defaultFontSize = 14.0;

/// [TextFormInput] is the [TextFormField] with local customized style.
///
class TextFormInput extends StatelessWidget {
  const TextFormInput({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.decoration,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.style,
    this.strutStyle,
    this.textDirection,
    this.textAlign = TextAlign.left,
    this.textAlignVertical,
    this.autofocus = false,
    this.readOnly = false,
    this.showCursor,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = false,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLengthEnforcement,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.onTapOutside,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.validator,
    this.inputFormatters,
    this.enabled,
    this.onSaved,
    this.radius = Style.radiusXs,
    this.contentPadding = const EdgeInsets.symmetric(vertical: Style.spacingSm, horizontal: Style.spacingMd),
    this.leading,
    this.trailing,
    this.label = "",
    this.labelConstraints = const BoxConstraints(minWidth: 72, maxWidth: 100),
    this.tileHorizontalSpacing = Style.spacingXxs,
  });
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool autofocus;
  final bool readOnly;
  final bool? showCursor;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final int? maxLength;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(PointerDownEvent)? onTapOutside;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final double radius;
  final EdgeInsets contentPadding;
  final Widget? leading;
  final Widget? trailing;
  final String label;
  final BoxConstraints labelConstraints;

  /// the spacing between the label and leading icon
  final double tileHorizontalSpacing;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = decoration?.fillColor ?? Theme.of(context).colorScheme.tertiary;
    final InputDecoration inputDecoration = decoration ?? const InputDecoration();
    final TextStyle inputTextStyle = style ?? const TextStyle();
    final double formFieldTopPadding = (inputDecoration.contentPadding?.vertical ?? _inputDecorationVerticalPadding);
    final double boxTopPadding = (formFieldTopPadding + contentPadding.top);
    final inputHeight = formFieldTopPadding * 2 +
        ((inputTextStyle.fontSize ?? _defaultFontSize) * (inputTextStyle.height ?? 1)) +
        contentPadding.vertical * 2;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            height: inputHeight,
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius), color: backgroundColor),
          ),
          Positioned.fill(
            top: boxTopPadding,
            left: contentPadding.left,
            right: contentPadding.right,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                alignment: AlignmentDirectional.topCenter,
                constraints: labelConstraints.copyWith(minHeight: math.max(labelConstraints.minHeight, inputHeight)),
                margin: EdgeInsets.only(top: formFieldTopPadding),
                child: Row(
                  children: [
                    if (leading != null) ...[leading!, SizedBox(width: tileHorizontalSpacing)],
                    Expanded(child: Text(label, style: TextStyle(color: Theme.of(context).primaryColor)))
                  ],
                ),
              ),
              Expanded(
                  child: TextFormField(
                controller: controller,
                initialValue: initialValue,
                focusNode: focusNode,
                decoration: decoration,
                keyboardType: keyboardType,
                textCapitalization: textCapitalization,
                textInputAction: textInputAction,
                style: style,
                strutStyle: strutStyle,
                textDirection: textDirection,
                textAlign: textAlign,
                textAlignVertical: textAlignVertical,
                autofocus: autofocus,
                readOnly: readOnly,
                showCursor: showCursor,
                obscuringCharacter: obscuringCharacter,
                obscureText: obscureText,
                autocorrect: autocorrect,
                smartDashesType: smartDashesType,
                smartQuotesType: smartQuotesType,
                enableSuggestions: enableSuggestions,
                maxLengthEnforcement: maxLengthEnforcement,
                maxLines: maxLines,
                minLines: minLines,
                expands: expands,
                maxLength: maxLength,
                onChanged: onChanged,
                onTapOutside: onTapOutside,
                onEditingComplete: onEditingComplete,
                onFieldSubmitted: onFieldSubmitted,
                validator: validator,
                inputFormatters: inputFormatters,
                enabled: enabled,
                onSaved: onSaved,
              )),
              if (trailing != null) trailing!
            ]),
          ),
        ],
      ),
    );
  }
}
