using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Xml.Linq;

namespace DB_Project
{
    public partial class Travelersignup : Form
    {
        public Travelersignup()
        {
            InitializeComponent();
        }

        private void Travelersignup_Load(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
                {
                    conn.Open();

                    // Get the next TravelerID (max + 1, or 1 if table is empty)
                    string getTravelerIDQuery = "SELECT ISNULL(MAX(TravelerID), 0) + 1 FROM Traveler";
                    SqlCommand travelerCmd = new SqlCommand(getTravelerIDQuery, conn);
                    int nextTravelerID = (int)travelerCmd.ExecuteScalar();
                    textBox1.Text = nextTravelerID.ToString();
                    textBox1.ReadOnly = true; // Optional: Make it non-editable


                    // Get a random AdminID from the Admin table
                    string getAdminIDQuery = "SELECT TOP 1 AdminID FROM Admin ORDER BY NEWID()";
                    SqlCommand adminCmd = new SqlCommand(getAdminIDQuery, conn);
                    int randomAdminID = (int)adminCmd.ExecuteScalar();
                    textBox11.Text = randomAdminID.ToString();
                    textBox11.ReadOnly = true; // Optional: Make it non-editable

                    conn.Close();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message);
            }
        }

        SqlConnection conn = new SqlConnection(DB_Config.ConnectionString);

        private void label12_Click(object sender, EventArgs e)
        {
            TravelerLoginPage TLP = new TravelerLoginPage();
            this.Hide();
            TLP.Show();
        }

        private void button5_Click(object sender, EventArgs e)
        {
            WebsiteHomePage WHP = new WebsiteHomePage();
            this.Hide();
            WHP.Show();
        }

        private void button4_Click(object sender, EventArgs e)
        {
            int travelerID = int.Parse(textBox1.Text);
            string name = textBox9.Text;
            string password = textBox10.Text;
            string address = textBox8.Text;
            string gender = comboBox1.SelectedItem?.ToString();
            string nationality = comboBox3.SelectedItem?.ToString();
            DateTime dob = dateTimePicker1.Value;
            string travelHistory = textBox7.Text;
            string preferredTrips = textBox2.Text;
            string email1 = textBox4.Text;
            string phone = textBox3.Text;
            int adminManager = int.Parse(textBox11.Text);

            if (string.IsNullOrWhiteSpace(name) || password.Length <= 8 || !password.Any(char.IsDigit) || !password.Any(char.IsLetter) || !password.Any(c => "!@#$%^&*()_+-=[]{};\":,.<>?".Contains(c)))
            {
                MessageBox.Show("Please enter a strong password with letters, numbers, and a special character (min 9 chars).", "Validation Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (!email1.Contains("@") || !email1.Contains("."))
            {
                MessageBox.Show("Invalid primary email format.", "Validation Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (phone.Length != 11 || !phone.All(char.IsDigit))
            {
                MessageBox.Show("Phone number must be 11 digits.", "Validation Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (gender == null || nationality == null)
            {
                MessageBox.Show("Please select both gender and nationality.", "Validation Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                try
                {
                    conn.Open();


                    string travelerInsert = @"INSERT INTO Traveler (TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes, AdminManager)
                                      VALUES (@TravelerID, @Name, @Password, @Address, @Gender, @Nationality, @DOB, @History, @Trips, @AdminID)";
                    SqlCommand travelerCmd = new SqlCommand(travelerInsert, conn);
                    travelerCmd.Parameters.AddWithValue("@TravelerID", travelerID);
                    travelerCmd.Parameters.AddWithValue("@Name", name);
                    travelerCmd.Parameters.AddWithValue("@Password", password);
                    travelerCmd.Parameters.AddWithValue("@Address", address);
                    travelerCmd.Parameters.AddWithValue("@Gender", gender);
                    travelerCmd.Parameters.AddWithValue("@Nationality", nationality);
                    travelerCmd.Parameters.AddWithValue("@DOB", dob);
                    travelerCmd.Parameters.AddWithValue("@History", travelHistory);
                    travelerCmd.Parameters.AddWithValue("@Trips", preferredTrips);
                    travelerCmd.Parameters.AddWithValue("@AdminID", adminManager);
                    travelerCmd.ExecuteNonQuery();

                    string emailInsert = @"INSERT INTO TravelerEmail (Email, TravelerID)
                                   VALUES (@Email, @TravelerID)";
                    SqlCommand emailCmd = new SqlCommand(emailInsert, conn);
                    emailCmd.Parameters.AddWithValue("@Email", email1);
                    emailCmd.Parameters.AddWithValue("@TravelerID", travelerID);
                    emailCmd.ExecuteNonQuery();

                    string phoneInsert = @"INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID)
                                   VALUES (@Phone, @TravelerID)";
                    SqlCommand phoneCmd = new SqlCommand(phoneInsert, conn);
                    phoneCmd.Parameters.AddWithValue("@Phone", phone);
                    phoneCmd.Parameters.AddWithValue("@TravelerID", travelerID);
                    phoneCmd.ExecuteNonQuery();
                    ////
                    string secondaryEmail = textBox6.Text;
                    if (!string.IsNullOrWhiteSpace(secondaryEmail))
                    {
                        if (!secondaryEmail.Contains("@") || !secondaryEmail.Contains("."))
                        {
                            MessageBox.Show("Invalid secondary email format.", "Validation Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                            return;
                        }

                        string secondaryEmailInsert = @"INSERT INTO TravelerEmail (Email, TravelerID)
                                    VALUES (@Email, @TravelerID)";
                        SqlCommand secEmailCmd = new SqlCommand(secondaryEmailInsert, conn);
                        secEmailCmd.Parameters.AddWithValue("@Email", secondaryEmail);
                        secEmailCmd.Parameters.AddWithValue("@TravelerID", travelerID);
                        secEmailCmd.ExecuteNonQuery();
                    }

                    string secondaryPhone = textBox5.Text;
                    if (!string.IsNullOrWhiteSpace(secondaryPhone))
                    {
                        if (secondaryPhone.Length != 11 || !secondaryPhone.All(char.IsDigit))
                        {
                            MessageBox.Show("Secondary phone number must be 11 digits.", "Validation Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                            return;
                        }

                        string secondaryPhoneInsert = @"INSERT INTO TravelerPhoneNumber (PhoneNumber, TravelerID)
                                    VALUES (@Phone, @TravelerID)";
                        SqlCommand secPhoneCmd = new SqlCommand(secondaryPhoneInsert, conn);
                        secPhoneCmd.Parameters.AddWithValue("@Phone", secondaryPhone);
                        secPhoneCmd.Parameters.AddWithValue("@TravelerID", travelerID);
                        secPhoneCmd.ExecuteNonQuery();
                    }

                    MessageBox.Show("Signup completed successfully!", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);


                    
                    TravelerHomePage THP = new TravelerHomePage(travelerID);
                    this.Hide();
                    THP.Show();
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

        private void label16_Click(object sender, EventArgs e)
        {

        }

        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void textBox7_TextChanged(object sender, EventArgs e)
        {

        }

        private void label15_Click(object sender, EventArgs e)
        {

        }

        private void label14_Click(object sender, EventArgs e)
        {

        }

        private void label13_Click(object sender, EventArgs e)
        {

        }

        private void dateTimePicker1_ValueChanged(object sender, EventArgs e)
        {

        }

        private void comboBox3_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void textBox10_TextChanged(object sender, EventArgs e)
        {

        }

        private void label11_Click(object sender, EventArgs e)
        {

        }

        private void textBox9_TextChanged(object sender, EventArgs e)
        {

        }

        private void label10_Click(object sender, EventArgs e)
        {

        }

        private void textBox8_TextChanged(object sender, EventArgs e)
        {

        }

        private void label9_Click(object sender, EventArgs e)
        {

        }

        private void textBox11_TextChanged(object sender, EventArgs e)
        {

        }

        private void label8_Click(object sender, EventArgs e)
        {

        }

        private void textBox6_TextChanged(object sender, EventArgs e)
        {

        }

        private void label7_Click(object sender, EventArgs e)
        {

        }

        private void textBox5_TextChanged(object sender, EventArgs e)
        {

        }

        private void label6_Click(object sender, EventArgs e)
        {

        }

        private void textBox4_TextChanged(object sender, EventArgs e)
        {

        }

        private void label5_Click(object sender, EventArgs e)
        {

        }

        private void textBox3_TextChanged(object sender, EventArgs e)
        {

        }

        private void label4_Click(object sender, EventArgs e)
        {

        }

        private void textBox2_TextChanged(object sender, EventArgs e)
        {

        }

        private void label3_Click(object sender, EventArgs e)
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