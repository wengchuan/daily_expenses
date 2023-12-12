import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RequestController{
  String path;
  String server;
  http.Response? _res;
  final Map<dynamic, dynamic> _body ={};
  final Map<String,String> _header ={};
  dynamic _resultData;



  RequestController({required this.path, required this.server});
  setBody(Map<String, dynamic> data){
    _body.clear();
    _body.addAll(data);
    _header["Content-Type"] = "application/json; charset=UTF-8";
  }
  Future<void> post() async{
    _res = await http.post(
      Uri.parse(server + path),
      headers:  _header,
      body: jsonEncode(_body),

    );
    _parseResult();

  }

  Future<void> put() async{
    _res = await http.put(
      Uri.parse(server + path),
      headers:  _header,
      body: jsonEncode(_body),

    );
    _parseResult();

  }

  Future<void> get() async {

    _res = await http.get(
      Uri.parse(server + path),
      headers:  _header,
    );
    _parseResult();
  }

  Future<void> delete() async {

    _res = await http.delete(
      Uri.parse(server + path),
      headers:  _header,
      body: jsonEncode(_body),
    );
    _parseResult();
  }


  void _parseResult(){
    try{
      print("raw response:${_res?.body} ");
      _resultData = jsonDecode(_res?.body??"");


    }catch(ex){
      _resultData = _res?.body;
      print("exception in http reuslt parsing ${ex}");

    }
  }
  dynamic result(){
    return _resultData;

  }
  int status(){
    return _res?.statusCode ?? 0;
  }


}