import 'dart:math';

enum Operation { addition, subtraction, multiplication, division }

class MathProblem {
  final int firstNumber;
  final int secondNumber;
  final Operation operation;
  final int answer;

  MathProblem({
    required this.firstNumber,
    required this.secondNumber,
    required this.operation,
    required this.answer,
  });

  static MathProblem generate(int level) {
    final random = Random();
    Operation operation;
    int first, second, result;

    // Determine which operations to include based on level
    List<Operation> availableOperations = [];
    
    if (level >= 1) availableOperations.add(Operation.addition);
    if (level >= 2) availableOperations.add(Operation.subtraction);
    if (level >= 3) availableOperations.add(Operation.multiplication);
    if (level >= 4) availableOperations.add(Operation.division);
    
    // If no operations available (shouldn't happen), default to addition
    if (availableOperations.isEmpty) {
      availableOperations.add(Operation.addition);
    }
    
    // Select a random operation from available ones
    operation = availableOperations[random.nextInt(availableOperations.length)];
    
    // Generate numbers based on operation and level
    switch (operation) {
      case Operation.addition:
        // Higher levels get larger numbers
        int maxValue = 10 + (level - 1) * 5;
        if (maxValue > 100) maxValue = 100;
        
        first = random.nextInt(maxValue) + 1;
        second = random.nextInt(maxValue) + 1;
        result = first + second;
        break;
        
      case Operation.subtraction:
        // Ensure positive results for young children
        int maxValue = 10 + (level - 1) * 5;
        if (maxValue > 100) maxValue = 100;
        
        result = random.nextInt(maxValue) + 1;
        second = random.nextInt(result) + 1;
        first = result + second;
        result = first - second;
        break;
        
      case Operation.multiplication:
        // Start with simple multiplication
        int maxFirst = 5 + (level - 3);
        if (maxFirst > 10) maxFirst = 10;
        
        int maxSecond = 5 + (level - 3);
        if (maxSecond > 10) maxSecond = 10;
        
        first = random.nextInt(maxFirst) + 1;
        second = random.nextInt(maxSecond) + 1;
        result = first * second;
        break;
        
      case Operation.division:
        // Start with simple division that results in whole numbers
        second = random.nextInt(5) + 1; // Divisor between 1-5
        result = random.nextInt(5) + 1; // Quotient between 1-5
        first = second * result; // Ensure clean division
        break;
    }
    
    return MathProblem(
      firstNumber: first,
      secondNumber: second,
      operation: operation,
      answer: result,
    );
  }
  
  @override
  String toString() {
    switch (operation) {
      case Operation.addition:
        return '$firstNumber + $secondNumber = ?';
      case Operation.subtraction:
        return '$firstNumber - $secondNumber = ?';
      case Operation.multiplication:
        return '$firstNumber × $secondNumber = ?';
      case Operation.division:
        return '$firstNumber ÷ $secondNumber = ?';
    }
  }
  
  // Phương thức mới để lấy phần đầu tiên của phép tính
  String getFirstPart() {
    return '$firstNumber';
  }
  
  // Phương thức mới để lấy phép toán
  String getOperationSymbol() {
    switch (operation) {
      case Operation.addition:
        return '+';
      case Operation.subtraction:
        return '-';
      case Operation.multiplication:
        return '×';
      case Operation.division:
        return '÷';
    }
  }
  
  // Phương thức mới để lấy phần thứ hai của phép tính
  String getSecondPart() {
    return '$secondNumber';
  }
}
