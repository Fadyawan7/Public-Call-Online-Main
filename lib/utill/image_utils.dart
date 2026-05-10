import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  /// Compress [file] to be under [maxBytes]. Returns the compressed file or original if compression fails.
  static Future<File> compressFile(File file,
      {int maxBytes = 1000000, // 1 MB
      int minQuality = 20}) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return file;
      }

      final Directory tempDir = await getTemporaryDirectory();
      String targetPath =
          p.join(tempDir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

      int quality = 90;
      File? result;

      while (quality >= minQuality) {
        final encoded = img.encodeJpg(image, quality: quality);
        result = File(targetPath)..writeAsBytesSync(encoded);

        final int fileSize = await result.length();
        if (fileSize <= maxBytes) {
          return result;
        }

        // try lower quality
        quality -= 10;
      }

      // If we couldn't get under maxBytes, return the best-effort result or original
      return result ?? file;
    } catch (e) {
      return file;
    }
  }
}
