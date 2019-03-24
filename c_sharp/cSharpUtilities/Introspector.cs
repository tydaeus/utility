using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Reflection;
using System.Text;

namespace cSharpUtilities

{
    /// <summary>
    /// Provides utility functions to assist with introspection (code examining code).
    /// </summary>
    public class Introspector
    {
        // this is a static utitility class
        private Introspector() { }

        // convert an object to a nested dictionary of its properties and member objects, suitable for conversion to JSON
        // known issues: circular references will cause infinite recursion, dates won't get handled properly, property-less objects will show as blank
        public static IDictionary<string, object> DictifyObject(object source)
        {
            Dictionary<string, object> result = new Dictionary<string, object>();

            foreach(PropertyDescriptor property in TypeDescriptor.GetProperties(source))
            {
                string propertyName = property.Name;
                object propertyValue = property.GetValue(source);
                object stringifiedValue = DictifyValue(propertyValue);
                result.Add(propertyName, stringifiedValue);
            }

            return result;
        }

        public static object DictifyValue(object value)
        {
            if (value == null)
            {
                return null;
            }

            // check for string before checking if enumerable, so we don't enumerate the string
            // strings and numbers are supported in JSON; preserve as-is
            else if (value is string
                    || value is sbyte
                    || value is byte
                    || value is short
                    || value is ushort
                    || value is int
                    || value is uint
                    || value is long
                    || value is ulong
                    || value is float
                    || value is double
                    || value is decimal
                    || value is Boolean)
            {
                return value;
            }

            else if (value is IEnumerable)
            {
                List<object> result = new List<object>();

                foreach (object member in (IEnumerable)value)
                {
                    result.Add(DictifyObject(member));
                }

                return result;
            }

            else
            {
                return DictifyObject(value);
            }

        }

        /// <summary>
        /// Generates a string describing the object's type and its properties. Adaptable for use as a generic ToString
        /// implementation.
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        public static string ConvertToPropertiesString(object obj)
        {
            if (obj == null)
            {
                return "null";
            }

            Type type = obj.GetType();

            StringBuilder result = new StringBuilder();
            result.Append("[")
                .Append(type.FullName)
                .Append("]: {");

            bool firstProp = true;

            foreach (PropertyInfo prop in obj.GetType().GetProperties())
            {
                // provide comma and space before all properties except first
                if (firstProp)
                {
                    firstProp = false;
                } else
                {
                    result.Append(", ");
                }

                result.Append(prop.Name)
                    .Append(":\"");

                object value = prop.GetValue(obj);

                if (value == null)
                {
                    result.Append("null");
                }
                else
                {
                    result.Append(value);
                }

                result.Append("\"");
            }

            result.Append("}");
            return result.ToString();
        }

    }
}
