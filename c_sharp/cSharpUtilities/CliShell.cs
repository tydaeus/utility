using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace cSharpUtilities
{
    public class CliShell
    {
        private Dictionary<string, CliCommand> commands = new Dictionary<string, CliCommand>();

        public CliShell AddCommand(CliCommand cliCommand)
        {
            if (cliCommand == null)
            {
                throw new ArgumentException("Unable to add null cliCommand");
            }

            if (string.IsNullOrWhiteSpace(cliCommand.Name))
            {
                throw new ArgumentException("Unable to add cliCommand with no name defined");
            }

            if (commands.ContainsKey(cliCommand.Name))
            {
                throw new ArgumentException("Unable to add command named {0}; a command already exists with this name");
            }

            commands.Add(cliCommand.Name, cliCommand);

            return this;
        }
    }

    public class CliCommand
    {
        protected string name;
        public string Name {
            get { return name; }
        }

        protected string description;
        public string Description {
            get { return description; }
            set { description = value; }
        }

        public CliCommand SetDescription(string description)
        {
            this.description = description;
            return this;
        }

        private Func<IList<string>, IDictionary<string, string>, string> invocation;
        public Func<IList<string>, IDictionary<string, string>, string> Invocation {
            get { return invocation; }
            set { invocation = value; }
        }

        public CliCommand SetInvocation(Func<IList<string>, IDictionary<string, string>, string> invocation)
        {
            this.invocation = invocation;
            return this;
        }

        public CliCommand(string name)
        {
            if (name == null || string.IsNullOrWhiteSpace(name))
            {
                throw new ArgumentException("unable to construct CliCommand with blank/empty name");
            }
            this.name = name;
        }

        public string Invoke(IList<string> arguments, IDictionary<string, string> environment)
        {
            if (invocation == null)
            {
                throw new NotImplementedException("Attempted to invoke cliCommand without a defined invocation");
            }

            return invocation(arguments, environment);
        }
    }
}
