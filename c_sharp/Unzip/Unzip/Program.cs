using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
// Must have reference to System.IO.Compression.FileSystem assembly for Unzip
using System.IO.Compression;

namespace Unzip
{
    /*
     * Simple Unzip utility for command-line use
     */
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length < 1 || args.Length > 2)
            {
                Console.Error.WriteLine("ERR: Invalid usage");
                Console.WriteLine("Usage: Unzip SOURCE_FILE [DEST_DIR]");
                Environment.Exit(1);
            }

            string sourceFile = args[0];
            string destDir = null;

            if (args.Length > 1)
            {
                destDir = args[1];
            }

            Unzip(sourceFile, destDir);
        }

        private static readonly Regex PATH_SEPERATORS = new Regex(@"[\\/]");

        public static string Unzip(string sourceFile, string destDir)
        {
            // default to removing .zip from file name
            if (destDir == null)
            {
                destDir = Path.GetFileNameWithoutExtension(sourceFile);
            }

            // ensure unzipped file name loses .zip
            if (Path.GetExtension(destDir).ToLower().Equals(".zip"))
            {
                destDir = Path.GetFileNameWithoutExtension(destDir);
            }

            // use sourceFile dir if destination does not specify dir
            if (PATH_SEPERATORS.Matches(destDir).Count == 0)
            {
                destDir = Path.Combine(Path.GetDirectoryName(sourceFile), destDir);
            }

            ZipFile.ExtractToDirectory(sourceFile, destDir);

            return Path.GetFullPath(destDir);
        }
    }
}
