import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Calculator(title: 'Calculator'),
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key, required this.title});
  final String title;

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _expression = "";
  String _result = "";

  void _onPressed(String input) {
    setState(() {
      if (input == 'C') {
        _expression = "";
        _result = "";
      } else if (input == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (input == '=') {
        _result = _evaluateExpression(_expression);
      } else if (input == 'x²') {
        if (_expression.isNotEmpty && double.tryParse(_expression) != null) {
          double number = double.parse(_expression);
          _result = (number * number).toStringAsFixed(2);
        }
      } else {
        if (_isOperator(input) && _expression.isNotEmpty && _isOperator(_expression[_expression.length - 1])) {
          return;
        }
        _expression += input;
      }
    });
  }

  String _evaluateExpression(String expression) {
    try {
      expression = expression.replaceAll('×', '*').replaceAll('÷', '/');
      final result = _calculate(expression);
      return result.toStringAsFixed(2);
    } catch (e) {
      return "Invalid Expression";
    }
  }

  double _calculate(String expression) {
    List<String> tokens = _tokenize(expression);
    List<String> postfix = _infixToPostfix(tokens);
    return _evaluatePostfix(postfix);
  }

  List<String> _tokenize(String expression) {
    final regex = RegExp(r'\d+\.?\d*|[+\-*/]');
    return regex.allMatches(expression).map((m) => m.group(0)!).toList();
  }

  List<String> _infixToPostfix(List<String> tokens) {
    final precedence = {'+': 1, '-': 1, '*': 2, '/': 2};
    final output = <String>[];
    final operators = <String>[];
    
    for (String token in tokens) {
      if (double.tryParse(token) != null) {
        output.add(token);
      } else {
        while (operators.isNotEmpty && precedence[operators.last]! >= precedence[token]!) {
          output.add(operators.removeLast());
        }
        operators.add(token);
      }
    }
    while (operators.isNotEmpty) {
      output.add(operators.removeLast());
    }
    return output;
  }

  double _evaluatePostfix(List<String> postfix) {
    final stack = <double>[];
    for (String token in postfix) {
      if (double.tryParse(token) != null) {
        stack.add(double.parse(token));
      } else {
        double b = stack.removeLast();
        double a = stack.removeLast();
        stack.add(_applyOperator(a, b, token));
      }
    }
    return stack.isNotEmpty ? stack.last : 0;
  }

  double _applyOperator(double a, double b, String op) {
    switch (op) {
      case '+': return a + b;
      case '-': return a - b;
      case '*': return a * b;
      case '/': return b != 0 ? a / b : double.nan;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_expression, style: const TextStyle(fontSize: 24, color: Colors.black54)),
                  const SizedBox(height: 10),
                  Text(_result, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[200],
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: _buttons.length,
                itemBuilder: (BuildContext context, int index) {
                  final button = _buttons[index];
                  return ElevatedButton(
                    onPressed: () => _onPressed(button),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isOperator(button) ? Colors.blueAccent : Colors.grey[300],
                      foregroundColor: _isOperator(button) ? Colors.white : Colors.black,
                    ),
                    child: Text(button, style: const TextStyle(fontSize: 20)),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  final List<String> _buttons = [
    '7', '8', '9', '/',
    '4', '5', '6', '*',
    '1', '2', '3', '-',
    'C', '0', '=', '+',
    '.', '⌫', '%', 'x²'
  ];

  bool _isOperator(String button) {
    return ['/', '*', '-', '+', '=', '%', 'x²'].contains(button);
  }
}


