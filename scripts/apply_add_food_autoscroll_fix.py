from pathlib import Path

path = Path('lib/main.dart')
text = path.read_text(encoding='utf-8')
marker = '// Re-align after the keyboard changes the viewport.'
if marker in text:
    print('Add-food autoscroll fix already applied')
    raise SystemExit(0)

needle = '      amountFocusNode.requestFocus();\n'
if text.count(needle) != 1:
    raise SystemExit(f'Expected exactly one quantity focus call, found {text.count(needle)}')

replacement = '''      amountFocusNode.requestFocus();
      // Re-align after the keyboard changes the viewport.
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      final focusedCtx = quantitySectionKey.currentContext;
      if (focusedCtx != null) {
        await Scrollable.ensureVisible(
          focusedCtx,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: 0.12,
        );
      }
'''
text = text.replace(needle, replacement)
path.write_text(text, encoding='utf-8')
print('Applied add-food quantity autoscroll fix')
