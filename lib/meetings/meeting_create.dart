import 'package:first_priority_app/controllers/school.dart';
import 'package:first_priority_app/meetings/controller/meeting_controller.dart';
import 'package:first_priority_app/models/cycle.dart';
import 'package:first_priority_app/models/meeting.dart';
import 'package:first_priority_app/models/meeting_role.dart';
import 'package:first_priority_app/models/user_profile.dart';
import 'package:first_priority_app/models/week.dart';
import 'package:first_priority_app/validators.dart';
import 'package:first_priority_app/widgets/generic_list.dart';
import 'package:first_priority_app/widgets/loading_dialog.dart';
import 'package:first_priority_app/widgets/text/title_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MeetingCreate extends StatefulWidget {
  final Meeting meeting;

  const MeetingCreate({Key key, this.meeting}) : super(key: key);

  @override
  _MeetingCreateState createState() => _MeetingCreateState();
}

class _MeetingCreateState extends State<MeetingCreate> {
  final _formKey = GlobalKey<FormState>();

  final _controller = Get.find<MeetingController>();
  final _schoolController = Get.find<SchoolController>();
  final _timeController = TextEditingController();

  final _roomController = TextEditingController();

  Week _week;
  Cycle _cycle;
  DateTime _meetingTime;
  bool isEditing = false;

  Map<String, ValueNotifier<List<UserProfile>>> roles;

  @override
  void initState() {
    super.initState();
    _roomController.text =
        widget.meeting?.room ?? _schoolController.school.value.room;

    _setTime(widget.meeting?.time);
    isEditing = widget.meeting != null;

    roles = {
      for (final roleId in MeetingRole.roles.keys) roleId: getRole(roleId)
    };
  }

  ValueNotifier<List<UserProfile>> getRole(String key) {
    return ValueNotifier((widget.meeting?.roles ?? {})[key] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Meeting" : "New Meeting"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: FutureBuilder(
            future: Future.wait([
              _controller.getWeeks(),
              _controller.getCycles(),
            ]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final weeks = snapshot.data[0] as List<Week>;
              final cycles = snapshot.data[1] as List<Cycle>;

              if (_week == null)
                _week = isEditing
                    ? weeks.firstWhere((x) => x.name == widget.meeting.week)
                    : weeks.first;

              if (_cycle == null)
                _cycle = isEditing
                    ? cycles.firstWhere((x) => x.name == widget.meeting.cycle)
                    : cycles.first;

              return Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _roomController,
                      decoration: InputDecoration(
                        labelText: 'Room',
                      ),
                      validator: Validators.required,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Meeting Date',
                        hintText: 'Pick Meeting Date & Time',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      validator: Validators.requiredWithMessage(
                        "Please pick a meeting date",
                      ),
                      controller: _timeController,
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            Duration(days: 365),
                          ),
                        );

                        if (date == null) return;

                        final time = await showTimePicker(
                          context: context,
                          initialTime: _schoolController.school.value.meetTime,
                        );

                        if (time == null) return;

                        _setTime(DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        ));
                      },
                    ),
                    DropdownButtonFormField<Week>(
                      decoration: InputDecoration(labelText: 'Week'),
                      value: _week,
                      onChanged: (Week newWeek) {
                        setState(() {
                          _week = newWeek;
                        });
                      },
                      items: weeks.map<DropdownMenuItem<Week>>(
                        (Week week) {
                          return DropdownMenuItem<Week>(
                            value: week,
                            child: Text(week.name),
                          );
                        },
                      ).toList(),
                    ),
                    DropdownButtonFormField<Cycle>(
                      decoration: InputDecoration(labelText: 'Cycle'),
                      value: _cycle,
                      onChanged: (Cycle newCycle) {
                        setState(() {
                          _cycle = newCycle;
                        });
                      },
                      items: cycles.map<DropdownMenuItem<Cycle>>(
                        (Cycle cycle) {
                          return DropdownMenuItem<Cycle>(
                            value: cycle,
                            child: Text(cycle.name),
                          );
                        },
                      ).toList(),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top: 20, bottom: 5),
                      child: TitleText('Roles'),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        roles.length,
                        (index) {
                          final roleId =
                              MeetingRole.roles.keys.elementAt(index);
                          final users = roles[roleId];
                          return GenericList<UserProfile>(
                            controller: users,
                            title: Text(
                              MeetingRole.roles[roleId].name,
                              style: Theme.of(context)
                                  .inputDecorationTheme
                                  .labelStyle
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                            ),
                            onSearch: _schoolController.searchUsers,
                            resultBuilder: (context, user, cb) {
                              return ListTile(
                                title: Text(user.name),
                                subtitle: Text(user.role),
                                onTap: cb,
                              );
                            },
                            itemBuilder: (context, user) {
                              return Card(
                                child: ListTile(
                                  visualDensity: VisualDensity.compact,
                                  trailing: Icon(Icons.arrow_back),
                                  title: Text(
                                    user.name,
                                  ),
                                  subtitle: Text(user.role),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          LoadingDialog.show(
                            context: context,
                            future: () async {
                              final rolesMap = roles.map(
                                (roleId, users) => MapEntry(
                                  roleId,
                                  users.value.map((e) => e.id).toList(),
                                ),
                              );

                              if (isEditing) {
                                await _controller.edit(
                                  meetingId: widget.meeting.id,
                                  room: _roomController.text,
                                  time: _meetingTime,
                                  week: _week.name,
                                  cycleId: _cycle.id,
                                  roles: rolesMap,
                                );
                              } else {
                                await _controller.create(
                                  schoolId: _schoolController.school.value.id,
                                  room: _roomController.text,
                                  time: _meetingTime,
                                  week: _week.name,
                                  cycleId: _cycle.id,
                                  roles: rolesMap,
                                );
                              }

                              Get.back();
                            },
                          );
                        }
                      },
                      child: Text(isEditing ? "Save" : "Schedule"),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _setTime(DateTime time) {
    if (time == null) return;

    _meetingTime = time;
    _timeController.text = DateFormat(
      'MMMM d @ h:mma',
    ).format(_meetingTime);
  }
}
