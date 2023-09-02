import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widget/card.dart';
import '../widget/expansion_tile.dart';
import '../widget/linear_progress_indicator.dart';
import '../widget/auto_complete.dart';
import '../widget/drop_down_button_form_field.dart';

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
  late String? _selectedCollege;
  late String? _selectedDepartment;
  late String? _selectedSemester;
  late String? _selectedHard;
  late String? _selectedRecommend;
  late ExpansionTileController _expansionTileController;
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
  late bool _isSearching;
  late List<dynamic>? _searchResult;

  @override
  void initState() {
    coursesList = [];
    teachersList = [];
    departmentList = {};
    _selectedTeacher = null;
    _selectedCourse = null;
    _selectedCollege = null;
    _selectedDepartment = null;
    _selectedSemester = null;
    _selectedHard = null;
    _selectedRecommend = null;
    _searchResult = null;
    _isSearching = false;
    _expansionTileController = ExpansionTileController();
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
            setState(() {
              departmentList[college] = depList;
            });
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
    setState(() {
      _searchResult = null;
      _isSearching = true;
    });
    var uri = Uri.parse('$baseURL/search');
    var dealYear = year != null
        ? year.length == 5
            ? year.substring(1, 5)
            : year.substring(1, 4)
        : null;
    var dealHard = hard != null
        ? hard == _hardList[0]
            ? 'E'
            : hard == _hardList[1]
                ? 'D'
                : hard == _hardList[2]
                    ? 'C'
                    : hard == _hardList[3]
                        ? 'B'
                        : 'A'
        : null;
    var dealRecommend = recommend != null
        ? recommend == _recommendList[0]
            ? 'E'
            : recommend == _recommendList[1]
                ? 'D'
                : recommend == _recommendList[2]
                    ? 'C'
                    : recommend == _recommendList[3]
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
          setState(() {
            _searchResult = result;
          });
          _expansionTileController.collapse();
          // debugPrint('search: ${result.toString()}');
        } else {
          debugPrint(
              '[ERROR] search: ${response.statusCode} ${data['code']} ${data['msg']} ${response.body}');
        }
      } else {
        debugPrint('[ERROR] search: ${response.statusCode} ${response.body}');
      }
      setState(() {
        _isSearching = false;
      });
    });
  }

  bool isSpam(String comment) {
    // TODO: 加上其他檢測方案
    for (var spam in ['湊三篇']) {
      if (comment.contains(spam)) {
        return true;
      }
    }
    return false;
  }

  void clearSearch() {
    setState(() {
      _searchResult = null;
    });
    _expansionTileController.expand();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜尋課程評論'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 700,
              minHeight: MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomCard(
                  child: CustomExpansionTile(
                    controller: _expansionTileController,
                    title: const Text('搜尋'),
                    subtitle: const Text('想以什麼條件搜尋？'),
                    leading: const Icon(Icons.search),
                    initiallyExpanded: true,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              CustomAutocomplete(
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
                                hintText: '請輸入課程名稱',
                                labelText: '課程名稱',
                                optionsMaxWidth:
                                    MediaQuery.of(context).size.width * 0.9 <
                                            400
                                        ? MediaQuery.of(context).size.width *
                                            0.9
                                        : 400,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              CustomAutocomplete(
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
                                hintText: '請輸入教師姓名',
                                labelText: '教師姓名',
                                optionsMaxWidth:
                                    MediaQuery.of(context).size.width * 0.9 <
                                            400
                                        ? MediaQuery.of(context).size.width *
                                            0.9
                                        : 400,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  CustomDropdownButtonFormField(
                                    hint: Text(_selectedCollegeDefault),
                                    value: _selectedCollege,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCollege = value.toString();
                                        _selectedDepartment = null;
                                      });
                                    },
                                    label: const Text('學院'),
                                    suffixIcon: _selectedCollege == null
                                        ? null
                                        : IconButton(
                                            icon: const Icon(Icons.close),
                                            tooltip: '取消選擇學院',
                                            onPressed: () {
                                              setState(() {
                                                _selectedCollege = null;
                                                _selectedDepartment = null;
                                              });
                                            },
                                          ),
                                    items: () {
                                      List<DropdownMenuItem<String?>> items =
                                          [];
                                      for (var key in departmentList.keys) {
                                        items.add(
                                          DropdownMenuItem(
                                            value: key,
                                            child: Text(key),
                                          ),
                                        );
                                      }
                                      return items;
                                    }(),
                                  ),
                                  CustomDropdownButtonFormField(
                                    validator: (value) {
                                      if (_selectedCollege != null &&
                                          value == null) {
                                        return '$_selectedDepartmentDefault或取消選擇學院';
                                      }
                                      return null;
                                    },
                                    hint: Text(_selectedDepartmentDefault),
                                    value: _selectedCollege == null
                                        ? null
                                        : _selectedDepartment,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedDepartment = value.toString();
                                      });
                                    },
                                    label: const Text('系所/科目'),
                                    suffixIcon: _selectedDepartment == null
                                        ? null
                                        : IconButton(
                                            icon: const Icon(Icons.close),
                                            tooltip: '取消選擇系所/科目',
                                            onPressed: () {
                                              setState(() {
                                                _selectedDepartment = null;
                                              });
                                            },
                                          ),
                                    items: _selectedCollege == null
                                        ? null
                                        : () {
                                            List<DropdownMenuItem<String?>>
                                                items = [];
                                            var college = _selectedCollege;
                                            if (departmentList
                                                .containsKey(college)) {
                                              for (var department
                                                  in departmentList[college]!) {
                                                items.add(
                                                  DropdownMenuItem(
                                                    value: department,
                                                    child: Text(department),
                                                  ),
                                                );
                                              }
                                            }
                                            return items;
                                          }(),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              CustomDropdownButtonFormField(
                                hint: Text(_selectedSemesterDefault),
                                value: _selectedSemester,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSemester = value.toString();
                                  });
                                },
                                label: const Text('學期'),
                                suffixIcon: _selectedSemester == null
                                    ? null
                                    : IconButton(
                                        icon: const Icon(Icons.close),
                                        tooltip: '取消選擇學期',
                                        onPressed: () {
                                          setState(() {
                                            _selectedSemester = null;
                                          });
                                        },
                                      ),
                                items: () {
                                  var items = <DropdownMenuItem<String?>>[];
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
                              const SizedBox(
                                height: 10,
                              ),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width >
                                            600
                                        ? double.infinity
                                        : MediaQuery.of(context).size.width *
                                                0.5 -
                                            25,
                                    child: CustomDropdownButtonFormField(
                                      hint: Text(_selectedHardDefault),
                                      value: _selectedHard,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedHard = value.toString();
                                        });
                                      },
                                      label: const Text('難度'),
                                      suffixIcon: _selectedHard == null
                                          ? null
                                          : IconButton(
                                              icon: const Icon(Icons.close),
                                              tooltip: '取消選擇難度',
                                              onPressed: () {
                                                setState(() {
                                                  _selectedHard = null;
                                                });
                                              },
                                            ),
                                      items: () {
                                        List<DropdownMenuItem<String?>> items =
                                            [];
                                        for (var hard in _hardList) {
                                          items.add(DropdownMenuItem(
                                            value: hard,
                                            child: Text(hard),
                                          ));
                                        }
                                        return items;
                                      }(),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width >
                                            600
                                        ? double.infinity
                                        : MediaQuery.of(context).size.width *
                                                0.5 -
                                            25,
                                    child: CustomDropdownButtonFormField(
                                      hint: Text(_selectedRecommendDefault),
                                      value: _selectedRecommend,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedRecommend = value.toString();
                                        });
                                      },
                                      label: const Text('推薦度'),
                                      suffixIcon: _selectedRecommend == null
                                          ? null
                                          : IconButton(
                                              icon: const Icon(Icons.close),
                                              tooltip: '取消選擇推薦度',
                                              onPressed: () {
                                                setState(() {
                                                  _selectedRecommend = null;
                                                });
                                              },
                                            ),
                                      items: () {
                                        List<DropdownMenuItem<String?>> items =
                                            [];
                                        for (var recommend in _recommendList) {
                                          items.add(DropdownMenuItem(
                                            value: recommend,
                                            child: Text(recommend),
                                          ));
                                        }
                                        return items;
                                      }(),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.search),
                                label: const Text('搜尋'),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    search(
                                      null,
                                      _selectedSemester,
                                      _selectedCourse,
                                      _selectedDepartment,
                                      _selectedTeacher,
                                      _selectedHard,
                                      _selectedRecommend,
                                    );
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isSearching)
                  Container(
                    padding: const EdgeInsets.all(4),
                    child: const CustomLinearProgressIndicator(),
                  ),
                Wrap(
                  children: [
                    if (_searchResult != null)
                      CustomCard(
                        child: ListTile(
                          title: const Text('搜尋結果'),
                          leading: const Icon(Icons.search),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: '清除搜尋結果',
                            onPressed: () {
                              clearSearch();
                            },
                          ),
                        ),
                      ),
                    if (_searchResult != null)
                      for (var i in _searchResult!.take(100))
                        // 先略過所有的廣告 TODO: 顯示廣告
                        if (i['ad'] == 0)
                          CustomCard(
                            child: CustomExpansionTile(
                              title: Text('${i['course']}'),
                              subtitle: Text('${i['teacher']}'),
                              initiallyExpanded: !isSpam(i['comment']),
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          '${i['comment']}',
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          '${i['hard'] == 'E' ? _hardList[0] : i['hard'] == 'D' ? _hardList[1] : i['hard'] == 'C' ? _hardList[2] : i['hard'] == 'B' ? _hardList[3] : _hardList[4]} ${i['recommend'] == 'E' ? _recommendList[0] : i['recommend'] == 'D' ? _recommendList[1] : i['recommend'] == 'C' ? _recommendList[2] : i['recommend'] == 'B' ? _recommendList[3] : _recommendList[4]}',
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          '${i['department']} ${i['year'].length == 4 ? '1${i['year']}' : '9${i['year']}'}',
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ), //
                                ),
                              ],
                            ),
                          ),
                    if (_searchResult != null && _searchResult!.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.center,
                        child: const Text('沒有搜尋結果'),
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
