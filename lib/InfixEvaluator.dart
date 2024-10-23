import 'dart:io';
import 'dart:math';

bool isOperator(String str) => str == '+' || str == '-' || str == '×' || str == '÷' || str == '^';

bool _isDigit(String char) => (char.codeUnitAt(0) >= 48 /*'0'*/ && char.codeUnitAt(0) <= 57 /*'9'*/);

bool _isValidSymbol(String str) => str == '(' || str == ')' || isOperator(str) || _isDigit(str); 

/* 
	Extracts operands from operandStack, and operator from operator stack.
	Then performs required operation and then store the result in operandStack.
	Handles various cases and throws exceptions in case of error
*/
void _extractOperandsAndPerformOperation({required List<String> operatorStack, required List<double> operandStack}) {
	
	if (operandStack.length < 2) {
		throw FormatException('Invalid Expression Given!');
	}

	String _operator = operatorStack.last;	
	operatorStack.removeLast();
		
	double op2 = operandStack.last;
	operandStack.removeLast();

	double op1 = operandStack.last;
	operandStack.removeLast();

	double res=0;

	switch(_operator) {
		case '+':
			res = op1 + op2;
			break;
		case '-':
			res = op1 - op2;
			break;
		case '×':
			res = op1 * op2;
			break;
		case '÷':
			if (op2 == 0) throw ArgumentError('Cannot divide by zero!');
			res = op1 / op2;
			break;
		case '^':
			res = pow(op1, op2).toDouble();	
			break;	
		default:
			throw UnimplementedError("Either '$_operator' is not implemented or is invalid operation...");
	}
	
	operandStack.add(res);	
}

bool _hasPrecedence(String operator1, String operator2) {

	if (operator1 == '^' && operator2 == '^') return false;	// It is right associative

	Map<String, int> precedenceTable = {
		'+' : 1,
		'-' : 1,
		'×' : 2,
		'÷' : 2,
		'^' : 3,
		'(' : 0,	// So that exception can't be thrown, when brackets are given as operators. Its logic is being handled in the evaluate function
		')' : 0,
	};

	if (!(precedenceTable.containsKey(operator1)) || !(precedenceTable.containsKey(operator2))) {
		throw UnimplementedError("Either '$operator1' or '$operator2' is invalid or not implemented yet...");
	}

//	stdout.write("\nDoes '$operator1' has precendence over '$operator2'? ${precedenceTable[operator1]! >= precedenceTable[operator2]!}\n");

	return precedenceTable[operator1]! >= precedenceTable[operator2]!;
}

double evaluateInfix(String expression) {
	
	//Using list as a stack, list provides constant time operations for inserting at end, removing from end and peeking last element
	List<double> operandStack = [];
	List<String> operatorStack = [];

	// To keep track how many brackets are opened so that we throw error if user didn't closed them
	int openedBrackets=0;

	for (int i = 0; i < expression.length; i++) {
	
		String token = expression[i];
	
		if (token == ' ');	// Skip
		
		/*	If a '-' comes right at the begining of expression, or right after the opening braces, then it is considered unary minus	
		 	which means its a number, or if the token is digit or character '.', because '.' might also indicate begining of decimal number
		*/
		else if ((token == '-' && (i == 0 || expression[i-1] == '(')) || (_isDigit(token) || token == '.')) {

			bool isNegative = false;

			if (token == '-') {
				//So that the number can be easily extracted
				isNegative = true;
				i++;
			}
	
			int j = i;
			while (j != expression.length && (_isDigit(expression[j]) || expression[j] == '.')) { ++j;}

			double? num = double.tryParse(expression.substring(i, j));
			
			if (num == null) throw FormatException("Format of number ${expression.substring(i,j)} is not correct!");

			// j-1 Because it might accidently skip one operator or bracket written right after the number
			i = j-1;
		
			// If number is negative, apply the sign
			if (isNegative) num *= -1;

			operandStack.add(num);
		}

		else if (token == '(') {
			// The '(' isn't an operator, however it will help to give high precedence to low precendence operators which are in brackets
			operatorStack.add(token);
			++openedBrackets;
		}

		else if (token == ')') {
	
			String expMessage = "End bracket ')' is given, but there is no start bracket!";
	
			if (operatorStack.isEmpty) throw FormatException(expMessage);

			--openedBrackets;
			while (operatorStack.last != '(') {
				_extractOperandsAndPerformOperation(operandStack: operandStack, operatorStack: operatorStack);	// Execute all operations in bracket
				if (operatorStack.isEmpty) throw FormatException(expMessage);	
			}

			operatorStack.removeLast();	// Also remove '(' from stack
		
		}

		else if (isOperator(token)) {
			if (operatorStack.isNotEmpty && _hasPrecedence(operatorStack.last, token))
				_extractOperandsAndPerformOperation(operandStack: operandStack, operatorStack: operatorStack);	

			operatorStack.add(token);
		}	
		
		else {
			throw FormatException('Invalid Expression Given!');
		}
	
	}	

	if (openedBrackets != 0) {
		throw FormatException('$openedBrackets brackets were opened, but never closed!');
	}

	while (operatorStack.isNotEmpty) 
		_extractOperandsAndPerformOperation(operandStack: operandStack, operatorStack: operatorStack);	

	if (operandStack.length != 1) throw ArgumentError('Invalid Expression Given!');

	return operandStack.last;
}

void main() {
	
	String? str = null;
	
	stdout.write('\nEnter any mathematical expression (without variables) : ');
	str = stdin.readLineSync();

	stdout.write('\nExpression : $str\n');

	try {	
		double ans = evaluateInfix(str!);
		print('\n$str = $ans\n');
	} catch (e) {
		print('\n$e');
	}
}
