using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace cSharpUtilities

{
    /// <summary>
    /// Provides utility functions to assist with introspection (code examining code).
    /// </summary>
    public class Introspector
    {
        // this is a static utitility class
        private Introspector() { }

        public static string StringifyPropertyValue(object obj, string propertyName)
        {
            object propertyValue = obj.GetType().GetProperty(propertyName).GetValue(obj, null);
            return StringifyValue(propertyValue);
        }

        public static string StringifyValue(object propertyValue)
        {
            if (propertyValue == null)
            {
                return "null";
            }

            JSONConvert

            // check for string before checking if enumerable
            if (propertyValue is string)
            {
                return "\"" + (string)propertyValue + "\"";
            }

            if (propertyValue is IEnumerable)
            {
                IEnumerable enumerableValue = (IEnumerable)propertyValue;

                StringBuilder result = new StringBuilder();
                result.Append("[");

                foreach (object member in enumerableValue)
                {
                    result.Append(Stringify(member)).Append(", ");
                }

                result.Append("]");
                return result.ToString();
            }

            return propertyValue.ToString();

        }

        public static string Stringify(object obj)
        {
            if (obj == null)
            {
                return "null";
            }
            else
            {
                return obj.ToString();
            }
        }
    }
}
