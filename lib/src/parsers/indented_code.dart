part of md_proc.src.parsers;

/// Parser for indented code blocks.
class IndentedCodeParser extends AbstractParser<Iterable<Block>> {
  static final RegExp _codeLineRegExp = new RegExp('^(?: {0,3}\t|    )(.*)\$');

  /// Constructor.
  IndentedCodeParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Iterable<Block>> parse(String text, int offset) {
    // Simple test, that we have indent
    int codeUnit = text.codeUnitAt(offset);
    if (codeUnit != _spaceCodeUnit && codeUnit != _tabCodeUnit) {
      return const ParseResult<Iterable<Block>>.failure();
    }

    // Main code

    StringBuffer result = new StringBuffer();
    StringBuffer rest = new StringBuffer();
    bool firstLine = true;
    int length = text.length;
    while (offset < length) {
      ParseResult<String> lineResult = container.lineParser.parse(text, offset);
      assert(lineResult.isSuccess);

      String line = lineResult.value;
      Match emptyLine = _emptyLineRegExp.firstMatch(line);
      if (emptyLine != null) {
        if (firstLine) {
          break;
        }

        Match codeLine = _codeLineRegExp.firstMatch(line);
        if (codeLine != null) {
          rest.writeln(codeLine[1]);
        } else {
          rest.writeln();
        }
      } else {
        Match codeLine = _codeLineRegExp.firstMatch(line);
        if (codeLine == null) {
          break;
        }
        if (rest.length > 0) {
          result.write(rest);
          rest = new StringBuffer();
        }
        result.writeln(codeLine[1]);
      }

      firstLine = false;
      offset = lineResult.offset;
    }

    if (result.length == 0) {
      return const ParseResult<Iterable<Block>>.failure();
    }

    return new ParseResult<Iterable<Block>>.success(
        <IndentedCodeBlock>[new IndentedCodeBlock(result.toString())], offset);
  }
}
