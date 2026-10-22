import '../constants/sample_copy.dart';

class AiResult {
  const AiResult({required this.reply, required this.done});

  final String reply;
  final List<String> done;
}

/// Local model boundary. Task 2 plugs llama.cpp in behind this.
/// Nothing in this file touches the network.
abstract class AiService {
  AiResult respond(String diaryText);

  /// Yields the reply as it grows. The fake yields the whole reply once
  /// unless [paced] is true, in which case it yields one character at a time.
  Stream<String> streamReply(String diaryText);
}

class FakeAiService implements AiService {
  FakeAiService({this.paced = false});

  /// Character cadence from the prototype: 55ms, 260ms after ，。、.
  final bool paced;

  static const tick = Duration(milliseconds: 55);
  static const pause = Duration(milliseconds: 260);
  static const settle = Duration(milliseconds: 700);

  @override
  AiResult respond(String diaryText) {
    final text = diaryText.trim();
    if (text == SampleCopy.entry) {
      return const AiResult(reply: SampleCopy.reply, done: SampleCopy.done);
    }
    final harsh =
        text.contains('什么都没做好') ||
        text.contains('很失败') ||
        text.contains('一事无成');
    final reply = harsh
        ? '这句话把今天说得很重。听起来，它对你有点太严了。你还是坐下来，把这一句写了下来。'
        : '你把今天写下了。句子里面，有你真正做过的事。';
    return AiResult(reply: reply, done: _grounded(text));
  }

  List<String> _grounded(String text) {
    final parts = text
        .split(RegExp(r'[。！？\n]+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty);
    final done = <String>[];
    for (final part in parts) {
      if (part.contains('没做') || part.contains('失败') || part.contains('一事无成')) {
        continue;
      }
      if (part.length <= 22) done.add(part);
      if (done.length == 4) break;
    }
    return done;
  }

  @override
  Stream<String> streamReply(String diaryText) async* {
    final reply = respond(diaryText).reply;
    if (!paced) {
      yield reply;
      return;
    }
    final buffer = StringBuffer();
    for (var i = 0; i < reply.length; i++) {
      buffer.write(reply[i]);
      yield buffer.toString();
      final mark = reply[i];
      await Future<void>.delayed('，。、'.contains(mark) ? pause : tick);
    }
  }
}
