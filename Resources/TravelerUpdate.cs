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
using System.Xml.Linq;

namespace DB_Project.Resources
{
    public partial class TravelerUpdate : Form
    {
        private int travelerID;
        public TravelerUpdate(int id)
        {

            InitializeComponent();
            travelerID = id;
        }
        private void TravelerUpdate_Load(object sender, EventArgs e)
        {
            textBox1.Text = travelerID.ToString();
            textBox1.ReadOnly = true;

            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                conn.Open();

                SqlCommand cmd = new SqlCommand(@"
            SELECT Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes
            FROM Traveler
            WHERE TravelerID = @TravelerID", conn);
                cmd.Parameters.AddWithValue("@TravelerID", travelerID);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        textBox9.Text = reader["Name"].ToString();
                        textBox10.Text = reader["Password"].ToString();
                        textBox8.Text = reader["Address"].ToString();
                        comboBox1.Text = reader["Gender"].ToString();
                        comboBox3.Text = reader["Nationality"].ToString();
                        dateTimePicker1.Value = Convert.ToDateTime(reader["DOB"]);
                        textBox7.Text = reader["TravelHistory"].ToString();
                        textBox2.Text = reader["PreferredTripTypes"].ToString();
                    }
                }

                SqlCommand emailCmd = new SqlCommand("SELECT Email FROM TravelerEmail WHERE TravelerID = @TravelerID", conn);
                emailCmd.Parameters.AddWithValue("@TravelerID", travelerID);
                using (SqlDataReader reader = emailCmd.ExecuteReader())
                {
                    int count = 0;
                    while (reader.Read())
                    {
                        if (count == 0)
                            textBox4.Text = reader["Email"].ToString();
                        else if (count == 1)
                            textBox6.Text = reader["Email"].ToString();
                        count++;
                    }
                }

                SqlCommand phoneCmd = new SqlCommand("SELECT PhoneNumber FROM TravelerPhoneNumber WHERE TravelerID = @TravelerID", conn);
                phoneCmd.Parameters.AddWithValue("@TravelerID", travelerID);
                using (SqlDataReader reader = phoneCmd.ExecuteReader())
                {
                    int count = 0;
                    while (reader.Read())
                    {
                        if (count == 0)
                            textBox3.Text = reader["PhoneNumber"].ToString();
                        else if (count == 1)
                            textBox5.Text = reader["PhoneNumber"].ToString();
                        count++;
                    }
                }

                SqlCommand adminCmd = new SqlCommand(@"
            SELECT AdminManager 
            FROM Traveler
            WHERE TravelerID = @TravelerID", conn);
                adminCmd.Parameters.AddWithValue("@TravelerID", travelerID);

                object adminName = adminCmd.ExecuteScalar();
                if (adminName != null)
                {
                    textBox11.Text = adminName.ToString();  // Assuming textBox11 is for admin name
                }
                else
                {
                    textBox11.Text = "Not assigned";  // Optional fallback
                }
            }

            
        }


        private void button5_Click(object sender, EventArgs e)
        {
            TravelerHomePage THP = new TravelerHomePage(travelerID);
            this.Hide();
            THP.Show();
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void button4_Click(object sender, EventArgs e)
        {
            if (textBox10.Text.Length < 8 || !Regex.IsMatch(textBox10.Text, @"[A-Za-z]") ||
        !Regex.IsMatch(textBox10.Text, @"[0-9]") || !Regex.IsMatch(textBox10.Text, @"[!@#$%^&*()]"))
            {
                MessageBox.Show("Password must be 8+ chars, include a letter, number, and special character.");
                return;
            }

            if (!Regex.IsMatch(textBox4.Text, @"\S+@\S+\.\S+"))
            {
                MessageBox.Show("Primary Email is invalid.");
                return;
            }

            if (!Regex.IsMatch(textBox3.Text, @"^\d{11}$"))
            {
                MessageBox.Show("Primary Phone must be 11 digits.");
                return;
            }

            int travelerID = int.Parse(textBox1.Text);


            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                conn.Open();
                SqlTransaction tx = conn.BeginTransaction();

                try
                {
                    // Update Traveler
                    SqlCommand cmd = new SqlCommand(@"
            UPDATE Traveler SET
                Name = @Name,
                Password = @Password,
                Address = @Address,
                Gender = @Gender,
                Nationality = @Nationality,
                DOB = @DOB,
                TravelHistory = @TravelHistory,
                PreferredTripTypes = @TripType
            WHERE TravelerID = @TravelerID", conn, tx);

                    cmd.Parameters.AddWithValue("@TravelerID", travelerID);
                    cmd.Parameters.AddWithValue("@Name", textBox9.Text);
                    cmd.Parameters.AddWithValue("@Password", textBox10.Text);
                    cmd.Parameters.AddWithValue("@Address", textBox8.Text);
                    cmd.Parameters.AddWithValue("@Gender", comboBox1.Text);
                    cmd.Parameters.AddWithValue("@Nationality", comboBox3.Text);
                    cmd.Parameters.AddWithValue("@DOB", dateTimePicker1.Value);
                    cmd.Parameters.AddWithValue("@TravelHistory", textBox7.Text);
                    cmd.Parameters.AddWithValue("@TripType", textBox2.Text);
                    cmd.ExecuteNonQuery();

                    // Delete old emails
                    SqlCommand deleteEmails = new SqlCommand("DELETE FROM TravelerEmail WHERE TravelerID = @TravelerID", conn, tx);
                    deleteEmails.Parameters.AddWithValue("@TravelerID", travelerID);
                    deleteEmails.ExecuteNonQuery();

                    // Delete old phone numbers
                    SqlCommand deletePhones = new SqlCommand("DELETE FROM TravelerPhoneNumber WHERE TravelerID = @TravelerID", conn, tx);
                    deletePhones.Parameters.AddWithValue("@TravelerID", travelerID);
                    deletePhones.ExecuteNonQuery();

                    // Insert new emails
                    SqlCommand cmdEmail1 = new SqlCommand("INSERT INTO TravelerEmail VALUES (@Email, @TravelerID)", conn, tx);
                    cmdEmail1.Parameters.AddWithValue("@Email", textBox4.Text);
                    cmdEmail1.Parameters.AddWithValue("@TravelerID", travelerID);
                    cmdEmail1.ExecuteNonQuery();

                    if (!string.IsNullOrWhiteSpace(textBox6.Text))
                    {
                        SqlCommand cmdEmail2 = new SqlCommand("INSERT INTO TravelerEmail VALUES (@Email, @TravelerID)", conn, tx);
                        cmdEmail2.Parameters.AddWithValue("@Email", textBox6.Text);
                        cmdEmail2.Parameters.AddWithValue("@TravelerID", travelerID);
                        cmdEmail2.ExecuteNonQuery();
                    }

                    // Insert new phone numbers
                    SqlCommand cmdPhone1 = new SqlCommand("INSERT INTO TravelerPhoneNumber VALUES (@Phone, @TravelerID)", conn, tx);
                    cmdPhone1.Parameters.AddWithValue("@Phone", textBox3.Text);
                    cmdPhone1.Parameters.AddWithValue("@TravelerID", travelerID);
                    cmdPhone1.ExecuteNonQuery();

                    if (!string.IsNullOrWhiteSpace(textBox5.Text))
                    {
                        SqlCommand cmdPhone2 = new SqlCommand("INSERT INTO TravelerPhoneNumber VALUES (@Phone, @TravelerID)", conn, tx);
                        cmdPhone2.Parameters.AddWithValue("@Phone", textBox5.Text);
                        cmdPhone2.Parameters.AddWithValue("@TravelerID", travelerID);
                        cmdPhone2.ExecuteNonQuery();
                    }

                    tx.Commit();
                    MessageBox.Show("Traveler info updated successfully!");
                }
                catch (Exception ex)
                {
                    tx.Rollback();
                    MessageBox.Show("Update failed: " + ex.Message);
                }
            }

        }

        private void textBox10_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox4_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox3_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox9_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox8_TextChanged(object sender, EventArgs e)
        {

        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void comboBox3_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void dateTimePicker1_ValueChanged(object sender, EventArgs e)
        {

        }

        private void textBox7_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox2_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox6_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox5_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
