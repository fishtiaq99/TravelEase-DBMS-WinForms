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

namespace DB_Project
{
    public partial class AdminLoginPagecs : Form
    {
        public AdminLoginPagecs()
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
            int adminID;
            if (!int.TryParse(textBox4.Text, out adminID))
            {
                MessageBox.Show("Please enter a valid Admin ID.");
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
                using (SqlConnection conn = new SqlConnection("Data Source=MIISHTIAQ\\SQLEXPRESS;Initial Catalog=TravelEase;Integrated Security=True;Encrypt=False"))
                {
                    conn.Open();

                    string query = @"SELECT Name, Role, Permissions 
                         FROM Admin 
                         WHERE AdminID = @id AND Password = @pwd";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", adminID);
                        cmd.Parameters.AddWithValue("@pwd", password);

                        SqlDataReader reader = cmd.ExecuteReader();

                        if (reader.Read())
                        {
                            string name = reader["Name"].ToString();
                            string role = reader["Role"].ToString();
                            string permissions = reader["Permissions"].ToString();

                            MessageBox.Show($"Login successful! Welcome {name}");

                            AdminHomePage adminPage = new AdminHomePage(); 
                            this.Hide();
                            adminPage.Show();
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

        private void textBox4_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox10_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
