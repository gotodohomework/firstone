import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:influsion_4_28/utils/clock.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import '../sqfliteHelper.dart';
import 'login/login.dart';
import './fileManagement/filemanagement.dart';
import './api/api.dart';
import 'dart:io';
import 'utils/debouncer.dart';
import 'package:flutter/services.dart'; // 导入该库

//消息提示
import 'package:fluttertoast/fluttertoast.dart';

class Home extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Home> {
  // final String data; // 接收传递过来的数据


  //当前时间
  var currentTime;
  //时间日期开始
  late Timer _timer;
  late DateTime dateTime;

  //床位使用时间计时
  late Timer _timer1;
  var usedtime;

  // Home(this.data);
  final dbHelper = DatabaseHelper();
  final api = Api();
  var path = "";
  final debouncer = Debouncer(milliseconds: 500);
  var total = 0;
  List<dynamic> bedList = [];

  var departmentList = [];
  var hospitalName = '';
  var department = '';
  String? dropdownValue;
  //请求响应信息
  String msg = '';
  String newName = '';

  List<String> options = ['Option 1', 'Option 2', 'Option 3'];
  final Map<String, IconData> iconMap = {
    '正常': Icons.mood,
    '缺液警告': Icons.invert_colors_off,
    '滴速异常': Icons.local_drink,
    '电压警告': Icons.electric_bolt,
    '设备故障': Icons.report_problem,
    '未知': Icons.flip_camera_ios_sharp,
    // 添加其他图标名称和对应的 IconData
  };
  //输液瓶正/异常配置
  //正常
  var normalcolor = [
    Color(0xFFE8F4FF)!,
    Color(0xFF1890FF)!,
    // Color(0xFFE0F7FA)!,
    // Colors.indigo[100]!
  ];
  //异常
  var abnormalcolor = [
    Color(0xFFFFEDED)!,
    Color(0xFFFF4949)!,
    // Color(0xFFE0F7FA)!,
    // Colors.indigo[100]!
  ];

  @override
  void initState() {
    super.initState();
    //时钟初始化
    dateTime = new DateTime.now();
    this._timer = new Timer.periodic(Duration(seconds: 1), setTime);
    // 将数据库密钥变成文件
    initializeFile().then((_) {
      // 获取床位信息
      _getList();
      // 获取医院信息
      showInfo();
      // 获取全部科室信息
      getlistdepartment();

      //启动已使用时间倒计时
      this._timer1 = new Timer.periodic(Duration(seconds: 10), updateTime);
    });

  }

  @override
  void dispose() {
    //释放资源
    _timer.cancel();
    _timer1.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // );
    return MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          appBar: AppBar(
            title: Text('${hospitalName}  ${department}'),
            backgroundColor: Colors.lightBlue, // 设置背景颜色为淡蓝色
            systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Color.fromRGBO(0, 0, 0, 1)),
            centerTitle: true,
            actions: <Widget>[
              Text(
                "${dateTime.year}/${dateTime.month}/${dateTime.day}",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              Text(
                "  ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: TextButton(
                    onPressed: () {
                      // 当按钮被按下时，弹出提示框
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // 构建对话框内容
                          return AlertDialog(
                            title: Text('确认操作'),
                            content: Text('您确定要清除密钥吗？'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // 用户点击"取消"按钮时关闭对话框
                                  Navigator.of(context).pop();
                                },
                                child: Text('取消'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // 用户点击"确定"按钮时执行相应逻辑
                                  print('密钥已清除');
                                  //删除密钥
                                  deleteSecret();

                                  Navigator.of(context).pop();
                                },
                                child: Text('确定'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.lightBlue), // 设置背景颜色
                    ),
                    child: Icon(Icons.delete),
                  ))
            ],
          ),

          body: Padding(
            padding: const EdgeInsets.all(0.0),
            child: RefreshIndicator(
                onRefresh: () {
                  return _getList();
                },
                child: Container(
                    decoration:
                        BoxDecoration(color: Color.fromRGBO(235, 240, 246, 1)
                            // 设置圆角
                            ),
                    height: 700,
                    width: 1400,
                    //刷新页面 调用的方法
                    child: total != 0 ? _buildGrid() : _nullShow())),
          ),
        ));
  }

  Widget _nullShow() {
    return ListView(
      children: [
        Container(
            margin: EdgeInsets.all(170.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('img/nullData.png'),
                Text('暂无数据，请尝试刷新/确保导入了正确的文件。')
              ],
            ))
      ],
    );
  }

  // #docregion grid
  Widget _buildGrid() => GridView.extent(
      //床位总体样式
      //每个床位的大小
      maxCrossAxisExtent: 200,
      //内边距
      padding: const EdgeInsets.all(4),
      mainAxisSpacing: 10,
      crossAxisSpacing: 20,
      children: _buildGridTileList(total));

  List<Container> _buildGridTileList(int count) => List.generate(
        count,
        (i) => Container(
            decoration: BoxDecoration(
              color: Colors.white, // 设置单元格的背景颜色
              borderRadius: BorderRadius.circular(12), // 设置圆角
            ),
            child: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext contextofform) {
                      // 定义表单控制器
                      TextEditingController textEditingController =
                          TextEditingController();
                      String dropdownValue = department;
                      return AlertDialog(
                        title: Text("更换科室/解绑"),
                        //  backgroundColor: Colors.green,
                        content: Container(
                          width: 350.0, // 自定义内容的宽度
                          height: 220.0, // 自定义内容的高度

                          child: ListView
                              (

                            children: [
                              //新床名
                              newbedNameTextField(i, textEditingController),

                              SizedBox(height: 20), // 添加垂直间距

                              SizedBox(
                                width: 100, // 设置宽度为300
                                height: 50, // 设置高度为150
                                child: DropdownMenu<String>(
                                  width: 300,
                                  menuHeight: 150,
                                  initialSelection: dropdownValue,
                                  onSelected: (String? value) {
                                    setState(() {
                                      dropdownValue = value!;
                                    });
                                  },
                                  dropdownMenuEntries:
                                      _buildMenuList(departmentList),
                                ),
                              ),

                              SizedBox(height: 50), // 添加垂直间距

                              //直接解绑
                              GestureDetector(
                                onTap: () {
                                  // 当按钮被按下时，弹出提示框
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      // 构建对话框内容
                                      return AlertDialog(
                                        title: Text('确认操作'),
                                        content: Text(
                                            '确认直接解绑‘${bedList[i]["bedName"]}’吗?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              // 用户点击"取消"按钮时关闭对话框
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('取消'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              if (await changeStatus(
                                                  bedList[i]["bedId"],
                                                  bedList[i]["bedName"])) {
                                                //操作成功提示
                                                showToast(0);
                                              } else {
                                                //操作失败提示
                                                showToast(1);
                                              }
                                              Navigator.of(context).pop();
                                              //外层
                                              Navigator.of(contextofform).pop();
                                              await _getList();
                                            },
                                            child: Text('确定'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Text(
                                  '直接解绑',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              )

                              // 添加更多组件
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                          
                              Navigator.of(context).pop(); // 关闭对话框
                            },
                            child: Text("取消"),
                          ),
                          TextButton(
                            onPressed: () async {
                              //防抖
                              debouncer.run(() async {
                                //信息校验

                                print(
                                    "新信息：${textEditingController.text}\n新科室名:${dropdownValue}");
                                print(
                                    "医院名${hospitalName}\n 床位id:${bedList[i]["bedId"]}");

                                if (await changeInfo(
                                    bedList[i]["bedId"],
                                    textEditingController.text,
                                    hospitalName,
                                    dropdownValue)) {
                                  //操作成功提示
                                  showToast(0);
                                } else {
                                  //操作失败提示
                                  showToast(1);
                                }
                                //外层
                                Navigator.of(contextofform).pop();

                                await _getList();
                              });
                            },
                            child: Text("确认"),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(1.0), 
                    ),
                  ),
                ),
                child: bedStatus(i))),
      );

  //设备异常信息展示文本
  Widget bedStatus(int i) {
    String alarm = '未知:${bedList[i]["alarm"]}';

    String icons = '未知';

    if (bedList[i]["alarm"] == '01') {
      alarm = '缺液警告';
      icons = '缺液警告';
    } else if (bedList[i]["alarm"] == '02') {
      alarm = '滴速异常';
      icons = '滴速异常';
    } else if (bedList[i]["alarm"] == '03') {
      alarm = '设备故障';
      icons = '设备故障';
    } else if (bedList[i]["alarm"] == '04') {
      alarm = '电压警告';
      icons = '电压警告';
    } else if (bedList[i]["alarm"] == '00') {
      alarm = '正常';
      icons = '正常';
    }
    return Stack (
      alignment: Alignment.center,
      children: [
        Positioned(
            top: 5,
            left: 30,
            child: Container(
              child: Text(
                "${bedList[i]["bedName"]}",
                style: TextStyle(
                  color: Colors.black, // 可选：设置文本颜色
                  fontSize: 22, // 可选：设置文本字体大小
                ),
              ),
            )),
        Positioned(
            top: 50,
            left: 94,
            child: Container(
                child: Column(
              children: [
                Text(
                  "${(bedList[i]["bedStatus"] == '0') ? '未锁定' : '已锁定'}",
                  style: TextStyle(
                    color: Colors.black, // 可选：设置文本颜色
                    fontSize: 15, // 可选：设置文本字体大小
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "${alarm}",
                  style: TextStyle(
                    color: Colors.black, // 可选：设置文本颜色
                    fontSize: 15, // 可选：设置文本字体大小
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "${bedList[i]["usertime"]}",
                  style: TextStyle(
                    color: Colors.black, // 可选：设置文本颜色
                    fontSize: 15, // 可选：设置文本字体大小
                  ),
                ),

              ],
            ))),
        Positioned(
          top: 25,
          left: 0,
          child: Stack(
            children: [
              Positioned(
                  top: 42,
                  left: 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 60,
                      height: 65,
                      child: WaveWidget(
                        config: CustomConfig(
                          colors: ((bedList[i]["alarm"] == '00')
                              ? normalcolor
                              : abnormalcolor),
                          durations: [18000, 8000],
                          heightPercentages: [0.1, 0.16],
                        ),
                        size: Size(double.infinity, double.infinity),
                        waveAmplitude: 1.0,
                      ),
                    ),
                  )),
              Positioned(
                  // top: 50,
                  // left: 90,
                  child: Container(
                width: 100,
                height: 150,
                child: Image.asset('img/icon/输液瓶测试.png'),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget newbedNameTextField(
      int i, TextEditingController textEditingController) {
    textEditingController.text = "${bedList[i]["bedName"]}";

    return TextField(
      keyboardType: TextInputType.url,
      controller: textEditingController,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')) // 禁止输入空格
      ],
      decoration: InputDecoration(
        hintText: "请输入新床位名",
      ),
    );
  }

  List<DropdownMenuEntry<String>> _buildMenuList(List<dynamic> data) {
    List<String> stringList = data.cast<String>();
    return stringList.map((String value) {
      return DropdownMenuEntry<String>(value: value, label: value);
    }).toList();
  }

  Widget listdepartmentDropdownButtonFormField(String dropdownValue) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      iconSize: 20,
      style: TextStyle(fontSize: 15, color: Colors.black),
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.only(left: 5, right: 5),
          border: OutlineInputBorder(gapPadding: 1),
          labelText: ''),
      // 设置默认值
      value: dropdownValue,
      // 选择回调
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
          // department = newValue;
        });
      },
      // 传入可选的数组
      items: departmentList
          .map<DropdownMenuItem<String>>((dynamic value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          })
          .toSet()
          .toList(),
    );
  }

  Widget showUsedTime(i) {
    // setTime1(i);
    return Text(
      "${usedtime}",
      style: TextStyle(
        color: Colors.black, // 可选：设置文本颜色
        fontSize: 15, // 可选：设置文本字体大小
      ),
    );
  }

// 请求响应信息  0 成功 1 失败
  void showToast(int flag) {
    Fluttertoast.showToast(
      msg: (flag == 0) ? "操作成功" : "操作失败！",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: (flag == 0)
          ? Color.fromRGBO(231, 250, 240, 1)
          : Color.fromRGBO(255, 237, 237, 1),
      textColor: (flag == 0)
          ? Color.fromRGBO(113, 226, 163, 1)
          : Color.fromRGBO(255, 73, 73, 1),
      fontSize: 16.0,
    );
  }



  //删除密钥 库
  Future<void> deleteSecret() async {
    print("删除密钥执行");

    dbHelper.deleteItem();
    var insertResult = await dbHelper.fetchItems();
    if (insertResult.isNotEmpty) {
      print('删除失败!');
    } else {
      Get.offAll(Login());
    }
  }

/**
 * 请求方法 间接传文件类
 */

  Future<void> initializeFile() async {
    //获取数据库密钥字符
    var insertResult = await dbHelper.fetchItems();
    var filepath = await convertFile(
        insertResult[0]['secretValue'], insertResult[0]['name']);
    setState(() {
      path = filepath;
    });
  }

  //请求医院信息
  Future<void> showInfo() async {
    File file = File(path);
    var hospitalInfo = await api.getInfo(file);
    setState(() {
      
      hospitalName = hospitalInfo["data"]["hospital"];
      department = hospitalInfo["data"]["department"];


    });

    getlistdepartment();
  }

//请求床位数据
  Future<void> _getList() async {
    File file = File(path);
    print("abab1");
    Map<String, dynamic> responseData = await api.getListData(file);
    bedList = responseData['list'];
    for (var bed in bedList) {
      try {
        // 解析原始的 usertime 字符串
        List<String> timeParts = bed['usertime'].split(':');
        int days = int.parse(timeParts[0]);
        int hours = int.parse(timeParts[1]);
        int minutes = int.parse(timeParts[2]);

        days = days * 60;
        // 将更新后的时间重新设置到 bed 对象中
        bed['usertime'] =
            '${days.toString().padLeft(2, '0')}:${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
        print("更新后时间：${bed['usertime']},I:${bed}");
      } catch (e) {
        print(e);
      }

    }

    setState(() {

      //请求数据
      total = int.parse(responseData['total']);
      bedList = bedList;

      print('Total: ${total}');
      print('第一个床位的名字: ${bedList}');
    });
  }

  Future<bool> addBed(String newbedname) async {
    print("添加用户");
    File file = File(path);
    print("abab1");
    Map<String, dynamic> responseData = await api.addBedInfo(file, newbedname);
    bool flag = false;
    setState(() {
      var code = responseData['code'];
      (code == 200) ? flag = true : flag = false;
      print('code: $code');
    });
    print("abab1${flag}");
    return flag;
  }

  //修改床位状态
  Future<bool> changeStatus(int bedId, String bedname) async {
    print("修改用户状态");
    File file = File(path);
    print("ID：${bedId}");
    print("名字:${bedname}");
    Map<String, dynamic> responseData =
        await api.changeBedStatus(file, bedId, bedname);
    bool flag = false;
    setState(() {
      var code = responseData['code'];
      msg = responseData['msg'];
      (code == 200) ? flag = true : flag = false;
      print('code: $code');
    });

    print("abab1${flag}");
    return flag;
  }

  Future<bool> changeInfo(int bedId, String bedname, String hospitalName,
      String dropdownValue) async {

    File file = File(path);
    Map<String, dynamic> responseData = await api.changeBedInfo(
        file, bedId, bedname, dropdownValue, hospitalName);
    bool flag = false;
    setState(() {
      var code = responseData['code'];
      msg = responseData['msg'];
      (code == 200) ? flag = true : flag = false;
      print('code: $code');
    });

    return flag;
  }

  //获取科室列表
  Future<void> getlistdepartment() async {
    print("医院名$hospitalName");
    Map<String, dynamic> responseData = await api.listdepartment(hospitalName);
    setState(() {
      var departmentNames = responseData['data'];
      departmentList = departmentNames
          .map((department) => department["departmentName"])
          .toList();
      print('全部科室信息: ${departmentList}');
    });
  }

  //设置时间 按秒调用更新
  void setTime(Timer timer) {
    setState(() {
      dateTime = new DateTime.now();
    });
  }

  //床位使用时间计时 按秒调用更新
  setTime1(i) {
    usedtime = bedList[i]["usertime"];

    _timer1 = Timer.periodic(Duration(milliseconds: 10000), (timer) {
      usedtime = TimeUtils.incrementTime(usedtime);

      setState(() {
        usedtime = usedtime;
      });

      print("更新后${usedtime},I:$i");
    });
  }

  updateTime(Timer timer) {
    _getList();
  }
}
