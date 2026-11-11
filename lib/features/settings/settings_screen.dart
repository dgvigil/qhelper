import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_helper/app/app_info.dart';
import 'package:q_helper/app/providers.dart';
import 'package:q_helper/domain/models/app_settings.dart';

const _quickMinutes = [30, 45, 60];

/// Preferences and About. Everything is stored on the device.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _custom = TextEditingController();
  bool _customMode = false;
  bool _customInvalid = false;
  bool _seeded = false;

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  void _seed(AppSettings s) {
    if (_seeded) return;
    _seeded = true;
    _customMode = !_quickMinutes.contains(s.defaultMinutes);
    _custom.text = '${s.defaultMinutes}';
  }

  Future<void> _save(AppSettings s) =>
      ref.read(settingsProvider.notifier).save(s);

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Could not load settings.')),
        data: (s) {
          _seed(s);
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _section(context, 'Default workout length'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final m in _quickMinutes)
                        ChoiceChip(
                          label: Text('$m min'),
                          selected: !_customMode && s.defaultMinutes == m,
                          onSelected: (_) {
                            setState(() {
                              _customMode = false;
                              _customInvalid = false;
                            });
                            _save(s.copyWith(defaultMinutes: m));
                          },
                        ),
                      ChoiceChip(
                        label: const Text('Custom'),
                        selected: _customMode,
                        onSelected: (_) => setState(() => _customMode = true),
                      ),
                    ],
                  ),
                ),
                if (_customMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: TextField(
                      key: const Key('default-minutes-field'),
                      controller: _custom,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (text) {
                        final minutes = int.tryParse(text.trim());
                        final valid = minutes != null && minutes > 0;
                        setState(() => _customInvalid = !valid);
                        if (valid) _save(s.copyWith(defaultMinutes: minutes));
                      },
                      decoration: InputDecoration(
                        labelText: 'Minutes',
                        errorText: _customInvalid
                            ? 'Enter minutes greater than zero'
                            : null,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                _section(context, 'Cues and device'),
                SwitchListTile(
                  title: const Text('Sound cues'),
                  value: s.soundEnabled,
                  onChanged: (v) => _save(s.copyWith(soundEnabled: v)),
                ),
                SwitchListTile(
                  title: const Text('Haptic cues'),
                  value: s.hapticsEnabled,
                  onChanged: (v) => _save(s.copyWith(hapticsEnabled: v)),
                ),
                SwitchListTile(
                  title: const Text('Keep screen awake during workouts'),
                  value: s.keepScreenAwake,
                  onChanged: (v) => _save(s.copyWith(keepScreenAwake: v)),
                ),
                SwitchListTile(
                  title: const Text('End-of-workout notification'),
                  subtitle: const Text(
                    'Asks for permission when you start a workout.',
                  ),
                  value: s.endNotificationEnabled,
                  onChanged: (v) =>
                      _save(s.copyWith(endNotificationEnabled: v)),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text(
                    'Sounds, vibration, and notifications follow your phone\'s '
                    'silent and Focus settings. They are not guaranteed to '
                    'arrive at the exact second.',
                  ),
                ),
                _section(context, 'About'),
                const ListTile(
                  title: Text('Q Helper'),
                  subtitle: Text('Version $appVersion'),
                ),
                const ListTile(title: Text(publisherCredit)),
                const ListTile(
                  title: Text('Independent community project'),
                  subtitle: Text(independenceNotice),
                ),
                const ListTile(
                  title: Text('License'),
                  subtitle: Text(licenseNotice),
                ),
                _linkTile(context, 'Privacy policy', privacyPolicyUrl),
                _linkTile(context, 'Support', supportUrl),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _section(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(color: Theme.of(context).colorScheme.primary),
    ),
  );

  Widget _linkTile(BuildContext context, String title, String url) {
    return ListTile(
      title: Text(title),
      subtitle: Text(url),
      trailing: IconButton(
        tooltip: 'Copy $title link',
        icon: const Icon(Icons.copy),
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: url));
          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Link copied')));
          }
        },
      ),
    );
  }
}
