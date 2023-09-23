import 'package:first_priority_app/controllers/api.dart';
import 'package:first_priority_app/controllers/school.dart';
import 'package:first_priority_app/meetings/order/order_contact.dart';
import 'package:first_priority_app/models/meeting.dart';
import 'package:first_priority_app/validators.dart';
import 'package:first_priority_app/widgets/loading_dialog.dart';
import 'package:first_priority_app/widgets/text/title_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'widgets/donuts_order_widget.dart';
import 'widgets/pizza_order_widget.dart';
import 'widgets/store_items_order_widget.dart';

class OrderScreen extends StatefulWidget {
  final Meeting meeting;

  const OrderScreen({Key key, this.meeting}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderContact = GlobalKey<OrderContactState>();
  final _expectedStudentsTextController = TextEditingController(text: "20");

  final SchoolController _schoolController = Get.find<SchoolController>();
  final Api _api = Get.find<Api>();

  Map<String, Widget> _types;

  static Map<String, String> _typeNames = {
    "Pizza": "Pizza",
    "StoreItems": "Store Items",
    "Donuts": "Donuts",
  };

  String _type;
  RxInt _expectedStudents = 20.obs;
  Map<String, dynamic> orderData;

  @override
  void initState() {
    _types = {
      "Pizza": PizzaOrderWidget(
        expectedStudents: _expectedStudents,
        meetingTime: widget.meeting.time,
        allowDelivery: _schoolController.school.value.allowDelivery,
        onData: (data) {
          orderData = data;
        },
      ),
      "StoreItems": StoreItemsOrderWidget(
        expectedStudents: _expectedStudents,
        onData: (data) {
          orderData = data;
        },
      ),
      "Donuts": DonutsOrderWidget(
        expectedStudents: _expectedStudents,
        onData: (data) {
          orderData = data;
        },
      ),
    };

    _type = _types.keys.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Invite Order"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                _buildNumberTextField(
                  "Expected # of Students",
                  _expectedStudentsTextController,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Order Type"),
                  value: _type,
                  onChanged: (String newType) {
                    setState(() {
                      _type = newType;
                    });
                  },
                  items: _types.keys.map<DropdownMenuItem<String>>(
                    (String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(_typeNames[type]),
                      );
                    },
                  ).toList(),
                ),
                const Divider(),
                TitleText(_typeNames[_type]),
                _types[_type] ?? Container(),
                const Divider(),
                OrderContact(
                  key: _orderContact,
                ),
                SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  child: Text("Order"),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      await _submitForm();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    LoadingDialog.show(
      context: context,
      future: () async {
        await _api.client.post(
          "/api/order/${_schoolController.school.value.id}",
          data: {
            "type": _type,
            "expectedStudents": _expectedStudents.value,
            "meetDate": widget.meeting.time.toIso8601String(),
            ...orderData,
            ..._orderContact.currentState.getData(),
          },
        );

        if (widget.meeting.time.difference(DateTime.now()).inDays < 1) {
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  "Warning",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: [
                  TextButton(
                    child: Text("Ok"),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
                content: Text(
                  "Because this order was placed less than 24 hours before the meeting, please contact your First Priority Representative to expedite the order.",
                ),
              );
            },
          );
        }

        Get.back();
      },
    );
  }

  Widget _buildNumberTextField(String title, TextEditingController controller) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: title,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: (text) {
        setState(() {
          _expectedStudents(int.tryParse(text) ?? 0);
        });
      },
      controller: controller,
      validator: Validators.required,
      keyboardType: TextInputType.number,
    );
  }
}
