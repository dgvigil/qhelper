import 'package:share_plus/share_plus.dart';

/// Boundary for the platform share sheet so screens can be tested without it.
abstract interface class ShareService {
  Future<void> shareText(String text, {String? subject});
}

class SharePlusShareService implements ShareService {
  const SharePlusShareService();

  @override
  Future<void> shareText(String text, {String? subject}) async {
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  }
}
