import 'package:dio/dio.dart';
import 'package:supabase/supabase.dart';
import '../core/network/api_client.dart';
import '../models/models.dart';

/// Auth SDK oturumu saklar ve yeniler; profil ve rol yalnızca API'den okunur.
abstract class AuthService {
  bool get hasSession;
  String? get email;
  Stream<void> get changes;
  Future<void> signIn(String email, String password);
  Future<void> signUp(String name, String email, String password);
  Future<void> signOut();
  Future<Profil> loadProfile();
  Future<Profil> saveProfile(String name);
}

class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this.client, this.api);
  final SupabaseClient client;
  final ApiClient api;

  @override
  bool get hasSession => client.auth.currentSession != null;
  @override
  String? get email => client.auth.currentUser?.email;
  @override
  Stream<void> get changes => client.auth.onAuthStateChange.map((_) {});
  @override
  Future<void> signIn(String email, String password) async {
    await client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUp(String name, String email, String password) async {
    await client.auth
        .signUp(email: email, password: password, data: {'ad_soyad': name});
  }

  @override
  Future<void> signOut() => client.auth.signOut(scope: SignOutScope.local);
  @override
  Future<Profil> loadProfile() async {
    try {
      final response = await api.dio.get<Map<String, dynamic>>('/api/profil');
      return Profil.fromJson(response.data!);
    } on DioException catch (e) {
      // E-posta onayından sonraki ilk girişte profil henüz oluşmamış olabilir.
      final metadata = client.auth.currentUser?.userMetadata;
      final name = metadata?['ad_soyad'] ?? metadata?['adSoyad'];
      if (e.response?.statusCode == 404 &&
          name is String &&
          name.trim().length >= 2 &&
          name.trim().length <= 100) {
        return saveProfile(name.trim());
      }
      rethrow;
    }
  }

  @override
  Future<Profil> saveProfile(String name) async {
    final response = await api.dio
        .put<Map<String, dynamic>>('/api/profil', data: {'adSoyad': name});
    return Profil.fromJson(response.data!);
  }
}
