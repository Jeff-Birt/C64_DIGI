namespace PCM_Cruncher
{
    partial class Form1
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
            ((System.ComponentModel.ISupportInitialize)(this.nudRound)).BeginInit();
            this.SuspendLayout();
            // 
            // btnFile
            // 
            this.btnFile.Location = new System.Drawing.Point(55, 58);
            this.btnFile.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.btnFile.Name = "btnFile";
            this.btnFile.Size = new System.Drawing.Size(100, 28);
            this.btnFile.TabIndex = 0;
            this.btnFile.Text = "#1 File";
            this.btnFile.UseVisualStyleBackColor = true;
            this.btnFile.Click += new System.EventHandler(this.btnFile_Click);
            // 
            // tbFile
            // 
            this.tbFile.Location = new System.Drawing.Point(259, 62);
            this.tbFile.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.tbFile.Name = "tbFile";
            this.tbFile.Size = new System.Drawing.Size(664, 22);
            this.tbFile.TabIndex = 1;
            // 
            // btnCrunch8
            // 
            this.btnCrunch8.Location = new System.Drawing.Point(55, 175);
            this.btnCrunch8.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.btnCrunch8.Name = "btnCrunch8";
            this.btnCrunch8.Size = new System.Drawing.Size(100, 28);
            this.btnCrunch8.TabIndex = 2;
            this.btnCrunch8.Text = "#3 Crunch";
            this.btnCrunch8.UseVisualStyleBackColor = true;
            this.btnCrunch8.Click += new System.EventHandler(this.btnCrunch_Click);
            // 
            // btnScale
            // 
            this.btnScale.Location = new System.Drawing.Point(55, 113);
            this.btnScale.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.btnScale.Name = "btnScale";
            this.btnScale.Size = new System.Drawing.Size(100, 28);
            this.btnScale.TabIndex = 4;
            this.btnScale.Text = "#2 Scale";
            this.btnScale.UseVisualStyleBackColor = true;
            this.btnScale.Click += new System.EventHandler(this.btnScale_Click);
            // 
            // tbStatus
            // 
            this.tbStatus.Location = new System.Drawing.Point(259, 116);
            this.tbStatus.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.tbStatus.Multiline = true;
            this.tbStatus.Name = "tbStatus";
            this.tbStatus.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.tbStatus.Size = new System.Drawing.Size(664, 345);
            this.tbStatus.TabIndex = 5;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(253, 22);
            this.label1.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(382, 25);
            this.label1.TabIndex = 6;
            this.label1.Text = "File should be a RAW 8-bit signed @ 8kHz";
            // 
            // btnCompress
            // 
            this.btnCompress.Location = new System.Drawing.Point(55, 380);
            this.btnCompress.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.btnCompress.Name = "btnCompress";
            this.btnCompress.Size = new System.Drawing.Size(152, 28);
            this.btnCompress.TabIndex = 7;
            this.btnCompress.Text = "RLE Compress";
            this.btnCompress.UseVisualStyleBackColor = true;
            this.btnCompress.Click += new System.EventHandler(this.btnCompress_Click);
            // 
            // btnDecompress
            // 
            this.btnDecompress.Location = new System.Drawing.Point(55, 433);
            this.btnDecompress.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.btnDecompress.Name = "btnDecompress";
            this.btnDecompress.Size = new System.Drawing.Size(152, 28);
            this.btnDecompress.TabIndex = 8;
            this.btnDecompress.Text = "RLE Decompress";
            this.btnDecompress.UseVisualStyleBackColor = true;
            this.btnDecompress.Click += new System.EventHandler(this.btnDecompress_Click);
            // 
            // cbRate
            // 
            this.cbRate.DisplayMember = "1";
            this.cbRate.FormattingEnabled = true;
            this.cbRate.Items.AddRange(new object[] {
            "4kHz",
            "8kHz"});
            this.cbRate.Location = new System.Drawing.Point(55, 234);
            this.cbRate.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.cbRate.Name = "cbRate";
            this.cbRate.Size = new System.Drawing.Size(72, 24);
            this.cbRate.TabIndex = 9;
            // 
            // btnUpscale
            // 
            this.btnUpscale.Location = new System.Drawing.Point(55, 311);
            this.btnUpscale.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.btnUpscale.Name = "btnUpscale";
            this.btnUpscale.Size = new System.Drawing.Size(152, 28);
            this.btnUpscale.TabIndex = 10;
            this.btnUpscale.Text = "Upscale 4khz->8khz";
            this.btnUpscale.UseVisualStyleBackColor = true;
            this.btnUpscale.Click += new System.EventHandler(this.btnUpscale_Click);
            // 
            // nudRound
            // 
            this.nudRound.Location = new System.Drawing.Point(55, 265);
            this.nudRound.Maximum = new decimal(new int[] {
            10,
            0,
            0,
            0});
            this.nudRound.Name = "nudRound";
            this.nudRound.Size = new System.Drawing.Size(72, 22);
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
            this.label2.Location = new System.Drawing.Point(134, 237);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(80, 17);
            this.label2.TabIndex = 12;
            this.label2.Text = "Output rate";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(134, 267);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(107, 17);
            this.label3.TabIndex = 13;
            this.label3.Text = "Rounding value";
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1067, 554);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.nudRound);
            this.Controls.Add(this.btnUpscale);
            this.Controls.Add(this.cbRate);
            this.Controls.Add(this.btnDecompress);
            this.Controls.Add(this.btnCompress);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.tbStatus);
            this.Controls.Add(this.btnScale);
            this.Controls.Add(this.btnCrunch8);
            this.Controls.Add(this.tbFile);
            this.Controls.Add(this.btnFile);
            this.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.Name = "Form1";
            this.Text = "Form1";
            ((System.ComponentModel.ISupportInitialize)(this.nudRound)).EndInit();
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
    }
}

