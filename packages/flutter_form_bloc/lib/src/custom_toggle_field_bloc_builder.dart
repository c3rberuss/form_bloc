import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_bloc/src/can_show_field_bloc_builder.dart';
import 'package:flutter_form_bloc/src/utils/utils.dart';
import 'package:form_bloc/form_bloc.dart';
import 'package:flutter_form_bloc/src/field_bloc_builder_control_affinity.dart';

/// A material design checkbox.
class CustomToggleFieldBlocBuilder extends StatelessWidget {
  const CustomToggleFieldBlocBuilder({
    Key key,
    @required this.booleanFieldBloc,
    this.enableOnlyWhenFormBlocCanSubmit = false,
    this.isEnabled = true,
    this.errorBuilder,
    this.padding,
    this.nextFocusNode,
    this.controlAffinity = FieldBlocBuilderControlAffinity.leading,
    this.animateWhenCanShow = true,
    @required this.toggleBuilder,
  })  : assert(enableOnlyWhenFormBlocCanSubmit != null),
        assert(controlAffinity != null),
        assert(isEnabled != null),
        assert(toggleBuilder != null),
        super(key: key);

  /// {@macro flutter_form_bloc.FieldBlocBuilder.fieldBloc}
  final BooleanFieldBloc<Object> booleanFieldBloc;

  /// {@template flutter_form_bloc.FieldBlocBuilderControlAffinity}
  // Where to place the control in widgets
  /// {@endtemplate}
  final FieldBlocBuilderControlAffinity controlAffinity;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.errorBuilder}
  final FieldBlocErrorBuilder errorBuilder;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.enableOnlyWhenFormBlocCanSubmit}
  final bool enableOnlyWhenFormBlocCanSubmit;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.isEnabled}
  final bool isEnabled;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.padding}
  final EdgeInsetsGeometry padding;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.nextFocusNode}
  final FocusNode nextFocusNode;

  /// {@macro  flutter_form_bloc.FieldBlocBuilder.animateWhenCanShow}
  final bool animateWhenCanShow;

  final Widget Function(bool value, Function(bool) onChanged) toggleBuilder;

  @override
  Widget build(BuildContext context) {
    if (booleanFieldBloc == null) {
      return SizedBox();
    }
    return CanShowFieldBlocBuilder(
      fieldBloc: booleanFieldBloc,
      animate: animateWhenCanShow,
      builder: (_, __) {
        return BlocBuilder<BooleanFieldBloc, BooleanFieldBlocState>(
          bloc: booleanFieldBloc,
          builder: (context, state) {
            return DefaultFieldBlocBuilderPadding(
              padding: padding,
              child: InputDecorator(
                decoration: Style.inputDecorationWithoutBorder.copyWith(
                  contentPadding: EdgeInsets.all(0),
                  prefixIcon: controlAffinity == FieldBlocBuilderControlAffinity.leading
                      ? _buildToggle(context: context, state: state)
                      : null,
                  suffixIcon: controlAffinity == FieldBlocBuilderControlAffinity.trailing
                      ? _buildToggle(context: context, state: state)
                      : null,
                  errorText: Style.getErrorText(
                    context: context,
                    errorBuilder: errorBuilder,
                    fieldBlocState: state,
                    fieldBloc: booleanFieldBloc,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildToggle({@required BuildContext context, @required BooleanFieldBlocState state}) {
    return toggleBuilder(
        state.value,
        fieldBlocBuilderOnChange<bool>(
          isEnabled: isEnabled,
          nextFocusNode: nextFocusNode,
          onChanged: booleanFieldBloc.updateValue,
        ));

    /*return Checkbox(
      checkColor: Style.getIconColor(
        customColor: checkColor,
        defaultColor: Theme.of(context).toggleableActiveColor,
      ),
      activeColor: activeColor,
      value: state.value,
      onChanged: fieldBlocBuilderOnChange<bool>(
        isEnabled: isEnabled,
        nextFocusNode: nextFocusNode,
        onChanged: booleanFieldBloc.updateValue,
      ),
    );*/
  }
}
