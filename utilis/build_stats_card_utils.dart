import 'package:flutter/material.dart';

Widget buildStatCard(
  String label,
  Future<int> future,
  IconData icon,
  Color color,
) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      constraints: BoxConstraints(minHeight: 140, maxHeight: 160),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icône avec fond décoratif
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(icon, color: color, size: 26),
          ),

          const SizedBox(height: 12),

          // Valeur avec FutureBuilder
          FutureBuilder<int>(
            future: future,
            builder: (context, snapshot) {
              return Text(
                snapshot.hasData ? "${snapshot.data}" : "...",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),

          const SizedBox(height: 6),

          // Label
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Indicateur de chargement optionnel
        ],
      ),
    ),
  );
}
