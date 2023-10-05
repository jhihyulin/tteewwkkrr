import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widget/card.dart';
import '../widget/expansion_tile.dart';
import '../widget/linear_progress_indicator.dart';
import '../widget/auto_complete.dart';
import '../widget/drop_down_button_form_field.dart';
import '../widget/scaffold_messenger.dart';

class SignablePage extends StatefulWidget {
  const SignablePage({Key? key}) : super(key: key);

  @override
  State<SignablePage> createState() => _SignablePageState();
}

class _SignablePageState extends State<SignablePage> {
  final _formKey = GlobalKey<FormState>();
  // 由於mixed content問題(原點tewkr.com沒有SSL)，所以用cloudfare worker來做代理
  final baseURL = 'https://tteewwkkrr.jhihyulin.workers.dev/api';
  late List<String> coursesList;
  late List<String> teachersList;
  late Map<String, List<String>> departmentList;
  final String _selectedCollegeDefault = '請選擇學院';
  final String _selectedDepartmentDefault = '請選擇系所/科目';
  final String _selectedSemesterDefault = '請選擇學期';
  final String _selectedSignableDefault = '請選擇加簽條件';
  late String? _selectedTeacher;
  late String? _selectedCourse;
  late String? _selectedCollege;
  late String? _selectedDepartment;
  late String? _selectedSemester;
  late String? _selectedSignable;
  late ScrollController _scrollController;
  final _maximumRead = 100;
  final List<String> _signableList = [
    '不可加簽',
    '低年級優先',
    '高年級優先',
    '本科系優先',
    '有限額加簽',
    '第一堂課出席才可加簽',
    '無限額加簽',
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
    _selectedSignable = null;
    _searchResult = null;
    _isSearching = false;
    _scrollController = ScrollController();
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
              '[ERROR] courseList: ${response.statusCode} ${data['code']} ${response.body}');
          CustomScaffoldMessenger.showErrorMessageSnackBar(
            context,
            '${response.statusCode} ${data['code']} 課程列表載入失敗',
          );
        }
      } else {
        coursesList = [];
        debugPrint(
            '[ERROR] courseList: ${response.statusCode} ${response.body}');
        CustomScaffoldMessenger.showErrorMessageSnackBar(
          context,
          '${response.statusCode} 課程列表載入失敗',
        );
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
          CustomScaffoldMessenger.showErrorMessageSnackBar(
            context,
            '${response.statusCode} ${data['code']} 教師列表載入失敗',
          );
        }
      } else {
        teachersList = [];
        debugPrint(
            '[ERROR] teachersList: ${response.statusCode} ${response.body}');
        CustomScaffoldMessenger.showErrorMessageSnackBar(
          context,
          '${response.statusCode} 教師列表載入失敗',
        );
      }
    });
  }

  void getDepartments() async {
    var uri = Uri.parse('$baseURL/department');
    http.get(uri).then(
      (response) {
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
            CustomScaffoldMessenger.showErrorMessageSnackBar(
              context,
              '${response.statusCode} ${data['code']} 系所列表載入失敗',
            );
          }
        } else {
          departmentList = {};
          debugPrint(
              '[ERROR] departmentList: ${response.statusCode} ${response.body}');
          CustomScaffoldMessenger.showErrorMessageSnackBar(
            context,
            '${response.statusCode} 系所列表載入失敗',
          );
        }
      },
    );
  }

  void search(String? token, String? year, String? course, String? department,
      String? teacher, String? signable) async {
    setState(() {
      _searchResult = null;
      _isSearching = true;
    });
    var uri = Uri.parse('$baseURL/search_signable');
    var dealYear = year != null
        ? year.length == 5
            ? year.substring(1, 5)
            : year.substring(1, 4)
        : null;
    http.post(
      uri,
      body: {
        "token": token ?? '',
        "year": dealYear ?? '',
        "course": course ?? '',
        "department": department ?? '',
        "teacher": teacher ?? '',
        "signable": signable ?? '',
      },
    ).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['code'] == 200) {
          var result = data['result'];
          setState(() {
            _searchResult = result;
          });
          // debugPrint('search: ${result.toString()}');
          Future.delayed(const Duration(seconds: 1), () {
            _scrollController.animateTo(
              MediaQuery.of(context).size.width > 700
                  ? 320 > _scrollController.position.maxScrollExtent
                      ? _scrollController.position.maxScrollExtent
                      : 320
                  : MediaQuery.of(context).size.width > 500
                      ? 386 > _scrollController.position.maxScrollExtent
                          ? _scrollController.position.maxScrollExtent
                          : 386
                      : 514 > _scrollController.position.maxScrollExtent
                          ? _scrollController.position.maxScrollExtent
                          : 514,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          });
        } else {
          debugPrint(
              '[ERROR] search: ${response.statusCode} ${data['code']} ${data['msg']} ${response.body}');
          CustomScaffoldMessenger.showErrorMessageSnackBar(
            context,
            '${response.statusCode} ${data['code']} 搜尋失敗',
          );
        }
      } else {
        debugPrint('[ERROR] search: ${response.statusCode} ${response.body}');
        CustomScaffoldMessenger.showErrorMessageSnackBar(
          context,
          '${response.statusCode} 搜尋失敗',
        );
      }
      setState(() {
        _isSearching = false;
      });
    });
  }

  void clearSearch() {
    setState(() {
      _searchResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜尋加簽資訊'),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
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
                  child: Column(
                    children: [
                      const ListTile(
                        title: Text('搜尋'),
                        subtitle: Text('想以什麼條件搜尋？'),
                        leading: Icon(Icons.search),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width >
                                            700
                                        ? 325
                                        : MediaQuery.of(context).size.width >
                                                500
                                            ? MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5 -
                                                25
                                            : double.infinity,
                                    child: CustomAutocomplete(
                                      optionsBuilder:
                                          (TextEditingValue textEditingValue) {
                                        if (textEditingValue.text == '') {
                                          return const Iterable.empty();
                                        }
                                        return coursesList
                                            .where((String option) {
                                          return option.contains(
                                            textEditingValue.text.toUpperCase(),
                                          );
                                        });
                                      },
                                      onSelected: (selection) {
                                        debugPrint('selected $selection');
                                        _selectedCourse = selection;
                                      },
                                      hintText: '請輸入課程名稱',
                                      labelText: '課程名稱',
                                      optionsMaxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9 <
                                              400
                                          ? MediaQuery.of(context).size.width *
                                              0.9
                                          : 400,
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width >
                                            700
                                        ? 325
                                        : MediaQuery.of(context).size.width >
                                                500
                                            ? MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5 -
                                                25
                                            : double.infinity,
                                    child: CustomAutocomplete(
                                      optionsBuilder:
                                          (TextEditingValue textEditingValue) {
                                        if (textEditingValue.text == '') {
                                          return const Iterable.empty();
                                        }
                                        return teachersList
                                            .where((String option) {
                                          return option.contains(
                                              textEditingValue.text
                                                  .toUpperCase());
                                        });
                                      },
                                      onSelected: (selection) {
                                        debugPrint('selected $selection');
                                        _selectedTeacher = selection;
                                      },
                                      hintText: '請輸入教師姓名',
                                      labelText: '教師姓名',
                                      optionsMaxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9 <
                                              400
                                          ? MediaQuery.of(context).size.width *
                                              0.9
                                          : 400,
                                    ),
                                  ),
                                ],
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
                                            700
                                        ? 325
                                        : MediaQuery.of(context).size.width >
                                                500
                                            ? MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5 -
                                                25
                                            : double.infinity,
                                    child: CustomDropdownButtonFormField(
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
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width >
                                            700
                                        ? 325
                                        : MediaQuery.of(context).size.width >
                                                500
                                            ? MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5 -
                                                25
                                            : double.infinity,
                                    child: CustomDropdownButtonFormField(
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
                                          _selectedDepartment =
                                              value.toString();
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
                                                    in departmentList[
                                                        college]!) {
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
                                  ),
                                ],
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
                                            700
                                        ? 325
                                        : MediaQuery.of(context).size.width >
                                                500
                                            ? MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5 -
                                                25
                                            : double.infinity,
                                    child: CustomDropdownButtonFormField(
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
                                        var items =
                                            <DropdownMenuItem<String?>>[];
                                        var nowYear =
                                            DateTime.now().year - 1911;
                                        for (var year = nowYear;
                                            year >= 99;
                                            year--) {
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
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width >
                                            700
                                        ? 325
                                        : MediaQuery.of(context).size.width >
                                                500
                                            ? MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5 -
                                                25
                                            : double.infinity,
                                    child: CustomDropdownButtonFormField(
                                      hint: Text(_selectedSignableDefault),
                                      value: _selectedSignable,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedSignable = value.toString();
                                        });
                                      },
                                      label: const Text('加簽條件'),
                                      suffixIcon: _selectedSignable == null
                                          ? null
                                          : IconButton(
                                              icon: const Icon(Icons.close),
                                              tooltip: '取消選擇加簽條件',
                                              onPressed: () {
                                                setState(() {
                                                  _selectedSignable = null;
                                                });
                                              },
                                            ),
                                      items: () {
                                        List<DropdownMenuItem<String?>> items =
                                            [];
                                        for (var hard in _signableList) {
                                          items.add(DropdownMenuItem(
                                            value: hard,
                                            child: Text(hard),
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
                              if (!_isSearching)
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
                                        _selectedSignable,
                                      );
                                    }
                                  },
                                ),
                              if (_isSearching)
                                const CustomLinearProgressIndicator(),
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
                Wrap(
                  children: [
                    if (_searchResult != null)
                      CustomCard(
                        child: ListTile(
                          title: const Text('搜尋結果'),
                          subtitle: Text(_searchResult!.isEmpty
                              ? '沒有搜尋結果'
                              : '共${_searchResult!.length}筆搜尋結果${_searchResult!.length > _maximumRead ? '，目前僅顯示前$_maximumRead筆' : ''}'),
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
                      for (var i in _searchResult!.take(_maximumRead))
                        CustomCard(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${i['course']}',
                                      style: TextStyle(
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.fontSize!,
                                      ),
                                    ),
                                    Text('${i['teacher']}'),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${i['signable']}'),
                                    Text(
                                        '${i['department']} ${i['year'].length == 4 ? '1${i['year']}' : '9${i['year']}'}'),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
