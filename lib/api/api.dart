import 'dart:io';
import 'package:dio/dio.dart';

class Api{
 // 创建一个 Dio 客户端实例
  var dio = Dio();

  var url = 'http://159.75.111.41:38848';
//获取列表
Future<dynamic> getListData(File file) async {
 

  // 构建 FormData 对象
  var formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(
      file.path,
      filename: file.path.split('/').last,
    ),
  });

  // 发送 POST 请求
  Response response = await dio.post(
    '${url}/system/bed/page', // 后端 URL
    data: formData, // 将 FormData 作为请求数据
    options: Options(
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    ),
  );

// 获取响应数据
  Map<String, dynamic> responseData = response.data;

  return responseData;
}

//获取医院信息
Future<dynamic> getInfo(File file) async {
  

  // 构建 FormData 对象
  var formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(
      file.path,
      filename: file.path.split('/').last,
    ),
    // 可以在这里添加其他需要发送的字段，例如：
    // 'other_field': 'value',
  });

  // 发送 POST 请求
  Response response = await dio.post(
    '${url}/system/bed/map', // 后端 URL
    data: formData, // 将 FormData 作为请求数据
    options: Options(
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    ),
  );

// 获取响应数据
  Map<String, dynamic> hospitalInfo = response.data;
  return hospitalInfo;
}

//新增床位
Future<dynamic> addBedInfo(File file, String newbedname) async {


  // 构建 FormData 对象
  var formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(
      file.path,
      filename: file.path.split('/').last,
    ),
  });

  // 发送 POST 请求
  Response response = await dio.post(
    '${url}/system/bed/add/${newbedname}', // 后端 URL
    data: formData, // 将 FormData 作为请求数据
    options: Options(
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    ),
  );

// 获取响应数据
  Map<String, dynamic> hospitalInfo = response.data;


  return hospitalInfo;
}

//修改床位状态
Future<dynamic> changeBedStatus(File file, int bedId, String bedname ,String bedStauts) async {
  

  // 构建 FormData 对象
  var formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(
      file.path,
      filename: file.path.split('/').last,
    ),
    // 可以在这里添加其他需要发送的字段，例如：
    'bedId': bedId,
    'bedname': bedname,
    'stutas': 0,
    'bedStauts':bedStauts
  });

  // 发送 put 请求
  Response response = await dio.put(
    '${url}/system/bed/editstatus', // 后端 URL
    data: formData, // 将 FormData 作为请求数据
    options: Options(
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    ),
  );

// 获取响应数据
  Map<String, dynamic> hospitalInfo = response.data;


  return hospitalInfo;
}

//查询设备报警信息
Future<dynamic> getBedbaojing(File file) async {
  

  // 构建 FormData 对象
  var formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(
      file.path,
      filename: file.path.split('/').last,
    ),
  });
  // 发送 put 请求
  Response response = await dio.post(
    '${url}/system/bed/getbaojing', // 后端 URL
    data: formData, // 将 FormData 作为请求数据
    options: Options(
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    ),
  );

// 获取响应数据
  Map<String, dynamic> baojingInfo = response.data;

  return baojingInfo;
}

//获得全部科室
Future<dynamic> listdepartment(String hospitalname) async {

  // 构建 FormData 对象
  var formData = FormData.fromMap({
    // 可以在这里添加其他需要发送的字段，例如：
    'hospitalname': hospitalname,
  });

  // 发送 POST 请求
  Response response = await dio.get(
    '${url}/system/department/listdepartment/${hospitalname}', // 后端 URL
    // 将 FormData 作为请求数据
    options: Options(
      headers: {
        'Content-Type': 'multipart/x-www-form-urlencoded',
      },
    ),
    data: formData,
  );

// 获取响应数据
  Map<String, dynamic> listdepartment = response.data;
  return listdepartment;
}

//修改床位信息
Future<dynamic> changeBedInfo(File file, int bedId, String bedname, String departmentName, String hospitalName) async {
  

  // 构建 FormData 对象
  var formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(
      file.path,
      filename: file.path.split('/').last,
    ),
    // 可以在这里添加其他需要发送的字段，例如：
    'bedId': bedId,
    'bedName': bedname,
    'departmentName': departmentName,
    'hospitalName': hospitalName,
  });

  // 发送 put 请求
  Response response = await dio.put(
    '${url}/system/bed/edit', // 后端 URL
    data: formData, // 将 FormData 作为请求数据
    options: Options(
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    ),
  );

// 获取响应数据
  Map<String, dynamic> hospitalInfo = response.data;
  return hospitalInfo;
}



}