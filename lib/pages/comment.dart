import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widget/card.dart';
import '../widget/expansion_tile.dart';
import '../widget/linear_progress_indicator.dart';
import '../widget/auto_complete.dart';
import '../widget/drop_down_button_form_field.dart';
import '../widget/scaffold_messenger.dart';

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
  final _maximumRead = 100;
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

  bool isSpam(String comment) {
    int spamCount = 0;

    // 檢測關鍵字
    for (var spam in ['湊三篇']) {
      if (comment.contains(spam)) {
        spamCount++;
      }
    }

    // TODO: 加上其他檢測方案

    // 設定判定為垃圾評論的門檻
    if (spamCount >= 1) {
      // 晚1秒再顯示訊息，避免在build的時候呼叫造成error
      // 1秒是不是最好的尚未驗證
      Future.delayed(const Duration(seconds: 1), () {
        // 先清空排程，避免有多個垃圾評論時，訊息重複顯示
        ScaffoldMessenger.of(context).clearSnackBars();
        CustomScaffoldMessenger.showMessageSnackBar(
          context,
          '已自動摺疊疑似垃圾評論',
        );
      });
      return true;
    }

    // 都沒有檢測到，就不是垃圾評論
    return false;
  }

  void clearSearch() {
    setState(() {
      _searchResult = null;
    });
    _expansionTileController.expand();
  }

  Widget colorBall(String grad, bool reverse) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: grad == 'E'
            ? reverse
                ? Colors.green
                : Colors.red
            : grad == 'D'
                ? reverse
                    ? Colors.blue
                    : Colors.orange
                : grad == 'C'
                    ? reverse
                        ? Colors.yellow
                        : Colors.yellow
                    : grad == 'B'
                        ? reverse
                            ? Colors.orange
                            : Colors.blue
                        : reverse
                            ? Colors.red
                            : Colors.green,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget doubleColorBall(String grad1, String grad2) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 使用圓點顏色紅到綠來表示推薦度及難度
        IconButton(
          icon: colorBall(grad1, false),
          tooltip: grad1 == 'E'
              ? _recommendList[0]
              : grad1 == 'D'
                  ? _recommendList[1]
                  : grad1 == 'C'
                      ? '${_recommendList[2]}(推薦度)'
                      : grad1 == 'B'
                          ? _recommendList[3]
                          : _recommendList[4],
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('推薦度'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < _recommendList.length; i++)
                        Row(
                          children: [
                            colorBall(
                                i == 0
                                    ? 'E'
                                    : i == 1
                                        ? 'D'
                                        : i == 2
                                            ? 'C'
                                            : i == 3
                                                ? 'B'
                                                : 'A',
                                false),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              _recommendList[i],
                            ),
                          ],
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('關閉'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        IconButton(
          icon: colorBall(grad2, true),
          tooltip: grad2 == 'E'
              ? _hardList[0]
              : grad2 == 'D'
                  ? _hardList[1]
                  : grad2 == 'C'
                      ? '${_hardList[2]}(難度)'
                      : grad2 == 'B'
                          ? _hardList[3]
                          : _hardList[4],
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('難度'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < _hardList.length; i++)
                        Row(
                          children: [
                            colorBall(
                                i == 0
                                    ? 'E'
                                    : i == 1
                                        ? 'D'
                                        : i == 2
                                            ? 'C'
                                            : i == 3
                                                ? 'B'
                                                : 'A',
                                true),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              _hardList[i],
                            ),
                          ],
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('關閉'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
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
                    onExpansionChanged: (value) {
                      if (_searchResult == null) {
                        _expansionTileController.expand();
                      }
                    },
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
                                    width:
                                        MediaQuery.of(context).size.width > 700
                                            ? 210
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
                                        ? 215
                                        : MediaQuery.of(context).size.width <
                                                400
                                            ? double.infinity
                                            : MediaQuery.of(context)
                                                        .size
                                                        .width *
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
                                            700
                                        ? 215
                                        : MediaQuery.of(context).size.width <
                                                400
                                            ? double.infinity
                                            : MediaQuery.of(context)
                                                        .size
                                                        .width *
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
                // 統計平均數值
                if (_searchResult != null && _searchResult!.isNotEmpty)
                  CustomCard(
                    child: Builder(
                      builder: (context) {
                        List recommend = [];
                        List hard = [];
                        for (var i in _searchResult!.take(_maximumRead)) {
                          if (i['ad'] == 0) {
                            recommend.add(i['recommend']);
                            hard.add(i['hard']);
                          }
                        }
                        var recommendSum = 0;
                        var hardSum = 0;
                        for (var i in recommend) {
                          recommendSum += i == 'E'
                              ? 1
                              : i == 'D'
                                  ? 2
                                  : i == 'C'
                                      ? 3
                                      : i == 'B'
                                          ? 4
                                          : 5;
                        }
                        for (var i in hard) {
                          hardSum += i == 'E'
                              ? 1
                              : i == 'D'
                                  ? 2
                                  : i == 'C'
                                      ? 3
                                      : i == 'B'
                                          ? 4
                                          : 5;
                        }
                        var recommendAvg = recommendSum / recommend.length;
                        var hardAvg = hardSum / hard.length;
                        return CustomExpansionTile(
                            title: const Text('統計'),
                            subtitle: const Text('平均數值'),
                            leading: const Icon(Icons.bar_chart),
                            initiallyExpanded: false,
                            trailing: doubleColorBall(
                              recommendAvg > 4.5
                                  ? 'A'
                                  : recommendAvg > 3.5
                                      ? 'B'
                                      : recommendAvg > 2.5
                                          ? 'C'
                                          : recommendAvg > 1.5
                                              ? 'D'
                                              : 'E',
                              hardAvg > 4.5
                                  ? 'A'
                                  : hardAvg > 3.5
                                      ? 'B'
                                      : hardAvg > 2.5
                                          ? 'C'
                                          : hardAvg > 1.5
                                              ? 'D'
                                              : 'E',
                            ),
                            // 表格 縱向分別是難度及推薦度，橫向分別是五級顏色的球，顏色由紅到綠，內度數值為該顏色(等級)的數量
                            children: [
                              Table(
                                children: [
                                  TableRow(
                                    children: [
                                      const Text(
                                        '數量',
                                        textAlign: TextAlign.center,
                                      ),
                                      for (var i = 'A';
                                          i != 'F';
                                          i = String.fromCharCode(
                                              i.codeUnitAt(0) + 1))
                                        colorBall(i, false),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      const Text(
                                        '推薦度',
                                        textAlign: TextAlign.center,
                                      ),
                                      for (var i = 'A';
                                          i != 'F';
                                          i = String.fromCharCode(
                                              i.codeUnitAt(0) + 1))
                                        Text(
                                          recommend
                                              .where((element) => element == i)
                                              .length
                                              .toString(),
                                          textAlign: TextAlign.center,
                                        ),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      const Text(
                                        '難度',
                                        textAlign: TextAlign.center,
                                      ),
                                      for (var i = 'E';
                                          i !=
                                              '@'; // utf16下 A的前一個字元 0041 -> 0040
                                          i = String.fromCharCode(
                                              i.codeUnitAt(0) - 1))
                                        Text(
                                          hard
                                              .where((element) => element == i)
                                              .length
                                              .toString(),
                                          textAlign: TextAlign.center,
                                        ),
                                    ],
                                  ),
                                ],
                              )
                            ]);
                      },
                    ),
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
                      for (var i in _searchResult!.take(_maximumRead))
                        // 先略過所有的廣告 TODO: 顯示廣告
                        if (i['ad'] == 0)
                          CustomCard(
                            child: CustomExpansionTile(
                              title: Text('${i['course']}'),
                              subtitle: Text('${i['teacher']}'),
                              initiallyExpanded: !isSpam(i['comment']),
                              trailing: doubleColorBall(
                                i['recommend'],
                                i['hard'],
                              ),
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
