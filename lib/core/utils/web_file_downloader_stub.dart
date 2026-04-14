import 'dart:typed_data';

/// Stub para plataformas no-web. Las descargas solo funcionan en el navegador.
class WebFileDownloader {
  static void downloadString(String filename, String content) {
    throw UnsupportedError('File download is only supported on web');
  }

  static void downloadBytes(
    String filename,
    Uint8List bytes, {
    String mimeType = 'application/octet-stream',
  }) {
    throw UnsupportedError('File download is only supported on web');
  }
}
