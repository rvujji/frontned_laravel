import '../../../core/api_client.dart';

class SessionReservationService {
  final ApiClient _apiClient = ApiClient();

  Future<void> reserveSession(int sessionId) async {
    await _apiClient.post('/v1/me/sessions/$sessionId/reserve');
  }

  Future<void> cancelReservation(int reservationId) async {
    await _apiClient.post('/v1/me/session-reservations/$reservationId/cancel');
  }
}
