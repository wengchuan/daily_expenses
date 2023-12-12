import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnterIp extends StatelessWidget {
   EnterIp({super.key});
  TextEditingController ipController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter IP Address"),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter The Server IP Address"),
            TextField(controller:ipController ,decoration: InputDecoration(
              labelText: "IP Address"
            ),),
            ElevatedButton(onPressed: () async{

              final prefs = await SharedPreferences.getInstance();
              String ip = ipController.text;
              await prefs.setString("ip", ip);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Ip ${ipController.text} is added")));

            }, child: Text("Enter")),
          ],
        ),
      ),
    );
  }
}
