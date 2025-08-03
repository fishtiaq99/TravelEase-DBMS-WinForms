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

namespace DB_Project.Resources
{
    public partial class TourOperatorCreateTrip : Form
    {
        private int operatorID;
        public TourOperatorCreateTrip(int id)
        {
            InitializeComponent();
            operatorID = id;
        }

        private void TourOperatorCreateTrip_Load(object sender, EventArgs e)
        {
            textBox10.Text = operatorID.ToString();
            textBox10.ReadOnly = true;

            try
            {
                using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
                {
                    conn.Open();

                    string getTripIDQuery = @"
                SELECT ISNULL(MAX(TripID), 0) + 1 
                FROM Trip";

                    SqlCommand tripIdCmd = new SqlCommand(getTripIDQuery, conn);

                    int nextTripID = (int)tripIdCmd.ExecuteScalar();
                    textBox1.Text = nextTripID.ToString();
                    textBox1.ReadOnly = true;

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
            TourOperatorHomePage TOHP = new TourOperatorHomePage(operatorID);
            this.Hide();
            TOHP.Show();
        }

        private void label14_Click(object sender, EventArgs e)
        {

        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void button4_Click(object sender, EventArgs e)
        {
            try
            {
                // Input collection from text fields
                int tripId = int.Parse(textBox1.Text.Trim());
                string title = textBox9.Text.Trim();
                decimal price = decimal.Parse(textBox8.Text.Trim());
                int capacity = int.Parse(textBox4.Text.Trim());
                string description = textBox6.Text.Trim();
                string passesDescription = textBox3.Text.Trim();
                string tripStatus = textBox7.Text.Trim();
                int availableSlots = int.Parse(textBox11.Text.Trim());
                int groupSize = int.Parse(textBox5.Text.Trim());
                decimal rating = decimal.Parse(textBox2.Text.Trim());

                DateTime startDate = dateTimePicker1.Value.Date;
                DateTime endDate = dateTimePicker2.Value.Date;
                int duration = (endDate - startDate).Days;

                // Example ServiceProviderID - you can prompt or select this elsewhere
                int serviceProviderId = 1;

                // Basic validation
                if (string.IsNullOrWhiteSpace(title) ||
                    string.IsNullOrWhiteSpace(description) ||
                    string.IsNullOrWhiteSpace(passesDescription) ||
                    string.IsNullOrWhiteSpace(tripStatus))
                {
                    MessageBox.Show("Please fill in all text fields.");
                    return;
                }

                if (startDate >= endDate)
                {
                    MessageBox.Show("Start Date must be before End Date.");
                    return;
                }

                if (price < 0 || capacity <= 0 || availableSlots < 0 || groupSize <= 0 || rating < 0)
                {
                    MessageBox.Show("Please ensure that price, capacity, available slots, group size, and rating are valid non-negative numbers.");
                    return;
                }

                using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
                {
                    conn.Open();

                    // Optional: Check for existing TripID
                    using (SqlCommand checkCmd = new SqlCommand("SELECT COUNT(*) FROM Trip WHERE TripID = @TripID", conn))
                    {
                        checkCmd.Parameters.AddWithValue("@TripID", tripId);
                        int count = (int)checkCmd.ExecuteScalar();
                        if (count > 0)
                        {
                            MessageBox.Show("TripID already exists. Please use a different ID.");
                            return;
                        }
                    }

                    // Start transaction
                    SqlTransaction transaction = conn.BeginTransaction();

                    try
                    {
                        // Insert into Trip
                        string insertTripQuery = @"
                    INSERT INTO Trip (
                        TripID, OperatorID, Title, Price, Capacity, TripType, Description,
                        PassesDescription, StartDate, EndDate, Duration, TripStatus,
                        AvailableSlots, GroupSize, Rating
                    )
                    VALUES (
                        @TripID, @OperatorID, @Title, @Price, @Capacity, @TripType, @Description,
                        @PassesDescription, @StartDate, @EndDate, @Duration, @TripStatus,
                        @AvailableSlots, @GroupSize, @Rating
                    );";

                        SqlCommand tripCmd = new SqlCommand(insertTripQuery, conn, transaction);
                        tripCmd.Parameters.AddWithValue("@TripID", tripId);
                        tripCmd.Parameters.AddWithValue("@OperatorID", operatorID); // Make sure operatorID is defined in your class
                        tripCmd.Parameters.AddWithValue("@Title", title);
                        tripCmd.Parameters.AddWithValue("@Price", price);
                        tripCmd.Parameters.AddWithValue("@Capacity", capacity);
                        tripCmd.Parameters.AddWithValue("@TripType", "Adventure"); // Optional: make dynamic
                        tripCmd.Parameters.AddWithValue("@Description", description);
                        tripCmd.Parameters.AddWithValue("@PassesDescription", passesDescription);
                        tripCmd.Parameters.AddWithValue("@StartDate", startDate);
                        tripCmd.Parameters.AddWithValue("@EndDate", endDate);
                        tripCmd.Parameters.AddWithValue("@Duration", duration);
                        tripCmd.Parameters.AddWithValue("@TripStatus", tripStatus);
                        tripCmd.Parameters.AddWithValue("@AvailableSlots", availableSlots);
                        tripCmd.Parameters.AddWithValue("@GroupSize", groupSize);
                        tripCmd.Parameters.AddWithValue("@Rating", rating);

                        tripCmd.ExecuteNonQuery();

                        // Insert into TripInvolves
                        string insertInvolvesQuery = @"
                    INSERT INTO TripInvolves (TripID, ServiceProviderID, Role)
                    VALUES (@TripID, @ServiceProviderID, @Role);";

                        SqlCommand involvesCmd = new SqlCommand(insertInvolvesQuery, conn, transaction);
                        involvesCmd.Parameters.AddWithValue("@TripID", tripId);
                        involvesCmd.Parameters.AddWithValue("@ServiceProviderID", serviceProviderId);
                        involvesCmd.Parameters.AddWithValue("@Role", "Hotel"); // Optional: Make this dynamic too

                        involvesCmd.ExecuteNonQuery();

                        transaction.Commit();
                        MessageBox.Show("Trip successfully created!");
                    }
                    catch (Exception ex)
                    {
                        transaction.Rollback();
                        MessageBox.Show("Error while creating trip: " + ex.Message);
                    }
                }
            }
            catch (FormatException)
            {
                MessageBox.Show("Please enter valid numeric values where required.");
            }
            catch (Exception ex)
            {
                MessageBox.Show("Unexpected error: " + ex.Message);
            }
        }

        private void textBox9_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox8_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox4_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox6_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox3_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox7_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox11_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox5_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox2_TextChanged(object sender, EventArgs e)
        {

        }

        private void dateTimePicker1_ValueChanged(object sender, EventArgs e)
        {

        }

        private void dateTimePicker2_ValueChanged(object sender, EventArgs e)
        {

        }

        private void textBox10_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
