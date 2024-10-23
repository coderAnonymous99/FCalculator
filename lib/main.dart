import 'package:flutter/material.dart';
import 'InfixEvaluator.dart';

void main() => runApp(CalculatorApp());

class CalculatorApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {

	@override
	State<Calculator> createState() => _CalculatorState();
	
} 

class _CalculatorState extends State<Calculator> {

	String display = '0';
	Color _displayBackgroundColor = Colors.white;	// The background color of display
	Color _displayTextColor = Colors.white;	// The text color of display

	@override
	void initState() {
	
		super.initState();	// Ensure that base class has initialiazed its state

		// This callback will be called after rendering of first frame. The context will be fully initialized then and can be used
		WidgetsBinding.instance.addPostFrameCallback((_){				
			resetColor();	// Simply set the color of the text to default color
		});
	
	}

	void addToDisplay(String value) {
		if (display == '0') {
			setState(() => display = value);
		} else {
			setState(() => display += value);
		}
	}
	
	void resetColor() {
		setState(() {
			final theme = Theme.of(context);
			_displayBackgroundColor = theme.colorScheme.surface;
			_displayTextColor = theme.colorScheme.onSurface;
		});
	}
	
	void clearDisplay() {
		display = '0';
		resetColor();	// setState will be called here, so need to call setState for change in display
	}

	void evaluateAnswer() {
		try {
			double ans = evaluateInfix(display);
			setState(() => display = ans.toStringAsFixed(4)); 	
		} catch (e) {
			setState(() {
				final theme = Theme.of(context);
				display = e.toString();
				_displayBackgroundColor = theme.colorScheme.error;	
				_displayTextColor = theme.colorScheme.onError;	
			});
			display = e.toString();
			
		}		
	}

	@override
	Widget build(BuildContext context) {
		
		return Scaffold(

			backgroundColor: Theme.of(context).colorScheme.primaryContainer,
			appBar: AppBar(
				title: Text(
					'Calculator',
					style: TextStyle(
						fontSize: 26,
						fontWeight: FontWeight.bold,
					),
				),
	
				backgroundColor: Theme.of(context).primaryColor,
				elevation: 5,
				centerTitle: true,	
		
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.vertical(
						bottom: Radius.circular(20), 	// Radius for bottom corners of appbar
					),
				),
			
			),	// AppBar		
		
			body: Center(
				child: Container(
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						mainAxisSize: MainAxisSize.min,
						children: [
							
							SizedBox(height: 20),

							Expanded(
								flex: 3,
								child: Card(
									color: _displayBackgroundColor,
									child: SingleChildScrollView(
										child: Padding(
											padding: EdgeInsets.all(8.0),
											child: Align(
												alignment: Alignment.bottomLeft,
												child: Text(
													display,
													style: TextStyle(
														color: _displayTextColor,
														fontSize: 24,
														fontWeight: FontWeight.bold,
													),	// TextStyle
												),	//Text
											),	// Align
										),	// Padding
									),	// SingleChildScrollView
								),	// Card
							),	// Expand

							SizedBox(height: 30),
								
							Expanded(	
								flex: 6,
								child: Container(
									width: 500,
									padding: EdgeInsets.all(6.0),						
									child: GridView.count(
											
										crossAxisCount: 4,	// Number of Columns
										crossAxisSpacing: 4,	// Spacing b/w columns
										mainAxisSpacing: 4,	// Spacing b/w rows
			
										children: [
											CalculatorButton(
												label: '1',
												callback: addToDisplay
											),
											CalculatorButton(
												label: '2',
												callback: addToDisplay
											),
											CalculatorButton(
												label: '3',
												callback: addToDisplay
											),
											CalculatorButton(
												label: ' + ',
												callback: addToDisplay
											),
											CalculatorButton(
												label: '4',
												callback: addToDisplay
											),
											CalculatorButton(
												label: '5',
												callback: addToDisplay
											),
											CalculatorButton(
												label: '6',
												callback: addToDisplay
											),
											Tooltip(
												message: 'Binary Minus - Performs Subtraction',
												child: CalculatorButton(
													label: ' - ',
													callback: addToDisplay
												),
											),
											CalculatorButton(
												label: '7',
												callback: addToDisplay
											),
											CalculatorButton(
												label: '8',
												callback: addToDisplay
											),
											CalculatorButton(
												label: '9',
												callback: addToDisplay
											),
											CalculatorButton(
												label: ' × ',
												callback: addToDisplay
											),
											CalculatorButton(
												label: '(',
												callback: addToDisplay
											),
											CalculatorButton(
												label: '0',
												callback: addToDisplay
											),
											CalculatorButton(
												label: ')',
												callback: addToDisplay
											),
											CalculatorButton(
												label: ' ÷ ',
												callback: addToDisplay
											),
											CalculatorButton(
												label: '=',
												specialCallback: evaluateAnswer
											),
											CalculatorButton(
												label: '.',
												callback: addToDisplay
											),
											CalculatorButton(
												label: "AC",
												specialCallback: clearDisplay
											),
											Tooltip(
												message: 'Unary Minus - Changes Sign Of Number',
												child: CalculatorButton(
													label: '-',
													callback: addToDisplay
												),
											),
										],

									),	// Grid View
								),	// Container
							), // Expanded 
						],	// Children of Column
					),	// Column
				), // Container
			),	// Center 

		);	// Scaffold
		
	}

}

class CalculatorButton extends StatelessWidget {

	final String label;	
	final void Function(String)? callback;
	final void Function()? specialCallback;

	CalculatorButton({required this.label, this.callback, this.specialCallback}) : assert(
																				(callback != null && specialCallback == null) ||
																				(callback == null && specialCallback != null),
																				'Either callback or specialCallback must be provided, but not both!');
	@override
	Widget build(BuildContext context) {

		return ElevatedButton (	//Sized Box to limit size of Elevated Button	
				style: ElevatedButton.styleFrom(
	
					backgroundColor: Theme.of(context).colorScheme.secondary,
					foregroundColor: Theme.of(context).colorScheme.onSecondary,
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(8),
					),
				),
	
				onPressed: () {
					if (callback != null) {
						callback!(label);
					} else {
						specialCallback!();
					}
				},
				child: Text(label),
		);	// Sized Box

	}
}
