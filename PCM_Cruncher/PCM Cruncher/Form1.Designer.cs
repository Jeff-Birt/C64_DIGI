namespace PCM_Cruncher
{
    partial class Cruncher
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Cruncher));
            this.btnFile = new System.Windows.Forms.Button();
            this.tbFile = new System.Windows.Forms.TextBox();
            this.btnCrunch8 = new System.Windows.Forms.Button();
            this.btnScale = new System.Windows.Forms.Button();
            this.tbStatus = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.btnCompress = new System.Windows.Forms.Button();
            this.btnDecompress = new System.Windows.Forms.Button();
            this.cbRate = new System.Windows.Forms.ComboBox();
            this.btnUpscale = new System.Windows.Forms.Button();
            this.nudRound = new System.Windows.Forms.NumericUpDown();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.cbCSV = new System.Windows.Forms.CheckBox();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.cbSigned = new System.Windows.Forms.CheckBox();
            ((System.ComponentModel.ISupportInitialize)(this.nudRound)).BeginInit();
            this.groupBox1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.groupBox3.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnFile
            // 
            this.btnFile.Location = new System.Drawing.Point(16, 26);
            this.btnFile.Name = "btnFile";
            this.btnFile.Size = new System.Drawing.Size(119, 23);
            this.btnFile.TabIndex = 0;
            this.btnFile.Text = "#1 File";
            this.btnFile.UseVisualStyleBackColor = true;
            this.btnFile.Click += new System.EventHandler(this.btnFile_Click);
            // 
            // tbFile
            // 
            this.tbFile.Location = new System.Drawing.Point(194, 50);
            this.tbFile.Name = "tbFile";
            this.tbFile.Size = new System.Drawing.Size(499, 20);
            this.tbFile.TabIndex = 1;
            // 
            // btnCrunch8
            // 
            this.btnCrunch8.Location = new System.Drawing.Point(16, 99);
            this.btnCrunch8.Name = "btnCrunch8";
            this.btnCrunch8.Size = new System.Drawing.Size(119, 23);
            this.btnCrunch8.TabIndex = 2;
            this.btnCrunch8.Text = "#3 Crunch";
            this.btnCrunch8.UseVisualStyleBackColor = true;
            this.btnCrunch8.Click += new System.EventHandler(this.btnCrunch_Click);
            // 
            // btnScale
            // 
            this.btnScale.Location = new System.Drawing.Point(16, 63);
            this.btnScale.Name = "btnScale";
            this.btnScale.Size = new System.Drawing.Size(119, 23);
            this.btnScale.TabIndex = 4;
            this.btnScale.Text = "#2 Scale";
            this.btnScale.UseVisualStyleBackColor = true;
            this.btnScale.Click += new System.EventHandler(this.btnScale_Click);
            // 
            // tbStatus
            // 
            this.tbStatus.Location = new System.Drawing.Point(194, 94);
            this.tbStatus.Multiline = true;
            this.tbStatus.Name = "tbStatus";
            this.tbStatus.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.tbStatus.Size = new System.Drawing.Size(499, 349);
            this.tbStatus.TabIndex = 5;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(356, 18);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(337, 20);
            this.label1.TabIndex = 6;
            this.label1.Text = "File should be a RAW 8-bit (un)signed @ 8kHz";
            // 
            // btnCompress
            // 
            this.btnCompress.Location = new System.Drawing.Point(16, 63);
            this.btnCompress.Name = "btnCompress";
            this.btnCompress.Size = new System.Drawing.Size(114, 23);
            this.btnCompress.TabIndex = 7;
            this.btnCompress.Text = "RLE Compress";
            this.btnCompress.UseVisualStyleBackColor = true;
            this.btnCompress.Click += new System.EventHandler(this.btnCompress_Click);
            // 
            // btnDecompress
            // 
            this.btnDecompress.Location = new System.Drawing.Point(16, 99);
            this.btnDecompress.Name = "btnDecompress";
            this.btnDecompress.Size = new System.Drawing.Size(114, 23);
            this.btnDecompress.TabIndex = 8;
            this.btnDecompress.Text = "RLE Decompress";
            this.btnDecompress.UseVisualStyleBackColor = true;
            this.btnDecompress.Click += new System.EventHandler(this.btnDecompress_Click);
            // 
            // cbRate
            // 
            this.cbRate.DisplayMember = "3";
            this.cbRate.FormattingEnabled = true;
            this.cbRate.Items.AddRange(new object[] {
            "4kHz Avg",
            "4kHz Skp",
            "8kHz"});
            this.cbRate.Location = new System.Drawing.Point(5, 25);
            this.cbRate.Name = "cbRate";
            this.cbRate.Size = new System.Drawing.Size(74, 21);
            this.cbRate.TabIndex = 9;
            // 
            // btnUpscale
            // 
            this.btnUpscale.Location = new System.Drawing.Point(16, 26);
            this.btnUpscale.Name = "btnUpscale";
            this.btnUpscale.Size = new System.Drawing.Size(114, 23);
            this.btnUpscale.TabIndex = 10;
            this.btnUpscale.Text = "Upscale 4khz->8khz";
            this.btnUpscale.UseVisualStyleBackColor = true;
            this.btnUpscale.Click += new System.EventHandler(this.btnUpscale_Click);
            // 
            // nudRound
            // 
            this.nudRound.Location = new System.Drawing.Point(5, 50);
            this.nudRound.Margin = new System.Windows.Forms.Padding(2);
            this.nudRound.Maximum = new decimal(new int[] {
            10,
            0,
            0,
            0});
            this.nudRound.Name = "nudRound";
            this.nudRound.Size = new System.Drawing.Size(54, 20);
            this.nudRound.TabIndex = 11;
            this.nudRound.Value = new decimal(new int[] {
            2,
            0,
            0,
            0});
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(84, 28);
            this.label2.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(60, 13);
            this.label2.TabIndex = 12;
            this.label2.Text = "Output rate";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(64, 54);
            this.label3.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(82, 13);
            this.label3.TabIndex = 13;
            this.label3.Text = "Rounding value";
            // 
            // cbCSV
            // 
            this.cbCSV.AutoSize = true;
            this.cbCSV.Location = new System.Drawing.Point(32, 81);
            this.cbCSV.Margin = new System.Windows.Forms.Padding(2);
            this.cbCSV.Name = "cbCSV";
            this.cbCSV.Size = new System.Drawing.Size(81, 17);
            this.cbCSV.TabIndex = 14;
            this.cbCSV.Text = "Create CSV";
            this.cbCSV.UseVisualStyleBackColor = true;
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.cbRate);
            this.groupBox1.Controls.Add(this.cbCSV);
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Controls.Add(this.label3);
            this.groupBox1.Controls.Add(this.nudRound);
            this.groupBox1.Location = new System.Drawing.Point(20, 172);
            this.groupBox1.Margin = new System.Windows.Forms.Padding(2);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Padding = new System.Windows.Forms.Padding(2);
            this.groupBox1.Size = new System.Drawing.Size(150, 103);
            this.groupBox1.TabIndex = 15;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Output Configuration";
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.btnFile);
            this.groupBox2.Controls.Add(this.btnScale);
            this.groupBox2.Controls.Add(this.btnCrunch8);
            this.groupBox2.Location = new System.Drawing.Point(20, 18);
            this.groupBox2.Margin = new System.Windows.Forms.Padding(2);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Padding = new System.Windows.Forms.Padding(2);
            this.groupBox2.Size = new System.Drawing.Size(150, 134);
            this.groupBox2.TabIndex = 16;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Crunching";
            // 
            // groupBox3
            // 
            this.groupBox3.Controls.Add(this.btnUpscale);
            this.groupBox3.Controls.Add(this.btnCompress);
            this.groupBox3.Controls.Add(this.btnDecompress);
            this.groupBox3.Location = new System.Drawing.Point(25, 302);
            this.groupBox3.Margin = new System.Windows.Forms.Padding(2);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Padding = new System.Windows.Forms.Padding(2);
            this.groupBox3.Size = new System.Drawing.Size(150, 141);
            this.groupBox3.TabIndex = 17;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "Aux Function";
            // 
            // cbSigned
            // 
            this.cbSigned.AutoSize = true;
            this.cbSigned.Location = new System.Drawing.Point(194, 22);
            this.cbSigned.Margin = new System.Windows.Forms.Padding(2);
            this.cbSigned.Name = "cbSigned";
            this.cbSigned.Size = new System.Drawing.Size(78, 17);
            this.cbSigned.TabIndex = 18;
            this.cbSigned.Text = "Signed File";
            this.cbSigned.UseVisualStyleBackColor = true;
            // 
            // Cruncher
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(719, 470);
            this.Controls.Add(this.cbSigned);
            this.Controls.Add(this.groupBox3);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.tbStatus);
            this.Controls.Add(this.tbFile);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "Cruncher";
            this.Text = "PCM Cruncher - Hey Birt";
            ((System.ComponentModel.ISupportInitialize)(this.nudRound)).EndInit();
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.groupBox2.ResumeLayout(false);
            this.groupBox3.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnFile;
        private System.Windows.Forms.TextBox tbFile;
        private System.Windows.Forms.Button btnCrunch8;
        private System.Windows.Forms.Button btnScale;
        private System.Windows.Forms.TextBox tbStatus;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button btnCompress;
        private System.Windows.Forms.Button btnDecompress;
        private System.Windows.Forms.ComboBox cbRate;
        private System.Windows.Forms.Button btnUpscale;
        private System.Windows.Forms.NumericUpDown nudRound;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.CheckBox cbCSV;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.CheckBox cbSigned;
    }
}

