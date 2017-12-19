using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace cSharpUtilities
{
    class CliArguments
    {
        private List<string> arguments = new List<string>();
        public List<string> Arguments
        {
            get { return arguments; }
        }
        

        private List<string> longFlags = new List<string>();
        public List<string> LongFlags
        {
            get { return longFlags;  }
        }

        private string shortFlags = "";
        public string ShortFlags
        {
            get { return shortFlags; }
        }

        public static readonly Regex ShortFlagsMatch = new Regex("^-[^-].+$");
        public static readonly Regex IllegalShortFlags = new Regex("[-:=\"']");
        public static readonly Regex LongFlagsMatch = new Regex("^--[^-].*$");
        public static readonly Regex IllegalLongFlags = new Regex("^--[:=\"']");

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
    }
}
