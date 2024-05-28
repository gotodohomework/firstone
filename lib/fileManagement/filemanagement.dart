import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

Future<void> writeFile(String fileName, String content) async {
  // 获取应用的文档目录
  final directory = await getApplicationDocumentsDirectory();
  // 创建文件
  final file = File('${directory.path}/$fileName');
  // 将内容写入文件
  await file.writeAsString(content);
}

Future<String> readFile(String fileName) async {
  // 获取应用的文档目录
  final directory = await getApplicationDocumentsDirectory();
  // 创建文件
  final file = File('${directory.path}/$fileName');
  // 从文件中读取内容
  return await file.readAsString();
}

// 确保在读取文件之前文件已经存在
Future<String> readFile1(String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  print("当前程序路径：${directory.path}/$fileName");
  final filePath = '${directory.path}/$fileName';
  final file = File(filePath);

  // 在尝试读取之前检查文件是否存在
  if (!await file.exists()) {
    return '';
  }

  return await file.readAsString();
}

Future<dynamic> uploadFileToProject(bool flag) async {
  // final directory = await getApplicationDocumentsDirectory();  getExternalStorageDirectory()\

  // final directory = await getExternalStorageDirectory();
  // final internalfilePath = '${directory!.path}/31010';
  // print("文文文件路径${directory.path}/31010");

  final internalfilePath = '/storage/emulated/0/31010';

  //用户手动上传
  if (flag) {
    // 获取上传的文件路径
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String? uploadfilePath = result.files.single.path;
      if (uploadfilePath != null) {
        var secret = await File(uploadfilePath).readAsString();

        //不同平台文件替换方法
        if (Platform.isAndroid) {
          replaceFile(uploadfilePath, internalfilePath);
        } else if (Platform.isIOS) {
          //将项目内存的密钥替换为用户上传的文件
          final uploadfilePathforios = await getApplicationDocumentsDirectory();
          replaceFile(uploadfilePath, uploadfilePathforios.path);
        }

        return {'secret': secret, 'name': result.files.first.name};
        //  if (Platform.isAndroid) {} else if (Platform.isIOS) {}//ios读文件
      } else {
        return ''; // 或者抛出异常，具体取决于你的需求
      }
    } else {
      // 用户取消了文件选择
      return '';
    }
  } else {
    //读项目中的密钥
    // 将文件内容读出
    final internalfilePath = '/storage/emulated/0/31010';
    File file = File(internalfilePath);

    var secret = await file.readAsString();
    return {'secret': secret, 'name': '31010'};
  }
}

Future<bool> doesFileExist(String filePath) async {
  return await File(filePath).exists();
}

Future<bool> replaceFile(String sourcePath, String targetPath) async {
  try {
    await File(sourcePath).copy(targetPath);
    return true;
  } catch (e) {}
  return false;
}

//删除文件
Future<bool> deleteFile() async {
  try {
    // 获取应用程序的文档目录
    final directory = await getApplicationDocumentsDirectory();

    // final directory = await getExternalStorageDirectory();
    final filePathforios = directory.path;
    // final file = File(filePath);

    final filePath = '/storage/emulated/0/31010';
    var file;

    //不同平台文件替换方法
    if (Platform.isAndroid) {
      file = File(filePath);
    } else if (Platform.isIOS) {
      file = File(filePathforios);
    }

    // 清空文件内容
    await file.delete();
    return true;
  } catch (e) {
    print('文件删除失败：$e');
  }
  return false;
}

//将字符串转化成文件 接受文件内容和文件名
Future<String> convertFile(String content, String name) async {
  try {
    // 获取应用程序文档目录
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    // 构造目标文件路径
    String filePath = '$appDocPath/${name}';

    // 将内容写入文件
    File file = File(filePath);
    await file.writeAsString(content);

    return filePath;
  } catch (e) {
    print('写入文件时出现错误：$e');
  }
  return '';
}

//查项目特定目录下内是否含有某一文件
Future<bool> hasSecret() async {
  // 获取应用程序的文档目录
  final directory = await getApplicationDocumentsDirectory();

  // final directory = await getExternalStorageDirectory();
  final filePathforios = directory.path;
  // final file = File(filePath);

  final filePath = '/storage/emulated/0/31010';
  var file;

  //不同平台文件替换方法
  if (Platform.isAndroid) {
    file = File(filePath);
  } else if (Platform.isIOS) {
    file = File(filePathforios);
  }
// 检查文件是否存在
  final exists = await file.exists();

  if (exists) {
    print(
        '文件存在:filePathfilePathfilePathfilePath $filePath,filePathforiosfilePathforiosfilePathforiosfilePathforiosfilePathforios:$filePathforios');
    return true;
  } else {
    print(
        '文件存在:filePathfilePathfilePathfilePath $filePath,filePathforiosfilePathforiosfilePathforiosfilePathforiosfilePathforios:$filePathforios');
    return false;
  }
}

//获取文件读取权限await Permission.storage.request().isGranted
Future<bool> requestPermissions() async {
  print("申请提交");
  if (await Permission.manageExternalStorage.request().isGranted) {
    print("申请提交       成功");
    await uploadFileToProject(false);
    print("调用后------------------");

    var status = await Permission.storage.status;
    if (status.isGranted) {
      print("权限已授予");
    } else {
      print("权限未授予");
    }

    return true;
  } else {
    print("申请提交       失败");
    return false;
  }
}
