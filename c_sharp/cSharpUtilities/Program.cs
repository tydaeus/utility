﻿using System;
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
            CliArguments cliArguments = new CliArguments(args);

            StringBuilder arguments = new StringBuilder();
            cliArguments.Arguments.ForEach(str => arguments.AppendFormat("{0} ", str));
            Console.WriteLine(string.Format("Arguments: {0}", arguments));

            Console.WriteLine(string.Format("Short Flags: {0}", cliArguments.ShortFlags));

            StringBuilder longFlags = new StringBuilder();
            cliArguments.LongFlags.ForEach(str => longFlags.AppendFormat("{0} ", str));
            Console.WriteLine(string.Format("Long Flags: {0}", longFlags));
            //TextFileDemo();
            Pause();
        }

        static void Pause()
        {
            Console.WriteLine("Press any key to continue...");
            Console.ReadKey();
            Console.WriteLine();
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
