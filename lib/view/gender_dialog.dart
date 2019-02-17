import 'package:flutter/material.dart';


class GenderDialog extends StatefulWidget {
  final int initalGender;
  final ValueChanged valueChangedCallback;
  const GenderDialog({Key key, this.initalGender, this.valueChangedCallback}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _GenderDialogState();
  }
}

class _GenderDialogState extends State<GenderDialog> {
  int _seletedGender;
  @override
  void initState() {
    _seletedGender =widget.initalGender;
    super.initState();
  }

  _onChangeGender(value){
    setState(() {
      _seletedGender = value;
    });
    widget.valueChangedCallback(value);
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
          title: Text('select gender'),
          children: <Widget>[
            RadioListTile(
              title: Text('Male'),
              value: 0,
              groupValue: _seletedGender,
              onChanged: _onChangeGender,
            ),
            RadioListTile(
              title: Text('Female'),
              value: 1,
              groupValue: _seletedGender,
              onChanged: _onChangeGender,
            ),
            RadioListTile(
              title: Text('Others'),
              value: 2,
              groupValue: _seletedGender,
              onChanged: _onChangeGender,
            ),
            Container(
              width: 46,
              height: 32,
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.only(right: 16),
              child: RaisedButton(
                color: Colors.blue[300],
                textColor: Colors.white,
                child: Text('Confirm'),
                onPressed: () {
                  Navigator.pop(context,_seletedGender);
                },
              ),
            )
          ],
        );
  }
}