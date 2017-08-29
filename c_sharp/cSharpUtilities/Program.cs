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
            FileTreeDemo();
            Pause();
        }

        static void Pause()
        {
            Console.WriteLine("Press any key to continue...");
            Console.ReadKey();
            Console.WriteLine();
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

            FileTree unzippedFileTree = zippedFileTree.Unzip("unzippedCopy");
            Console.WriteLine("Copy unzipped");
            Pause();

            destFileTree.Delete();
            zippedFileTree.Delete();
            unzippedFileTree.Delete();
            Console.WriteLine("Copies deleted");
        }

    }
}
