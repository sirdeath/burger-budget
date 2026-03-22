import '../entities/user_preference.dart';

abstract class UserPreferenceRepository {
  Future<UserPreference> getUserPreference();
}
