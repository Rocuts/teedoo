import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

class WebFileDownloader {
  /// Descarga un archivo de texto en el navegador.
  static void downloadString(String filename, String content) {
    final bytes = web.Blob(
      [content.toJS].toJS,
      web.BlobPropertyBag(type: 'text/plain;charset=utf-8'),
    );
    _triggerDownload(filename, bytes);
  }

  /// Descarga un archivo binario (como un .docx generado por docx_template) en el navegador.
  static void downloadBytes(
    String filename,
    Uint8List bytes, {
    String mimeType =
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  }) {
    final blob = web.Blob(
      [bytes.toJS].toJS,
      web.BlobPropertyBag(type: mimeType),
    );
    _triggerDownload(filename, blob);
  }

  static void _triggerDownload(String filename, web.Blob blob) {
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = filename
      ..style.display = 'none';

    web.document.body!.appendChild(anchor);
    anchor.click();

    // Cleanup
    anchor.remove();
    web.URL.revokeObjectURL(url);
  }
}
