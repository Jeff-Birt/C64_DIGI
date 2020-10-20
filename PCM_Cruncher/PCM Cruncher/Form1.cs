using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;

namespace PCM_Cruncher
{
    //enum OutputRate { SR8K = 1, SR4K = 2 };

    public partial class Cruncher : Form
    {
        StreamWriter logWriter;

        #region UI
        /// <summary>
        /// Initialize the UI
        /// </summary>
        public Cruncher()
        {
            InitializeComponent();
            cbRate.SelectedIndex = 0;
        }

        /// <summary>
        /// Select file to operate on
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnFile_Click(object sender, EventArgs e)
        {
            System.Windows.Forms.OpenFileDialog openFileDialog1;  
            openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
            openFileDialog1.ShowDialog();
            tbFile.Text = openFileDialog1.FileName;
        }

        /// <summary>
        /// Scale 8bit PCM file to take up entire 0-255 range
        /// Saves file with '_SCL' appended to file name
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnScale_Click(object sender, EventArgs e)
        {
            string inputFile = tbFile.Text;
            string outputFile = "";

            if (File.Exists(inputFile))
            {
                tbStatus.Text += Environment.NewLine;
                tbStatus.Text = "Scaling 8bit PCM 0-255 (_SCL)" + Environment.NewLine;
                int minValue = 255; int maxValue = -255;

                findMinMax(inputFile, cbSigned.Checked, ref minValue, ref maxValue);
                double scalar = findScalar(minValue, maxValue);
                double offset = -1 * minValue;

                tbStatus.Text += "Original Min: " + minValue.ToString() + Environment.NewLine;
                tbStatus.Text += "Original Max: " + maxValue.ToString() + Environment.NewLine;
                tbStatus.Text += "Offset: " + offset.ToString() + Environment.NewLine;
                tbStatus.Text += "Scalar: " + scalar.ToString() + Environment.NewLine;

                outputFile = scaleFile(inputFile, scalar, offset);
                tbFile.Text = outputFile;   // update file name text box

                minValue = 255; maxValue = -255;
                if (File.Exists(outputFile))
                {
                    findMinMax(outputFile, false, ref minValue, ref maxValue);
                }

                tbStatus.Text += "Corrected Min: " + minValue.ToString() + Environment.NewLine;
                tbStatus.Text += "Corrected Max: " + maxValue.ToString() + Environment.NewLine;
                tbStatus.Text += "Done" + Environment.NewLine;
            }
            else
            {
                tbStatus.Text += "Input file does not exist!";
            }
        }

        /// <summary>
        /// PCM Cruncher, Round up and downsample from 8bit to 4bit PCM
        /// Output can be set to 4khz or 8khz
        /// Saves file with '_CRN' appended to file name
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnCrunch_Click(object sender, EventArgs e)
        {
            string inputFile = tbFile.Text;
            string outputFile = "";
            long outputFileSize = -1;

            if (File.Exists(inputFile))
            {
                if (cbRate.SelectedIndex == 0)
                {
                    outputFile = crunch4Avg(inputFile);
                    tbFile.Text = outputFile;
                }
                else if (cbRate.SelectedIndex == 1)
                {
                    outputFile = crunch4Skip(inputFile);
                    tbFile.Text = outputFile;
                }
                else
                {
                    outputFile = crunch8(inputFile);
                    tbFile.Text = outputFile;
                }

                if (File.Exists(outputFile))
                {
                    outputFileSize =  new System.IO.FileInfo(outputFile).Length;
                }
                long inputFileSize = new System.IO.FileInfo(inputFile).Length;

                tbStatus.Text += Environment.NewLine;
                tbStatus.Text += "Crunch 8bit PCM to packed 4bit PCM (_CRN)" + Environment.NewLine;
                tbStatus.Text += "Input file size (bytes): " + inputFileSize.ToString() + Environment.NewLine;
                tbStatus.Text += "Ouput file size (bytes): " + outputFileSize.ToString() + Environment.NewLine;
                tbStatus.Text += "Done" + Environment.NewLine;
            }
            else
            {
                tbStatus.Text += "Input file does not exist!";
            }

        }

        /// <summary>
        /// Upscale a 4khz rate file to 8khz, used to test upscaling 
        /// Saves file with '_UP' appended to file name
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnUpscale_Click(object sender, EventArgs e)
        {
            string inputFile = tbFile.Text;
            string outputFile = "";
            long outputFileSize = -1;

            if (File.Exists(inputFile))
            {
                outputFile = upscale4to8(inputFile);
                tbFile.Text = outputFile;   // update file name text box

                if (File.Exists(outputFile))
                {
                    outputFileSize = new System.IO.FileInfo(outputFile).Length;
                }
                long inputFileSize = new System.IO.FileInfo(inputFile).Length;

                tbStatus.Text += Environment.NewLine;
                tbStatus.Text += "Upsacle 4khz to 8khz (_UP)" + Environment.NewLine;
                tbStatus.Text += "Input file size (bytes): " + inputFileSize.ToString() + Environment.NewLine;
                tbStatus.Text += "Output file size (bytes): " + outputFileSize.ToString() + Environment.NewLine;
                tbStatus.Text += "Done" + Environment.NewLine;
            }

        }

        /// <summary>
        /// RLE Compress file
        /// Saves file with '_RLE' appended to file name
        /// Works but takes to long to decode on C64
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnCompress_Click(object sender, EventArgs e)
        {
            string inputFile = tbFile.Text;
            string outputFile = "";
            long outputFileSize = -1;

            if (File.Exists(inputFile))
            {
                List<int> value = new List<int>();
                outputFile = rleCompress(inputFile, ref value);
                tbFile.Text = outputFile;   // update file name text box

                if (File.Exists(outputFile))
                {
                    outputFileSize = new System.IO.FileInfo(outputFile).Length;
                }
                long inputFileSize = new System.IO.FileInfo(inputFile).Length;

                tbStatus.Text += Environment.NewLine;
                tbStatus.Text += "RLE compress 4bit packed PCM (_RLE)" + Environment.NewLine;
                tbStatus.Text += "Input file size (bytes): " + inputFileSize.ToString() + Environment.NewLine;
                tbStatus.Text += "Number of nibble clusters: " + value.Count + Environment.NewLine;
                tbStatus.Text += "Nibble clusters size (bytes): " + (value.Count * 2) + Environment.NewLine;
                tbStatus.Text += "Total nibbles in clusters: " + value.Sum() + Environment.NewLine;
                tbStatus.Text += "Total bytes in clusters: " + value.Sum() / 2 + Environment.NewLine;
                tbStatus.Text += "Output file size (bytes): " + outputFileSize.ToString() + Environment.NewLine;
                tbStatus.Text += "Done" + Environment.NewLine;
            }
            else
            {
                tbStatus.Text += "Input file does not exist!";
            }
        }

        /// <summary>
        /// Decompress RLE encoded file, used as a test
        /// Saves file with '_ELR' appended to file name
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnDecompress_Click(object sender, EventArgs e)
        {
            string inputFile = tbFile.Text;
            string outputFile = "";
            long outputFileSize = -1;

            if (File.Exists(inputFile))
            {
                outputFile = rleDecompress(inputFile);
                tbFile.Text = outputFile;   // update file name text box

                if (File.Exists(outputFile))
                {
                    outputFileSize = new System.IO.FileInfo(outputFile).Length;
                }
                long inputFileSize = new System.IO.FileInfo(inputFile).Length;

                tbStatus.Text += Environment.NewLine;
                tbStatus.Text += "RLE decompress 4bit packed PCM (_ELR)" + Environment.NewLine;
                tbStatus.Text += "Input file size (bytes): " + inputFileSize.ToString() + Environment.NewLine;
                tbStatus.Text += "Output file size (bytes): " + outputFileSize.ToString() + Environment.NewLine;
                tbStatus.Text += "Done" + Environment.NewLine;
            }
            else
            {
                tbStatus.Text += "Input file does not exist!";
            }
        }

        #endregion UI

        #region "Data manipulation"

        /// <summary>
        /// Scales binary file to byte range 0-255
        /// </summary>
        /// <param name="inputFile"></param>
        private string scaleFile(string inputFile, double scalar, double offset)
        {
            string outputFile = ""; // will return empty string if input filename empty

            if (inputFile != "")
            {
                outputFile = buildOutputFileName(inputFile, "_SCL");

                FileStream inputfs = new FileStream(inputFile, FileMode.Open, FileAccess.Read);
                BinaryReader fileReader = new BinaryReader(inputfs);
                FileStream outputfs = new FileStream(outputFile, FileMode.Create);
                BinaryWriter fileWriter = new BinaryWriter(outputfs);

                int v1 = 0;
                long fileSize = inputfs.Length;
                for (long i = 0; i < fileSize; i++)
                {
                    if (cbSigned.Checked)
                    {
                        v1 = (int)(((double)fileReader.ReadSByte() + offset) * scalar);
                    }
                    else
                    {
                        v1 = (int)(((double)fileReader.ReadByte() + offset) * scalar);
                    }

                    v1 = Math.Min(255, v1); // keep from going over
                    v1 = Math.Max(0, v1);   // or under range

                    fileWriter.Write((byte)v1);
                }

                fileReader.Close();
                inputfs.Close();

                fileWriter.Close();
                outputfs.Close();
            }
            return outputFile;
        }

        /// <summary>
        /// Crunch to 4khz - Downsample to 4bits @ 4khz, crunches two 4bit samples
        /// into one output byte. Output at 4khz rate by averaging two nibbles
        /// </summary>
        /// <param name="inputFile"></param>
        /// <returns>output file name</returns>
        /// Averaging method: 
        /// state->0=read Byte1, state->1=read Byte2, avg. Bytes1&2=low nibble
        /// state->2=read Byte3, state->3=Read Byte4, avg. Bytes3&4=high nibble
        private string crunch4Avg(string inputFile)
        {
            string outputFile = "";

            if (inputFile != "")
            {
                int round = (int)nudRound.Value;
                int bytesOutput = 0;
                string tag = "_SR4KAVG_" + round.ToString() + "_RND";
                outputFile = buildOutputFileName(inputFile, tag);

                FileStream inputfs = new FileStream(inputFile, FileMode.Open, FileAccess.Read);
                BinaryReader fileReader = new BinaryReader(inputfs);
                FileStream outputfs = new FileStream(outputFile, FileMode.CreateNew);
                BinaryWriter fileWriter = new BinaryWriter(outputfs);

                if (cbCSV.Checked) { createLogFile(outputFile); }

                int state = 0;
                int lowByte = 0;
                int hiByte = 0;
                long fileSize = inputfs.Length;
                for (long i = 0; i < fileSize; i++)
                {
                    byte nextByte = fileReader.ReadByte();

                    if (state == 0)
                    {
                        lowByte = nextByte;
                        state = 1;
                    }
                    else if (state == 1)
                    {
                        lowByte = (lowByte + nextByte) >> 1; // sum last two bytes and /2
                        lowByte = lowByte + round; // round up
                        lowByte = Math.Min(lowByte, 255); // clip @ 255
                        lowByte = lowByte >> 4; // shift to low nibble position
                        lowByte = Math.Max(lowByte, 1); // never output a zero nibble
                        state = 2;
                    }
                    else if (state == 2)
                    {
                        hiByte = nextByte;
                        state = 3;
                    }
                    else if (state == 3)
                    {
                        hiByte = (hiByte + nextByte) >> 1; // sum last two bytes and /2
                        hiByte = hiByte + round; // round up
                        hiByte = Math.Min(hiByte, 255); // clip @ 255
                        hiByte = hiByte & 0xF0; // same effect as scaling to 4-bit shifting to upper nibble
                        hiByte = Math.Max(hiByte, 0x10); // never output a zero nibble

                        fileWriter.Write((byte)(hiByte | lowByte)); // combine hi & low nibbles
                        bytesOutput++;
                        if (cbCSV.Checked) 
                        { 
                            writeLog(lowByte.ToString());
                            writeLog((hiByte >> 4).ToString());
                        }
                        
                        state = 0;
                    }

                }

                // pad the file so it ends on page boundry in C64
                int orphanedBytes = bytesOutput % 256;
                int padding = orphanedBytes > 0 ? 256 - orphanedBytes : 0;
                for (int p = 0; p < padding; p++)
                {
                    fileWriter.Write((byte)(lowByte | hiByte)); // combine hi & low nibbles
                    if (cbCSV.Checked)
                    {
                        writeLog(lowByte.ToString());
                        writeLog((hiByte >> 4).ToString());
                    }
                }

                fileReader.Close();
                inputfs.Close();

                fileWriter.Close();
                outputfs.Close();

                if (cbCSV.Checked) { closeLogFile(); }

            }

            return outputFile;
        }

        /// <summary>
        /// Crunch 4khz - Downsample to 4bits @ 4khz, cruches two 4bit samples
        /// into one output byte. Outputs at a 4khz rate by skipping every other nibble
        /// </summary>
        /// <param name="inputFile"></param>
        /// <returns>output file name</returns>
        /// Skip method: state->0=Byte1-lowNib, 2=Byte3-highNib
        private string crunch4Skip(string inputFile)
        {
            string outputFile = "";

            if (inputFile != "")
            {
                int round = (int)nudRound.Value;
                int bytesOutput = 0;
                string tag = "_SR4KSKP_" + round.ToString() + "_RND";
                outputFile = buildOutputFileName(inputFile, tag);

                FileStream inputfs = new FileStream(inputFile, FileMode.Open, FileAccess.Read);
                BinaryReader fileReader = new BinaryReader(inputfs);
                FileStream outputfs = new FileStream(outputFile, FileMode.CreateNew);
                BinaryWriter fileWriter = new BinaryWriter(outputfs);

                if (cbCSV.Checked) { createLogFile(outputFile); }

                int state = 0;
                int lowByte = 0;
                int hiByte = 0;
                long fileSize = inputfs.Length;
                for (long i = 0; i < fileSize; i++)
                {
                    byte nextByte = fileReader.ReadByte();

                    if (state == 0)
                    {
                        lowByte = nextByte;
                        lowByte = lowByte + round; // round up
                        lowByte = Math.Min(lowByte, 255); // clip @ 255
                        lowByte = lowByte >> 4; // shift to low nibble position
                        lowByte = Math.Max(lowByte, 1); // never output a zero nibble
                        state = 1;
                    }
                    else if (state == 1)
                    {
                        // skip this byte
                        state = 2;
                    }
                    else if (state == 2)
                    {
                        hiByte = nextByte;
                        hiByte = (hiByte + nextByte) >> 1; // sum last two bytes and /2
                        hiByte = hiByte + round; // round up
                        hiByte = Math.Min(hiByte, 255); // clip @ 255
                        hiByte = hiByte & 0xF0; // same effect as scaling to 4-bit shifting to upper nibble
                        hiByte = Math.Max(hiByte, 0x10); // never output a zero nibble

                        fileWriter.Write((byte)(hiByte | lowByte)); // combine hi & low nibbles
                        bytesOutput++;
                        if (cbCSV.Checked)
                        {
                            writeLog(lowByte.ToString());
                            writeLog((hiByte >> 4).ToString());
                        }

                        state = 3;
                    }
                    else if (state == 3)
                    {
                        //skip this byte
                        state = 0;
                    }

                }

                // pad the file so it ends on page boundry in C64
                int orphanedBytes = bytesOutput % 256;
                int padding = orphanedBytes > 0 ? 256 - orphanedBytes : 0;
                for (int p = 0; p < padding; p++)
                {
                    fileWriter.Write((byte)(lowByte | hiByte)); // combine hi & low nibbles
                    if (cbCSV.Checked)
                    {
                        writeLog(lowByte.ToString());
                        writeLog((hiByte >> 4).ToString());
                    }
                }

                fileReader.Close();
                inputfs.Close();

                fileWriter.Close();
                outputfs.Close();

                if (cbCSV.Checked) { closeLogFile(); }

            }

            return outputFile;
        }

        /// <summary>
        /// Crunch 8khz - Downsample to 4bits, crunches two 4bit samples
        /// into one output byte. Output is at 8khz
        /// </summary>
        /// <param name="inputFile"></param>
        /// <returns>output file name</returns>
        private string crunch8(string inputFile)
        {
            string outputFile = "";

            if (inputFile != "")
            {
                int round = (int)nudRound.Value;
                int bytesOutput = 0;
                string tag = "_SR8K_" + round.ToString() + "_RND";
                outputFile = buildOutputFileName(inputFile, tag);

                FileStream inputfs = new FileStream(inputFile, FileMode.Open, FileAccess.Read);
                BinaryReader fileReader = new BinaryReader(inputfs);

                FileStream outputfs = new FileStream(outputFile, FileMode.Create);
                BinaryWriter fileWriter = new BinaryWriter(outputfs);

                if (cbCSV.Checked) { createLogFile(outputFile); }

                int outByte = 0;
                int lowNibble = 0;
                int highNibble = 0;
                int hiLo = 0;
                long fileSize = inputfs.Length;
                for (long i = 0; i < fileSize; i++)
                {
                    int nextByte = fileReader.ReadByte();

                    nextByte = nextByte + round; // round up
                    nextByte = Math.Min(nextByte, 255); // clip @ 255

                    // If this is an odd byte save upper nibble shifted to lower nibble position
                    // If this is an even byte combine this upper nibble with last nibble
                    if ((hiLo % 2) != 0)
                    {
                        highNibble = nextByte & 0xF0; // save only high nibble
                        highNibble = Math.Max(0x10, highNibble); // make sure high nibble > 0
                        outByte = highNibble | lowNibble;

                        fileWriter.Write((byte)outByte);
                        bytesOutput++;
                        if (cbCSV.Checked) 
                        { 
                            writeLog(lowNibble.ToString());
                            writeLog((highNibble >> 4).ToString());
                        }
                    }
                    else
                    {
                        lowNibble = nextByte >> 4;
                        lowNibble = Math.Max(lowNibble, 1); // never output a zero nibble
                    }
                    hiLo++;
                }

                // pad the file so it ends on page boundry in C64
                int orphanedBytes = bytesOutput % 256;
                int padding = orphanedBytes > 0 ? 256 - orphanedBytes : 0;
                for (int p = 0; p < padding; p++)
                {
                    fileWriter.Write((byte)outByte);
                    if (cbCSV.Checked)
                    {
                        writeLog(lowNibble.ToString());
                        writeLog((highNibble >> 4).ToString());
                    }
                }

                fileReader.Close();
                inputfs.Close();

                fileWriter.Close();
                outputfs.Close();

                if (cbCSV.Checked) { closeLogFile(); }

            }

            return outputFile;
        }

        /// <summary>
        /// Upscale a 4khz crunched file to 8khz, this allows us to test an
        /// externally upscaled file against the quality of the C64 upscaling
        /// </summary>
        /// <param name="inputFile"></param>
        /// <returns></returns>
        private string upscale4to8(string inputFile)
        {
            string outputFile = "";

            if (inputFile != "")
            {
                outputFile = buildOutputFileName(inputFile, "_UP8K");

                FileStream inputfs = new FileStream(inputFile, FileMode.Open, FileAccess.Read);
                BinaryReader fileReader = new BinaryReader(inputfs);
                FileStream outputfs = new FileStream(outputFile, FileMode.Create);
                BinaryWriter fileWriter = new BinaryWriter(outputfs);

                if (cbCSV.Checked) { createLogFile(outputFile); }

                byte output = 0;
                int index = 0;
                int lowNibble = 0;
                int midNibble = 0;
                int highNibble = 0;
                int lastNibble = 0;
                long fileSize = inputfs.Length;

                for (long i = 0; i < fileSize; i++)
                {
                    byte nextByte = fileReader.ReadByte();

                    switch (index) {
                        case 0: // writes (midA | lowA), saves hiA
                            lowNibble = nextByte & 0x0F; // all values in low nibble position
                            highNibble = nextByte >> 4; // all values in low nibble position
                            midNibble = (lowNibble + highNibble) >> 1; // all values in low nibble position
                            output = (byte)((midNibble << 4) | lowNibble);
                            fileWriter.Write(output);
                            if (cbCSV.Checked) 
                            { 
                                writeLog(lowNibble.ToString());
                                writeLog(midNibble.ToString());
                            }

                            lastNibble = highNibble;
                            index = 1;
                            break;
                        case 1: // writes (mid-HiA-LoB | hiA), writes (midB | lowB), saves hiB
                            lowNibble = nextByte & 0x0F;
                            highNibble = nextByte >> 4;
                            midNibble = (lowNibble + lastNibble) >> 1;
                            output = (byte)((midNibble << 4) | lastNibble);
                            fileWriter.Write(output);
                            if (cbCSV.Checked) 
                            {
                                writeLog(lastNibble.ToString());
                                writeLog(midNibble.ToString());
                            }

                            midNibble = (lowNibble + highNibble) >> 1;
                            output = (byte)((midNibble << 4) | lowNibble);
                            fileWriter.Write(output);
                            if (cbCSV.Checked)
                            {
                                writeLog(lowNibble.ToString());
                                writeLog(midNibble.ToString());
                            }

                            lastNibble = highNibble;
                            break;
                    }
                }

                // need to write out an extra byte to make a full page.
                output = (byte)((midNibble << 4) | lowNibble);
                fileWriter.Write(output);
                if (cbCSV.Checked)
                {
                    writeLog(lowNibble.ToString());
                    writeLog(midNibble.ToString());
                }

                fileReader.Close();
                inputfs.Close();

                fileWriter.Close();
                outputfs.Close();

                if (cbCSV.Checked) { closeLogFile(); }
            }

            return outputFile;
        }

        /// <summary>
        /// RLE Compress a 4bit packed sample file
        /// This works but takes too much time to decode in C64
        /// </summary>
        /// <param name="inputFile"></param>
        /// <returns></returns>
        private string rleCompress(string inputFile, ref List<int> value)
        {
            string outputFile = "";
            int maxNibblesInCluster = 16;

            int lastNibble = -1; int lowNibble = -1; int highNibble = -1; int count = 1;
            byte nextByte;

            if (inputFile != "")
            {
                outputFile = buildOutputFileName(inputFile, "_RLE");

                FileStream inputfs = new FileStream(inputFile, FileMode.Open, FileAccess.Read);
                BinaryReader fileReader = new BinaryReader(inputfs);
                FileStream outputfs = new FileStream(outputFile, FileMode.Create);
                BinaryWriter fileWriter = new BinaryWriter(outputfs);

                long fileSize = inputfs.Length;
                for (long i = 0; i < fileSize; i++)
                {
                      nextByte = fileReader.ReadByte();
                     lowNibble = (int)nextByte & 0x0F;
                    highNibble = (int)nextByte >> 4;

                    // if lowNibble matches previous nibble (lastNibble) 
                    if ( (lowNibble == lastNibble) & (count < maxNibblesInCluster) )
                    {
                        count++; // keep track of the number of matching nibbles

                        // if we have a full set of nibbles, write out RLE byte pair
                        if (count == maxNibblesInCluster) 
                        {
                            value.Add(count);           // track stats
                            writeRLEPair(fileWriter, ref count, ref lastNibble, ref highNibble);
                        }
                        lowNibble = -1;                 // low nibble was consumed
                    }

                    // if lowNibble not consumed above keep processing it
                    if (lowNibble != -1)
                    {
                        // Are we are on a 'new' pass.
                        if ( (count == 1) & (lastNibble == -1) )
                        {
                            lastNibble = lowNibble;     // Promote lastNibble for highNibble testing below
                            lowNibble = -1;             // consumed it flag
                        }
                        else if (count > 5)
                        {
                            // if #nibbles >5 enough to REL
                            int oldCount = count;
                            writeRLEPair(fileWriter, ref count, ref lastNibble, ref lowNibble);
                            value.Add(oldCount - count);  // count only nibbles in pairs
                        }
                        else // count >= 1 and count < 5
                        {
                            // if count > 1 we did not have enough nibbles for an RLE pair 
                            // write out as many lastNibble pairs as possible
                            while (count > 1)
                            {
                                fileWriter.Write((byte)((lastNibble << 4) | lastNibble));
                                count -= 2;
                            }

                            // if count = 1 we have an odd # of nibbles, one will be left over from above 
                            // or we could be on new pass where a nibble is left in lastNibble that != lowNibble
                            if (count == 1)
                            {
                                fileWriter.Write((byte)((lowNibble << 4) | lastNibble));

                                lastNibble = highNibble;    // bypass highNibble testing below
                                highNibble = -1;            // as we are out of nibbles
                                lowNibble = -1;             // consumed it flag
                                count = 1;                  // and need it to start a 'new' pass
                            }
                            else // *** not sure about this maybe instrument to see if it gets called **
                            {
                                // we still have the lowNibble
                                lastNibble = lowNibble; // promote to use for highNibble test below
                                lowNibble = -1;     // used it flag
                                count = 1;
                            }
                        } // end of else count > 1 and count < 5
                    } // end of lowNibble != -1

                    // see if we have a highNibble left (not used above)
                    if (highNibble != -1)
                    {
                        // if highNibble matches previous nibble (lastNibble)
                        if ( (highNibble == lastNibble) & (count < 15) )
                        {
                            count++;

                            // if we have a full set of nibbles write out RLE pair
                            // lowNibble is being used as placeholder, it is already == -1
                            if (count == maxNibblesInCluster)
                            {
                                value.Add(count);           // track stats
                                writeRLEPair(fileWriter, ref count, ref lastNibble, ref lowNibble);
                            }
                            highNibble = -1;        // highNibble was consumed
                        }

                        // Is highNibble still left, if so keep processing
                        if (highNibble != -1)
                        {
                            // highNibble != lastNibble and count == 1 write out byte
                            if (count == 1)
                            {
                                fileWriter.Write((byte)((highNibble << 4) | lastNibble));

                                lastNibble = -1;    // consumed it flag, flags new pass
                                highNibble = -1;    // consumed it flag
                                count = 1;
                            }
                            else if (count > 5)
                            {
                                // nibbles >5 enough to write out RLE pair
                                int oldCount = count;
                                writeRLEPair(fileWriter, ref count, ref lastNibble, ref highNibble);
                                value.Add(oldCount - count); // count only nibbles in pairs
                            }
                            else // count > 1 and count < 5
                            {
                                // we did not have enough nibbles for an RLE pair 
                                // we have #n nibbles of lastNibble to write
                                // make byte of two lastNibble, write out count / 2 byt
                                while (count > 1)
                                {
                                    fileWriter.Write((byte)((lastNibble << 4) | lastNibble));
                                    count -= 2;
                                }

                                // if odd number of nibbles one will be left over from above 
                                // make nibble of lastNibble | highNibble, write it out
                                if (count == 1)
                                {
                                    fileWriter.Write((byte)((highNibble << 4) | lastNibble));

                                    lastNibble = -1;     // we have used all nibble, flag new pass
                                    highNibble = -1;     // flag it used
                                    count = 1;
                                }
                                else
                                {
                                    // we still have the highNibble left so promote it to lastNibble
                                    lastNibble = highNibble;
                                    highNibble = -1;     // used it flag
                                    count = 1;
                                }
                            } // end of else // count > 1 and count < 5

                        } // end of (highNibble != -1) test #2
                    } // end of (highNibble != -1) test #1

                } // end of file processing

                // *** need to handle a left over nibble or byte here
                if (lastNibble != -1)
                {
                    //tbStatus.Text += "count: " + count.ToString() + Environment.NewLine;
                    //tbStatus.Text += "lastNibble: " + lastNibble.ToString() + Environment.NewLine;
                    //tbStatus.Text += " lowNibble: " + lowNibble.ToString() + Environment.NewLine;
                    //tbStatus.Text += "highNibble: " + highNibble.ToString() + Environment.NewLine;

                    fileWriter.Write((byte)((lastNibble << 4) | lastNibble));

                    // if count > 1 we did not have enough nibbles for an RLE pair 
                    // make byte of two last nibbles, write out count / 2 bytes
                    while (count > 2)
                    {
                        fileWriter.Write((byte)((lastNibble << 4) | lastNibble));
                        count -= 2;
                    }
                    //tbStatus.Text += "final count: " + count.ToString() + Environment.NewLine;
                }

                fileReader.Close();
                inputfs.Close();

                fileWriter.Close();
                outputfs.Close();
            }

            return outputFile;
        }

        /// <summary>
        /// Uncompress an RLE compressed 4bit packed file
        /// Used as a test of RLE compression routine
        /// </summary>
        /// <param name="inputFile"></param>
        private string rleDecompress(string inputFile)
        {
            string outputFile = "";
            //int maxNibblesInCluster = 16;

            List<int> value = new List<int>();
            int lastNibble = -1; int lowNibble = -1; int highNibble = -1; //int count = 1;
            byte nextByte; int temp;

            if (inputFile != "")
            {
                outputFile = buildOutputFileName(inputFile, "_ELR");

                FileStream inputfs = new FileStream(inputFile, FileMode.Open, FileAccess.Read);
                BinaryReader fileReader = new BinaryReader(inputfs);
                FileStream outputfs = new FileStream(outputFile, FileMode.Create);
                BinaryWriter fileWriter = new BinaryWriter(outputfs);

                long fileSize = inputfs.Length;
                for (long i = 0; i < fileSize; i++)
                {
                    if (lowNibble != -1 | highNibble != -1)
                    {
                        tbStatus.Text += "Error";
                    }

                    nextByte = nextByte = fileReader.ReadByte();
                    lowNibble = (int)nextByte & 0x0F; // low nibble
                    highNibble = (int)nextByte >> 4;   // high nibble

                    // if nextByte is 0x00 then the next byte is an RLE byte
                    if (nextByte == 0x00)
                    {
                        i++; // make sure index stays in sync
                        // read next byte in as it is an RLE byte
                        nextByte = nextByte = fileReader.ReadByte();
                        lowNibble = (int)nextByte & 0x0F; // low nibble
                        highNibble = ((int)nextByte >> 4) + 1;   // high nibble

                        // We need to write out #highNibble values of lowNibble 
                        // if we have a left over nibble we need to consume it first
                        if (lastNibble != -1)
                        {
                            temp =  (lowNibble << 4) | lastNibble;
                            fileWriter.Write((byte)temp); // 

                            highNibble -= 1;    // account for nibble we used
                            lastNibble = -1;    // flag as used
                        }

                        // now write out remaining nibbles packed in bytes
                        while (highNibble > 1)
                        {
                            fileWriter.Write((byte)((lowNibble << 4) | lowNibble)); // #nibbes|nibble_value
                            highNibble -= 2;
                        }
                        lastNibble = -1;    // flag as used

                        // If a nibble is left over save it as lastNibble
                        if (highNibble == 1)
                        {
                            lastNibble = lowNibble;
                        }

                        lowNibble = -1;     // flag as used
                        highNibble = -1;    // flag as used
                    }
                    else
                    {
                        // nextByte was not RLE, just ordinary nibbles

                        // we have no left over nibble so write out nextByte directly
                        if (lastNibble == -1)
                        {

                            fileWriter.Write((byte)nextByte);
                            lastNibble = -1;    // flag as used
                            lowNibble = -1;     // flag as used
                            highNibble = -1;    // flag as used
                        }
                        else
                        {
                            // we have a nibble left over we need to consume
                            fileWriter.Write((byte)((lowNibble << 4) | lastNibble)); // 

                            lastNibble = highNibble; // now save left over highNibble
                            lowNibble = -1;     // flag as used
                            highNibble = -1;    // flag as used
                        }
                    }

                }

                fileReader.Close();
                inputfs.Close();

                fileWriter.Close();
                outputfs.Close();
            }

            return outputFile;
        }

        /// <summary>
        /// Helper to write out an RLE 'pair', a byte where high nibble is 
        /// # of encoded nibbles, and low nibble is value of encoded nibbles
        /// </summary>
        /// <param name="fileWriter"></param>
        /// <param name="count"></param>
        /// <param name="lastNibble"></param>
        /// <param name="sourceNibble"></param>
        private void writeRLEPair(BinaryWriter fileWriter, ref int count, ref int lastNibble, ref int sourceNibble)
        {
            fileWriter.Write((byte)0x00); // RLE flag
            fileWriter.Write((byte)((count-1 << 4) | lastNibble)); // #nibbes|nibble_value

            lastNibble = sourceNibble;    // consumed lastNibble replace with sourceNibble
            sourceNibble = -1;            // flag sourceNibble consumed
            count = 1;                    // reset count
        }
        #endregion "Data manipulation"

        #region "Misc helper methods"
        /// <summary>
        /// Helper to build output file name
        /// </summary>
        /// <param name="inputFile"></param>
        /// <returns></returns>
        private string buildOutputFileName(string inputFile, string fileType)
        {
            return Path.Combine(Path.GetDirectoryName(inputFile),
                    Path.GetFileNameWithoutExtension(inputFile) + fileType +
                    Path.GetExtension(inputFile));
        }

        /// <summary>
        /// Find minimum and maximum byte values in a binary file
        /// </summary>
        /// <param name="minValue"></param>
        /// <param name="maxValue"></param>
        private void findMinMax(string inputFile, bool signed, ref int minValue, ref int maxValue)
        {
            if (inputFile != "")
            {
                FileStream inputfs = new FileStream(inputFile, FileMode.Open, FileAccess.Read);
                BinaryReader fileReader = new BinaryReader(inputfs);

                long fileSize = inputfs.Length;
                for (long i = 0; i < fileSize; i++)
                {
                    int v1;
                    if (signed)
                    {
                        v1 = fileReader.ReadSByte();
                    }
                    else
                    {
                        v1 = fileReader.ReadByte();
                    }

                    if (v1 < minValue)
                    {
                        minValue = v1;
                    }
                    else if (v1 > maxValue)
                    {
                        maxValue = v1;
                    }
                }

                fileReader.Close();
                inputfs.Close();
            }
        }

        /// <summary>
        /// Finds scalar needed to scale byte array to 1-255
        /// </summary>
        /// <param name="minValue"></param>
        /// <param name="maxValue"></param>
        /// <returns></returns>
        private double findScalar(int minValue, int maxValue)
        {
            double span = maxValue - minValue;
            return 255 / span;
        }
        #endregion "Misc helper methods"

        #region "Log file methods"
        /// <summary>
        /// Helper to create a log file for outputing CSV version of data
        /// </summary>
        /// <param name="fileName"></param>
        private void createLogFile(string fileName)
        {
            logWriter = new StreamWriter(fileName + ".csv");
        }

        /// <summary>
        /// Write a single data point out as string
        /// </summary>
        /// <param name="data"></param>
        private void writeLog(string data)
        {
            logWriter.Write(data + ",");
        }

        /// <summary>
        /// Close the log file
        /// </summary>
        private void closeLogFile()
        {
            logWriter.Close();
        }
        #endregion "Log file methods"

    }
}
