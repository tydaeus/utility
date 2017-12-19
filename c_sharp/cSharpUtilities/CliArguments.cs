using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace cSharpUtilities
{
    /// <summary>
    /// Splits the array of command-line arguments into three categories: arguments, shortFlags, and longFlags.
    /// </summary>
    class CliArguments
    {
        private List<string> arguments = new List<string>();

        /// <summary>
        /// Represents the actual arguments to the program. Includes all arguments not prefixed with at least one '-'.
        /// </summary>
        public List<string> Arguments
        {
            get { return arguments; }
        }
        

        private List<string> longFlags = new List<string>();

        /// <summary>
        /// List of all long-format arguments to the program. Arguments prefixed with "--" are considered to be
        /// LongFlags. The "--" prefix will be stripped before the arguments are added to the list.
        /// </summary>
        public List<string> LongFlags
        {
            get { return longFlags;  }
        }

        private string shortFlags = "";

        /// <summary>
        /// All short-format arguments to the program, combined into one string. Arguments prefixed with "-" are
        /// considered to be ShortFlags. All short flags passed will be combined into this string, unseparated.
        /// E.g. {"-ab", "-c"} and {"-a", "-b", "-c"} would both result in ShortFlags holding "abc".
        /// </summary>
        public string ShortFlags
        {
            get { return shortFlags; }
        }

        public static readonly Regex ShortFlagsMatch = new Regex("^-[^-].+$");
        public static readonly Regex IllegalShortFlags = new Regex("[-:=\"']");
        public static readonly Regex LongFlagsMatch = new Regex("^--[^-].*$");
        // future: allow multiple rules for rejecting long flags
        public static readonly Regex IllegalLongFlags = new Regex("^--[:=\"']");

        private static readonly char[] longFlagSplitChars = new char[] { ':', '=' };

        /// <summary>
        /// Creates a new CliArguments, containing args split into Arguments, LongFlags, and ShortFlags.
        /// </summary>
        /// <param name="args">command line argument array</param>
        /// <exception cref="ArgumentException">If an illegal ShortFlag or LongFlag is detected. The exception's 
        /// message will provide some detail.</exception>
        public CliArguments(string[] args)
        {
            for (int i = 0; i < args.Length; i++)
            {
                if (ShortFlagsMatch.IsMatch(args[i]))
                {
                    if (IllegalShortFlags.IsMatch(args[i].Substring(1)))
                    {
                        StringBuilder illegalFlags = new StringBuilder();

                        throw new ArgumentException(string.Format("short flags include illegal short flags: {0}", args[i]));
                    }
                    shortFlags += args[i].Substring(1);
                }
                else if (LongFlagsMatch.IsMatch(args[i]))
                {
                    if (IllegalLongFlags.IsMatch(args[i]))
                    {
                        throw new ArgumentException(string.Format("illegal long flag: {0}", args[i]));
                    }
                    longFlags.Add(args[i].Substring(2));
                }
                else
                {
                    arguments.Add(args[i]);
                }
            }

        }

        /// <summary>
        /// Convenience function to split a LongFlag into its name and its provided parameter value (if any).
        /// </summary>
        /// <param name="longFlag"></param>
        /// <returns>A key-value pair whose key will be longFlag's name, and whose value will be longFlag's parameter
        /// value. Empty key and value if longFlag is null/empty. Empty value if longFlag has no parameter value.
        /// Will split longFlag on the first instance of ':' or '='.</returns>
        public static KeyValuePair<string, string> SplitLongFlag(string longFlag)
        {
            if (string.IsNullOrWhiteSpace(longFlag))
            {
                return new KeyValuePair<string, string>("", "");
            }

            string key = "";
            string value = "";

            int splitChar = longFlag.IndexOfAny(longFlagSplitChars, 0);

            if (splitChar == -1)
            {
                key = longFlag;
            }
            else
            {
                key = longFlag.Substring(0, splitChar);
                value = longFlag.Substring(splitChar + 1, (longFlag.Length - (splitChar + 1)));
            }

            return new KeyValuePair<string, string>(key, value);
        }
    }
}
