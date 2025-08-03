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
using System.Windows.Forms.VisualStyles;

namespace DB_Project.Resources
{
    
    public partial class TravelerBooking : Form
    {
        private int TravelerID;
        public TravelerBooking(int id)
        {
            InitializeComponent();
            TravelerID = id;
        }

        private void TravelerBooking_Load(object sender, EventArgs e)
        {
            // TODO: This line of code loads data into the 'travelEaseDataSet6.Booking' table. You can move, or remove it, as needed.
            this.bookingTableAdapter.Fill(this.travelEaseDataSet6.Booking);
            textBox2.Text = TravelerID.ToString();
            textBox2.ReadOnly = true;

        }

        private void button5_Click(object sender, EventArgs e)
        {
            TravelerHomePage THP = new TravelerHomePage(TravelerID);
            this.Hide();
            THP.Show();
        }

        private void textBox2_TextChanged(object sender, EventArgs e)
        {

        }

        private void button2_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(textBox2.Text, out int travelerID) ||
                !int.TryParse(textBox1.Text, out int tripID))
            {
                MessageBox.Show("Please enter valid numeric values for Traveler ID and Trip ID.",
                                "Invalid Input", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                try
                {
                    conn.Open();

                    // Step 1: Check if booking exists for given traveler and trip
                    string bookingQuery = @"
                SELECT BookingID, PaymentStatus 
                FROM Booking 
                WHERE TravelerID = @TravelerID AND TripID = @TripID";

                    int bookingID = -1;
                    string fallbackPaymentStatus = null;

                    using (SqlCommand cmd = new SqlCommand(bookingQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@TravelerID", travelerID);
                        cmd.Parameters.AddWithValue("@TripID", tripID);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                bookingID = reader.GetInt32(0);
                                fallbackPaymentStatus = reader.GetString(1);
                            }
                            else
                            {
                                MessageBox.Show("No booking found for this trip by the traveler.",
                                                "Booking Not Found", MessageBoxButtons.OK, MessageBoxIcon.Information);
                                return;
                            }
                        }
                    }

                    // Step 2: Check if payment exists for the booking
                    string paymentQuery = @"
                SELECT PaymentStatus 
                FROM Payment 
                WHERE BookingID = @BookingID";

                    using (SqlCommand cmd = new SqlCommand(paymentQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@BookingID", bookingID);

                        object result = cmd.ExecuteScalar();
                        if (result != null)
                        {
                            textBox10.Text = result.ToString();
                        }
                        else
                        {
                            textBox10.Text = fallbackPaymentStatus;
                        }

                        MessageBox.Show("Payment status retrieved successfully.",
                                        "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show("An error occurred:\n" + ex.Message,
                                    "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        private void textBox10_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            // Basic validation
            bool validTraveler = int.TryParse(textBox2.Text, out int travelerID);
            bool validTrip = int.TryParse(textBox1.Text, out int tripID);
            bool validAmount = decimal.TryParse(textBox9.Text, out decimal enteredAmount);
            bool validMethod = !string.IsNullOrWhiteSpace(textBox7.Text);

            if (!validTraveler || !validTrip || !validAmount || !validMethod)
            {
                string errorDetails = $"Traveler: {validTraveler}, Trip: {validTrip}, Amount: {validAmount}, Method: {validMethod}";
                MessageBox.Show("Please enter valid Traveler ID, Trip ID, Amount, and Payment Method.\n\nDebug Info:\n" + errorDetails,
                                "Invalid Input", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }


            string method = textBox7.Text.Trim();

            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                try
                {
                    conn.Open();

                    // Step 1: Check if booking exists for this traveler and trip
                    string getBookingQuery = @"
                SELECT BookingID, TotalPrice, PaymentStatus 
                FROM Booking 
                WHERE TravelerID = @TravelerID AND TripID = @TripID";

                    int bookingID = -1;
                    decimal expectedAmount = 0;
                    string paymentStatus = "";

                    using (SqlCommand cmd = new SqlCommand(getBookingQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@TravelerID", travelerID);
                        cmd.Parameters.AddWithValue("@TripID", tripID);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                bookingID = reader.GetInt32(0);
                                expectedAmount = reader.GetDecimal(1);
                                paymentStatus = reader.GetString(2);
                            }
                            else
                            {
                                MessageBox.Show("No booking found for this traveler and trip.",
                                                "Booking Not Found", MessageBoxButtons.OK, MessageBoxIcon.Error);
                                return;
                            }
                        }
                    }

                    // Step 2: Check if payment already exists
                    string checkPaymentQuery = "SELECT COUNT(*) FROM Payment WHERE BookingID = @BookingID";
                    using (SqlCommand cmd = new SqlCommand(checkPaymentQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@BookingID", bookingID);
                        int paymentExists = (int)cmd.ExecuteScalar();

                        if (paymentExists > 0 || paymentStatus.Equals("Paid", StringComparison.OrdinalIgnoreCase))
                        {
                            MessageBox.Show("Payment has already been made for this booking.",
                                            "Already Paid", MessageBoxButtons.OK, MessageBoxIcon.Information);
                            return;
                        }
                    }

                    // Step 3: Validate amount
                    if (enteredAmount < expectedAmount)
                    {
                        MessageBox.Show("The entered amount is LESS than the total price.",
                                        "Amount Mismatch", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        return;
                    }
                    else if (enteredAmount > expectedAmount)
                    {
                        MessageBox.Show("The entered amount is MORE than the total price.",
                                        "Amount Mismatch", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        return;
                    }

                    // Step 4: Insert into Payment table
                    string insertPaymentQuery = @"
                INSERT INTO Payment (PaymentID, BookingID, Amount, PaymentDate, PaymentMethod, PaymentStatus)
                VALUES ((SELECT ISNULL(MAX(PaymentID), 0) + 1 FROM Payment),
                        @BookingID, @Amount, GETDATE(), @Method, 'Paid')";

                    using (SqlCommand cmd = new SqlCommand(insertPaymentQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@BookingID", bookingID);
                        cmd.Parameters.AddWithValue("@Amount", enteredAmount);
                        cmd.Parameters.AddWithValue("@Method", method);
                        cmd.ExecuteNonQuery();
                    }

                    // Step 5: Update Booking's PaymentStatus
                    string updateBooking = "UPDATE Booking SET PaymentStatus = 'Paid' WHERE BookingID = @BookingID";
                    using (SqlCommand cmd = new SqlCommand(updateBooking, conn))
                    {
                        cmd.Parameters.AddWithValue("@BookingID", bookingID);
                        cmd.ExecuteNonQuery();
                    }

                    MessageBox.Show("Payment successful!", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Error: " + ex.Message, "Exception", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }


        private void textBox9_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox7_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox3_TextChanged(object sender, EventArgs e)
        {

        }

        private void button7_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(textBox1.Text, out int tripID))
            {
                MessageBox.Show("Please enter a valid Trip ID.", "Invalid Input", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                try
                {
                    conn.Open();

                    string getPriceQuery = @"
                SELECT TOP 1 TotalPrice 
                FROM Booking 
                WHERE TripID = @TripID";

                    using (SqlCommand cmd = new SqlCommand(getPriceQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@TripID", tripID);

                        object result = cmd.ExecuteScalar();

                        if (result != null)
                        {
                            decimal price = Convert.ToDecimal(result);
                            textBox4.Text = price.ToString("F2"); // Display with 2 decimal places
                        }
                        else
                        {
                            MessageBox.Show("No booking found for this Trip ID.", "Not Found", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        }
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Error: " + ex.Message, "Exception", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        private void textBox4_TextChanged(object sender, EventArgs e)
        {

        }

        private void button4_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(textBox1.Text, out int tripID) ||
        !int.TryParse(textBox2.Text, out int travelerID))
            {
                MessageBox.Show("Please enter valid Trip ID and Traveler ID.", "Invalid Input", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                try
                {
                    conn.Open();

                    // 1. Check if Trip exists and has available slots
                    string checkTripQuery = "SELECT AvailableSlots, Price FROM Trip WHERE TripID = @TripID";
                    int availableSlots = 0;
                    decimal tripPrice = 0;

                    using (SqlCommand cmd = new SqlCommand(checkTripQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@TripID", tripID);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                availableSlots = reader.GetInt32(0);
                                tripPrice = reader.GetDecimal(1);
                            }
                            else
                            {
                                MessageBox.Show("Trip does not exist.", "Not Found", MessageBoxButtons.OK, MessageBoxIcon.Error);
                                return;
                            }
                        }
                    }

                    if (availableSlots <= 0)
                    {
                        MessageBox.Show("No available slots for this trip.", "Unavailable", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        return;
                    }

                    // 2. Check if Traveler exists
                    string travelerExistsQuery = "SELECT COUNT(*) FROM Traveler WHERE TravelerID = @TravelerID";
                    using (SqlCommand cmd = new SqlCommand(travelerExistsQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@TravelerID", travelerID);
                        int exists = (int)cmd.ExecuteScalar();
                        if (exists == 0)
                        {
                            MessageBox.Show("Traveler does not exist.", "Not Found", MessageBoxButtons.OK, MessageBoxIcon.Error);
                            return;
                        }
                    }

                    // 3. Check if this traveler already booked this trip
                    string bookingCheckQuery = "SELECT COUNT(*) FROM Booking WHERE TravelerID = @TravelerID AND TripID = @TripID";
                    using (SqlCommand cmd = new SqlCommand(bookingCheckQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@TravelerID", travelerID);
                        cmd.Parameters.AddWithValue("@TripID", tripID);
                        int count = (int)cmd.ExecuteScalar();

                        if (count > 0)
                        {
                            MessageBox.Show("You have already booked this trip.", "Already Booked", MessageBoxButtons.OK, MessageBoxIcon.Information);
                            return;
                        }
                    }

                    // 4. Insert booking
                    string insertBookingQuery = @"
                INSERT INTO Booking (BookingID, TravelerID, TripID, BookingDate, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason)
                VALUES ((SELECT ISNULL(MAX(BookingID), 0) + 1 FROM Booking),
                        @TravelerID, @TripID, GETDATE(), 1, @TotalPrice, 'Failed', 'Pending', NULL)";

                    using (SqlCommand cmd = new SqlCommand(insertBookingQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@TravelerID", travelerID);
                        cmd.Parameters.AddWithValue("@TripID", tripID);
                        cmd.Parameters.AddWithValue("@TotalPrice", tripPrice);
                        cmd.ExecuteNonQuery();
                    }

                    // 5. Decrease available slots
                    string updateTripSlots = "UPDATE Trip SET AvailableSlots = AvailableSlots - 1 WHERE TripID = @TripID";
                    using (SqlCommand cmd = new SqlCommand(updateTripSlots, conn))
                    {
                        cmd.Parameters.AddWithValue("@TripID", tripID);
                        cmd.ExecuteNonQuery();
                    }

                    MessageBox.Show("Booking successful! Payment pending.", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Error: " + ex.Message, "Exception", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        private void button6_Click(object sender, EventArgs e)
        {
            // Validate Trip ID input
            if (!int.TryParse(textBox1.Text.Trim(), out int tripID))
            {
                MessageBox.Show("Please enter a valid numeric Trip ID.", "Invalid Input", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                try
                {
                    conn.Open();

                    // Query TripStatus for the given TripID
                    string query = @"SELECT TripStatus FROM Trip WHERE TripID = @TripID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@TripID", tripID);

                        object result = cmd.ExecuteScalar();

                        if (result != null)
                        {
                            string tripStatus = result.ToString();
                            textBox3.Text = tripStatus;  // Replace with the textbox you want to display the trip status in
                        }
                        else
                        {
                            MessageBox.Show("No trip found with the given Trip ID.", "Trip Not Found", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        }
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show("An error occurred:\n" + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }


        private void button3_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                try
                {
                    conn.Open();

                    string query = @"SELECT BookingID, TripID, NumOfParticipants, TotalPrice, PaymentStatus, BookingStatus, CancellationReason 
                             FROM Booking
                             WHERE TravelerID = @TravelerID";

                    using (SqlDataAdapter adapter = new SqlDataAdapter(query, conn))
                    {
                        adapter.SelectCommand.Parameters.AddWithValue("@TravelerID", TravelerID);

                        DataTable dt = new DataTable();
                        adapter.Fill(dt);
                        dataGridView1.DataSource = dt;
                        dataGridView1.Visible = true;
                    }

                    dataGridView1.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Error loading bookings: " + ex.Message);
                }
            }
        }

        private void button8_Click(object sender, EventArgs e)
        {
            // Validate TripID input
            if (!int.TryParse(textBox1.Text.Trim(), out int tripID))
            {
                MessageBox.Show("Please enter a valid numeric Trip ID.", "Invalid Input", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // Read and sanitize cancellation reason
            string reason = textBox5.Text.Trim();
            if (string.IsNullOrEmpty(reason))
            {
                reason = null; // optional
            }

            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                try
                {
                    conn.Open();

                    // 1. Check if this trip exists in the user's bookings
                    string checkQuery = @"SELECT BookingStatus FROM Booking 
                                  WHERE TravelerID = @TravelerID AND TripID = @TripID";

                    SqlCommand checkCmd = new SqlCommand(checkQuery, conn);
                    checkCmd.Parameters.AddWithValue("@TravelerID", TravelerID);
                    checkCmd.Parameters.AddWithValue("@TripID", tripID);

                    object statusObj = checkCmd.ExecuteScalar();

                    if (statusObj == null)
                    {
                        MessageBox.Show("No booking found for this Trip ID under your account.", "Not Found", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        return;
                    }

                    string bookingStatus = statusObj.ToString();

                    // 2. Check if already cancelled
                    if (bookingStatus == "Cancelled")
                    {
                        MessageBox.Show("This booking has already been cancelled.", "Already Cancelled", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        return;
                    }

                    // 3. Perform cancellation
                    string updateQuery = @"UPDATE Booking 
                                   SET BookingStatus = 'Cancelled',
                                       PaymentStatus = 'Refunded',
                                       CancellationReason = @Reason
                                   WHERE TravelerID = @TravelerID AND TripID = @TripID";

                    SqlCommand updateCmd = new SqlCommand(updateQuery, conn);
                    updateCmd.Parameters.AddWithValue("@TravelerID", TravelerID);
                    updateCmd.Parameters.AddWithValue("@TripID", tripID);
                    updateCmd.Parameters.AddWithValue("@Reason", (object)reason ?? DBNull.Value);

                    int rowsAffected = updateCmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        MessageBox.Show("Booking cancelled successfully.", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                    else
                    {
                        MessageBox.Show("Failed to cancel the booking. Please try again later.", "Failure", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show("An error occurred:\n" + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }


        private void textBox5_TextChanged(object sender, EventArgs e)
        {

        }

        private void button9_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(textBox1.Text.Trim(), out int tripID))
            {
                MessageBox.Show("Please enter a valid Trip ID.", "Invalid Input", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                try
                {
                    conn.Open();

                    string query = @"
                SELECT TOP 1 BookingStatus
                FROM Booking
                WHERE TravelerID = @TravelerID AND TripID = @TripID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@TravelerID", TravelerID); // <-- make sure this variable exists
                        cmd.Parameters.AddWithValue("@TripID", tripID);

                        object result = cmd.ExecuteScalar();

                        if (result != null)
                        {
                            textBox6.Text = result.ToString();  // Replace with the textbox for displaying status
                        }
                        else
                        {
                            MessageBox.Show("No booking found for the given Trip ID and your Traveler ID.", "Not Found", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        }
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Error: " + ex.Message, "Exception", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        private void textBox6_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
