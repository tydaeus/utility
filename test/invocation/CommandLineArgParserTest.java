package invocation;

import static org.junit.Assert.*;

import java.util.List;

import invocation.CommandLineArgParser.Option;

import org.junit.Before;
import org.junit.Test;
import static org.mockito.Mockito.*;

public class CommandLineArgParserTest {
	
	CommandLineArgParser unit;

	@Before
	public void setUp() throws Exception {
		unit = new CommandLineArgParser();
	}

	@Test
	public void addOption_adds_newly_created_option_to_options_list() {
		Option expected = unit.addOption();
		
		List<Option> optionList = unit.getOptions();
		
		boolean containsOption = false;
		
		for (Option o : optionList) {
			if (o == expected) {
				containsOption = true;
				break;
			}
		}
		
		assertTrue(containsOption);
	}

/*
 * parse()
 */
	@Test
	public void parse_calls_added_action_on_option_matched_by_one_char_flag() {
		CommandLineArgParser.Action vAction = spy(CommandLineArgParser.Action.class);
		unit.addOption().addFlag("v").addAction(vAction);
		
		unit.parse(new String[] { "-v" });
		
		verify(vAction).act(new String[0]);
	}
	
	@Test
	public void parse_calls_added_action_on_option_matched_by_verbose_flag() {
		CommandLineArgParser.Action vAction = spy(CommandLineArgParser.Action.class);
		unit.addOption().addFlag("verbose").addAction(vAction);
		
		unit.parse(new String[] { "--verbose" });
		
		verify(vAction).act(new String[0]);
	}
	
	@Test
	public void parse_doesnt_call_added_action_if_option_not_matched() {
		CommandLineArgParser.Action vAction = spy(CommandLineArgParser.Action.class);
		unit.addOption().addFlag("v").addAction(vAction);
		
		unit.parse(new String[] { "-ex", "--foo" });
		
		verify(vAction, never()).act(new String[0]);
	}
	
	@Test
	public void parse_calls_action_only_once_if_option_matched_multiple_times() {
		CommandLineArgParser.Action vAction = spy(CommandLineArgParser.Action.class);
		unit.addOption().addFlag("v", "verbose").addAction(vAction);
		
		unit.parse(new String[] { "-v", "--verbose" });
		
		verify(vAction).act(new String[0]);
	}

}
