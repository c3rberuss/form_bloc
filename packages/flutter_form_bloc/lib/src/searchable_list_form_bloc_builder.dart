import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_form_bloc/src/utils/utils.dart';


class SearchableListFormBlocBuilder<Value> extends StatefulWidget {

  /// {@macro flutter_form_bloc.FieldBlocBuilder.fieldBloc}
  final SelectFieldBloc<Value, Object> selectFieldBloc;

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

  final Widget Function(Value) itemBuilder;
  final String Function(Value) showSelected;
  final bool Function(String, Value) searchCondition;

  SearchableListFormBlocBuilder({
    Key key,
    @required this.selectFieldBloc,
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
    @required this.itemBuilder,
    @required this.searchCondition,
  });

  @override
  _SearchableListFormBlocBuilderState createState() => _SearchableListFormBlocBuilderState<Value>();
}

class _SearchableListFormBlocBuilderState<Value> extends State<SearchableListFormBlocBuilder<Value>> {

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
      _showList(context);
    }
  }

  void _showList(BuildContext context) async{
    FocusScope.of(context).requestFocus(FocusNode());
    var result = await showDialog<Value>(
      context: context,
      builder: (context) {
        return _DialogSearchable<Value>(
          showSelected: widget.showSelected,
          items: widget.selectFieldBloc.state.items,
          buildItem: widget.itemBuilder,
          searchCondition: widget.searchCondition,
        );
      },
    );

    if (result != null) {
      fieldBlocBuilderOnChange<Value>(
        isEnabled: widget.isEnabled,
        nextFocusNode: widget.nextFocusNode,
        onChanged: (value) {
          widget.selectFieldBloc.updateValue(value);
          // Used for hide keyboard
          // FocusScope.of(context).requestFocus(FocusNode());
        },
      )(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _DialogSearchable<Value> extends StatefulWidget {

  final List<Value> items;
  final Widget Function(Value) buildItem;
  final String Function(Value) showSelected;
  final bool Function(String, Value) searchCondition;


  _DialogSearchable({this.items, this.buildItem, this.showSelected, this.searchCondition});

  @override
  __DialogSearchableState<Value> createState() => __DialogSearchableState<Value>();
}

class __DialogSearchableState<Value> extends State<_DialogSearchable<Value>> {

  List<Value> searchableList;
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
            widget.items.where((Value item) => widget.searchCondition(query, item)).toList();
      });
    }
  }
}
