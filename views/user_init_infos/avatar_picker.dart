import 'package:eduai_mentor/utilis/app_texts_utils.dart';
import 'package:eduai_mentor/views/user_init_infos/goal_settings.dart';
import 'package:flutter/material.dart';
import 'avatar_store.dart'; // Importez la classe

class AvatarPickerScreen extends StatefulWidget {
  const AvatarPickerScreen({super.key});

  @override
  _AvatarPickerScreenState createState() => _AvatarPickerScreenState();
}

class _AvatarPickerScreenState extends State<AvatarPickerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                AppTexts.chooseMentor(context),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B61FF),
                ),
              ),
              SizedBox(height: 10),
              Text(AppTexts.mentorGuidance(context)),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: AvatarStore.allAvatars.length,
                  itemBuilder: (context, index) {
                    bool isSelected =
                        AvatarStore.selectedAvatarId ==
                        AvatarStore.allAvatars[index]['id'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          AvatarStore.setSelectedAvatar(
                            AvatarStore.allAvatars[index]['id']!,
                          );
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? Color(0xFF7B61FF)
                                : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AvatarStore.allAvatars[index]['img']!,
                              height: 80,
                              width: 80,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.face,
                                  size: 60,
                                  color: Color(0xFF7B61FF),
                                );
                              },
                            ),
                            Text(
                              AvatarStore.allAvatars[index]['name']!,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
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
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: AvatarStore.selectedAvatarId == null
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GoalSettingScreen(),
                        ),
                      ),
                child: Text(
                  AppTexts.continueBtn(context),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
