using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

/**
 * Provides example code for registry ops.
 * 
 * Note that for performance reasons, the RegistryKey class should be used in
 * place of Registry.GetValue/SetValue if numerous reads/writes are being 
 * performed.
 */

namespace cSharpUtilities
{
    class RegEditor
    {

        public static readonly object NONEXISTENT_VALUE = new object();
        public static readonly object NONEXISTENT_KEY = new object();

        public static object ReadKey(string keyName, string valName)
        {
            object result = Microsoft.Win32.Registry.GetValue(
                keyName,
                valName,
                NONEXISTENT_VALUE);

       

            if (result == null)
            {
                result = NONEXISTENT_KEY;
            }

            return result;
        }
    }

}
