using System;
using System.IO;
using System.Text.RegularExpressions;
// Must add reference to System.IO.Compression.FileSystem assembly
using System.IO.Compression;

namespace cSharpUtilities
{

    /**
     * Provides util functions for working with sets of files.
     * 
     * Unless stated otherwise, functions will generally detect whether the
     * "file" in question is a directory or a regular file.
     * 
     * Instance functions operate on the the "root" file (directory or file) 
     * specified at creation and either modify instance's root or return a new 
     * FileTree, depending on operation performed.
     * 
     * Static functions operate on specified file.
     */
    class FileTree
    {
        string root;

        public FileTree(string root)
        {
            this.root = root;
        }

        public string Root
        {
            get
            {
                return root;
            }
            set
            {
                root = value;
            }
        }

        public void Traverse(Action<string, int> visit)
        {
            Traverse(this.root, visit);
        }

        public static void Traverse(string root, Action<string, int> visit)
        {
            Traverse(Path.GetFullPath(root), visit);
        }

        private static void Traverse(string path, Action<string, int> visit, int nestedLevel = 0)
        {
            if (Directory.Exists(path))
            {
                visit(path, nestedLevel);
                foreach (string dir in Directory.GetDirectories(path))
                {
                    Traverse(dir, visit, nestedLevel + 1);
                }
                foreach (string file in Directory.GetFiles(path))
                {
                    Traverse(file, visit, nestedLevel + 1);
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

        public FileTree CopyTo(string destination, Boolean verbose = false)
        {
            Copy(root, destination, verbose);

            if (IsDirectory())
            {
                return new FileTree(destination);
            } else if (IsFile())
            {
                return new FileTree(destination + Path.GetFileName(root));
            } else
            {
                throw new InvalidOperationException("Somehow performed CopyTo on root that was neither dir nor file");
            }
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
            if (!Directory.Exists(destDir.FullName))
            {
                if (verbose)
                {
                    Console.WriteLine(@"Creating dir {0}", destDir.FullName);
                }
                Directory.CreateDirectory(destDir.FullName);
            }

            foreach (FileInfo file in sourceDir.GetFiles())
            {
                CopyFile(file, destDir, verbose);
            }

            foreach(DirectoryInfo subDir in sourceDir.GetDirectories())
            {
                CopyDir(subDir, new DirectoryInfo(Path.Combine(destDir.FullName, subDir.Name)), verbose);
            }
        }

        public static void CopyFile(string sourceFile, string destDir, Boolean verbose = false)
        {
            CopyFile(new FileInfo(sourceFile), new DirectoryInfo(destDir), verbose);
        }

        public static void CopyFile(FileInfo sourceFile, DirectoryInfo destDir, Boolean verbose = false)
        {
            if (verbose)
            {
                Console.WriteLine(@"Copying file {0}\{1}", destDir.FullName, sourceFile.Name);
            }
            sourceFile.CopyTo(Path.Combine(destDir.FullName, sourceFile.Name), true);
        }

        public void Delete()
        {
            Delete(this.root);
        }

        public static void Delete(string path)
        {
            if (Directory.Exists(path))
            {
                DeleteDir(path);
            }
            else if (File.Exists(path))
            {
                DeleteFile(path);
            } else
            {
                throw new ArgumentException("Unable to delete path '" + path + "': " +
                    "is neither file nor dir");
            }
        }

        public static void DeleteDir(string dirPath)
        {
            Directory.Delete(dirPath, true);
        }

        public static void DeleteFile(string filePath)
        {
            File.Delete(filePath);
        }

        /**
         * Attempts to move the root file of this fileTree to the specified 
         * location, updating root value appropriately on success.
         */
        public void MoveTo(string destDir)
        {
            string originalRoot = Path.GetFullPath(root);
            Boolean isFile = IsFile();

            Move(root, destDir);

            if (isFile)
            {
                root = Path.GetFullPath(destDir + Path.GetFileName(originalRoot));
            } else
            {
                root = destDir;
            }

          
        }

        public static void Move(string source, string destDir)
        {
            if (File.Exists(source))
            {
                MoveFile(source, destDir);
            } else if (Directory.Exists(source))
            {
                MoveDir(source, destDir);
            }
            else
            {
                throw new ArgumentException("Illegal move source '" + source + "' ");
            }
        }

        public static void MoveDir(string sourceDir, string destDir)
        {
            MoveDir(new DirectoryInfo(sourceDir), new DirectoryInfo(destDir));
        }

        public static void MoveDir(DirectoryInfo sourceDir, DirectoryInfo destDir)
        {
            sourceDir.MoveTo(destDir.FullName);
        }

        public static void MoveFile(string sourceFile, string destDir)
        {
            MoveFile(new FileInfo(sourceFile), new DirectoryInfo(destDir));
        }

        public static void MoveFile(FileInfo sourceFile, DirectoryInfo destDir)
        {
            sourceFile.MoveTo(destDir.FullName);
        }
        public FileTree Zip(string destination = null)
        {
            return new FileTree(ZipDir(root, destination));
        }

        public static string ZipDir(string sourceDir, string destFilePath = null)
        {
            // default to adding .zip to source dir name
            if (destFilePath == null)
            {
                destFilePath = sourceDir + ".zip";
            }

            // ensure zipped file name ends in .zip
            if (!Path.GetExtension(destFilePath).ToLower().Equals(".zip"))
            {
                destFilePath += ".zip";
            }

            // use root dir if destination does not specify dir
            if (PATH_SEPERATORS.Matches(destFilePath).Count == 0)
            {
                destFilePath = Path.Combine(Path.GetDirectoryName(sourceDir), destFilePath);
            }

            ZipFile.CreateFromDirectory(sourceDir, destFilePath);

            return Path.GetFullPath(destFilePath);
        }

        public FileTree Unzip(string destination = null)
        {
            return new FileTree(Unzip(root, destination));
        }

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

        public Boolean IsFile()
        {
            return File.Exists(root);
        }

        public Boolean IsZip()
        {
            // assume that file extension is correct
            return File.Exists(root) && Path.GetExtension(root).ToLower().Equals("zip");
        }

        private static readonly Regex PATH_SEPERATORS = new Regex(@"[\\/]");

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
