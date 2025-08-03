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

namespace DB_Project.Resources
{
    public partial class TravelerReview : Form
    {
        private int travelerID;
        public TravelerReview(int Id)
        {
            InitializeComponent();
            travelerID = Id;
        }
        private void TravelerReview_Load(object sender, EventArgs e)
        {
            textBox10.Text = travelerID.ToString();
            textBox10.ReadOnly = true;

            try
            {
                using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
                {
                    conn.Open();

                    string getReviewIDQuery = @"
                    SELECT ISNULL(MAX(ReviewID), 0) + 1 
                    FROM Review ";

                    SqlCommand reviewCmd = new SqlCommand(getReviewIDQuery, conn);
                    reviewCmd.Parameters.AddWithValue("@TravelerID", travelerID);

                    int nextReviewID = (int)reviewCmd.ExecuteScalar();
                    textBox4.Text = nextReviewID.ToString();
                    textBox4.ReadOnly = true;


                    conn.Close();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message);
            }


        }
        private void button5_Click(object sender, EventArgs e)
        {
            TravelerHomePage THP = new TravelerHomePage(travelerID);
            this.Hide();
            THP.Show();
        }

        private void button4_Click(object sender, EventArgs e)
        {
            int reviewID = int.Parse(textBox4.Text); // Auto-generated reviewID
            int tripID;
            int rating;
            string comments = textBox3.Text;

            // Validate inputs
            if (!int.TryParse(textBox1.Text, out tripID) ||
                !int.TryParse(textBox2.Text, out rating) ||
                string.IsNullOrWhiteSpace(comments))
            {
                MessageBox.Show("Please fill all fields correctly.");
                return;
            }

            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                conn.Open();

                // 1. Check if the traveler has a confirmed booking for the trip
                string checkBookingQuery = @"
            SELECT COUNT(*) 
            FROM Booking 
            WHERE TravelerID = @TravelerID AND TripID = @TripID AND BookingStatus = 'Confirmed'";

                using (SqlCommand checkBookingCmd = new SqlCommand(checkBookingQuery, conn))
                {
                    checkBookingCmd.Parameters.AddWithValue("@TravelerID", travelerID);
                    checkBookingCmd.Parameters.AddWithValue("@TripID", tripID);

                    int bookingExists = (int)checkBookingCmd.ExecuteScalar();

                    if (bookingExists == 0)
                    {
                        MessageBox.Show("You can only review trips you've actually booked.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return;
                    }
                }

                // 2. Check if a review already exists
                string checkReviewQuery = @"
            SELECT COUNT(*) 
            FROM Review 
            WHERE TravelerID = @TravelerID AND TripID = @TripID";

                using (SqlCommand checkReviewCmd = new SqlCommand(checkReviewQuery, conn))
                {
                    checkReviewCmd.Parameters.AddWithValue("@TravelerID", travelerID);
                    checkReviewCmd.Parameters.AddWithValue("@TripID", tripID);

                    int reviewExists = (int)checkReviewCmd.ExecuteScalar();

                    if (reviewExists > 0)
                    {
                        MessageBox.Show("You have already submitted a review for this trip.", "Review Exists", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        return;
                    }
                }

                // 3. Insert the review
                string insertQuery = @"
            INSERT INTO Review (ReviewID, TravelerID, TripID, Rating, Comments, ReviewDate)
            VALUES (@ReviewID, @TravelerID, @TripID, @Rating, @Comments, @ReviewDate)";

                using (SqlCommand insertCmd = new SqlCommand(insertQuery, conn))
                {
                    insertCmd.Parameters.AddWithValue("@ReviewID", reviewID);
                    insertCmd.Parameters.AddWithValue("@TravelerID", travelerID);
                    insertCmd.Parameters.AddWithValue("@TripID", tripID);
                    insertCmd.Parameters.AddWithValue("@Rating", rating);
                    insertCmd.Parameters.AddWithValue("@Comments", comments);
                    insertCmd.Parameters.AddWithValue("@ReviewDate", DateTime.Now.Date);

                    int rowsAffected = insertCmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        MessageBox.Show("Review submitted successfully!", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                    else
                    {
                        MessageBox.Show("Failed to submit review.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }

                conn.Close();
            }
        }





        private void textBox10_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox4_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox2_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox3_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
