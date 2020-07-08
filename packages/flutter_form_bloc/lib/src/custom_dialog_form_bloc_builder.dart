import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_form_bloc/src/utils/utils.dart';

class CustomDialogFormBlocBuilder<Value> extends StatefulWidget {
  /// {@macro flutter_form_bloc.FieldBlocBuilder.fieldBloc}
  final TextFieldBloc textFieldBloc;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.errorBuilder}
  final FieldBlocErrorBuilder errorBuilder;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.enableOnlyWhenFormBlocCanSubmit}
  final bool enableOnlyWhenFormBlocCanSubmit;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.isEnabled}
  final bool isEnabled;

  /// If `true` an empty item is showed at the top of the dropdown items,
  /// and can be used for deselect.
  final bool showEmptyItem;

  /// The milliseconds for show the dropdown items when the keyboard is open
  /// and closes. By default is 600 milliseconds.
  final int millisecondsForShowDropdownItemsWhenKeyboardIsOpen;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.padding}
  final EdgeInsetsGeometry padding;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.nextFocusNode}
  final FocusNode nextFocusNode;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.focusNode}
  final FocusNode focusNode;

  /// {@template flutter_form_bloc.FieldBlocBuilder.decoration}
  /// The decoration to show around the field.
  /// {@endtemplate}
  final InputDecoration decoration;

  /// How the text in the decoration should be aligned horizontally.
  final TextAlign textAlign;

  /// {@macro  flutter_form_bloc.FieldBlocBuilder.animateWhenCanShow}
  final bool animateWhenCanShow;

  final String Function(Value) showSelected;
  final Future<Value> Function() getValueFromDialog;
  final bool showClearIcon;
  final Icon clearIcon;

  CustomDialogFormBlocBuilder({
    Key key,
    @required this.textFieldBloc,
    this.enableOnlyWhenFormBlocCanSubmit = false,
    this.isEnabled = true,
    this.errorBuilder,
    this.padding,
    this.decoration = const InputDecoration(),
    @required this.animateWhenCanShow,
    this.nextFocusNode,
    this.showEmptyItem = true,
    this.millisecondsForShowDropdownItemsWhenKeyboardIsOpen = 600,
    this.focusNode,
    this.textAlign,
    @required this.showSelected,
    this.showClearIcon = true,
    this.clearIcon,
    @required this.getValueFromDialog,
  });

  @override
  _CustomDialogFormBlocBuilderState createState() => _CustomDialogFormBlocBuilderState<Value>();
}

class _CustomDialogFormBlocBuilderState<Value> extends State<CustomDialogFormBlocBuilder<Value>> {
  FocusNode _focusNode = FocusNode();

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _focusNode;

  @override
  void initState() {
    _effectiveFocusNode.addListener(_onFocusRequest);
    super.initState();
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_onFocusRequest);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusRequest() {
    if (_effectiveFocusNode.hasFocus) {
      _showDialog(context);
    }
  }

  void _showDialog(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());

    var result = await widget.getValueFromDialog();

    if (result != null) {
      fieldBlocBuilderOnChange<Value>(
        isEnabled: widget.isEnabled,
        nextFocusNode: widget.nextFocusNode,
        onChanged: (value) {
          widget.textFieldBloc.updateValue(widget.showSelected(value));
          widget.textFieldBloc.updateExtraData(value);
          // Used for hide keyboard
          // FocusScope.of(context).requestFocus(FocusNode());
        },
      )(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.textFieldBloc == null) {
      return SizedBox();
    }

    return Focus(
      focusNode: _effectiveFocusNode,
      child: CanShowFieldBlocBuilder(
        fieldBloc: widget.textFieldBloc,
        animate: widget.animateWhenCanShow,
        builder: (_, __) {
          return BlocBuilder<TextFieldBloc, TextFieldBlocState>(
            bloc: widget.textFieldBloc,
            builder: (context, state) {
              final isEnabled = fieldBlocIsEnabled(
                isEnabled: this.widget.isEnabled,
                enableOnlyWhenFormBlocCanSubmit: widget.enableOnlyWhenFormBlocCanSubmit,
                fieldBlocState: state,
              );

              Widget child;

              if (state.value == null ||
                  state.value.isEmpty && widget.decoration.hintText != null) {
                child = Text(
                  widget.decoration.hintText,
                  style: widget.decoration.hintStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: widget.decoration.hintMaxLines,
                );
              } else {
                child = Text(
                  state.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: Style.getDefaultTextStyle(
                    context: context,
                    isEnabled: isEnabled,
                  ),
                );
              }

              return DefaultFieldBlocBuilderPadding(
                padding: widget.padding,
                child: GestureDetector(
                  onTap: !isEnabled ? null : () => _showDialog(context),
                  child: InputDecorator(
                    decoration: _buildDecoration(context, state, isEnabled),
                    isEmpty: (state.value == null || state.value.isEmpty) &&
                        widget.decoration.hintText == null,
                    child: child,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  InputDecoration _buildDecoration(BuildContext context, TextFieldBlocState state, bool isEnabled) {
    InputDecoration decoration = this.widget.decoration;

    decoration = decoration.copyWith(
      enabled: isEnabled,
      errorText: Style.getErrorText(
        context: context,
        errorBuilder: widget.errorBuilder,
        fieldBlocState: state,
        fieldBloc: widget.textFieldBloc,
      ),
      suffixIcon: decoration.suffixIcon ??
          (widget.showClearIcon
              ? AnimatedOpacity(
                  duration: Duration(milliseconds: 400),
                  opacity: widget.textFieldBloc.state.value == null ||
                          widget.textFieldBloc.state.value.isEmpty
                      ? 0.0
                      : 1.0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    child: widget.clearIcon ?? Icon(Icons.clear),
                    onTap: widget.textFieldBloc.state.value == null
                        ? null
                        : widget.textFieldBloc.clear,
                  ),
                )
              : null),
    );

    return decoration;
  }
}
