using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace cSharpUtilities
{
    /*
     * Example/utility code for working with text files
     */
    class TextFile
    {
        private string filepath;

        public TextFile(string filepath)
        {
            this.filepath = filepath;
        }

        public string Filepath
        {
            get
            {
                return this.filepath;
            }
            set
            {
                this.filepath = value;
            }
        }

        // writes content to the file (replacing any existing content)
        public void WriteContent(string content)
        {
            WriteContent(this.filepath, content);
        }

        public static void WriteContent(string filepath, string content)
        {
            using (StreamWriter sw = new StreamWriter(filepath, false))
            {
                sw.Write(content);
                sw.Close();
            }
        }

        // adds content to the file (creating the file if it doesn't exist)
        public void AppendContent(string content)
        {
            AppendContent(this.filepath, content);
        }

        public static void AppendContent(string filepath, string content)
        {
            using (StreamWriter writer = new StreamWriter(filepath, true))
            {
                writer.Write(content);
                writer.Close();
            }

        }

        public List<string> ReadLines()
        {
            return ReadLines(this.filepath);
        }

        // returns the contents of the text file as an array of strings, one 
        // for each line in the file
        public List<string> ReadLines(string filepath)
        {
            string curLine = "";
            List<string> result = new List<string>();

            using (StreamReader reader = new StreamReader(filepath))
            {
                while ((curLine = reader.ReadLine()) != null)
                {
                    result.Add(curLine);
                }
            }

            return result;
        }

        public string ReadFile()
        {
            return ReadFile(filepath);
        }

        // returns the contents of the text file as a single string
        public static string ReadFile(string filepath)
        {
            using (StreamReader reader = new StreamReader(filepath))
            {
                return reader.ReadToEnd();
            }
        }

    }
}
