package invocation;

import static org.junit.Assert.*;

import java.util.List;

import invocation.CommandLineArgParser.Action;

import org.junit.Before;
import org.junit.Test;

import static org.mockito.Mockito.*;

public class CommandLineArgParser_OptionTest {
	
	CommandLineArgParser.Option unit;

	@Before
	public void setUp() throws Exception {
		unit = spy(CommandLineArgParser.Option.class);
	}
	
/*
 * #parse()
 */
	@Test
	public void parse_returns_true_if_oneChar_flag_matched() {
		unit.addOneCharFlag('f');
		
		assertTrue(unit.parse("-xf"));
	}
	
	@Test
	public void parse_returns_false_if_oneChar_flag_not_matched() {
		unit.addOneCharFlag('f');
		
		assertFalse(unit.parse("-vx"));
	}
	
	@Test
	public void parse_returns_true_if_verbose_flag_matched() {
		unit.addVerboseFlag("verbose");
		
		assertTrue(unit.parse("--verbose"));
	}
	
	@Test
	public void parse_returns_false_if_verbose_flag_not_matched() {
		unit.addVerboseFlag("verbose");
		
		assertFalse(unit.parse("--force"));
	}
	
	@Test
	public void parse_calls_performAction_if_oneChar_flag_matched() {
		unit.addOneCharFlag('v');
		
		unit.parse("-xv");
		
		verify(unit).performAction(new String[0]);
	}
	
	@Test
	public void parse_calls_performAction_if_verbose_flag_matched() {
		unit.addVerboseFlag("verbose");
		
		unit.parse("--verbose");
		
		verify(unit).performAction(new String[0]);
	}
	
	@Test
	public void parse_calls_performAction_with_single_argument_if_equals_argument_provided() {
		unit.addVerboseFlag("environment");
		
		unit.parse("--environment=TEST");
		
		verify(unit).performAction(new String[]{"TEST"});
	}
	
	@Test
	public void parse_calls_performAction_with_all_arguments_if_equals_argument_provides_multiple_space_separated_args_in_quotes() {
		unit.addVerboseFlag("params");
		
		unit.parse("--params=\"x y foo\"");
		
		verify(unit).performAction(new String[]{"x", "y", "foo"});
	}
/*
 * addOneCharFlag()	
 */
	@Test
	public void addOneCharFlag_throws_IllegalArgumentException_if_nonletter_added_as_flag() {
		try {
			unit.addOneCharFlag('-');
			fail("Expected IllegalArgumentException");
		} catch (IllegalArgumentException e) {
			// success
		}
		
		try {
			unit.addOneCharFlag('=');
			fail("Expected IllegalArgumentException");
		} catch (IllegalArgumentException e) {
			// success
		}
	}
	
/*
 * addVerboseFlag()
 */
	@Test
	public void addVerboseFlag_throws_IllegalArgumentException_if_flag_contains_equals() {
		try {
			unit.addVerboseFlag("myflag=something");
			fail("Expected IllegalArgumentException");
		} catch (IllegalArgumentException e) {
			// success
		}
	}
	
	@Test
	public void addVerboseFlag_throws_IllegalArgumentException_if_flag_starts_with_dash() {
		try {
			unit.addVerboseFlag("-myflag");
			fail("Expected IllegalArgumentException");
		} catch(IllegalArgumentException e) {
			// success
		}
	}
	
	@Test
	public void addVerboseFlag_throws_IllegalArgumentException_if_flag_contains_space() {
		try {
			unit.addVerboseFlag("my flag");
			fail("Expected IllegalArgumentException");
		} catch(IllegalArgumentException e) {
			// success
		}
	}
/*
 * addFlag()
 */
	
	@Test
	public void addFlag_with_single_char_param_calls_addOneCharFlag() {
		unit.addFlag("v");
		
		verify(unit).addOneCharFlag('v');
	}
	
	@Test
	public void addFlag_with_multi_char_param_calls_addVerboseFlag() {
		unit.addFlag("verbose");
		
		verify(unit).addVerboseFlag("verbose");
	}

/*
 * test()
 */
	@Test
	public void test_returns_false_when_no_flags_set() {
		assertFalse(unit.test("-f"));
	}
	
	@Test
	public void test_returns_true_when_one_char_flag_has_been_set() {
		unit.addOneCharFlag('f');
		
		assertTrue(unit.test("-f"));
	}
	
	@Test
	public void test_will_not_match_verbose_flag_to_one_char_flag() {
		unit.addOneCharFlag('f');
		
		assertFalse(unit.test("--force"));
	}

	@Test
	public void test_returns_true_when_verbose_flag_has_been_set() {
		unit.addVerboseFlag("force");
		
		assertTrue(unit.test("--force"));
	}
	
/**
 * addAction() | performAction()
 */
	
	@Test
	public void action_added_via_addAction_can_be_retrieved_via_getActions() {
		
		Action expected = mock(Action.class);
		
		unit.addAction(expected);
		
		List<Action> actions = unit.getActions();
		boolean containsExpected = false;
		
		for (Action a: actions) {
			if (a == expected) {
				containsExpected = true;
				break;
			}
		}
		
		assertTrue(containsExpected);
		
	}
		
	@Test
	public void performAction_calls_act_on_first_added_action() {		
		Action action = mock(Action.class);
		
		unit.addAction(action);
		
		unit.performAction(null);
		
		verify(action).act(null);
	}
	
	@Test
	public void performAction_calls_act_on_all_added_actions() {
		Action[] actions = new Action[]{ mock(Action.class), mock(Action.class), mock(Action.class) };
		
		for (Action action : actions) {
			unit.addAction(action);
		}
		
		unit.performAction(null);
		
		for (Action action : actions) {
			verify(action).act(null);
		}
	}
	
	@Test
	public void performAction_passes_arguments_on_to_action$act() {
		Action action = mock(Action.class);
		
		unit.addAction(action);
		
		unit.performAction(new String[] {"argument"});
		
		verify(action).act(new String[] {"argument"});
	}
	
}
