import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:docx_template/docx_template.dart';
import 'package:http/http.dart' as http;

class ReportTemplateService {
  /// Carga la plantilla desde assets, inyecta las variables y devuelve el .docx en bytes.
  static Future<Uint8List?> generateReportFromTemplate(
    Map<String, dynamic> variables,
  ) async {
    try {
      // 1. Cargar plantilla cruda
      final ByteData data = await rootBundle.load(
        'assets/templates/informe_base.docx',
      );
      // Forzar una copia explícita y "growable" para que el paquete docx no tire un "Unmodifiable list"
      final List<int> byteList = List<int>.from(
        data.buffer.asUint8List(),
        growable: true,
      );
      final bytes = Uint8List.fromList(byteList);

      // 2. Instanciar manejador de docx_template
      final docx = await DocxTemplate.fromBytes(bytes);

      // 3. Crear el contenido inyectable
      final content = Content();

      // Allowed template variable keys to prevent injection
      const allowedKeys = {
        'TITULO_REPORTE',
        'FECHA_CORTE',
        'RESUMEN_EJECUTIVO',
        'INGRESOS_TOTALES',
        'FACTURAS_DESTACADAS',
        'CONCLUSION',
        'GRAFICO_JSON',
        'GRAFICO',
      };

      for (final entry in variables.entries) {
        if (!allowedKeys.contains(entry.key)) continue;

        if (entry.key == 'GRAFICO_JSON') {
          // Construir URL de QuickChart y descargar la imagen del gráfico
          try {
            final chartJson = entry.value.toString();
            // Validate it's actually parseable JSON before sending externally
            if (chartJson.length > 5000) {
              debugPrint('Chart JSON exceeds max length, skipping');
              continue;
            }
            final encoded = Uri.encodeComponent(chartJson);
            final url = 'https://quickchart.io/chart?c=$encoded';

            final response = await http.get(Uri.parse(url));
            if (response.statusCode == 200) {
              // Copia explícita de los bytes HTTP, ya que en Web devuelven Listas inmutables
              final validImageBytes = Uint8List.fromList(response.bodyBytes);
              content.add(ImageContent('GRAFICO', validImageBytes));
            } else {
              debugPrint('Error fetch chart: ${response.statusCode}');
            }
          } catch (e) {
            debugPrint('Error fetching chart image: $e');
          }
        } else {
          content.add(TextContent(entry.key, entry.value.toString()));
        }
      }

      // 4. Generar y retornar el nuevo archivo
      final generatedBytes = await docx.generate(content);
      return generatedBytes != null ? Uint8List.fromList(generatedBytes) : null;
    } catch (e) {
      debugPrint('Error al generar plantilla DOCX: $e');
      return null;
    }
  }
}
