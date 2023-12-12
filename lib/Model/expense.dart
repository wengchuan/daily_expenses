import 'package:shared_preferences/shared_preferences.dart';

import '../Controller/sqlite_db.dart';
import '../Controller/request_controller.dart';
class Expense {
  static const String SQLiteTable ="expense";
  String id;
  String desc;
  double amount;
  String dateTime;

  Expense(this.id, this.amount, this.desc, this.dateTime);

  Expense.fromJson(Map<String, dynamic> json):
      id = json['id'] as String,
      desc = json['desc'] as String,
      amount = double.parse(json['amount'] as dynamic),
      dateTime = json['dateTime'] as String;

  Map<String, dynamic> toJson() =>{'id':id,'desc' :desc , 'amount':amount, 'dateTime':dateTime};

  Future<Expense?> save() async{

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString('ip');
    RequestController req = RequestController(path: "/api/expenses.php", server:"http://$server" );
    req.setBody(toJson());
    await req.post();
    await SQLiteDB().insert(SQLiteTable, req.result());
    if (req.status() == 200 && req.result() != null ){


       return Expense.fromJson(req.result());


    }
    else{

      if(await SQLiteDB().insert(SQLiteTable, toJson())!=0){
        return Expense.fromJson(toJson());
      }else{
        return null;
      }
    }


  }

  Future<bool> update() async{

    await SQLiteDB().update(SQLiteTable, toJson());
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString('ip');
    RequestController req = RequestController(path: "/api/expenses.php", server:"http://$server" );
    req.setBody(toJson());
    await req.put();
    if(req.status()==200){
      return true;
    }
    return false;

  }
  Future<bool> delete() async{

    await SQLiteDB().delete(SQLiteTable, toJson());
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString('ip');
    RequestController req = RequestController(path: "/api/expenses.php", server:"http://$server" );
    req.setBody(toJson());
    await req.delete();
    if(req.status()==200){
      return true;
    }
    return false;

  }




  static Future<List<Expense>> loadAll() async{
    List<Expense> result =[];
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString('ip');
    RequestController req = RequestController(path: "/api/expenses.php", server:"http://$server" );

    await req.get();
    if (req.status() == 200 && req.result() != null ){

      for(var item in req.result()){
        result.add(Expense.fromJson(item));
      }
    }else{
      // else it will load from local storage
      List<Map<String, dynamic>> result = await SQLiteDB().queryAll(SQLiteTable);
      List<Expense> expenses = [];
      for (var item in result){
        result.add(Expense.fromJson(item) as Map<String, dynamic>);
      }

    }

  return result;

  }



}