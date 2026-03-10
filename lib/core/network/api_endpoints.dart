import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  ApiEndpoints._();
  // static const baseUrl = 'https://developerruhban.com/services/webmail/api';
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  // Auth
  static const login           = '/auth/login.php';
  static const register        = '/auth/register.php';
  static const forgotPassword  = '/auth/forgot_password.php';
  static const logout          = '/auth/logout.php';

  // Dashboard
  static const dashboardStats = '/dashboard/stats.php';


  // Email
  static const sendEmail       = '/email/send.php';
  static const history         = '/email/history.php';
  static const viewEmail       = '/email/view.php';
  static const deleteEmail     = '/email/delete.php';

  // Templates
  static const templates        = '/templates/list.php';
  static const createTemplate   = '/templates/create.php';
  static const updateTemplate   = '/templates/update.php';
  static const deleteTemplate   = '/templates/delete.php';

  // Profile
  static const profile          = '/user/profile.php';
  static const updateProfile    = '/user/update.php';
  static const changePassword   = '/user/password.php';
}
