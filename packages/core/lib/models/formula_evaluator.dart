import 'dart:math';

/// Error thrown when a formula cannot be parsed or evaluated.
class FormulaError implements Exception {
  final String message;
  const FormulaError(this.message);
  @override
  String toString() => 'FormulaError: $message';
}

/// Abstract base class for AST nodes in a parsed formula.
sealed class AstNode {
  num evaluate(Map<String, dynamic> context);
}

/// Literal number node.
class NumberNode extends AstNode {
  final num value;
  NumberNode(this.value);
  @override
  num evaluate(Map<String, dynamic> context) => value;
}

/// Field reference node (e.g., STR, DEX).
class FieldRefNode extends AstNode {
  final String name;
  FieldRefNode(this.name);
  @override
  num evaluate(Map<String, dynamic> context) {
    if (!context.containsKey(name)) {
      throw FormulaError('Unknown field reference: $name');
    }
    final val = context[name];
    if (val is num) return val;
    if (val is int) return val;
    if (val is double) return val;
    throw FormulaError('Field $name is not a number');
  }
}

/// Dice roll node (NdM+k).
class DiceNode extends AstNode {
  final int count;
  final int sides;
  final AstNode? modifier;
  DiceNode(this.count, this.sides, [this.modifier]);

  static final _rng = Random();

  @override
  num evaluate(Map<String, dynamic> context) {
    num sum = 0;
    for (int i = 0; i < count; i++) {
      sum += _rng.nextInt(sides) + 1;
    }
    if (modifier != null) {
      sum += modifier!.evaluate(context);
    }
    return sum;
  }
}

/// Binary operation node (+, -, *, /).
class BinaryOpNode extends AstNode {
  final String operator;
  final AstNode left;
  final AstNode right;
  BinaryOpNode(this.operator, this.left, this.right);
  @override
  num evaluate(Map<String, dynamic> context) {
    final l = left.evaluate(context);
    final r = right.evaluate(context);
    return switch (operator) {
      '+' => l + r,
      '-' => l - r,
      '*' => l * r,
      '/' => l / r,
      _ => throw FormulaError('Unknown operator: $operator'),
    };
  }
}

/// Function call node (floor, ceil).
class FunctionNode extends AstNode {
  final String name;
  final AstNode arg;
  FunctionNode(this.name, this.arg);
  @override
  num evaluate(Map<String, dynamic> context) {
    final val = arg.evaluate(context);
    return switch (name) {
      'floor' => val.floor(),
      'ceil' => val.ceil(),
      _ => throw FormulaError('Unknown function: $name'),
    };
  }
}

/// Internal recursive descent parser for formula strings.
class _FormulaParser {
  final String _input;
  int _pos = 0;

  _FormulaParser(this._input);

  AstNode parse() {
    final node = _expression();
    _skipWhitespace();
    if (_pos < _input.length) {
      throw FormulaError(
          'Unexpected character at position $_pos: ${_input[_pos]}');
    }
    return node;
  }

  AstNode _expression() {
    // term (('+' | '-') term)*
    var node = _term();
    while (true) {
      _skipWhitespace();
      if (_pos >= _input.length) break;
      final ch = _input[_pos];
      if (ch == '+' || ch == '-') {
        _pos++;
        final right = _term();
        node = BinaryOpNode(ch, node, right);
      } else {
        break;
      }
    }
    return node;
  }

  AstNode _term() {
    // factor (('*' | '/') factor)*
    var node = _factor();
    while (true) {
      _skipWhitespace();
      if (_pos >= _input.length) break;
      final ch = _input[_pos];
      if (ch == '*' || ch == '/') {
        _pos++;
        final right = _factor();
        node = BinaryOpNode(ch, node, right);
      } else {
        break;
      }
    }
    return node;
  }

  AstNode _factor() {
    _skipWhitespace();
    if (_pos >= _input.length) {
      throw FormulaError('Unexpected end of formula');
    }

    final ch = _input[_pos];

    // Parenthesized expression
    if (ch == '(') {
      _pos++;
      final node = _expression();
      _skipWhitespace();
      if (_pos >= _input.length || _input[_pos] != ')') {
        throw FormulaError('Expected closing parenthesis');
      }
      _pos++;
      return node;
    }

    // Function call: floor(...) or ceil(...)
    if (_isAlpha(ch)) {
      final name = _readIdentifier();
      _skipWhitespace();
      if (_pos < _input.length && _input[_pos] == '(') {
        // This is a function call
        _pos++; // skip '('
        final arg = _expression();
        _skipWhitespace();
        if (_pos >= _input.length || _input[_pos] != ')') {
          throw FormulaError('Expected closing parenthesis for function $name');
        }
        _pos++; // skip ')'
        return FunctionNode(name, arg);
      } else {
        // This is a field reference
        return FieldRefNode(name);
      }
    }

    // Number or dice notation
    if (_isDigit(ch) || ch == '.') {
      return _numberOrDice();
    }

    throw FormulaError('Unexpected character: $ch');
  }

  AstNode _numberOrDice() {
    // Read number
    final start = _pos;
    while (_pos < _input.length && (_isDigit(_input[_pos]) || _input[_pos] == '.')) {
      _pos++;
    }
    final numStr = _input.substring(start, _pos);
    final numValue = numStr.contains('.')
        ? double.parse(numStr)
        : int.parse(numStr);

    _skipWhitespace();

    // Check for dice notation: d followed by sides
    if (_pos < _input.length && _input[_pos] == 'd') {
      _pos++; // skip 'd'
      _skipWhitespace();
      final sidesStart = _pos;
      while (_pos < _input.length && _isDigit(_input[_pos])) {
        _pos++;
      }
      if (sidesStart == _pos) {
        throw FormulaError('Expected number of sides after d');
      }
      final sides = int.parse(_input.substring(sidesStart, _pos));
      final count = numValue.toInt();

      _skipWhitespace();

      // Check for modifier: + or -
      if (_pos < _input.length && (_input[_pos] == '+' || _input[_pos] == '-')) {
        final op = _input[_pos];
        _pos++;
        final modifier = _term();
        if (op == '-') {
          return DiceNode(count, sides, BinaryOpNode('-', NumberNode(0), modifier));
        }
        return DiceNode(count, sides, modifier);
      }

      return DiceNode(count, sides);
    }

    return NumberNode(numValue);
  }

  String _readIdentifier() {
    final start = _pos;
    while (_pos < _input.length && _isAlpha(_input[_pos])) {
      _pos++;
    }
    return _input.substring(start, _pos);
  }

  void _skipWhitespace() {
    while (_pos < _input.length && _input[_pos] == ' ') {
      _pos++;
    }
  }

  bool _isAlpha(String ch) =>
      (ch.codeUnitAt(0) >= 65 && ch.codeUnitAt(0) <= 90) ||
      (ch.codeUnitAt(0) >= 97 && ch.codeUnitAt(0) <= 122);

  bool _isDigit(String ch) =>
      ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
}

/// Pure-Dart formula parser and evaluator.
///
/// Supports arithmetic (+, -, *, /), parentheses, dice notation (NdM+k),
/// field references (STR, DEX), and functions (floor, ceil).
class FormulaEvaluator {
  /// Evaluate a formula string against a data context.
  ///
  /// Throws [FormulaError] on syntax errors, unknown field references,
  /// or evaluation failures.
  static num evaluate(String formula, Map<String, dynamic> context) {
    final parser = _FormulaParser(formula);
    final ast = parser.parse();
    return ast.evaluate(context);
  }

  /// Extract all field reference names from a formula.
  ///
  /// Useful for building dependency graphs for circular reference detection.
  static List<String> getDependencies(String formula) {
    final parser = _FormulaParser(formula);
    final ast = parser.parse();
    return _collectDependencies(ast);
  }

  static List<String> _collectDependencies(AstNode node) {
    final deps = <String>[];
    if (node is FieldRefNode) {
      deps.add(node.name);
    } else if (node is BinaryOpNode) {
      deps.addAll(_collectDependencies(node.left));
      deps.addAll(_collectDependencies(node.right));
    } else if (node is FunctionNode) {
      deps.addAll(_collectDependencies(node.arg));
    } else if (node is DiceNode) {
      if (node.modifier != null) {
        deps.addAll(_collectDependencies(node.modifier!));
      }
    }
    return deps;
  }

  /// Detect circular dependencies in a set of derivedFrom formulas.
  ///
  /// [formulas] is a map of field key -> formula string.
  /// Throws [FormulaError] if a cycle is detected.
  static void detectCircularDependencies(Map<String, String> formulas) {
    // Build dependency graph
    final graph = <String, List<String>>{};
    for (final entry in formulas.entries) {
      final deps = getDependencies(entry.value);
      graph[entry.key] = deps;
    }

    // DFS cycle detection
    const white = 0; // unvisited
    const gray = 1;  // in progress
    const black = 2; // completed
    final color = <String, int>{};

    String? cyclePath;

    void dfs(String node, List<String> path) {
      color[node] = gray;
      path.add(node);

      for (final dep in graph[node] ?? []) {
        if (!formulas.containsKey(dep)) continue; // external field, skip
        final depColor = color[dep] ?? white;
        if (depColor == gray) {
          // Found cycle
          final cycleStart = path.indexOf(dep);
          final cycle = path.sublist(cycleStart);
          cyclePath = '${cycle.join(' -> ')} -> $dep';
          return;
        }
        if (depColor == white) {
          dfs(dep, path);
          if (cyclePath != null) return;
        }
      }

      path.removeLast();
      color[node] = black;
    }

    for (final key in formulas.keys) {
      if ((color[key] ?? white) == white) {
        dfs(key, []);
        if (cyclePath != null) break;
      }
    }

    if (cyclePath != null) {
      throw FormulaError('Circular dependency detected: $cyclePath');
    }
  }
}
