import 'package:flutter/material.dart';

class PeoplePage extends StatefulWidget {
  @override
  _PeoplePageState createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  int numberOfPeople = 1;
  List<TextEditingController> controllers = [TextEditingController()];

  void updatePeople(int value) {
    setState(() {
      numberOfPeople = value;

      controllers = List.generate(
        numberOfPeople,
        (index) => TextEditingController(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lista de Pessoas")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Número de pessoas: $numberOfPeople"),
                DropdownButton<int>(
                  value: numberOfPeople,
                  items: List.generate(
                    10,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text("${index + 1}"),
                    ),
                  ),
                  onChanged: (value) => updatePeople(value!),
                ),
              ],
            ),

            SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: numberOfPeople,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextField(
                      controller: controllers[index],
                      decoration: InputDecoration(
                        labelText: "Nome da pessoa ${index + 1}",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                },
              ),
            ),

            ElevatedButton(
              onPressed: () {
                for (var c in controllers) {
                  print(c.text);
                }
              },
              child: Text("Guardar nomes"),
            )
          ],
        ),
      ),
    );
  }
}