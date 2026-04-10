abstract class RouteConstants {
  static const String home = '/';
  static const String today = '/today';
  static const String calendar = '/calendar';
  static const String backlog = '/backlog';
  static const String taskCreate = '/tasks/create';
  static const String taskEdit = '/tasks/edit/:id';
  static const String settings = '/settings';
  static const String resolution = '/resolution';
  static const String onboarding = '/onboarding';

  /// Build a concrete edit path for a known task id.
  static String taskEditPath(String id) => '/tasks/edit/$id';
}
