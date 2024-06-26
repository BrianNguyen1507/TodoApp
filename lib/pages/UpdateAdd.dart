import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo/Notification/ScheduleNotifications.dart';
import 'package:todo/constant/colors.dart';
import 'package:todo/main.dart';
import 'package:todo/models/congviec.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo/services/AddTask.dart';
import 'package:todo/services/handle/handleDateTime.dart';
import 'package:todo/services/updateTask.dart';
import 'package:todo/Provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UpdateAddTask extends StatefulWidget {
  const UpdateAddTask({super.key, required this.taskToUpdate});
  final CongViec? taskToUpdate;
  @override
  State<UpdateAddTask> createState() => _UpdateAddTaskState();
}

class _UpdateAddTaskState extends State<UpdateAddTask> {
  late String _priority;
  late Timer? _timer;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _discriptionController = TextEditingController();
  late DateTime _selectedDate;
  late String _selectedTime;

  Future<DateTime?> _selectDate() async {
    DateTime? pickedDate =
        await HandleDateTime.pickDate(context, _selectedDate);
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      return _selectedDate;
    }
    return null;
  }

  Future<String?> _selectTime() async {
    String? pickedTime =
        await HandleDateTime.pickTime(context, _selectedDate, _selectedTime);
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
      return _selectedTime;
    }
    return null;
  }

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _selectedTime = DateFormat('kk:mm').format(DateTime.now());
      });
    });
    if (isUpdating) {
      super.initState();
      _nameController.text = widget.taskToUpdate!.name;
      _discriptionController.text = widget.taskToUpdate!.description!;
      _priority = widget.taskToUpdate!.priority;
      _selectedDate = widget.taskToUpdate!.date;
      _selectedTime = widget.taskToUpdate!.time;
    } else {
      resetDateTime();
    }
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  void resetDateTime() {
    _nameController.clear();
    _discriptionController.clear();
    _selectedDate = DateTime.now();
    _selectedTime = DateFormat('kk:mm').format(DateTime.now());
    _priority = 'Low';
  }

  bool get isUpdating => widget.taskToUpdate != null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: isUpdating
            ? Text(
                AppLocalizations.of(context)!.updatetask,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.title),
              )
            : Text(
                AppLocalizations.of(context)!.addtask,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.title),
              ),
        backgroundColor: Provider.of<ThemeProvider>(context)
            .themeData
            .appBarTheme
            .backgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.arrow,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                maxLength: 100,
                controller: _nameController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 0.5,
                      color: AppColors.grey,
                    ),
                  ),
                  hintText: AppLocalizations.of(context)!.dosmth,
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _discriptionController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 0.5,
                      color: AppColors.grey,
                    ),
                  ),
                  hintText: AppLocalizations.of(context)!.description,
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${AppLocalizations.of(context)!.date}:   ",
                              style: const TextStyle(
                                color: AppColors.title,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: DateFormat('yyyy-MM-dd')
                                  .format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.subtitle,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.button,
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        child: MaterialButton(
                          child: const Icon(
                            Icons.calendar_today,
                            color: AppColors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            _selectDate();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${AppLocalizations.of(context)!.time}:   ",
                              style: const TextStyle(
                                color: AppColors.title,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: _selectedTime,
                              style: const TextStyle(
                                color: AppColors.subtitle,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.title,
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        child: MaterialButton(
                          child: const Icon(
                            Icons.av_timer_rounded,
                            color: AppColors.white,
                            size: 40,
                          ),
                          onPressed: () {
                            _selectTime();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.priority,
                    style: const TextStyle(
                      color: AppColors.title,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: <Widget>[
                          Radio<String>(
                            value: 'High',
                            groupValue: _priority,
                            onChanged: (value) {
                              setState(() {
                                _priority = value!;
                              });
                            },
                          ),
                          Text(AppLocalizations.of(context)!.high),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Radio<String>(
                            value: 'Medium',
                            groupValue: _priority,
                            onChanged: (value) {
                              setState(() {
                                _priority = value!;
                              });
                            },
                          ),
                          Text(AppLocalizations.of(context)!.medium),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Radio<String>(
                            value: 'Low',
                            groupValue: _priority,
                            onChanged: (value) {
                              setState(() {
                                _priority = value!;
                              });
                            },
                          ),
                          Text(AppLocalizations.of(context)!.low),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 50,
              width: double.infinity,
              color: Colors.transparent,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.button,
                ),
                onPressed: () async {
                  NotificationController.initializeAndScheduleNotifications();
                  if (isUpdating) {
                    final updatedTask = CongViec(
                      id: widget.taskToUpdate!.id,
                      name: _nameController.text,
                      description: _discriptionController.text,
                      date: _selectedDate,
                      time: _selectedTime,
                      priority: _priority,
                    );
                    await UpdateTask.updateTask(updatedTask);
                    Fluttertoast.showToast(
                      msg:
                          ' ${AppLocalizations.of(context)!.updatetask} ${AppLocalizations.of(context)!.success}',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: AppColors.blue,
                      textColor: AppColors.white,
                      fontSize: 16,
                    );
                  } else {
                    final newTask = CongViec(
                      name: _nameController.text,
                      description: _discriptionController.text,
                      date: _selectedDate,
                      time: _selectedTime,
                      priority: _priority,
                    );
                    await AddTask.addTask(newTask);
                    Fluttertoast.showToast(
                      msg:
                          ' ${AppLocalizations.of(context)!.addtask} ${AppLocalizations.of(context)!.success}',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: AppColors.blue,
                      textColor: AppColors.white,
                      fontSize: 16,
                    );
                  }
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyApp(),
                    ),
                  );
                },
                child: isUpdating
                    ? Text(
                        AppLocalizations.of(context)!.updatetask,
                        style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )
                    : Text(
                        AppLocalizations.of(context)!.addtask,
                        style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
