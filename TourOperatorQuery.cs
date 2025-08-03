using System;
using System.Data;
using System.Data.SqlClient;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace DB_Project
{
    public partial class TourOperatorQuery : Form
    {
        private int operatorID;

        public TourOperatorQuery(int id)
        {
            InitializeComponent();
            operatorID = id;
        }

        private void TourOperatorQueries_Load(object sender, EventArgs e)
        {
            // TODO: This line of code loads data into the 'travelEaseDataSet23.Inquiries' table. You can move, or remove it, as needed.
            this.inquiriesTableAdapter2.Fill(this.travelEaseDataSet23.Inquiries);
            textBox1.Text = operatorID.ToString();
            textBox1.ReadOnly = true;
        }

        private void button5_Click(object sender, EventArgs e)
        {
            TourOperatorHomePage TOHP = new TourOperatorHomePage(operatorID);
            this.Hide();
            TOHP.Show();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            string inputTripId = textBox3.Text.Trim();

            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                conn.Open();

                if (string.IsNullOrEmpty(inputTripId))
                {
                    // Show all inquiries for this tour operator
                    using (SqlCommand cmd = new SqlCommand(@"
                SELECT i.InquiryID, i.TravelerID, i.BookingID, i.InquiryTime, i.ResponseTime
                FROM Inquiries i
                WHERE i.TourOperatorID = @OperatorID", conn))
                    {
                        cmd.Parameters.AddWithValue("@OperatorID", operatorID);
                        SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                        DataTable table = new DataTable();
                        adapter.Fill(table);
                        dataGridView1.DataSource = table;
                        dataGridView1.AutoResizeColumns();

                        MessageBox.Show("Showing all inquiries for your trips.");
                    }
                }
                else
                {
                    // Validate if the TripID belongs to this operator
                    using (SqlCommand checkCmd = new SqlCommand(@"
                SELECT COUNT(*) 
                FROM Trip 
                WHERE TripID = @TripID AND OperatorID = @OperatorID", conn))
                    {
                        checkCmd.Parameters.AddWithValue("@TripID", inputTripId);
                        checkCmd.Parameters.AddWithValue("@OperatorID", operatorID);
                        int count = (int)checkCmd.ExecuteScalar();

                        if (count == 0)
                        {
                            MessageBox.Show("This TripID does not belong to you or does not exist.");
                            dataGridView1.DataSource = null;
                        }
                        else
                        {
                            // Show all inquiries related to that TripID
                            using (SqlCommand cmd = new SqlCommand(@"
                        SELECT i.InquiryID, i.TravelerID, i.BookingID, i.InquiryTime, i.ResponseTime, i.TourOPeratorID, i.Query, i.Response, i.TripID
                        FROM Inquiries i
                        INNER JOIN Booking b ON i.BookingID = b.BookingID
                        WHERE b.TripID = @TripID AND i.TourOperatorID = @OperatorID", conn))
                            {
                                cmd.Parameters.AddWithValue("@TripID", inputTripId);
                                cmd.Parameters.AddWithValue("@OperatorID", operatorID);
                                SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                                DataTable table = new DataTable();
                                adapter.Fill(table);
                                dataGridView1.DataSource = table;
                                dataGridView1.AutoResizeColumns();
                                dataGridView1.Visible = true;

                                if (table.Rows.Count == 0)
                                {
                                    MessageBox.Show("No inquiries found for this TripID.");
                                }
                                else
                                {
                                    MessageBox.Show("Showing inquiries for TripID: " + inputTripId);
                                }
                            }
                        }
                    }
                }
            }
        }

        // Optional: You can remove these if unused
        private void textBox1_TextChanged(object sender, EventArgs e) { }
        private void textBox3_TextChanged(object sender, EventArgs e) { }

        private void button6_Click(object sender, EventArgs e)
        {
            string inputTripId = textBox3.Text.Trim();        // TripID textbox
            string inputInquiryId = textBox4.Text.Trim();     // InquiryID textbox
            string responseText = textBox2.Text.Trim();       // Response textbox

            if (string.IsNullOrEmpty(inputTripId) || string.IsNullOrEmpty(inputInquiryId) || string.IsNullOrEmpty(responseText))
            {
                MessageBox.Show("Please enter Trip ID, Inquiry ID, and a response.");
                return;
            }

            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                conn.Open();

                // Step 1: Verify if inquiry exists, belongs to operator, and is not already responded
                using (SqlCommand checkCmd = new SqlCommand(@"
            SELECT COUNT(*) 
            FROM Inquiries
            WHERE InquiryID = @InquiryID 
              AND TripID = @TripID 
              AND TourOperatorID = @OperatorID 
              AND ResponseTime IS NULL", conn))
                {
                    checkCmd.Parameters.AddWithValue("@InquiryID", inputInquiryId);
                    checkCmd.Parameters.AddWithValue("@TripID", inputTripId);
                    checkCmd.Parameters.AddWithValue("@OperatorID", operatorID);

                    int count = (int)checkCmd.ExecuteScalar();

                    if (count == 0)
                    {
                        MessageBox.Show("Either this inquiry does not exist, does not belong to you, or has already been responded to.");
                        return;
                    }
                }

                // Step 2: Update Response and ResponseTime
                using (SqlCommand updateCmd = new SqlCommand(@"
            UPDATE Inquiries
            SET Response = @ResponseText,
                ResponseTime = GETDATE()
            WHERE InquiryID = @InquiryID", conn))
                {
                    updateCmd.Parameters.AddWithValue("@InquiryID", inputInquiryId);
                    updateCmd.Parameters.AddWithValue("@ResponseText", responseText);

                    int rowsAffected = updateCmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        MessageBox.Show("Inquiry responded successfully.");
                    }
                    else
                    {
                        MessageBox.Show("Failed to update the inquiry.");
                    }
                }
            }
        }


        private void textBox4_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox2_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
