import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/scraping/models/parsed_metadata.dart';
import 'package:marky/core/scraping/parsers/source_parser.dart';
import 'package:marky/core/scraping/source_parser_registry.dart';

class _FakeParser implements SourceParser {
  _FakeParser(this._hosts);

  final Set<String> _hosts;

  @override
  Set<String> get hosts => _hosts;

  @override
  Future<ParsedMetadata?> parse(String url) async => null;
}

void main() {
  setUp(SourceParserRegistry.instance.clear);

  tearDown(SourceParserRegistry.instance.clear);

  group('SourceParserRegistry', () {
    test('resolve returns null for empty URL', () {
      expect(SourceParserRegistry.instance.resolve(''), isNull);
    });

    test('resolve returns null for malformed URL', () {
      expect(SourceParserRegistry.instance.resolve('not a url'), isNull);
    });

    test('resolve returns null when no parsers registered', () {
      expect(
        SourceParserRegistry.instance.resolve('https://example.com'),
        isNull,
      );
    });

    test('resolve matches exact host', () {
      final parser = _FakeParser({'example.com'});
      SourceParserRegistry.instance.register(parser);

      expect(
        SourceParserRegistry.instance.resolve('https://example.com/path'),
        same(parser),
      );
    });

    test('resolve is case-insensitive', () {
      final parser = _FakeParser({'Example.COM'});
      SourceParserRegistry.instance.register(parser);

      expect(
        SourceParserRegistry.instance.resolve('https://example.com'),
        same(parser),
      );
      expect(
        SourceParserRegistry.instance.resolve('https://EXAMPLE.COM'),
        same(parser),
      );
    });

    test('resolve normalizes www prefix', () {
      final parser = _FakeParser({'youtube.com'});
      SourceParserRegistry.instance.register(parser);

      expect(
        SourceParserRegistry.instance.resolve('https://www.youtube.com/watch'),
        same(parser),
      );
      expect(
        SourceParserRegistry.instance.resolve('https://youtube.com/watch'),
        same(parser),
      );
    });

    test('resolve strips www from parser host too', () {
      final parser = _FakeParser({'www.github.com'});
      SourceParserRegistry.instance.register(parser);

      expect(
        SourceParserRegistry.instance.resolve('https://github.com/repo'),
        same(parser),
      );
    });

    test('resolve returns null for unknown host', () {
      final parser = _FakeParser({'youtube.com'});
      SourceParserRegistry.instance.register(parser);

      expect(
        SourceParserRegistry.instance.resolve('https://twitter.com'),
        isNull,
      );
    });

    test('resolve returns first matching parser', () {
      final parserA = _FakeParser({'example.com'});
      final parserB = _FakeParser({'example.com'});
      SourceParserRegistry.instance.register(parserA);
      SourceParserRegistry.instance.register(parserB);

      expect(
        SourceParserRegistry.instance.resolve('https://example.com'),
        same(parserA),
      );
    });

    test('resolve matches multiple YouTube host variants', () {
      final parser = _FakeParser({'youtube.com', 'www.youtube.com', 'youtu.be'});
      SourceParserRegistry.instance.register(parser);

      expect(
        SourceParserRegistry.instance.resolve('https://youtube.com/watch?v=abc'),
        same(parser),
      );
      expect(
        SourceParserRegistry.instance.resolve('https://www.youtube.com/watch?v=abc'),
        same(parser),
      );
      expect(
        SourceParserRegistry.instance.resolve('https://youtu.be/abc123'),
        same(parser),
      );
    });

    test('clear removes all parsers', () {
      SourceParserRegistry.instance.register(_FakeParser({'example.com'}));
      expect(SourceParserRegistry.instance.isEmpty, isFalse);

      SourceParserRegistry.instance.clear();
      expect(SourceParserRegistry.instance.isEmpty, isTrue);
      expect(SourceParserRegistry.instance.length, 0);
    });

    test('resolve handles URL without scheme', () {
      // Uri.tryParse may or may not extract a host from "example.com"
      // depending on how it's interpreted; we just ensure no exception.
      expect(
        SourceParserRegistry.instance.resolve('example.com'),
        isNull,
      );
    });
  });
}
