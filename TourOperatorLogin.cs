using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace DB_Project
{
    public partial class TourOperatorLogin : Form
    {

        public TourOperatorLogin()
        {
            InitializeComponent();
        }

        private void Heading_Click(object sender, EventArgs e)
        {

        }

        private void button5_Click(object sender, EventArgs e)
        {
            WebsiteHomePage WHP = new WebsiteHomePage();
            this.Hide();
            WHP.Show();
        }

        private void LabelSignup_Click(object sender, EventArgs e)
        {
            TourOperatorSignup TOL = new TourOperatorSignup();
            this.Hide();
            TOL.Show();

        }

        private void button4_Click(object sender, EventArgs e)
        {
            int operatorID;
            if (!int.TryParse(textBox4.Text, out operatorID))
            {
                MessageBox.Show("Please enter a valid Operator ID.");
                return;
            }

            string password = textBox10.Text.Trim();

            if (string.IsNullOrEmpty(password))
            {
                MessageBox.Show("Password cannot be empty.");
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
                {
                    conn.Open();

                    string query = @"SELECT COUNT(*) 
                             FROM TourOperator 
                             WHERE OperatorID = @id AND Password = @pwd";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", operatorID);
                        cmd.Parameters.AddWithValue("@pwd", password);

                        int count = (int)cmd.ExecuteScalar();

                        if (count == 1)
                        {
                            MessageBox.Show("Login successful!");

                            TourOperatorHomePage TOHP = new TourOperatorHomePage(operatorID);
                            this.Hide();
                            TOHP.Show();
                        }
                        else
                        {
                            MessageBox.Show("Invalid ID or Password.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message);
            }
            
                       

            
                       
        }

        private void textBox10_TextChanged(object sender, EventArgs e)
        {

        }

        private void label11_Click(object sender, EventArgs e)
        {

        }

        private void textBox4_TextChanged(object sender, EventArgs e)
        {

        }

        private void label4_Click(object sender, EventArgs e)
        {

        }

        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void TourOperatorLogin_Load(object sender, EventArgs e)
        {
            // TODO: This line of code loads data into the 'travelEaseDataSet18.TourOperator' table. You can move, or remove it, as needed.
            this.tourOperatorTableAdapter.Fill(this.travelEaseDataSet18.TourOperator);

        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }
    }
}
