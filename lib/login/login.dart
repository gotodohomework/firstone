import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../home.dart';
import 'package:sqflite/sqflite.dart';
import '../sqfliteHelper.dart';
import '../fileManagement/filemanagement.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/background.png'), // 设置背景图片
                fit: BoxFit.cover, // 让背景图片铺满整个容器
              ),
            ),
            child: Login1()));
  }
}

class Login1 extends StatelessWidget {
  const Login1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoginIndex();
  }
}

class LoginIndex extends StatefulWidget {
  LoginIndex({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LoginIndexState();
  }
}

class _LoginIndexState extends State<LoginIndex> {
  var url =
      "http://192.168.100.20:38848/doc.html#/default/%E5%BA%8A%E4%BD%8D%E7%AE%A1%E7%90%86%E6%8E%A5%E5%8F%A3/checkSecretUsingPUT";

  var secret = "";
  var sign = "";
  final dbHelper = DatabaseHelper();
  var result;
  Database? database;

  @override
  void initState() {
    super.initState();
//查是否存有数据，有则直接跳转，无则留在登录
    isHasSecret();
    // result = fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          height: 500,
          width: 900,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
          child: Row(
            children: [
              Image.asset('assets/img/login.png'),
              Container(
                  margin: EdgeInsets.all(25.0),
                  height: 400,
                  width: 250,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                  child: Center(
                      child: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        margin: EdgeInsets.only(top: 20.0), // 设置上边界为20像素
                        height: 50,
                        width: 300,
                        child: Center(
                            child: Text(
                          '欢迎登录',
                          style: TextStyle(
                            fontFamily: 'Helvetica Neue',
                            color: Color.fromRGBO(102, 102, 102, 1),
                            fontSize: 30, // 设置文本大小为20
                          ),
                        )),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        height: 50,
                        width: 300,
                        child: Center(
                            child: Text(
                          '科室床位管理',
                          style: TextStyle(
                            fontFamily: 'Helvetica Neue',
                            color: Color.fromRGBO(102, 102, 102, 1),
                            fontSize: 20, // 设置文本大小为20
                          ),
                        )),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 25.0),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        height: 30,
                        width: 300,
                        child: Center(
                            child: Text(
                          '点击上传文件以登录:',
                          style: TextStyle(
                            fontFamily: 'Helvetica Neue',
                            color: Color.fromRGBO(102, 102, 102, 1),
                            fontSize: 20, // 设置文本大小为20
                          ),
                        )),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        height: 100,
                        width: 100,
                        child: TextButton(
                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(
                                    Size(50, 50)), // 设置按钮的最小大小为200x50
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.white),
                                shape: MaterialStateProperty.all(
                                    const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25.0))))),
                            //登录验证与提交
                            onPressed: () async {
                              if (await openFileExplorer(true)) {
                                Get.to(Home());
                              } else {
                                showToast(0);
                              }
                            },
                            child: const Icon(
                              Icons.add_to_photos_outlined,
                              size: 40.0,
                            )),
                      ),

                      // Icon(Icons.add_to_photos_outlined)
                    ],
                  ))),
            ],
          )),
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

  // 插入数据
  Future<void> insertItem(String secret, String sign) async {
    // 写入文件示例
    await writeFile('example.txt', '$secret\n$sign');
  }

  //初始化跳转控制 库
  Future<void> isHasSecret() async {
    var insertResult = await dbHelper.fetchItems();

    //查库有无密钥
    if (insertResult.isNotEmpty) {
      //有数据，执行跳转
      Get.to(Home());
    } else {
      //数据库无数据，再查内部文件有无密钥  ../../assets/secretkey
      if (await hasSecret()) {
        //有数据,将数据存库
        print("有数据11111111111111");

        if (await openFileExplorer(false)) {
          Get.to(Home());
        }
      } else {
        print("无数据");
      }
      return;
    }
  }

  //密钥存库
  Future<bool> openFileExplorer(bool flag) async {
    var result;
    //手动上传
    if (flag) {
      //获取文件内容
      result = await uploadFileToProject(flag);
    } else {
      //密钥在项目里，读出存库
      //获取文件内容
      result = await uploadFileToProject(flag);
    }
    // 插入数据
    await dbHelper.insertItem(result);
    var insertResult = await dbHelper.fetchItems();
    if (insertResult.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
}

class LogInIcon extends StatelessWidget {
  const LogInIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // leading: Image.asset(
      //   "static/logo.png",
      // ),
      title: const Text(
        "",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
