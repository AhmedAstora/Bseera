import 'package:get/get.dart';

class ProfileController extends GetxController {
  var name = 'أحمد محمد'.obs;
  var email = 'ahmed@example.com'.obs;
  var profileImagePath = ''.obs;

  void updateName(String newName) => name.value = newName;
  void updateEmail(String newEmail) => email.value = newEmail;
  void updateImage(String path) => profileImagePath.value = path;
}