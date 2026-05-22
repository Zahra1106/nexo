import 'package:get/get.dart';
import 'package:nexo/screens/home.dart';
import '../../core/services/api_service.dart';
import '../../core/storage/local_storage.dart';

class LoginController extends GetxController {
  final isLoading = false.obs;
  final errorMsg = ''.obs;

  Future<void> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      errorMsg.value = 'Username aur password dono daalo';
      return;
    }

    isLoading.value = true;
    errorMsg.value = '';

    final data = await ApiService.login(username, password);

    if (data != null && data['user_info'] != null) {
      final userInfo = data['user_info'];

      if (userInfo['status'] == 'Active') {
        await LocalStorage.saveLogin(username, password);
        Get.offAll(() => const HomeScreen()); // ✅ Fixed
      } else {
        errorMsg.value = 'Account expired ya inactive hai';
      }
    } else {
      errorMsg.value = 'Wrong username ya password';
    }

    isLoading.value = false;
  }
}