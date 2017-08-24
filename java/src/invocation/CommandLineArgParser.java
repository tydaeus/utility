package invocation;

import java.util.ArrayList;
import java.util.List;

/**
 * provides ability to parse command line arguments
 * @author tydaeus
 *
 */
public class CommandLineArgParser {
	
	List<Option> options = new ArrayList<Option>(5);
	
	public void parse(String[] args) {
		for (Option option : options) {
			for (String arg : args) {
				if (option.parse(arg)) {
					break;
				}
			}
		}
	}
		
	public Option addOption() {
		Option result = new Option();
		options.add(result);
		return result;
	}
		
	public List<Option> getOptions() {
		return options;
	}
	
	/**
	 * represents a single command-line option (which may have more than 1 
	 * possible invocation)
	 * @author tydaeus
	 */
	public static class Option {
		// list of multi-char flags (e.g. "--verbose")
		private List<String> verboseFlags = new ArrayList<String>();
		// list of single-char flags (e.g. "-v")
		private List<Character> oneCharFlags = new ArrayList<Character>();
		// list of actions that should be performed if this option is matched
		private List<Action> actions = new ArrayList<Action>();
		
		/**
		 * parses a command line argument against this Option's flags. If any
		 * flags match, performAction will be called with any flag options
		 * passed along. PerformAction will be called only once, no matter how
		 * many flags match.
		 * @param arg the command-line argument
		 * @return whether a flag was matched
		 */
		public boolean parse(String arg) {
			String[] params = new String[0];

			arg = arg.replaceAll("\"", "");
			int splitLoc = arg.indexOf("=");
			
			if (splitLoc > -1) {
				params = arg.substring(splitLoc + 1).split("\\s");
				arg = arg.substring(0,  splitLoc);
			}
			
			if(test(arg)) {
				performAction(params);
				return true;
			} else {
				return false;
			}
		}
		
		/**
		 * @param arg command line invocation item
		 * @return true if arg matches one of the flags defined for this option
		 */
		public boolean test(String arg) {
			if (arg.matches("^-\\w+$")) {
				return testOneCharFlags(arg);
			} else {
				return testVerboseFlags(arg);
			}
		}
		
		private boolean testOneCharFlags(String arg) {
			char[] chars = arg.toCharArray();
			for (char c : chars) {
				for (char d : oneCharFlags) {
					if (c == d) {
						return true;
					}
				}
			}
			return false;			
		}
		
		private boolean testVerboseFlags(String arg) {
			arg = arg.replaceFirst("--", "");
			for (String s: verboseFlags) {
				if (s.equalsIgnoreCase(arg)) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * register one or more single-character flags
		 * @param flags list of characters to register
		 * @return this Option for chaining
		 */
		public Option addOneCharFlag(char... flags) {
			for (char c : flags) {
				if (!Character.isAlphabetic(c)) {
					throw new IllegalArgumentException("Cannot add '" + c + "' as a flag");
				}
				
				oneCharFlags.add(c);
			}
			
			return this;
		}
		
		/**
		 * register one or more verbose flags
		 * @param flags list of characters to register
		 * @return this Option for chaining
		 */
		public Option addVerboseFlag(String... flags) {
			for (String s : flags) {
				if (s.contains("=")) {
					throw new IllegalArgumentException("verbose flag cannot contain '='");
				}
				if (s.startsWith("-")) {
					throw new IllegalArgumentException("verbose flag cannot start with '-'");
				}
				if (s.matches(".*\\s.*")) {
					throw new IllegalArgumentException("verbose flag cannot contain space");
				}
				verboseFlags.add(s);
			}
			
			return this;
		}
		
		/**
		 * adds one or more flags appropriately for their length
		 * @param flags a list of strings
		 * @return this Option for chaining
		 */
		public Option addFlag(String... flags) {
			
			for (String flag : flags) {
				if (flag.length() == 1) {
					addOneCharFlag(flag.charAt(0));
				} else {
					addVerboseFlag(flag);
				}
			}
			
			return this;
		}
		
		/**
		 * register an action to perform when any of this Option's flags are
		 * matched
		 * @param action
		 * @return this Option for chaining
		 */
		public Option addAction(Action action) {
			this.actions.add(action);
			return this;
		}
		
		/**
		 * @return the list of actions registered on this Option
		 */
		public List<Action> getActions() {
			return actions;
		}
		
		/**
		 * call all registered actions
		 */
		protected void performAction(String[] arguments) {
			for (Action action : actions) {
				action.act(arguments);
			}
		}
	}
	
	/**
	 * represents an action to be performed when a command-line option flag is
	 * matched
	 * @author tydaeus
	 */
	public static interface Action {
		
		/**
		 * this method will be called when the flag registered with it is
		 * matched
		 * @param args an array of the arguments passed to the flag; empty
		 * 	if no such arguments were passed
		 */
		public void act(String[] args);
	}
}


