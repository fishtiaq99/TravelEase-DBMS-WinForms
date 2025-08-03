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
    public partial class TravelerLoginPage : Form
    {
        public TravelerLoginPage()
        {
            InitializeComponent();
        }

        private void Heading_Click(object sender, EventArgs e)
        {

        }

        private void TravelerLoginPage_Load(object sender, EventArgs e)
        {

        }

        private void textBox2_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void LabelSignup_Click(object sender, EventArgs e)
        {
            Travelersignup TSP = new Travelersignup();
            this.Hide();
            TSP.Show();

        }

        private void button5_Click(object sender, EventArgs e)
        {
            WebsiteHomePage WHP = new WebsiteHomePage();
            this.Hide();
            WHP.Show();
        }

        private void button4_Click(object sender, EventArgs e)
        {
            string inputEmail = textBox4.Text;
            string inputPassword = textBox10.Text;

            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                conn.Open();
                string query = @"
        SELECT T.Password, T.TravelerID 
        FROM Traveler T
        INNER JOIN TravelerEmail TE ON T.TravelerID = TE.TravelerID
        WHERE TE.Email = @Email
    ";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Email", inputEmail);

                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    string dbPassword = reader["Password"].ToString();
                    int travelerID = Convert.ToInt32(reader["TravelerID"]);

                    if (dbPassword == inputPassword)
                    {
                        reader.Close();
                        TravelerHomePage THP = new TravelerHomePage(travelerID);
                        this.Hide();
                        THP.Show();
                    }
                    else
                    {
                        reader.Close();
                        MessageBox.Show("Incorrect Password", "Login Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
                else
                {
                    MessageBox.Show("Incorrect email", "Login Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }

                conn.Close();
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
