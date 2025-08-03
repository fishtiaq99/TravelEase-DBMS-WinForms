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
    public partial class HotelServiceProviderLogin : Form
    {
        public HotelServiceProviderLogin()
        {
            InitializeComponent();

        }

        private void button5_Click(object sender, EventArgs e)
        {
            WebsiteHomePage WHP = new WebsiteHomePage();
            this.Hide();
            WHP.Show();
        }

        private void button4_Click(object sender, EventArgs e)
        {

            int providerID;
            if (!int.TryParse(textBox4.Text, out providerID))
            {
                MessageBox.Show("Please enter a valid Service Provider ID.");
                return;
            }

            string providerName = textBox10.Text.Trim();

            // Validate password
            if (string.IsNullOrEmpty(providerName) || providerName.Length <= 8 || !providerName.Contains("!"))
            {
                MessageBox.Show("Password must be longer than 8 characters and contain at least one '!'.");
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection("Data Source=MIISHTIAQ\\SQLEXPRESS;Initial Catalog=TravelEase;Integrated Security=True;Encrypt=False"))
                {
                    conn.Open();

                    // Database query to check for valid login
                    string query = @"SELECT COUNT(*) 
                         FROM HotelServiceProvider 
                         WHERE ServiceProviderID = @id AND Password = @name";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", providerID);
                        cmd.Parameters.AddWithValue("@name", providerName);

                        int count = (int)cmd.ExecuteScalar();

                        if (count == 1)
                        {
                            MessageBox.Show("Login successful!");

                            // Navigate to HomePage
                            HotelServiceProviderHomePage HSPHP = new HotelServiceProviderHomePage();
                            this.Hide();
                            HSPHP.Show();
                        }
                        else
                        {
                            MessageBox.Show("Invalid Service Provider ID or Password.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message);
            }


        }

        private void textBox4_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox10_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
