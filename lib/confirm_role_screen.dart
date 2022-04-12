import 'package:first_priority_app/async_search_delegate.dart';
import 'package:first_priority_app/controllers/account.dart';
import 'package:first_priority_app/controllers/school.dart';
import 'package:first_priority_app/models/school.dart';
import 'package:first_priority_app/models/user.dart';
import 'package:first_priority_app/validators.dart';
import 'package:first_priority_app/widgets/header_app_bar.dart';
import 'package:first_priority_app/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfirmRoleScreen extends StatefulWidget {
  @override
  State<ConfirmRoleScreen> createState() => _ConfirmRoleScreenState();
}

class _ConfirmRoleScreenState extends State<ConfirmRoleScreen> {
  static const FORMAT = "MMMM yyyy";
  static const commitmentForms = {
    ConfirmationRole.student: null,
    ConfirmationRole.studentLeader:
        "https://core.firstpriority.cc/cms/student-leader-commitment",
    ConfirmationRole.teacherSponsor:
        "https://core.firstpriority.cc/cms/teacher-sponsor-commitment",
    ConfirmationRole.mentor:
        "https://core.firstpriority.cc/cms/mentor-commitment"
  };

  final AccountController _accountController = Get.find<AccountController>();
  final SchoolController _schoolsController = Get.find<SchoolController>();

  final _graduationYearController = TextEditingController();
  final _schoolController = TextEditingController();

  ConfirmationRole _confirmationRole = ConfirmationRole.student;
  DateTime _graduationYear;
  School _school;
  bool _formOpened = false;
  bool _isStudentLeader = false;

  @override
  void initState() {
    super.initState();
    final user = _accountController.user.value;
    if (user.hasRole("Leader"))
      _confirmationRole = ConfirmationRole.studentLeader;
    if (user.hasRole("Sponsor"))
      _confirmationRole = ConfirmationRole.teacherSponsor;
    if (user.hasRoles(["Mentor", "WaitingMentor"]))
      _confirmationRole = ConfirmationRole.mentor;

    if (user.graduationYear != null) setGraduationYear(user.graduationYear);

    _isStudentLeader = _confirmationRole == ConfirmationRole.studentLeader;
  }

  void setGraduationYear(DateTime graduationYear) {
    setState(() {
      _graduationYear = graduationYear;
      _graduationYearController.text = Jiffy(_graduationYear).format(FORMAT);
    });
  }

  void setSchool(School school) {
    setState(() {
      _school = school;
      _schoolController.text = _school.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formUrl = commitmentForms[_confirmationRole];
    return Scaffold(
      appBar: HeaderAppBar(
        title: "Commitment",
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: ListView(
          children: [
            if (_schoolsController.school == null)
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'School',
                  hintText: 'Pick your School',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                validator:
                    Validators.requiredWithMessage("Please pick a School"),
                controller: _schoolController,
                readOnly: true,
                onTap: () async {
                  showSearch(
                    context: context,
                    delegate: AsyncSearchDelegate<School>(
                      future: _schoolsController.searchSchools,
                      builder: (context, school) {
                        return ListTile(
                          title: Text(school.name),
                          onTap: () {
                            setSchool(school);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            if (_confirmationRole == ConfirmationRole.studentLeader ||
                _confirmationRole == ConfirmationRole.student)
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Graduation Year',
                  hintText: 'Pick your Graduation Month & Year',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                controller: _graduationYearController,
                readOnly: true,
                onTap: () async {
                  var graduationYear = await showMonthPicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                  );

                  if (graduationYear == null) return;
                  setGraduationYear(graduationYear);
                },
              ),
            if (_confirmationRole == ConfirmationRole.studentLeader ||
                _confirmationRole == ConfirmationRole.student)
              CheckboxListTile(
                title: Text("I'm a Student Leader"),
                value: _isStudentLeader,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool value) {
                  setState(() {
                    _isStudentLeader = value;
                    if (value) {
                      _confirmationRole = ConfirmationRole.studentLeader;
                    } else {
                      _confirmationRole = ConfirmationRole.student;
                    }
                  });
                },
              ),
            if (formUrl != null)
              Container(
                margin: EdgeInsets.only(bottom: 4),
                child: Text(
                  'Fill out the Commitment Form and then press the "Done" button to finish your yearly commitment.',
                  textAlign: TextAlign.center,
                ),
              ),
            if (formUrl != null)
              ElevatedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Text("Commitment Form"),
                      margin: EdgeInsets.symmetric(horizontal: 4),
                    ),
                    Icon(Icons.open_in_browser),
                  ],
                ),
                onPressed: () async {
                  await canLaunch(formUrl)
                      ? await launch(formUrl)
                      : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Unable to open commitment form"),
                        ));
                  setState(() {
                    _formOpened = true;
                  });
                },
              ),
            SizedBox(height: 8),
            ElevatedButton(
              child: Text("Done"),
              onPressed: () {
                if (!_formOpened &&
                    _confirmationRole != ConfirmationRole.student) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Commitment Form"),
                          content: Text(
                              "Please open and fill out the Commitment Form before continuing."),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Ok"))
                          ],
                        );
                      });
                } else {
                  LoadingDialog.show(
                      context: context,
                      future: () async {
                        await _accountController.roleConfirmation(
                          role: _confirmationRole,
                          school: _school,
                          graduationYear: _graduationYear,
                        );
                      });
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
