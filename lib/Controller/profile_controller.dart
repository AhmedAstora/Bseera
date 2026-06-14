import 'package:get/get.dart';

class ProfileController extends GetxController {
  var name = 'اسم المستخدم'.obs;
  var profileImagePath = ''.obs;


  void updateImage(String path) {
    profileImagePath.value = path;
    profileImagePath.refresh(); // هذا السطر يضمن إجبار GetX على تحديث كل الـ Obx المرتبطة فوراً
  }
  void updateName(String newName) => name.value = newName;

}