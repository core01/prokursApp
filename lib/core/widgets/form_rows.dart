import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/core/utils/organization_rules.dart';

/// A text field 44 pt tall at the default text size, like a list row: the body line is 22 pt.
const formFieldVerticalPadding = (kMinInteractiveDimensionCupertino - 22) / 2;

/// A labelled field in a form section; the error, if any, below it.
class FormFieldRow extends StatelessWidget {
  const FormFieldRow({
    super.key,
    required this.label,
    required this.child,
    this.error,
    this.labelWidth = 96,
  });

  final String label;
  final Widget child;
  final String? error;

  /// The label column: long labels (an organization's) need more than the default.
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    return CupertinoFormRow(
      padding: const EdgeInsetsDirectional.only(start: AppSpacing.lg, end: AppSpacing.xs),
      prefix: SizedBox(width: labelWidth, child: Text(label)),
      error: error == null
          ? null
          : Text(
              error!,
              style: AppTypography.footnote.copyWith(
                color: AppColors.error.resolveFrom(context),
              ),
            ),
      child: child,
    );
  }
}

/// The text field of a [FormFieldRow]: borderless, 44 pt tall.
CupertinoTextField formTextField({
  required TextEditingController controller,
  required String placeholder,
  required ValueChanged<String> onChanged,
  TextInputType? keyboardType,
  int? maxLines = 1,
  int? maxLength,
  bool enabled = true,
}) {
  return CupertinoTextField.borderless(
    controller: controller,
    placeholder: placeholder,
    placeholderStyle: const TextStyle(color: AppColors.secondaryLabel),
    padding: const EdgeInsetsDirectional.symmetric(
      horizontal: AppSpacing.xs,
      vertical: formFieldVerticalPadding,
    ),
    keyboardType: keyboardType,
    maxLines: maxLines,
    maxLength: maxLength,
    enabled: enabled,
    onChanged: onChanged,
  );
}

/// A date in a [FormFieldRow]: a tap opens a wheel to pick a day no later than [lastDate]
/// (today in Almaty unless given), and a button there clears it. [value] is a day, or null.
class FormDateRow extends StatelessWidget {
  const FormDateRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.error,
    this.placeholder = 'Не указана',
    this.labelWidth = 96,
    this.enabled = true,
    this.lastDate,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String? error;
  final String placeholder;
  final double labelWidth;
  final bool enabled;
  final DateTime? lastDate;

  Future<void> _pick(BuildContext context) async {
    final last = lastDate ?? todayInAlmaty();
    var picked = value != null && !value!.isAfter(last) ? value! : last;
    final result = await showCupertinoModalPopup<_DateChoice>(
      context: context,
      builder: (context) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context, _DateChoice.clear),
                    child: const Text('Очистить'),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context, _DateChoice.done),
                    child: const Text('Готово'),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: picked,
                  maximumDate: last,
                  onDateTimeChanged: (date) => picked = dateOnly(date),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (result == _DateChoice.done) onChanged(picked);
    if (result == _DateChoice.clear) onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final secondary = AppColors.secondaryLabel.resolveFrom(context);
    return FormFieldRow(
      label: label,
      error: error,
      labelWidth: labelWidth,
      child: CupertinoButton(
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.xs),
        minimumSize: const Size.square(kMinInteractiveDimensionCupertino),
        onPressed: enabled ? () => _pick(context) : null,
        child: Text(
          value == null ? placeholder : formatDate(value!),
          style: AppTypography.body.copyWith(
            color: value == null ? secondary : AppColors.label.resolveFrom(context),
          ),
        ),
      ),
    );
  }
}

enum _DateChoice { done, clear }
