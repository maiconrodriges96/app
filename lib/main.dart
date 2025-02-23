import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Habit {
  String name;
  bool isHealthy;
  List<bool> daysCompleted; // True or False for each day of the week

  Habit({
    required this.name,
    required this.isHealthy,
    required this.daysCompleted,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HabitManager(),
    );
  }
}

class HabitManager extends StatefulWidget {
  @override
  _HabitManagerState createState() => _HabitManagerState();
}

class _HabitManagerState extends State<HabitManager> {
  List<Habit> habits = [];
  final TextEditingController habitController = TextEditingController();

  // Function to calculate daily points
  int calculatePoints(Habit habit) {
    int points = 0;
    for (int i = 0; i < 7; i++) {
      if (habit.daysCompleted[i]) {
        points += habit.isHealthy ? 1 : -2; // +1 for healthy, -2 for negative habits
      }
    }
    return points;
  }

  // Function to calculate total points for the week
  int getTotalPoints() {
    int totalPoints = 0;
    for (var habit in habits) {
      totalPoints += calculatePoints(habit);
    }
    return totalPoints;
  }

  // Add new habit
  void addHabit(String habitName, bool isHealthy) {
    setState(() {
      habits.add(Habit(
        name: habitName,
        isHealthy: isHealthy,
        daysCompleted: List.filled(7, false),
      ));
    });
    habitController.clear();
  }

  // Remove habit
  void removeHabit(int index) {
    setState(() {
      habits.removeAt(index);
    });
  }

  // Show modal to confirm habit removal
  void showRemoveDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar remoção'),
          content: Text('Você tem certeza que deseja remover este hábito?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                removeHabit(index);
                Navigator.of(context).pop();
              },
              child: Text('Remover'),
            ),
          ],
        );
      },
    );
  }

  // Show modal to add new habit
  void showAddHabitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Novo Hábito'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: habitController,
                decoration: InputDecoration(labelText: 'Nome do Hábito'),
              ),
              DropdownButton<bool>(
                value: true,
                items: [
                  DropdownMenuItem(child: Text("Saudável"), value: true),
                  DropdownMenuItem(child: Text("Negativo"), value: false),
                ],
                onChanged: (value) {
                  // No-op, just for UI; Logic will go below
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                String habitName = habitController.text.trim();
                if (habitName.isNotEmpty) {
                  bool isHealthy = true; // Default healthy (will need modification for custom choice)
                  addHabit(habitName, isHealthy);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gerenciador de Hábitos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: showAddHabitDialog,
              child: Text('Adicionar Hábito'),
              style: ElevatedButton.styleFrom(primary: Colors.black),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(habit.name),
                      trailing: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => showRemoveDialog(index),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (int i = 0; i < 7; i++)
                            Checkbox(
                              value: habit.daysCompleted[i],
                              onChanged: (bool? value) {
                                setState(() {
                                  habit.daysCompleted[i] = value!;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Text(
              'Saldo Total da Semana: ${getTotalPoints()} pontos',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
