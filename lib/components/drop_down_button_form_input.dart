import 'package:flutter/material.dart';
import 'package:sleep_tracker/utils/style.dart';

/// [DropdownButtonFormInput] is the [DropdownButtonFormField] with local customized style.
///
class DropdownButtonFormInput<T> extends StatelessWidget {
  DropdownButtonFormInput({
    super.key,
    this.items,
    this.selectedItemBuilder,
    this.value,
    this.hint,
    this.disabledHint,
    this.onChanged,
    this.onTap,
    this.elevation = 8,
    this.style,
    this.icon,
    this.iconSize = 24.0,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.isDense = true,
    this.isExpanded = false,
    this.itemHeight,
    this.focusColor,
    this.focusNode,
    this.autofocus = false,
    this.dropdownColor,
    this.decoration,
    this.onSaved,
    this.validator,
    this.autovalidateMode,
    this.menuMaxHeight,
    this.enableFeedback,
    this.borderRadius,
    this.padding,
    this.radius = Style.radiusXs,
    this.contentPadding = const EdgeInsets.symmetric(vertical: Style.spacingSm, horizontal: Style.spacingMd),
    this.leading,
    this.trailing,
    this.label = "",
    this.labelConstraints = const BoxConstraints(minWidth: 72, maxWidth: 100),
    this.tileHorizontalSpacing = Style.spacingXxs,
  }) : assert(
          items == null ||
              items.isEmpty ||
              value == null ||
              items.where((DropdownMenuItem<T> item) {
                    return item.value == value;
                  }).length ==
                  1,
          "There should be exactly one item with [DropdownButton]'s value: "
          '$value. \n'
          'Either zero or 2 or more [DropdownMenuItem]s were detected '
          'with the same value',
        );
  final List<DropdownMenuItem<T>>? items;
  final List<Widget> Function(BuildContext)? selectedItemBuilder;
  final T? value;
  final Widget? hint;
  final Widget? disabledHint;
  final void Function(T?)? onChanged;
  final void Function()? onTap;
  final int elevation;
  final TextStyle? style;
  final Widget? icon;
  final Color? iconDisabledColor;
  final Color? iconEnabledColor;
  final double iconSize;
  final bool isDense;
  final bool isExpanded;
  final double? itemHeight;
  final Color? focusColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? dropdownColor;
  final InputDecoration? decoration;
  final void Function(T?)? onSaved;
  final String? Function(T?)? validator;
  final AutovalidateMode? autovalidateMode;
  final double? menuMaxHeight;
  final bool? enableFeedback;
  final AlignmentGeometry alignment = AlignmentDirectional.centerStart;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: contentPadding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: backgroundColor,
        ),
        child: Row(children: [
          ConstrainedBox(
            constraints: labelConstraints,
            child: Row(
              children: [
                if (leading != null) ...[leading!, SizedBox(width: tileHorizontalSpacing)],
                Expanded(child: Text(label, style: TextStyle(color: Theme.of(context).primaryColor)))
              ],
            ),
          ),
          Expanded(
              child: DropdownButtonFormField<T>(
            items: items,
            selectedItemBuilder: selectedItemBuilder,
            value: value,
            hint: hint,
            disabledHint: disabledHint,
            onChanged: onChanged,
            elevation: elevation,
            style: style,
            icon: icon,
            iconSize: iconSize,
            iconDisabledColor: iconDisabledColor,
            iconEnabledColor: iconEnabledColor,
            isDense: isDense,
            isExpanded: isExpanded,
            itemHeight: itemHeight,
            focusColor: focusColor,
            focusNode: focusNode,
            autofocus: autofocus,
            dropdownColor: dropdownColor,
            decoration: decoration,
            onSaved: onSaved,
            validator: validator,
            autovalidateMode: autovalidateMode,
            menuMaxHeight: menuMaxHeight,
            enableFeedback: enableFeedback,
            borderRadius: borderRadius,
            padding: padding,
          )),
          if (trailing != null) trailing!
        ]),
      ),
    );
  }
}
