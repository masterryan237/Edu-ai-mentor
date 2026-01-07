import 'package:flutter/material.dart';

Widget buildStatCard(
  String label,
  Future<int> future,
  IconData icon,
  Color color,
) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          FutureBuilder<int>(
            future: future,
            builder: (context, snapshot) {
              return Text(
                snapshot.hasData ? "${snapshot.data}" : "...",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              );
            },
          ),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    ),
  );
}
