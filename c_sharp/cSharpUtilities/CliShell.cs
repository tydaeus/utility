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
    }

    public abstract class CliCommand
    {
        protected string name;
        public string Name { get; }

        protected string description;
        public string Description { get; }

        public abstract string Invoke(IList<string> arguments, IDictionary<string, string> environment);
    }
}
