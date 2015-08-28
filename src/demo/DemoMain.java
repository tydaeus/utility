package demo;

import java.lang.reflect.Method;

import invocation.CommandLineArgParser;

public class DemoMain {

	static boolean verbose = false;
	
	public static void main(String[] args) {
		System.out.println("demo started");	
		
		parseArgs(args);
		
		Foo foo = new Foo();
		
		System.out.println("foo's canonical name: " + foo.getClass().getCanonicalName());
		Method[] methods = foo.getClass().getMethods();
		
		System.out.println("Methods:");
		for (Method method : methods) {
			System.out.println("\t" + method.getName());
		}
	}
	
	public static void parseArgs(String[] args) {
		CommandLineArgParser argParser = new CommandLineArgParser();
		
		argParser.addOption().addFlag("v", "verbose").addAction(new CommandLineArgParser.Action() {
			public void act(String[] args) {
				verbose = true;
			}
		});
		
		argParser.parse(args);
		
		if (verbose) {
			System.out.println("Verbose mode enabled");
		}		
	}

}
