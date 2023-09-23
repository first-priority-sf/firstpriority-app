import 'package:first_priority_app/controllers/api.dart';
import 'package:first_priority_app/controllers/school.dart';
import 'package:first_priority_app/models/meeting.dart';
import 'package:first_priority_app/validators.dart';
import 'package:first_priority_app/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ReportScreen extends StatefulWidget {
  final Meeting meeting;

  const ReportScreen({
    Key key,
    @required this.meeting,
  }) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final Api _api = Get.find<Api>();
  final SchoolController _schoolController = Get.find<SchoolController>();

  final TextEditingController _attendanceTextController =
      TextEditingController(text: "0");
  final TextEditingController _decisionsTextController =
      TextEditingController(text: "0");
  final TextEditingController _connectionsTextController =
      TextEditingController(text: "0");

  final TextEditingController _storyTextController = TextEditingController();
  final TextEditingController _notesTextController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> values = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meeting Report"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildCheckboxTile("Student Lead", "studentLead"),
              _buildCheckboxTile("Followed Plan", "followedPlan"),
              _buildCheckboxTile("Energy", "energy"),
              _buildCheckboxTile("Story", "story"),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    if (values["story"] ?? false)
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Tell the story!",
                          hintText: "Enter story here...",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        controller: _storyTextController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ),
                    const Divider(),
                    _buildNumberTextField(
                      "Attendance",
                      _attendanceTextController,
                    ),
                    _buildNumberTextField(
                      "Decisions",
                      _decisionsTextController,
                    ),
                    _buildNumberTextField(
                      "Church Connect",
                      _connectionsTextController,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Notes",
                        hintText: "Enter notes here...",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      controller: _notesTextController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    ElevatedButton(
                      child: Text("Submit"),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          await _submitForm();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
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
          "/api/meetings/${_schoolController.school.value.id}/report",
          data: {
            "schoolId": _schoolController.school.value.id,
            "week": widget.meeting.week,
            "meetDay": widget.meeting.time.weekday,
            "meetWeek": widget.meeting.time
                .subtract(Duration(days: widget.meeting.time.weekday))
                .toIso8601String(),
            "clubMet": true,
            "studentLead": values["studentLead"] ?? false,
            "followedPlan": values["followedPlan"] ?? false,
            "energy": values["energy"] ?? false,
            "story": values["story"] ?? false,
            "storyNotes": _storyTextController.text,
            "attendance": int.parse(_attendanceTextController.text) ?? 0,
            "decisions": int.parse(_decisionsTextController.text) ?? 0,
            "connections": int.parse(_connectionsTextController.text) ?? 0,
            "notes": _notesTextController.text,
          },
        );

        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildCheckboxTile(String title, String key) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 20),
      ),
      value: values[key] ?? false,
      onChanged: (newValue) {
        setState(() {
          values[key] = newValue;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
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
      controller: controller,
      validator: Validators.required,
      keyboardType: TextInputType.number,
    );
  }
}
