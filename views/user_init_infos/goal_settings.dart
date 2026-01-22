import 'package:eduai_mentor/views/user_init_infos/level_placements.dart';
import 'package:eduai_mentor/utilis/app_texts_utils.dart';
import 'package:flutter/material.dart';

class GoalSettingScreen extends StatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  _GoalSettingScreenState createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
  String? selectedGoal;

  List<Map<String, dynamic>> get strategicGoals => [
    {
      'id': 'exam',
      'title': AppTexts.goalExamTitle,
      'desc': AppTexts.goalExamDesc,
      'icon': '🎯',
    },
    {
      'id': 'mastery',
      'title': AppTexts.goalMasteryTitle,
      'desc': AppTexts.goalMasteryDesc,
      'icon': '🧠',
    },
    {
      'id': 'productivity',
      'title': AppTexts.goalProductivityTitle,
      'desc': AppTexts.goalProductivityDesc,
      'icon': '⚡',
    },
    {
      'id': 'career',
      'title': AppTexts.goalCareerTitle,
      'desc': AppTexts.goalCareerDesc,
      'icon': '💼',
    },
    {
      'id': 'other',
      'title': AppTexts.goalOtherTitle,
      'desc': AppTexts.goalOtherDesc,
      'icon': '✨',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppTexts.yourAmbition(context),
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTexts.primaryFocus(context),
              style: TextStyle(
                fontSize: 26,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              AppTexts.goalAdaptation(context),
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: strategicGoals.length,
                itemBuilder: (context, index) {
                  final goal = strategicGoals[index];
                  bool isSelected = selectedGoal == goal['id'];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => selectedGoal = goal['id'] as String),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 15),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(0xFF7B61FF).withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected
                              ? Color(0xFF7B61FF)
                              : Colors.grey[200]!,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            goal['icon'] as String,
                            style: TextStyle(fontSize: 30),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (goal['title'] as Function(BuildContext))(
                                    context,
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  (goal['desc'] as Function(BuildContext))(
                                    context,
                                  ),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle, color: Color(0xFF7B61FF)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7B61FF),
                minimumSize: Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: selectedGoal == null
                  ? null
                  : () {
                      // Direction le test de niveau
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LevelPlacementScreen(),
                        ),
                      );
                    },
              child: Text(
                AppTexts.validateMyGoal(context),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
