using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace cSharpUtilities
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                //UsbBrowser.PrintUsbDevices();
                //FlagParseDemo(args);
                //TextFileDemo();
            }
            catch(Exception e)
            {
                Console.Error.WriteLine("ERROR: ");
                Console.Error.WriteLine(e.Message);
            }

            Pause();
        }

        static void Pause()
        {
            Console.WriteLine("Press any key to continue...");
            Console.ReadKey();
            Console.WriteLine();
        }

        static void FlagParseDemo(string[] args)
        {
            CliArguments cliArguments = new CliArguments(args);

            StringBuilder arguments = new StringBuilder();
            cliArguments.Arguments.ForEach(str => arguments.AppendFormat("{0} ", str));
            Console.WriteLine(string.Format("Arguments: {0}", arguments));

            Console.WriteLine(string.Format("Short Flags: {0}", cliArguments.ShortFlags));

            StringBuilder longFlags = new StringBuilder();
            cliArguments.LongFlags.ForEach(delegate (string str)
            {
                KeyValuePair<string, string> splitFlag = CliArguments.SplitLongFlag(str);
                longFlags.AppendFormat("[key:{0}; value:{1}]", splitFlag.Key, splitFlag.Value);
            });
            Console.WriteLine(string.Format("Long Flags: {0}", longFlags));

            // Prototype help display
            Configuration.Properties.ForEach(delegate (Property property)
            {
                Console.WriteLine(property.Name);
                Console.WriteLine();
                Console.WriteLine(string.Format("Flags: {0}", property.LongFlags));
                Console.WriteLine();
                Console.WriteLine(property.Description);
                Console.WriteLine("--------------------------------------------------------------------------------");
                Console.WriteLine();
            });

            Configuration.ReadLongFlags(cliArguments.LongFlags);

            Configuration.ErrorContacts.Value = "someoneElse&badDomain.com";

            Configuration.Properties.ForEach(property => Console.WriteLine(property));
        }

        static void TextFileDemo()
        {
            TextFile tf = new TextFile(@"C:\workspace\sandbox\testTextFile.txt");
            tf.WriteContent("Some Text file content.\r\nIncludes a new line.\r\n");
            Console.WriteLine("TextFile written.");
            Pause();

            tf.AppendContent("Appended content.");
            Console.WriteLine("Additional Content appended.");
        }

        static void FileTreeDemo()
        {
            FileTree sourceFileTree = new FileTree("..\\..");

            FileTree destFileTree = sourceFileTree.CopyTo(@"C:\workspace\sandbox\copyTest", true);
            Console.WriteLine("Files copied");
            Pause();

            destFileTree.MoveTo(@"C:\workspace\sandbox\movedCopyTest");
            Console.WriteLine("Copy moved");
            Pause();

            FileTree zippedFileTree = destFileTree.Zip("zippedCopy");
            Console.WriteLine("Copy zipped");
            Pause();

            Console.WriteLine("Zipped Copy MD5: " + zippedFileTree.CalcMd5());
            Pause();

            FileTree unzippedFileTree = zippedFileTree.Unzip("unzippedCopy");
            Console.WriteLine("Copy unzipped");
            Pause();

            Console.WriteLine("unzippedCopy manifest:");
            Console.WriteLine(unzippedFileTree.BuildManifest());

            destFileTree.Delete();
            zippedFileTree.Delete();
            unzippedFileTree.Delete();
            Console.WriteLine("Copies deleted");
        }

    }
}
