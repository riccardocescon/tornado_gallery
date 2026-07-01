import 'package:flutter_test/flutter_test.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/file_name_utils.dart';

void main() {
  group('FileNameUtils.basename', () {
    test('strips forward-slash directories', () {
      expect(FileNameUtils.basename('/a/b/c.png'), 'c.png');
    });

    test('strips back-slash directories', () {
      expect(FileNameUtils.basename(r'a\b\c.png'), 'c.png');
    });

    test('handles mixed separators', () {
      expect(FileNameUtils.basename(r'a/b\c.png'), 'c.png');
    });

    test('returns input when there is no separator', () {
      expect(FileNameUtils.basename('c.png'), 'c.png');
    });
  });

  group('FileNameUtils.extensionOf', () {
    test('lower-cases the extension', () {
      expect(FileNameUtils.extensionOf('IMG.PNG'), 'png');
    });

    test('takes the text after the last dot', () {
      expect(FileNameUtils.extensionOf('archive.tar.gz'), 'gz');
    });

    test('returns whole string when there is no dot', () {
      expect(FileNameUtils.extensionOf('noext'), 'noext');
    });
  });

  group('Constants.imageExtensions', () {
    test('contains the supported image extensions', () {
      expect(Constants.imageExtensions, {'png', 'jpg', 'jpeg'});
    });
  });
}
