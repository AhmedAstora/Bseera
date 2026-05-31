import 'package:get/get.dart';

class ProfileController extends GetxController {
  var name = 'احمد ابو عمرة'.obs;
  var email = 'ghost.basha2800@gmail.com'.obs;
  var profileImagePath = ''.obs;


  void updateImage(String path) {
    profileImagePath.value = path;
    profileImagePath.refresh(); // هذا السطر يضمن إجبار GetX على تحديث كل الـ Obx المرتبطة فوراً
  }
  void updateName(String newName) => name.value = newName;
  void updateEmail(String newEmail) => email.value = newEmail;

}