abstract class ApiEndPoints {
  static String baseURL = "http://127.0.0.1:8000";
  static String generateTextUrl = "/generate/text";
  static String getProjects = "/projects/";
  static String createProject = "/projects/create";
  static String getProjectConversations = "/project/conversations/";
  static String deleteProjectConversation = "/project/conversations/";
  static String profile = "/profile/";
  static String logout = "/profile/logout";
  static String changePassword = "/profile/change-password";
  static String register = "/auth/register";
  static String login = "/auth/login";
  static String refresh = "/auth/refresh";
}
