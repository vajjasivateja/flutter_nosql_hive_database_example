import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  List<Map<String, dynamic>> items = [];

  final shoppingBox = Hive.box("shopping_box");

  //read all items list
  void getAllItems() {
    final data = shoppingBox.keys.map((key) {
      final item = shoppingBox.get(key);
      return {"key": key, "name": item["name"], "quantity": item["quantity"]};
    }).toList();
    setState(() {
      items = data.reversed.toList();
    });
  }

  //create a new item
  Future<void> createItem(Map<String, dynamic> newItem) async {
    await shoppingBox.add(newItem);
    print("Amount of data is ${shoppingBox.length}");
    getAllItems();
  }

  //update item
  Future<void> updateItem(int itemKey, Map<String, dynamic> item) async {
    await shoppingBox.put(itemKey, item);
    getAllItems();
  }

  //delete item
  Future<void> deleteItem(int itemKey) async {
    await shoppingBox.delete(itemKey);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sucessfully deleted the item from database")));
    getAllItems();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hive Database Example")),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.yellow.shade100,
            child: ListTile(
              title: Text(items[index]["name"]),
              subtitle: Text("Quantity: ${items[index]["quantity"]}"),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          showForm(context, items[index]["key"]);
                        },
                        icon: Icon(Icons.edit)),
                    IconButton(
                        onPressed: () {
                          deleteItem(items[index]["key"]);
                        },
                        icon: Icon(Icons.delete)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showForm(context, null);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void showForm(BuildContext context, int? itemKey) async {
    if (itemKey != null) {
      final existingItem = items.firstWhere((element) => element["key"] == itemKey);
      nameController.text = existingItem["name"];
      quantityController.text = existingItem["quantity"];
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 5,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(top: 15, right: 15, left: 15, bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: nameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(hintText: "Name"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: "Quantity"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () async {
                    if (itemKey != null) {
                      updateItem(itemKey, {
                        "name": nameController.text.toString(),
                        "quantity": quantityController.text.toString(),
                      });
                    } else {
                      createItem({
                        "name": nameController.text.toString(),
                        "quantity": quantityController.text.toString(),
                      });
                    }
                    nameController.text = "";
                    quantityController.text = "";
                    Navigator.of(context).pop();
                  },
                  child: Text(itemKey == null ? "Create New" : "Update"))
            ],
          ),
        );
      },
    );
  }
}
