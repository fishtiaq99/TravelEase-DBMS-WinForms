using DB_Project.Resources;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace DB_Project
{
    public partial class TourOperatorUpdate : Form
    {
        private int operatorID;
        public TourOperatorUpdate(int id)
        {
            InitializeComponent();
            operatorID = id;
        }

        private void button5_Click(object sender, EventArgs e)
        {
            TourOperatorHomePage TOHP = new TourOperatorHomePage(operatorID);
            this.Hide();
            TOHP.Show();
        }

        private void button4_Click(object sender, EventArgs e)
        {
            if (textBox10.Text.Length < 8 ||
                !Regex.IsMatch(textBox10.Text, @"[A-Za-z]") ||
                !Regex.IsMatch(textBox10.Text, @"[0-9]"))
            {
                MessageBox.Show("Password must be 8+ chars, include a letter, number, and special character.");
                return;
            }

            if (!Regex.IsMatch(textBox3.Text, @"\S+@\S+\.\S+"))
            {
                MessageBox.Show("Contact Email is invalid.");
                return;
            }

            if (!Regex.IsMatch(textBox4.Text, @"^\d{11}$"))
            {
                MessageBox.Show("Phone number must be 11 digits.");
                return;
            }

            int operatorID = int.Parse(textBox1.Text);

            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                conn.Open();

                try
                {
                    SqlCommand cmd = new SqlCommand(@"
                UPDATE TourOperator SET
                    AdminID = @AdminID,
                    CompanyName = @CompanyName,
                    CompanyAddress = @CompanyAddress,
                    ContactPhone = @ContactPhone,
                    ContactEmail = @ContactEmail,
                    Password = @Password,
                    TripsOffered = @TripsOffered
                WHERE OperatorID = @OperatorID", conn);

                    cmd.Parameters.AddWithValue("@OperatorID", operatorID);
                    cmd.Parameters.AddWithValue("@AdminID", textBox5.Text);
                    cmd.Parameters.AddWithValue("@CompanyName", textBox7.Text);
                    cmd.Parameters.AddWithValue("@CompanyAddress", textBox2.Text);
                    cmd.Parameters.AddWithValue("@ContactPhone", textBox4.Text);
                    cmd.Parameters.AddWithValue("@ContactEmail", textBox3.Text);
                    cmd.Parameters.AddWithValue("@Password", textBox10.Text);
                    cmd.Parameters.AddWithValue("@TripsOffered", textBox11.Text);

                    int rows = cmd.ExecuteNonQuery();
                    if (rows > 0)
                        MessageBox.Show("Tour Operator information updated successfully!");
                    else
                        MessageBox.Show("No rows updated. Check if OperatorID exists.");
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Update failed: " + ex.Message);
                }
            }
        }


        private void TourOperatorUpdate_Load(object sender, EventArgs e)
        {
            textBox1.Text = operatorID.ToString(); // Display OperatorID
            textBox1.ReadOnly = true;

            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                conn.Open();

                SqlCommand cmd = new SqlCommand(@"
            SELECT CompanyName, Password, CompanyAddress, ContactPhone, ContactEmail, TripsOffered, AdminID
            FROM TourOperator
            WHERE OperatorID = @OperatorID", conn);
                cmd.Parameters.AddWithValue("@OperatorID", operatorID);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        textBox7.Text = reader["CompanyName"].ToString();       // Company Name
                        textBox10.Text = reader["Password"].ToString();         // Password
                        textBox2.Text = reader["CompanyAddress"].ToString();    // Address
                        textBox4.Text = reader["ContactPhone"].ToString();      // Phone
                        textBox3.Text = reader["ContactEmail"].ToString();      // Email
                        textBox11.Text = reader["TripsOffered"].ToString();      // Trips
                        textBox5.Text = reader["AdminID"] != DBNull.Value ? reader["AdminID"].ToString() : "Not assigned";  // AdminID
                    }
                }
            }
        }

        private void textBox7_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox10_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox2_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox4_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox3_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox11_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox5_TextChanged(object sender, EventArgs e)
        {

        }

        private void label6_Click(object sender, EventArgs e)
        {

        }

        private void label3_Click(object sender, EventArgs e)
        {

        }

        private void label16_Click(object sender, EventArgs e)
        {

        }

        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void label14_Click(object sender, EventArgs e)
        {

        }

        private void label11_Click(object sender, EventArgs e)
        {

        }

        private void label5_Click(object sender, EventArgs e)
        {

        }

        private void label4_Click(object sender, EventArgs e)
        {

        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void Heading_Click(object sender, EventArgs e)
        {

        }
    }
}
