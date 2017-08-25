using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace cSharpUtilities
{

    /**
     * Provides util functions for working with sets of files.
     * 
     * Instance functions operate on the the "root" file (directory or file) 
     * specified at creation. Static functions operate on specified file.
     */
    class FileTree
    {
        string root;

        public FileTree(string root)
        {
            this.root = root;
        }

        public void Traverse(Action<string, int> visit)
        {
            Traverse(this.root, visit);
        }

        public static void Traverse(string root, Action<string, int> visit)
        {
            traverse(Path.GetFullPath(root), visit);
        }

        static void traverse(string path, Action<string, int> visit, int nestedLevel = 0)
        {
            if (Directory.Exists(path))
            {
                visit(path, nestedLevel);
                foreach (string dir in Directory.GetDirectories(path))
                {
                    traverse(dir, visit, nestedLevel + 1);
                }
                foreach (string file in Directory.GetFiles(path))
                {
                    traverse(file, visit, nestedLevel + 1);
                }
            }
            else if (File.Exists(path))
            {
                visit(path, nestedLevel);
            }
            else
            {
                Console.WriteLine("ERROR: file '" + path + "' does not exist");
            }
        }

        public void CopyTo(string destination, Boolean verbose = false)
        {
            Copy(root, destination, verbose);
            
        }

        public static void Copy(string source, string destination, Boolean verbose = false)
        {
            if (Directory.Exists(source))
            {
                CopyDir(source, destination, verbose);
            }
            else if (File.Exists(source))
            {
                DirectoryInfo destDir = Directory.CreateDirectory(destination);

                File.Copy(source, destDir.FullName);
            }
            else
            {
                throw new ArgumentException("Unable to copy from '" + source + "'");
            }
        }

        public static void CopyDir(string source, string destination, Boolean verbose = false)
        {
            CopyDir(new DirectoryInfo(source), new DirectoryInfo(destination), verbose);
        }

        public static void CopyDir(DirectoryInfo sourceDir, DirectoryInfo destDir, Boolean verbose = false)
        {
            Directory.CreateDirectory(destDir.FullName);

            foreach(FileInfo file in sourceDir.GetFiles())
            {
                if (verbose)
                {
                    Console.WriteLine(@"Copying {0}\{1}", destDir.FullName, file.Name);
                }
                file.CopyTo(Path.Combine(destDir.FullName, file.Name), true);
            }

            foreach(DirectoryInfo subDir in sourceDir.GetDirectories())
            {
                CopyDir(subDir, destDir.CreateSubdirectory(subDir.Name));
            }
        }

        public Boolean IsFile()
        {
            return File.Exists(root);
        }

        public Boolean IsDirectory()
        {
            return Directory.Exists(root);
        }

        public Boolean Exists()
        {
            return IsFile() || IsDirectory();
        }

        public static void DisplayFile(string path, int nestedLevel = 0)
        {
            string message = buildIndent(nestedLevel);
            if (Directory.Exists(path))
            {
                message += "D";
            }
            else if (File.Exists(path))
            {
                message += "F";
            }
            else
            {
                message += "?";
            }

            message += ": " + path;

            Console.WriteLine(message);
        }

        static string buildIndent(int level)
        {
            string result = "";

            while (level > 0)
            {
                result += "  ";
                level--;
            }

            return result;
        }
    }
}
