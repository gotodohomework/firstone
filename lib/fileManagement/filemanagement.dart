import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

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
  final filePath = '${directory.path}/$fileName';
  final file = File(filePath);

  // 在尝试读取之前检查文件是否存在
  if (!await file.exists()) {
    return '';
  }

  return await file.readAsString();
}

Future<dynamic> uploadFileToProject() async {
  // 获取上传的文件路径
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result != null) {
    String? filePath = result.files.single.path;
    
    if (filePath != null) {
      var secret = await File(filePath).readAsString();
      return {'secret':secret,'name':result.files.first.name};
    } else {
      return ''; // 或者抛出异常，具体取决于你的需求
    }
  } else {
    // 用户取消了文件选择
    return '';
  }
}

Future<bool> doesFileExist(String filePath) async {
  return await File(filePath).exists();
}

Future<bool> replaceFile(String sourcePath, String targetPath) async {
  try {
    await File(sourcePath).copy(targetPath);
    return true;
  } catch (e) {
  }
  return false;
}

Future<bool> deleteFile(String filePath) async {
  try {
    await File(filePath).delete();
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
