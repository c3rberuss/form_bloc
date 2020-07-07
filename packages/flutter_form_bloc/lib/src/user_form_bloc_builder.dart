import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_bloc/src/can_show_field_bloc_builder.dart';
import 'package:flutter_form_bloc/src/utils/utils.dart';
import 'package:form_bloc/form_bloc.dart';

/// A material design date picker.
class UserFormBlocBuilder<T> extends StatefulWidget {
  const UserFormBlocBuilder({
    Key key,
    @required this.dateTimeFieldBloc,
    this.enableOnlyWhenFormBlocCanSubmit = false,
    this.isEnabled = true,
    this.errorBuilder,
    this.padding,
    this.decoration = const InputDecoration(),
    this.textDirection,
    this.builder,
    this.useRootNavigator = false,
    this.routeSettings,
    @required this.animateWhenCanShow,
    this.showClearIcon = true,
    this.clearIcon,
    this.nextFocusNode,
    @required this.items,
    @required this.showSelected,
    @required this.buildItem,
    @required this.searchCondition,
    this.focusNode,
  })  : assert(enableOnlyWhenFormBlocCanSubmit != null),
        assert(isEnabled != null),
        assert(decoration != null),
        super(key: key);

  /// {@macro flutter_form_bloc.FieldBlocBuilder.fieldBloc}
  final InputFieldBloc<T, Object> dateTimeFieldBloc;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.errorBuilder}
  final FieldBlocErrorBuilder errorBuilder;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.enableOnlyWhenFormBlocCanSubmit}
  final bool enableOnlyWhenFormBlocCanSubmit;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.isEnabled}
  final bool isEnabled;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.padding}
  final EdgeInsetsGeometry padding;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.decoration}
  final InputDecoration decoration;

  /// {@macro  flutter_form_bloc.FieldBlocBuilder.animateWhenCanShow}
  final bool animateWhenCanShow;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.nextFocusNode}
  final FocusNode nextFocusNode;

  /// {@macro flutter_form_bloc.FieldBlocBuilder.focusNode}
  final FocusNode focusNode;

  final bool showClearIcon;

  final Icon clearIcon;

  final TextDirection textDirection;
  final TransitionBuilder builder;
  final bool useRootNavigator;
  final RouteSettings routeSettings;

  final List<T> items;
  final Widget Function(T) buildItem;
  final String Function(T) showSelected;
  final bool Function(String, T) searchCondition;

  @override
  _UserFormBlocBuilderState createState() => _UserFormBlocBuilderState<T>();
}

class _UserFormBlocBuilderState<T> extends State<UserFormBlocBuilder<T>> {
  final DatePickerMode initialDatePickerMode = DatePickerMode.day;

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
      _showPicker(context);
    }
  }

  void _showPicker(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    var result = await showDialog<T>(
      context: context,
      builder: (context) {
        return _DialogSearchable<T>(
          showSelected: widget.showSelected,
          items: widget.items,
          buildItem: widget.buildItem,
          searchCondition: widget.searchCondition,
        );
      },
    );

    if (result != null) {
      fieldBlocBuilderOnChange<T>(
        isEnabled: widget.isEnabled,
        nextFocusNode: widget.nextFocusNode,
        onChanged: (value) {
          widget.dateTimeFieldBloc.updateValue(value);
          // Used for hide keyboard
          // FocusScope.of(context).requestFocus(FocusNode());
        },
      )(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dateTimeFieldBloc == null) {
      return SizedBox();
    }

    return Focus(
      focusNode: _effectiveFocusNode,
      child: CanShowFieldBlocBuilder(
        fieldBloc: widget.dateTimeFieldBloc,
        animate: widget.animateWhenCanShow,
        builder: (_, __) {
          return BlocBuilder<InputFieldBloc<T, Object>, InputFieldBlocState<T, Object>>(
            bloc: widget.dateTimeFieldBloc,
            builder: (context, state) {
              final isEnabled = fieldBlocIsEnabled(
                isEnabled: this.widget.isEnabled,
                enableOnlyWhenFormBlocCanSubmit: widget.enableOnlyWhenFormBlocCanSubmit,
                fieldBlocState: state,
              );

              Widget child;

              if (state.value == null && widget.decoration.hintText != null) {
                child = Text(
                  widget.decoration.hintText,
                  style: widget.decoration.hintStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: widget.decoration.hintMaxLines,
                );
              } else {
                child = Text(
                  state.value != null ? widget.showSelected(state.value) : '',
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
                  onTap: !isEnabled ? null : () => _showPicker(context),
                  child: InputDecorator(
                    decoration: _buildDecoration(context, state, isEnabled),
                    isEmpty: state.value == null && widget.decoration.hintText == null,
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

  InputDecoration _buildDecoration(
      BuildContext context, InputFieldBlocState<T, Object> state, bool isEnabled) {
    InputDecoration decoration = this.widget.decoration;

    decoration = decoration.copyWith(
      enabled: isEnabled,
      errorText: Style.getErrorText(
        context: context,
        errorBuilder: widget.errorBuilder,
        fieldBlocState: state,
        fieldBloc: widget.dateTimeFieldBloc,
      ),
      suffixIcon: decoration.suffixIcon ??
          (widget.showClearIcon
              ? AnimatedOpacity(
                  duration: Duration(milliseconds: 400),
                  opacity: widget.dateTimeFieldBloc.state.value == null ? 0.0 : 1.0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    child: widget.clearIcon ?? Icon(Icons.clear),
                    onTap: widget.dateTimeFieldBloc.state.value == null
                        ? null
                        : widget.dateTimeFieldBloc.clear,
                  ),
                )
              : null),
    );

    return decoration;
  }

}

class _DialogSearchable<T> extends StatefulWidget {

  final List<T> items;
  final Widget Function(T) buildItem;
  final String Function(T) showSelected;
  final bool Function(String, T) searchCondition;


  _DialogSearchable({this.items, this.buildItem, this.showSelected, this.searchCondition});

  @override
  __DialogSearchableState<T> createState() => __DialogSearchableState<T>();
}

class __DialogSearchableState<T> extends State<_DialogSearchable<T>> {

  List<T> searchableList;
  TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    searchableList = widget.items;
    _searchController.addListener(() {
      _filterList(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {


    return  Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          print(MediaQuery.of(context).viewInsets.bottom);

          return Wrap(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
                    child: Text(
                      "Hint",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Search",
                        hintStyle: TextStyle(
                          //color: HexColor(textColor),
                          fontSize: 15,
                        ),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            style: BorderStyle.solid,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: constraints.biggest.height * 0.7,
                    child: ListView.builder(
                      itemCount: searchableList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            Navigator.pop(context, searchableList[index]);
                            _searchController.clear();
                          },
                          child: widget.buildItem(searchableList[index]),
                        );
                      },
                    ),
                  ),
                  Divider(),
                  Container(
                    height: constraints.biggest.height * 0.1,
                    padding: EdgeInsets.only(right: 8, bottom: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancelar"),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  _filterList(String query) {
    print(query);

    if (query.isNotEmpty) {
      setState(() {
        searchableList =
            widget.items.where((T item) => widget.searchCondition(query, item)).toList();
      });
    }
  }
}

