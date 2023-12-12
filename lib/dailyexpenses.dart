

import 'package:daily_expenses/Controller/request_controller.dart';
import 'package:flutter/material.dart';
import './Model/expense.dart';
  void main(){
    runApp(DailyExpenseApp(username: '',));
  }



  class DailyExpenseApp extends StatelessWidget {
    String username ="";
     DailyExpenseApp({super.key,required this.username});



    @override
    Widget build(BuildContext context) {

      return MaterialApp(



        home: ExpenseList(username: username,),


      );
    }



  }



  class ExpenseList extends StatefulWidget {
    String username ="";
     ExpenseList({super.key,required this.username});

    @override
    State<ExpenseList> createState() => _ExpenseListState();
  }

  class _ExpenseListState extends State<ExpenseList> {

    _ExpenseListState();

    final List<Expense> expenses =[];
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController totalContorller = TextEditingController();
    final TextEditingController txtDateController = TextEditingController();
    double totalSpend = 0.0;




// Navigate to edit Screen
    void _editExpense(int index){
      Navigator.push(context, MaterialPageRoute(builder:
      (context)=> EditExpenseScreen(expense: expenses[index],
          onSave: (editedExpense){
          setState(() {
            totalSpend += editedExpense.amount - expenses[index].amount;
            expenses[index] = editedExpense;
            totalContorller.text = totalSpend.toString();
          });

          })
      ));

    }


    void _addExpense() async{
      String description = descriptionController.text.trim();
      String amount = amountController.text.trim();
      double? parsedAmount = double.tryParse(amount);

      if(amount.isNotEmpty&& description.isNotEmpty){
        Expense exp = Expense("",double.parse(amount), description, txtDateController.text);
        Expense? e = await exp.save() ;
        if(e!=null ){
          setState(() {
            expenses.add(e);
            descriptionController.clear();
            amountController.clear();
            calculateTotal();
          });
        }
        else{
          _showMessage("Failed to save Expenses data");
        }

      }


      }



    void calculateTotal(){
      totalSpend =0;
      for(Expense ex in expenses){
        totalSpend += ex.amount;
      }
      totalContorller.text = totalSpend.toString();
    }

    void _removeExpense(int index){
      totalSpend -= expenses[index].amount;
      Expense exp = Expense(expenses[index].id, expenses[index].amount,
          expenses[index].desc, expenses[index].dateTime);

      exp.delete();
      setState(() {
        expenses.removeAt(index);
        totalContorller.text = totalSpend.toString();
      });

    }

    void _showMessage(String msg){
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)));
      }
      }


  _selectDate() async{
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101));

    final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now());

    if(pickedDate != null && pickedTime != null){
      setState(() {
        txtDateController.text = "${pickedDate.year}-${pickedDate.month}-"
            "${pickedDate.day} ${pickedTime.hour}:${pickedTime.minute}:00";
      });
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _showMessage("Welcome ${widget.username}");

      RequestController req = RequestController(
          path: "/api/timezone/Asia/Kuala_Lumpur",
          server: "http://worldtimeapi.org"
      );
      req.get().then((value){
        dynamic res = req.result();
        txtDateController.text = res["dateTime"].toString().substring(0,19).replaceAll('T', ' ');

      });
      expenses.addAll(await Expense.loadAll());
      setState(() {
        calculateTotal();
      });

    });


     }



    @override
    Widget build(BuildContext context) {

      return Scaffold(

        appBar: AppBar(title: Text("Daily Expense"),) ,
        body: Column(

          children: [



            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Description"
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: amountController,
                decoration: InputDecoration(
                    labelText: "Amount (RM)"
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                keyboardType: TextInputType.datetime,
                controller: txtDateController,
                readOnly: true,
                onTap: _selectDate,
                decoration: const InputDecoration(
                    labelText: "Date"
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: totalContorller,
                decoration: InputDecoration(
                    labelText: "Total Spend (RM)"
                ),
              ),
            ),


            ElevatedButton(onPressed: _addExpense,
                child: Text("Add Expense")),

            Container(
              child: _buildListView(),
            )


          ],
        ),

      );
    }
  Widget _buildListView(){
      return Expanded(
          child: ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context,index){

              return Dismissible(
                key: Key(expenses[index].id.toString()),
                background: Container(
                  color: Colors.red,
                  child: Center(
                    child: Text(
                      "Delete",
                      style: TextStyle(color: Colors.white),
                    ),

                  ),

                ),
                onDismissed: (direction){
                  _removeExpense(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Item dismissed")));

                },

                child: Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(expenses[index].desc),
                    subtitle: Row(
                      children: [
                        Text("Amount : ${expenses[index].amount}"),
                        const Spacer(),
                        Text("Date: ${expenses[index].dateTime}")
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: ()=> _removeExpense(index),
                    ),
                    onLongPress: (){
                      _editExpense(index);
                      },
                  ),
                ),
              );

            },
          )
      );

  }


  }

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;
  final Function(Expense) onSave;

  EditExpenseScreen({required this.expense, required this.onSave});

  @override
  _EditExpenseScreenState createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {

  final List<Expense> expenses =[];
  final TextEditingController idController  = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();


  _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101));

    final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now());

    if (pickedDate != null && pickedTime != null) {
      setState(() {
        dateController.text = "${pickedDate.year}-${pickedDate.month}-"
            "${pickedDate.day} ${pickedTime.hour}:${pickedTime.minute}:00";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    idController.text = widget.expense.id;
    descController.text = widget.expense.desc;
    amountController.text = widget.expense.amount.toString();
    dateController.text = widget.expense.dateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Expense"),),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: idController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "ID",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: "Description",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              keyboardType: TextInputType.datetime,
              controller: dateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: const InputDecoration(
                  labelText: "Date"
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: "Amount (RM)",
              ),
            ),
          ),
          ElevatedButton(onPressed: () async{
            Expense exp = Expense(idController.text,double.parse(amountController.text), descController.text, widget.expense.dateTime);
            widget.onSave(exp);
            await exp.update();
            Navigator.pop(context);
          }, child: Text("Save"))
        ],
      ),
    );
  }
}



