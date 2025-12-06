import 'package:flutter/cupertino.dart';


class MyPointsEmptyState extends StatelessWidget {
  const MyPointsEmptyState({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "У вас пока нет обменных пунктов",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          CupertinoButton.filled(
            onPressed: onAdd,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: const Text("Добавить"),
          ),
        ],
      ),
    );
  }
}
