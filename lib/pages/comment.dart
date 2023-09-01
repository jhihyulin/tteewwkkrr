import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart';

import '../widget/card.dart';
import '../widget/expansion_tile.dart';

class CommentPage extends StatefulWidget {
  const CommentPage({Key? key}) : super(key: key);

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final _formKey = GlobalKey<FormState>();
  final baseURL = 'http://tewkr.com/api';
  late List<String> coursesList;
  late List<String> teachersList;
  late Map<String, List<String>> departmentList;
  final String _selectedCollegeDefault = '請選擇學院';
  final String _selectedDepartmentDefault = '請選擇系所/科目';
  final String _selectedSemesterDefault = '請選擇學期';
  final String _selectedHardDefault = '請選擇難度';
  final String _selectedRecommendDefault = '請選擇推薦度';
  late String? _selectedTeacher;
  late String? _selectedCourse;
  late String _selectedCollege;
  late String _selectedDepartment;
  late String _selectedSemester;
  late String _selectedHard;
  late String _selectedRecommend;
  final List<String> _recommendList = [
    '非常不推薦',
    '不推薦',
    '普通',
    '推薦',
    '非常推薦',
  ];
  final List<String> _hardList = [
    '非常簡單',
    '有點簡單',
    '普通',
    '有點困難',
    '非常困難',
  ];

  @override
  void initState() {
    coursesList = [];
    teachersList = [];
    departmentList = {};
    _selectedTeacher = null;
    _selectedCourse = null;
    _selectedCollege = _selectedCollegeDefault;
    _selectedDepartment = _selectedDepartmentDefault;
    _selectedSemester = _selectedSemesterDefault;
    _selectedHard = _selectedHardDefault;
    _selectedRecommend = _selectedRecommendDefault;
    getCourses();
    getTeachers();
    getDepartments();
    super.initState();
  }

  void getCourses() async {
    var uri = Uri.parse('$baseURL/getserverlist/courses');
    http.get(uri).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['code'] == 200) {
          var result = data['result'];
          for (var key in result) {
            coursesList.add(key['value']);
          }
          // debugPrint('courseList: ${coursesList.toString()}');
        } else {
          coursesList = [];
          debugPrint(
              '[ERROR] courseList: ${response.statusCode} ${response.body}');
        }
      } else {
        coursesList = [];
        debugPrint(
            '[ERROR] courseList: ${response.statusCode} ${response.body}');
      }
    });
  }

  void getTeachers() async {
    var uri = Uri.parse('$baseURL/getserverlist/teachers');
    http.get(uri).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['code'] == 200) {
          var result = data['result'];
          for (var key in result) {
            teachersList.add(key['value']);
          }
          // debugPrint('teachersList: ${teachersList.toString()}');
        } else {
          teachersList = [];
          debugPrint(
              '[ERROR] teachersList: ${response.statusCode} ${data['code']} ${data['msg']} ${response.body}');
        }
      } else {
        teachersList = [];
        debugPrint(
            '[ERROR] teachersList: ${response.statusCode} ${response.body}');
      }
    });
  }

  void getDepartments() async {
    var uri = Uri.parse('$baseURL/department');
    http.get(uri).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['code'] == 200) {
          var result = data['result'];
          for (var key in result) {
            var college = key['college'];
            List<String> depList = [];
            for (var department in key['department']) {
              depList.add(department['department']);
            }
            departmentList[college] = depList;
          }
          debugPrint('departmentList: ${departmentList.toString()}');
        } else {
          departmentList = {};
          debugPrint(
              '[ERROR] departmentList: ${response.statusCode} ${data['code']} ${data['msg']} ${response.body}');
        }
      } else {
        departmentList = {};
        debugPrint(
            '[ERROR] departmentList: ${response.statusCode} ${response.body}');
      }
    });
  }

  void search(String? token, String? year, String? course, String? department,
      String? teacher, String? hard, String? recommend) async {
    var uri = Uri.parse('$baseURL/search');
    var dealYear = year != null
        ? year.length == 5
            ? year.substring(1, 5)
            : year.substring(1, 4)
        : null;
    var dealHard = hard != null
        ? hard == '非常簡單'
            ? 'E'
            : hard == '有點簡單'
                ? 'D'
                : hard == '普通'
                    ? 'C'
                    : hard == '有點困難'
                        ? 'B'
                        : 'A'
        : null;
    var dealRecommend = recommend != null
        ? recommend == '非常不推薦'
            ? 'E'
            : recommend == '不推薦'
                ? 'D'
                : recommend == '普通'
                    ? 'C'
                    : recommend == '推薦'
                        ? 'B'
                        : 'A'
        : null;
    http.post(
      uri,
      body: {
        "token": token ?? '',
        "year": dealYear ?? '',
        "course": course ?? '',
        "department": department ?? '',
        "teacher": teacher ?? '',
        "hard": dealHard ?? '',
        "recommend": dealRecommend ?? '',
      },
    ).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['code'] == 200) {
          var result = data['result'];
          debugPrint('search: ${result.toString()}');
        } else {
          debugPrint(
              '[ERROR] search: ${response.statusCode} ${data['code']} ${data['msg']} ${response.body}');
        }
      } else {
        debugPrint('[ERROR] search: ${response.statusCode} ${response.body}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜尋課程評論'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          height: MediaQuery.of(context).size.height -
              AppBar().preferredSize.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomCard(
                child: CustomExpansionTile(
                  title: const Text('搜尋'),
                  leading: const Icon(Icons.search),
                  initiallyExpanded: true,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Autocomplete<String>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const Iterable.empty();
                              }
                              return coursesList.where((String option) {
                                return option.contains(
                                    textEditingValue.text.toUpperCase());
                              });
                            },
                            onSelected: (selection) {
                              debugPrint('selected $selection');
                              _selectedCourse = selection;
                            },
                          ),
                          Autocomplete<String>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const Iterable.empty();
                              }
                              return teachersList.where((String option) {
                                return option.contains(
                                    textEditingValue.text.toUpperCase());
                              });
                            },
                            onSelected: (selection) {
                              debugPrint('selected $selection');
                              _selectedTeacher = selection;
                            },
                          ),
                          Wrap(
                            children: [
                              DropdownButton(
                                hint: Text(_selectedCollegeDefault),
                                value: _selectedCollege,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCollege = value.toString();
                                    _selectedDepartment =
                                        _selectedDepartmentDefault;
                                  });
                                },
                                items: () {
                                  List<DropdownMenuItem<String>> items = [];
                                  items.add(DropdownMenuItem(
                                    value: _selectedCollegeDefault,
                                    child: Text(_selectedCollegeDefault),
                                  ));
                                  for (var key in departmentList.keys) {
                                    items.add(DropdownMenuItem(
                                      value: key,
                                      child: Text(key),
                                    ));
                                  }
                                  return items;
                                }(),
                              ),
                              DropdownButton(
                                hint: Text(_selectedDepartmentDefault),
                                value:
                                    _selectedCollege == _selectedCollegeDefault
                                        ? null
                                        : _selectedDepartment,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDepartment = value.toString();
                                  });
                                },
                                items: _selectedCollege ==
                                        _selectedCollegeDefault
                                    ? null
                                    : () {
                                        List<DropdownMenuItem<String>> items =
                                            [];
                                        items.add(DropdownMenuItem(
                                          value: _selectedDepartmentDefault,
                                          child:
                                              Text(_selectedDepartmentDefault),
                                        ));
                                        var college = _selectedCollege;
                                        if (departmentList
                                            .containsKey(college)) {
                                          for (var department
                                              in departmentList[college]!) {
                                            items.add(DropdownMenuItem(
                                              value: department,
                                              child: Text(department),
                                            ));
                                          }
                                        }
                                        return items;
                                      }(),
                              ),
                            ],
                          ),
                          DropdownButton(
                            hint: Text(_selectedSemesterDefault),
                            value: _selectedSemester,
                            onChanged: (value) {
                              setState(() {
                                _selectedSemester = value.toString();
                              });
                            },
                            items: () {
                              var items = <DropdownMenuItem<String>>[];
                              items.add(
                                DropdownMenuItem(
                                  value: _selectedSemesterDefault,
                                  child: Text(_selectedSemesterDefault),
                                ),
                              );
                              var nowYear = DateTime.now().year - 1911;
                              for (var year = nowYear; year >= 99; year--) {
                                items.add(
                                  DropdownMenuItem(
                                    value: '$year-2',
                                    child: Text('$year-2'),
                                  ),
                                );
                                items.add(
                                  DropdownMenuItem(
                                    value: '$year-1',
                                    child: Text('$year-1'),
                                  ),
                                );
                              }
                              return items;
                            }(),
                          ),
                          Wrap(
                            children: [
                              DropdownButton(
                                hint: Text(_selectedHardDefault),
                                value: _selectedHard,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedHard = value.toString();
                                  });
                                },
                                items: () {
                                  List<DropdownMenuItem<String>> items = [];
                                  items.add(DropdownMenuItem(
                                    value: _selectedHardDefault,
                                    child: Text(_selectedHardDefault),
                                  ));
                                  for (var hard in _hardList) {
                                    items.add(DropdownMenuItem(
                                      value: hard,
                                      child: Text(hard),
                                    ));
                                  }
                                  return items;
                                }(),
                              ),
                              DropdownButton(
                                hint: Text(_selectedRecommendDefault),
                                value: _selectedRecommend,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRecommend = value.toString();
                                  });
                                },
                                items: () {
                                  List<DropdownMenuItem<String>> items = [];
                                  items.add(DropdownMenuItem(
                                    value: _selectedRecommendDefault,
                                    child: Text(_selectedRecommendDefault),
                                  ));
                                  for (var recommend in _recommendList) {
                                    items.add(DropdownMenuItem(
                                      value: recommend,
                                      child: Text(recommend),
                                    ));
                                  }
                                  return items;
                                }(),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.search),
                            label: const Text('搜尋'),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                search(
                                  null,
                                  _selectedSemester == _selectedSemesterDefault
                                      ? null
                                      : _selectedSemester,
                                  _selectedCourse,
                                  _selectedDepartment ==
                                              _selectedDepartmentDefault ||
                                          _selectedDepartment == ''
                                      ? null
                                      : _selectedDepartment,
                                  _selectedTeacher,
                                  _selectedHard == _selectedHardDefault
                                      ? null
                                      : _selectedHard,
                                  _selectedRecommend ==
                                          _selectedRecommendDefault
                                      ? null
                                      : _selectedRecommend,
                                );
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                children: [],
              )
            ],
          ),
        ),
      ),
    );
  }
}
