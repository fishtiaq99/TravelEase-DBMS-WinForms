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
    public partial class TravelerQueryPage : Form
    {
        private int travelerID;
        public TravelerQueryPage(int id)
        {
            InitializeComponent();
            travelerID = id;
        }


        private void TravelerQueryPage_Load(object sender, EventArgs e)
        {
            // TODO: This line of code loads data into the 'travelEaseDataSet17.Inquiries' table. You can move, or remove it, as needed.
            this.inquiriesTableAdapter.Fill(this.travelEaseDataSet17.Inquiries);
            try
            {
                using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
                {
                    conn.Open();

                    // Get the next TravelerID (max + 1, or 1 if table is empty)
                    string getTravelerIDQuery = "SELECT ISNULL(MAX(InquiryID), 0) + 1 FROM Inquiries";
                    SqlCommand travelerCmd = new SqlCommand(getTravelerIDQuery, conn);
                    int nextTravelerID = (int)travelerCmd.ExecuteScalar();
                    textBox4.Text = nextTravelerID.ToString();
                    textBox4.ReadOnly = true; // Optional: Make it non-editable


                    textBox10.Text = travelerID.ToString();
                    textBox10.ReadOnly = true; // Optional: Make it non-editable

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

        private void textBox4_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox10_TextChanged(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            // Read input values from textboxes
            int inquiryId = int.Parse(textBox4.Text);
            int travelerId = int.Parse(textBox10.Text);
            string queryText = textBox1.Text;
            int bookingId = int.Parse(textBox2.Text);

            if (!int.TryParse(textBox2.Text, out bookingId))
            {
                MessageBox.Show("Invalid Booking ID.");
                return;
            }

            if (string.IsNullOrWhiteSpace(queryText))
            {
                MessageBox.Show("Please enter a query.");
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
                {
                    conn.Open();

                    // Check if the booking exists and belongs to the traveler
                    string checkBookingQuery = "SELECT COUNT(*) FROM Booking WHERE BookingID = @BookingID AND TravelerID = @TravelerID";
                    using (SqlCommand checkCmd = new SqlCommand(checkBookingQuery, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@BookingID", bookingId);
                        checkCmd.Parameters.AddWithValue("@TravelerID", travelerId);

                        int count = (int)checkCmd.ExecuteScalar();
                        if (count == 0)
                        {
                            MessageBox.Show("No such booking found for this traveler.");
                            return;
                        }
                    }

                    // Get the Tour Operator ID from Trip table via Booking
                    string getOperatorQuery = @"
                        SELECT t.OperatorID, b.TripID
                        FROM Booking b
                        JOIN Trip t ON b.TripID = t.TripID
                        WHERE b.BookingID = @BookingID AND b.TravelerID = @TravelerID";

                    int tourOperatorId;
                    int tripId;
                    using (SqlCommand getOpCmd = new SqlCommand(getOperatorQuery, conn))
                    {
                        getOpCmd.Parameters.AddWithValue("@BookingID", bookingId);
                        getOpCmd.Parameters.AddWithValue("@TravelerID", travelerId);

                        using (SqlDataReader reader = getOpCmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                tourOperatorId = reader.GetInt32(reader.GetOrdinal("OperatorID"));
                                tripId = reader.GetInt32(reader.GetOrdinal("TripID"));
                            }
                            else
                            {
                                MessageBox.Show("Could not find the Tour Operator or Trip for this booking.");
                                return;
                            }
                        }
                    }

                    // Insert the new inquiry
                    string insertQuery = @"
                INSERT INTO Inquiries (InquiryID, TravelerID, BookingID, InquiryTime, TourOperatorID, ResponseTime, Query, TripID)
                VALUES (@InquiryID, @TravelerID, @BookingID, @InquiryTime, @TourOperatorID, NULL, @Query, @TripID)";

                    using (SqlCommand insertCmd = new SqlCommand(insertQuery, conn))
                    {
                        insertCmd.Parameters.AddWithValue("@InquiryID", inquiryId);
                        insertCmd.Parameters.AddWithValue("@TravelerID", travelerId);
                        insertCmd.Parameters.AddWithValue("@BookingID", bookingId);
                        insertCmd.Parameters.AddWithValue("@InquiryTime", DateTime.Now);
                        insertCmd.Parameters.AddWithValue("@TourOperatorID", tourOperatorId);
                        insertCmd.Parameters.AddWithValue("@Query", queryText);
                        insertCmd.Parameters.AddWithValue("@TripID", tripId); // Add TripID

                        int rowsAffected = insertCmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            MessageBox.Show("Inquiry submitted successfully.");
                        }
                        else
                        {
                            MessageBox.Show("Failed to submit inquiry.");
                        }
                    }

                    conn.Close();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message);
            }
        }

        private void textBox2_TextChanged(object sender, EventArgs e)
        {

        }

        private void button2_Click(object sender, EventArgs e)
        {
            dataGridView1.Visible = true; // Show the hidden DataGridView

            try
            {
                using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
                {
                    conn.Open();

                    // Load all inquiries for the current traveler
                    string query = @"
                SELECT InquiryID, BookingID, TourOperatorID, InquiryTime, ResponseTime, Query, Response
                FROM Inquiries
                WHERE TravelerID = @TravelerID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@TravelerID", travelerID);
                        SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                        DataTable table = new DataTable();
                        adapter.Fill(table);
                        dataGridView1.DataSource = table;
                    }

                    conn.Close();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error loading inquiries: " + ex.Message);
            }
        }


        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }
    }
}
