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
    public partial class TourOperatorSignup : Form
    {
        public TourOperatorSignup()
        {
            InitializeComponent();
        }

        private void TourOperatorSignup_Load(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
                {
                    conn.Open();

                    // Get the next OperatorID (max + 1, or 1 if table is empty)
                    string getOperatorIDQuery = "SELECT ISNULL(MAX(OperatorID), 0) + 1 FROM TourOperator";
                    SqlCommand operatorCmd = new SqlCommand(getOperatorIDQuery, conn);
                    int nextOperatorID = (int)operatorCmd.ExecuteScalar();
                    textBox1.Text = nextOperatorID.ToString();
                    textBox1.ReadOnly = true;

                    // Get a random AdminID from the Admin table
                    string getAdminIDQuery = "SELECT TOP 1 AdminID FROM Admin ORDER BY NEWID()";
                    SqlCommand adminCmd = new SqlCommand(getAdminIDQuery, conn);
                    int randomAdminID = (int)adminCmd.ExecuteScalar();
                    textBox2.Text = randomAdminID.ToString();
                    textBox2.ReadOnly = true;

                    conn.Close();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error loading form: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }


        SqlConnection conn = new SqlConnection(DB_Config.ConnectionString);

        private void button5_Click(object sender, EventArgs e)
        {
            WebsiteHomePage WHP = new WebsiteHomePage();
            this.Hide();
            WHP.Show();
        }

        private void label12_Click(object sender, EventArgs e)
        {
            TourOperatorLogin TOL = new TourOperatorLogin();
            this.Hide();
            TOL.Show();
        }

        private void button4_Click(object sender, EventArgs e)
        {
            int operatorID = int.Parse(textBox1.Text);
            int adminID = int.Parse(textBox2.Text);
            string companyName = textBox9.Text;
            string companyAddress = textBox5.Text;
            string contactPhone = textBox3.Text;
            string contactEmail = textBox4.Text;
            string password = textBox10.Text;
            string tripsOffered = textBox7.Text;

            // --- Input Validations ---
            if (string.IsNullOrWhiteSpace(companyName) || string.IsNullOrWhiteSpace(companyAddress))
            {
                MessageBox.Show("Company Name and Address are required.", "Validation Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (password.Length <= 8 || !password.Any(char.IsDigit) || !password.Any(char.IsLetter) || !password.Any(c => "!@#$%^&*()_+-=[]{};\":,.<>?".Contains(c)))
            {
                MessageBox.Show("Password must be strong (min 9 characters, including letters, numbers, and a special character).", "Validation Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (!contactEmail.Contains("@") || !contactEmail.Contains("."))
            {
                MessageBox.Show("Invalid primary email format.", "Validation Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (contactPhone.Length != 11 || !contactPhone.All(char.IsDigit))
            {
                MessageBox.Show("Phone number must be 11 digits.", "Validation Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // --- Database Insert ---
            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                try
                {
                    conn.Open();

                    string operatorInsert = @"INSERT INTO TourOperator 
            (OperatorID, AdminID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, Password, TripsOffered)
            VALUES (@OperatorID, @AdminID, @CompanyName, @CompanyAddress, @ContactPhone, @ContactEmail, @Password, @TripsOffered)";

                    SqlCommand cmd = new SqlCommand(operatorInsert, conn);
                    cmd.Parameters.AddWithValue("@OperatorID", operatorID);
                    cmd.Parameters.AddWithValue("@AdminID", adminID);
                    cmd.Parameters.AddWithValue("@CompanyName", companyName);
                    cmd.Parameters.AddWithValue("@CompanyAddress", companyAddress);
                    cmd.Parameters.AddWithValue("@ContactPhone", contactPhone);
                    cmd.Parameters.AddWithValue("@ContactEmail", contactEmail);
                    cmd.Parameters.AddWithValue("@Password", password);
                    cmd.Parameters.AddWithValue("@TripsOffered", tripsOffered);
                    cmd.ExecuteNonQuery();

                    MessageBox.Show("Tour Operator signup completed successfully!", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);

                    TourOperatorHomePage topPage = new TourOperatorHomePage(operatorID);
                    this.Hide();
                    topPage.Show();
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Error during signup: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
                finally
                {
                    conn.Close();
                }
            }
        }

        private void textBox9_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox10_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox9_TextChanged_1(object sender, EventArgs e)
        {

        }
    }
}