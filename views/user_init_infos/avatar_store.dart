class AvatarStore {
  static String? _selectedAvatarId;
  static const List<Map<String, String>> _avatars = [
    {'id': 'owl', 'name': 'Professor Owl', 'img': 'assets/images/owl.png'},
    {'id': 'robot', 'name': 'EduBot', 'img': 'assets/images/robot.png'},
    {'id': 'fox', 'name': 'Smart Fox', 'img': 'assets/images/fox.png'},
  ];

  // Getters
  static String? get selectedAvatarId => _selectedAvatarId;

  static String? get selectedAvatarImg {
    if (_selectedAvatarId == null) return null;
    try {
      return _avatars.firstWhere(
        (avatar) => avatar['id'] == _selectedAvatarId,
      )['img'];
    } catch (e) {
      return null;
    }
  }

  static String? get selectedAvatarName {
    if (_selectedAvatarId == null) return null;
    try {
      return _avatars.firstWhere(
        (avatar) => avatar['id'] == _selectedAvatarId,
      )['name'];
    } catch (e) {
      return null;
    }
  }

  static Map<String, String>? get selectedAvatar {
    if (_selectedAvatarId == null) return null;
    try {
      return _avatars.firstWhere((avatar) => avatar['id'] == _selectedAvatarId);
    } catch (e) {
      return null;
    }
  }

  // Setter
  static void setSelectedAvatar(String id) {
    _selectedAvatarId = id;
  }

  // Toutes les avatars
  static List<Map<String, String>> get allAvatars => _avatars;
}
