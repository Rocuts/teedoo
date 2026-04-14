import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_result.dart';
import '../network/dio_client.dart';

/// Provider del servicio de explicaciones fiscales con IA.
final fiscalExplanationServiceProvider = Provider<FiscalExplanationService>((
  ref,
) {
  return FiscalExplanationService(dioClient: ref.read(dioClientProvider));
});

/// Servicio que solicita explicaciones fiscales validadas por OpenAI.
///
/// Flujo:
/// 1. Recibe los datos estructurados del motor de reglas (conclusión ya resuelta).
/// 2. Envía al endpoint /api/fiscal/explain que llama a OpenAI.
/// 3. OpenAI redacta la justificación profesional.
/// 4. El servidor post-valida que no haya alucinaciones legales.
/// 5. Retorna la explicación validada o null si falla.
class FiscalExplanationService {
  final DioClient _dioClient;

  /// En desarrollo, usa el dev_server local en port 3001.
  /// En producción, usa la API normal via DioClient.
  static const String _devBaseUrl = 'http://localhost:3001';

  const FiscalExplanationService({required DioClient dioClient})
    : _dioClient = dioClient;

  /// Solicita una explicación validada por OpenAI para una optimización fiscal.
  ///
  /// Retorna el texto de la explicación verificada, o null si:
  /// - La API no está disponible
  /// - OpenAI no pudo generar la explicación
  /// - La post-validación rechazó la respuesta (alucinación detectada)
  Future<String?> explain({
    required String ruleName,
    required String ruleExplanation,
    required String legalReference,
    required double estimatedSaving,
    required int fiscalYear,
    required String autonomousCommunity,
    String? confidenceLevel,
    String? riskLevel,
    String? actionRequired,
  }) async {
    final data = {
      'ruleName': ruleName,
      'ruleExplanation': ruleExplanation,
      'legalReference': legalReference,
      'estimatedSaving': estimatedSaving,
      'fiscalYear': fiscalYear,
      'autonomousCommunity': autonomousCommunity,
      'confidenceLevel': confidenceLevel ?? 'medium',
      'riskLevel': riskLevel ?? 'low',
      'actionRequired': actionRequired,
    };

    // En desarrollo, llamar directamente al dev_server local
    if (kDebugMode) {
      return _callDevServer(data);
    }

    // En producción, usar el DioClient normal
    final result = await _dioClient.safePost<Map<String, dynamic>>(
      '/api/fiscal/explain',
      data: data,
    );

    return result.when(
      success: (responseData) => _extractExplanation(responseData),
      failure: (_) => null,
    );
  }

  static Dio? _devDio;

  /// Llama al dev_server local para desarrollo.
  Future<String?> _callDevServer(Map<String, dynamic> data) async {
    try {
      final dio = _devDio ??= Dio(
        BaseOptions(
          baseUrl: _devBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final response = await dio.post<Map<String, dynamic>>(
        '/api/fiscal/explain',
        data: data,
      );

      final responseData = response.data;
      if (response.statusCode == 200 && responseData != null) {
        return _extractExplanation(responseData);
      }

      // 422 = validación rechazó la respuesta (alucinación)
      if (response.statusCode == 422 && responseData != null) {
        debugPrint(
          '[FiscalExplanation] Respuesta rechazada por validación: '
          '${responseData['error']?['details']}',
        );
        // Retornar el fallback del motor de reglas
        final fallback = responseData['fallbackExplanation'];
        return fallback is String ? fallback : null;
      }

      return null;
    } on DioException catch (e) {
      debugPrint('[FiscalExplanation] Error dev_server: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('[FiscalExplanation] Error inesperado: $e');
      return null;
    }
  }

  /// Extrae el texto de explicación de la respuesta del servidor.
  String? _extractExplanation(Map<String, dynamic> data) {
    final explanation = data['explanation'];
    if (explanation is String && explanation.isNotEmpty) {
      return explanation;
    }
    return null;
  }

  /// Solicita una explicación y retorna el Result completo.
  Future<Result<String>> explainWithResult({
    required String ruleName,
    required String ruleExplanation,
    required String legalReference,
    required double estimatedSaving,
    required int fiscalYear,
    required String autonomousCommunity,
  }) async {
    final result = await explain(
      ruleName: ruleName,
      ruleExplanation: ruleExplanation,
      legalReference: legalReference,
      estimatedSaving: estimatedSaving,
      fiscalYear: fiscalYear,
      autonomousCommunity: autonomousCommunity,
    );

    if (result != null) {
      return Success(result);
    }
    return const Failure(
      UnknownException(message: 'No se pudo generar la explicación.'),
    );
  }
}
