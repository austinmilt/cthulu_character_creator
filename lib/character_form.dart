import 'package:flutter/material.dart';

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();

  String _message = "What's the secret password?";
  Color? _messageColor;

  void _onChanged(String? newValue) {
    final String? lower = newValue?.toLowerCase();
    if (lower == null) {
      setState(() {
        _message = "What's the secret password?";
        _messageColor = null;
      });
    } else if (lower == 's') {
      setState(() {
        _message = "That's the spirit!";
        _messageColor = const Color.fromARGB(255, 201, 120, 0);
      });
    } else if (lower == 'sm') {
      setState(() {
        _message = "Getting warmer";
        _messageColor = const Color.fromARGB(255, 201, 174, 0);
      });
    } else if (lower == 'smo') {
      setState(() {
        _message = "Smo...kin?";
        _messageColor = const Color.fromARGB(255, 191, 201, 0);
      });
    } else if (lower == 'smoo') {
      setState(() {
        _message = "I think you got it 😄";
        _messageColor = const Color.fromARGB(255, 188, 201, 0);
      });
    } else if (lower == 'smooc') {
      setState(() {
        _message = "So close!";
        _messageColor = const Color.fromARGB(255, 121, 201, 0);
      });
    } else if (lower == 'smooch') {
      setState(() {
        _message = "WOWOWOWOW 😚";
        _messageColor = const Color.fromARGB(255, 201, 0, 100);
      });
    } else {
      setState(() {
        _message = "Cold 🥶";
        _messageColor = const Color.fromARGB(255, 0, 104, 201);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        constraints: BoxConstraints.loose(const Size.fromWidth(600)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: _message, labelStyle: TextStyle(color: _messageColor)),
              onChanged: _onChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'password';
                } else if (value == 's') {}
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
