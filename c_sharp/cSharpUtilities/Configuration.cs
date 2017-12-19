using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace cSharpUtilities
{
    class Configuration
    {

        // singleton only
        internal static readonly Configuration configuration = new Configuration();

        internal Boolean initialized = false;

        private List<Property> properties = new List<Property>();
        public static List<Property> Properties {
            get {
                configuration.Init();
                return configuration.properties;
            }
        }

        private IDictionary<string, Property> propertiesByName = new Dictionary<string, Property>();
        private IDictionary<string, Property> propertiesByLongFlag = new Dictionary<string, Property>();

        private Configuration() { }

        // allows properties to get added to the list as they're created
        internal static void AddProperty(Property property)
        {
            if (configuration.initialized)
            {
                throw new InvalidOperationException("attempted to add a property to configuration post-init");
            }

            configuration.properties.Add(property);
        }

        // Performs setup and validation. Once-only; future calls will be ignored.  
        // Properties should not get added after initialization.
        private void Init()
        {
            if (initialized)
            {
                return;
            }

            properties.ForEach(delegate (Property property)
                {
                    if (string.IsNullOrWhiteSpace(property.Name))
                    {
                        throw new InvalidOperationException("nameless property defined; each property must have a unique name");
                    }

                    if (string.IsNullOrEmpty(property.Description))
                    {
                        Console.WriteLine(string.Format("Warning: property '{0}' has no description defined", property.Name));
                    }

                    IndexPropertyByName(property);
                    IndexPropertyByFlags(property);
                    property.RestoreDefaultValue();
                });

            properties.Sort(delegate (Property a, Property b)
            {
                return string.Compare(a.Name, b.Name);
            });
        }

        /// <summary>
        /// Helper for init. Adds property to the dictionary of properties index by name.
        /// </summary>
        /// <param name="property"></param>
        /// <exception cref="InvalidOperationException">if a property has already been indexed with the same name
        /// </exception>
        private void IndexPropertyByName(Property property)
        {
            if (propertiesByName.ContainsKey(property.Name))
            {
                throw new InvalidOperationException(string.Format("attempted to define property with duplicate name '{0}'", property.Name));
            }

            propertiesByName.Add(property.Name, property);
        }

        /// <summary>
        /// Helper for init. Adds property to the dictionaryi of properties indexed by long flag.
        /// </summary>
        /// <param name="property"></param>
        /// <exception cref="InvalidOperationException">if one of the flags has already been used</exception>
        private void IndexPropertyByFlags(Property property)
        {
            property.longFlags.ForEach(delegate (string longFlag)
            {
                if (propertiesByLongFlag.ContainsKey(longFlag))
                {
                    throw new InvalidOperationException(string.Format("attempted to define property with duplicate flag '{0}'", longFlag));
                }

                propertiesByLongFlag.Add(longFlag, property);
            });
        }

        public Property GetPropertyByName(string name)
        {
            propertiesByName.TryGetValue(name, out Property result);
            return result;
        }

        public Property GetPropertyByLongFlag(string longFlag)
        {
            propertiesByLongFlag.TryGetValue(longFlag, out Property result);
            return result;
        }

        public static StringProperty Zebes = new StringProperty()
            .SetName("Zebes")
            // .SetDescription("Configurates the Zebes-type frob-modulator.")
            .SetDefaultValue("A");

        public static StringProperty Environment = new StringProperty()
            .SetName("Environment")
            .SetDescription("What environment this application is currently running in.")
            .SetDefaultValue("DEV");

        public static StringProperty ErrorContacts = new StringProperty()
            .SetName("Error Contacts")
            .SetDescription("Comma-separated list of email addresses for people who should be contacted in the event of trouble.")
            .SetDefaultValue("undefined&badAddress.com");
    }

    public abstract class Property
    {
        protected string name = "Unnamed";
        public string Name {  get { return name; } }

        protected string description = "";
        public string Description { get { return description; } }

        internal List<string> longFlags = new List<string>();

        public abstract void RestoreDefaultValue();
    }

    public class StringProperty : Property
    {
        internal StringProperty SetName(string name)
        {
            this.name = name;
            return this;
        }

        internal StringProperty SetDescription(string description)
        {
            this.description = description;
            return this;
        }

        private string defaultValue = "";
        public string DefaultValue { get { return defaultValue;  } }
        internal StringProperty SetDefaultValue(string defaultValue)
        {
            this.defaultValue = defaultValue;
            return this;
        }

        private string value = "";
        public string Value
        {
            get { return value; }
            set { this.value = value; }
        }
        public StringProperty SetValue(string value)
        {
            this.value = value;
            return this;
        }

        internal StringProperty AddLongFlag(string longFlag)
        {
            longFlags.Add(longFlag);
            return this;
        }

        public override void RestoreDefaultValue()
        {
            value = defaultValue;
        }

        internal StringProperty() {
            Configuration.AddProperty(this);
        }


    }

}
