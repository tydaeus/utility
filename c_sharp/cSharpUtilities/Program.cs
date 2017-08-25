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
            FileTree fileTree = new FileTree("..\\..");

            fileTree.CopyTo(@"C:\workspace\sandbox\copyTest", true);

            pause();
        }

        static void pause()
        {
            Console.WriteLine("Press any key to continue...");
            Console.ReadKey();
        }

    }
}
