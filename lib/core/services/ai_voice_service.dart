import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../mock/mock_data.dart';
import '../utils/web_file_downloader.dart';
import 'report_template_service.dart';

enum AiVoiceState { idle, connecting, listening, processing, speaking, error }

class AiVoiceService extends ChangeNotifier {
  AiVoiceState _state = AiVoiceState.idle;
  AiVoiceState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _lastTranscript;
  String? get lastTranscript => _lastTranscript;

  String? _activeWidgetId;
  String? get activeWidgetId => _activeWidgetId;

  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;
  MediaStream? _localStream;
  final RTCVideoRenderer _audioRenderer = RTCVideoRenderer();

  RTCVideoRenderer get audioRenderer => _audioRenderer;

  AiVoiceService() {
    _initRenderer();
  }

  Future<void> _initRenderer() async {
    await _audioRenderer.initialize();
  }

  void toggleListening() async {
    if (_state == AiVoiceState.idle || _state == AiVoiceState.error) {
      await _startSession();
    } else {
      _disconnect();
    }
  }

  // ── Session instructions for the AI ──

  static const _sessionInstructions = '''
Eres TeeDoo (pronunciado TIDU), un asistente de Business Intelligence (BI) experto integrado en una aplicación de facturación electrónica española.

Responde siempre de manera MUY concisa, amigable, profesional y directa en español.
No des largas explicaciones a menos que se te pida. Piensa como un ejecutivo financiero.
Si te preguntan datos específicos que no tienes, indica que estás conectado a la demo y ofrece ayuda general sobre facturación, compliance TicketBAI/Verifactu, e IVA.
''';

  static const _realtimeModel = 'gpt-realtime';

  /// URL del endpoint que devuelve el token efímero.
  /// En producción (Vercel) usa ruta relativa.
  /// En dev local (localhost) apunta al proxy en puerto 3001.
  static Uri get _clientSecretEndpoint {
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host == 'localhost' || host == '127.0.0.1') {
        return Uri.parse('http://localhost:3001/api/realtime/client-secrets');
      }
      return Uri.parse('/api/realtime/client-secrets');
    }
    return Uri.parse('${AppConstants.apiBaseUrl}/realtime/client-secrets');
  }

  // ── Step 1: Get ephemeral token from backend ──

  Future<String> _getEphemeralToken() async {
    final response = await http.post(
      _clientSecretEndpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'session': {
          'type': 'realtime',
          'model': _realtimeModel,
          'instructions': _sessionInstructions,
          'modalities': ['audio', 'text'],
          'audio': {
            'output': {'voice': 'coral'},
          },
          'turn_detection': {'type': 'server_vad'},
          'tools': [
            {
              'type': 'function',
              'name': 'get_dashboard_kpis',
              'description':
                  'Llama a esta función para obtener los KPIs principales del negocio: cantidad de facturas emitidas, ingresos totales del mes actual, facturas pendientes de cobro y facturas vencidas.',
              'parameters': {
                'type': 'object',
                'properties': <String, dynamic>{},
                'required': <String>[],
              },
            },
            {
              'type': 'function',
              'name': 'get_invoices_history',
              'description':
                  'Llama a esta función para obtener un resumen del histórico de facturas, incluyendo detalles sobre el mes (ej: Q1, Enero, Febrero, Marzo), su estado de pago, a quién se emitieron y su monto total.',
              'parameters': {
                'type': 'object',
                'properties': <String, dynamic>{},
                'required': <String>[],
              },
            },
            {
              'type': 'function',
              'name': 'highlight_ui_element',
              'description':
                  'Llama a esta función cuando estés hablando con el usuario sobre un dato específico para que la pantalla lo resalte estéticamente y el usuario pueda seguirte visualmente. ¡Haz esto siempre que hables sobre una métrica clave!',
              'parameters': {
                'type': 'object',
                'properties': {
                  'element_id': {
                    'type': 'string',
                    'enum': [
                      'revenue_kpi',
                      'emitted_kpi',
                      'pending_kpi',
                      'overdue_kpi',
                      'revenue_chart',
                      'invoice_status_panel',
                    ],
                    'description':
                        'El ID del elemento gráfico que deseas resaltar en la pantalla durante tu respuesta.',
                  },
                },
              },
              'required': ['element_id'],
            },
            {
              'type': 'function',
              'name': 'generate_report',
              'description':
                  'Llama a esta función para generar y descargar un documento Word (.docx) corporativo usando una plantilla predefinida. La plantilla tiene etiquetas clave. Debes analizar los datos e inyectar el valor exacto para cada variable como un String corto y directo. Si la variable es una lista, usa saltos de línea \\n.',
              'parameters': {
                'type': 'object',
                'properties': {
                  'filename': {
                    'type': 'string',
                    'description':
                        'El título o nombre del archivo. Debe terminar en .docx. Ejemplo: Reporte_Q1.docx',
                  },
                  'variables': {
                    'type': 'object',
                    'description':
                        'El mapa de variables Mappleables. Las llaves son: TITULO_REPORTE, FECHA_CORTE, RESUMEN_EJECUTIVO, INGRESOS_TOTALES, FACTURAS_DESTACADAS, CONCLUSION.',
                    'properties': {
                      'TITULO_REPORTE': {'type': 'string'},
                      'FECHA_CORTE': {'type': 'string'},
                      'RESUMEN_EJECUTIVO': {'type': 'string'},
                      'INGRESOS_TOTALES': {'type': 'string'},
                      'FACTURAS_DESTACADAS': {'type': 'string'},
                      'CONCLUSION': {'type': 'string'},
                      'GRAFICO_JSON': {
                        'type': 'string',
                        'description':
                            'Configuración JSON literal de QuickChart con los datos relevantes a graficar (ej. {"type":"pie","data":{"labels":["Pagadas","Pendientes"],"datasets":[{"data":[12000,3000]}]}}). NO uses comillas en exceso ni escapes raros, solo un string de JSON válido para QuickChart.',
                      },
                    },
                    'required': [
                      'TITULO_REPORTE',
                      'FECHA_CORTE',
                      'RESUMEN_EJECUTIVO',
                      'INGRESOS_TOTALES',
                      'FACTURAS_DESTACADAS',
                      'CONCLUSION',
                      'GRAFICO_JSON',
                    ],
                  },
                },
                'required': ['filename', 'variables'],
              },
            },
          ],
        },
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMsg;
      try {
        final body = jsonDecode(response.body);
        errorMsg = (body['error']?['message'] as String?) ?? response.body;
      } catch (_) {
        errorMsg = 'HTTP ${response.statusCode}';
      }
      throw Exception('Token efímero no disponible: $errorMsg');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token =
        (data['client_secret'] as Map<String, dynamic>?)?['value'] as String? ??
        data['value'] as String?;
    if (token == null) {
      throw Exception('Respuesta inesperada: no se encontró el token efímero');
    }
    return token;
  }

  // ── Step 2–4: WebRTC + SDP exchange ──

  Future<void> _startSession() async {
    try {
      _state = AiVoiceState.connecting;
      _errorMessage = null;
      _lastTranscript = null;
      notifyListeners();

      // Step 1: Get microphone first (triggers permission prompt immediately)
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': false,
      });

      // Step 2: Ephemeral token (runs while user already granted mic)
      final ephemeralToken = await _getEphemeralToken();

      // Step 3: Create PeerConnection
      _peerConnection = await createPeerConnection({
        'sdpSemantics': 'unified-plan',
      });

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.track.kind == 'audio' && event.streams.isNotEmpty) {
          _audioRenderer.srcObject = event.streams[0];
        }
      };

      _peerConnection!.onConnectionState = (RTCPeerConnectionState connState) {
        if (connState == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
            connState ==
                RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
          _state = AiVoiceState.error;
          _errorMessage = 'Conexión WebRTC perdida';
          notifyListeners();
        }
      };

      // Add mic tracks to peer connection
      for (final track in _localStream!.getTracks()) {
        _peerConnection!.addTrack(track, _localStream!);
      }

      // Step 4: Create Data Channel
      final dcInit = RTCDataChannelInit()..ordered = true;
      _dataChannel = await _peerConnection!.createDataChannel(
        'oai-events',
        dcInit,
      );

      _dataChannel!.onMessage = (RTCDataChannelMessage message) {
        if (message.isBinary) return;
        try {
          final data = jsonDecode(message.text) as Map<String, dynamic>;
          _handleServerEvent(data);
        } catch (e) {
          debugPrint('Error parsing server event: $e');
        }
      };

      _dataChannel!.onDataChannelState = (RTCDataChannelState dcState) {
        debugPrint('DataChannel state: $dcState');
      };

      // Step 5: Create SDP Offer
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      // Step 6: Send SDP to OpenAI Realtime calls endpoint
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/realtime/calls'),
        headers: {
          'Authorization': 'Bearer $ephemeralToken',
          'Content-Type': 'application/sdp',
        },
        body: offer.sdp!,
      );

      final responseBody = response.body;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Response body is the SDP answer
        final answer = RTCSessionDescription(responseBody, 'answer');
        await _peerConnection!.setRemoteDescription(answer);

        _state = AiVoiceState.listening;
        notifyListeners();
      } else {
        String errorMsg;
        try {
          final parsed = jsonDecode(responseBody) as Map<String, dynamic>;
          errorMsg = (parsed['error']?['message'] as String?) ?? responseBody;
        } catch (_) {
          errorMsg = 'HTTP ${response.statusCode}: $responseBody';
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Voice session error: $e');
      _cleanup(silent: true);
      _state = AiVoiceState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  // ── Handle server events from the data channel ──

  void _handleServerEvent(Map<String, dynamic> event) {
    final type = event['type'] as String?;
    if (type == null) return;

    switch (type) {
      case 'input_audio_buffer.speech_started':
        _state = AiVoiceState.listening;
        notifyListeners();

      case 'input_audio_buffer.speech_stopped':
        _state = AiVoiceState.processing;
        notifyListeners();

      case 'response.created':
      case 'response.audio.delta':
        _state = AiVoiceState.speaking;
        notifyListeners();

      case 'response.audio_transcript.done':
        final transcript = event['transcript'] as String?;
        if (transcript != null && transcript.isNotEmpty) {
          _lastTranscript = transcript;
          notifyListeners();
        }

      case 'response.done':
        // Stay in listening for continuous conversation
        _state = AiVoiceState.listening;
        notifyListeners();

      case 'response.function_call_arguments.done':
        _handleFunctionCall(event);

      case 'error':
        final msg =
            (event['error']?['message'] as String?) ?? 'Error del servidor';
        debugPrint('Server error event: $msg');
        _state = AiVoiceState.error;
        _errorMessage = msg;
        notifyListeners();
    }
  }

  // ── Execute requested functions and send results back ──

  void _handleFunctionCall(Map<String, dynamic> event) async {
    if (_dataChannel == null ||
        _dataChannel!.state != RTCDataChannelState.RTCDataChannelOpen) {
      return;
    }

    final callId = event['call_id'] as String?;
    final functionName = event['name'] as String?;

    if (callId == null || functionName == null) return;

    debugPrint('AI Function Call invoked: $functionName');

    String functionOutput = '';

    if (functionName == 'get_dashboard_kpis') {
      functionOutput = MockData.getKpisSummary();
    } else if (functionName == 'get_invoices_history') {
      functionOutput = MockData.getInvoicesSummary();
    } else if (functionName == 'highlight_ui_element') {
      try {
        final argsString = event['arguments'] as String? ?? '{}';
        debugPrint('Raw highlight args: $argsString');
        final Map<String, dynamic> args =
            jsonDecode(argsString) as Map<String, dynamic>;
        final elementId = args['element_id'] as String?;
        if (elementId != null) {
          _activeWidgetId = elementId;
          notifyListeners();
          functionOutput =
              'Success: Elemento $elementId resaltado exitosamente.';
          debugPrint('Visual Agent: Highlighting $elementId');
        } else {
          functionOutput = 'Error: faltan parámetros.';
        }
      } catch (e) {
        debugPrint('Exception in highlight_ui_element: $e');
        functionOutput = 'Error parsing arguments: $e';
      }
    } else if (functionName == 'generate_report') {
      try {
        String argsString = event['arguments'] as String? ?? '{}';
        debugPrint('Raw generate_report args: $argsString');

        // OpenAI sometimes hallucinates an extra '}' at the end of long generations. Safety check:
        Map<String, dynamic> args;
        try {
          args = jsonDecode(argsString) as Map<String, dynamic>;
        } catch (e) {
          debugPrint(
            'First JSON decode failed, attempting to sanitize extra trailing characters...',
          );
          argsString = argsString.trim();
          if (argsString.endsWith('}}')) {
            argsString = argsString.substring(0, argsString.length - 1);
          }
          args = jsonDecode(argsString) as Map<String, dynamic>;
        }

        final filename = args['filename'] as String? ?? 'reporte.docx';
        final variablesMap = args['variables'] as Map<String, dynamic>? ?? {};

        final bytes = await ReportTemplateService.generateReportFromTemplate(
          variablesMap,
        );

        if (bytes != null) {
          WebFileDownloader.downloadBytes(filename, bytes);
          functionOutput =
              'Success: Reporte DOCX corporativo descargado exitosamente.';
          debugPrint('Visual Agent: Downloading Word Report $filename');
        } else {
          functionOutput =
              'Error: No se pudo generar el documento Word. Revisa la plantilla assets/templates/informe_base.docx.';
        }
      } catch (e) {
        debugPrint('Exception in generate_report: $e');
        functionOutput = 'Error parsing arguments o descargando: $e';
      }
    } else {
      functionOutput = 'Error: Función no encontrada o no soportada.';
    }

    // Send the result back to the model
    final resultEvent = {
      'type': 'conversation.item.create',
      'item': {
        'type': 'function_call_output',
        'call_id': callId,
        'output': functionOutput,
      },
    };

    _dataChannel!.send(RTCDataChannelMessage(jsonEncode(resultEvent)));

    // Request the model to speak the response based on the new data
    final responseEvent = {
      'type': 'response.create',
      'response': {
        'modalities': ['text', 'audio'],
      },
    };

    _dataChannel!.send(RTCDataChannelMessage(jsonEncode(responseEvent)));
  }

  // ── Disconnect and return to idle ──

  void _disconnect() {
    _cleanup();
  }

  // ── Cleanup all WebRTC resources ──

  void _cleanup({bool silent = false}) {
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _localStream = null;

    _dataChannel?.close();
    _dataChannel = null;

    _peerConnection?.close();
    _peerConnection = null;

    _audioRenderer.srcObject = null;

    if (!silent) {
      _state = AiVoiceState.idle;
      _lastTranscript = null;
      _activeWidgetId = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _cleanup(silent: true);
    _audioRenderer.dispose();
    super.dispose();
  }
}
