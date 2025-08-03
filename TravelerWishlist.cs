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
    public partial class TravelerWishlist : Form
    {
        private int travelerID;
        public TravelerWishlist(int id)
        {
            InitializeComponent();
            travelerID = id;
        }

        private void button5_Click(object sender, EventArgs e)
        {
            TravelerHomePage THP = new TravelerHomePage(travelerID);
            this.Hide();
            THP.Show();
        }

        private void TravelerWishlist_Load(object sender, EventArgs e)
        {
            textBox10.Text = travelerID.ToString();
            textBox10.ReadOnly = true;

            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                conn.Open();

                string query = "SELECT WishID FROM Wishlist WHERE TravelerID = @TravelerID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@TravelerID", travelerID);

                    object result = cmd.ExecuteScalar();
                    if (result != null)
                    {
                        textBox4.Text = result.ToString();
                        textBox4.ReadOnly = true;
                    }
                    else
                    {
                        MessageBox.Show("No wishlist found for this traveler.", "Info", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                }

                conn.Close();
            }

            // Load Trip data if needed (though you may not need this unless editing trips directly)
            // this.tripTableAdapter.Fill(this.travelEaseDataSet5.Trip);
        }


        private void button2_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                conn.Open();

                string query = @"
            SELECT T.TripID, T.Title, T.Description, T.StartDate, T.EndDate
            FROM WishlistAdd WA
            JOIN Trip T ON WA.TripID = T.TripID
            WHERE WA.TravelerID = @TravelerID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@TravelerID", travelerID);

                    SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    adapter.Fill(dt);

                    dataGridViewWishlist.DataSource = dt;
                    dataGridViewWishlist.Visible = true; // Show the grid now
                }

                conn.Close();
            }
        }

        private void dataGridViewWishlist_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void button4_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(textBox10.Text, out int travelerID) ||
        !int.TryParse(textBox4.Text, out int wishlistID) ||
        !int.TryParse(textBox1.Text, out int tripID))
            {
                MessageBox.Show("Please enter valid numeric values for Traveler ID, Wishlist ID, and Trip ID.",
                                "Invalid Input", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                try
                {
                    conn.Open();

                    // Step 1: Check if TripID exists
                    string checkTripQuery = "SELECT COUNT(*) FROM Trip WHERE TripID = @TripID";
                    using (SqlCommand checkTripCmd = new SqlCommand(checkTripQuery, conn))
                    {
                        checkTripCmd.Parameters.AddWithValue("@TripID", tripID);
                        int tripExists = (int)checkTripCmd.ExecuteScalar();

                        if (tripExists == 0)
                        {
                            MessageBox.Show("The Trip ID does not exist. Please enter a valid Trip ID.",
                                            "Trip Not Found", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                            return;
                        }
                    }

                    // Step 2: Check if the trip is in the user's wishlist
                    string checkWishlistQuery = @"
                SELECT COUNT(*) FROM WishlistAdd
                WHERE WishlistID = @WishlistID AND TravelerID = @TravelerID AND TripID = @TripID";

                    using (SqlCommand checkCmd = new SqlCommand(checkWishlistQuery, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@WishlistID", wishlistID);
                        checkCmd.Parameters.AddWithValue("@TravelerID", travelerID);
                        checkCmd.Parameters.AddWithValue("@TripID", tripID);

                        int exists = (int)checkCmd.ExecuteScalar();
                        if (exists == 0)
                        {
                            MessageBox.Show("This trip is not in your wishlist.",
                                            "Not Found", MessageBoxButtons.OK, MessageBoxIcon.Information);
                            return;
                        }
                    }

                    // Step 3: Delete the entry
                    string deleteQuery = @"
                DELETE FROM WishlistAdd
                WHERE WishlistID = @WishlistID AND TravelerID = @TravelerID AND TripID = @TripID";

                    using (SqlCommand deleteCmd = new SqlCommand(deleteQuery, conn))
                    {
                        deleteCmd.Parameters.AddWithValue("@WishlistID", wishlistID);
                        deleteCmd.Parameters.AddWithValue("@TravelerID", travelerID);
                        deleteCmd.Parameters.AddWithValue("@TripID", tripID);

                        int rows = deleteCmd.ExecuteNonQuery();
                        if (rows > 0)
                        {
                            MessageBox.Show("Trip successfully removed from your wishlist!",
                                            "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        }
                        else
                        {
                            MessageBox.Show("Failed to remove the trip. Please try again.",
                                            "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        }
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show("An error occurred:\n" + ex.Message,
                                    "Exception", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        private void textBox4_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox10_TextChanged(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
            {
                if (!int.TryParse(textBox10.Text, out int travelerID) ||
                    !int.TryParse(textBox4.Text, out int wishlistID) ||
                    !int.TryParse(textBox1.Text, out int tripID))
                {
                    MessageBox.Show("Please enter valid numeric values for Traveler ID, Wishlist ID, and Trip ID.",
                                    "Invalid Input", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
                {
                    try
                    {
                        conn.Open();

                        // Step 1: Check if TripID exists
                        string checkTripQuery = "SELECT COUNT(*) FROM Trip WHERE TripID = @TripID";
                        using (SqlCommand checkTripCmd = new SqlCommand(checkTripQuery, conn))
                        {
                            checkTripCmd.Parameters.AddWithValue("@TripID", tripID);
                            int tripExists = (int)checkTripCmd.ExecuteScalar();

                            if (tripExists == 0)
                            {
                                MessageBox.Show("The Trip ID does not exist. Please enter a valid Trip ID.",
                                                "Trip Not Found", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                                return;
                            }
                        }

                        // Step 2: Check if entry already exists in WishlistAdd
                        string checkWishlistQuery = @"
                SELECT COUNT(*) FROM WishlistAdd
                WHERE WishlistID = @WishlistID AND TravelerID = @TravelerID AND TripID = @TripID";

                        using (SqlCommand checkCmd = new SqlCommand(checkWishlistQuery, conn))
                        {
                            checkCmd.Parameters.AddWithValue("@WishlistID", wishlistID);
                            checkCmd.Parameters.AddWithValue("@TravelerID", travelerID);
                            checkCmd.Parameters.AddWithValue("@TripID", tripID);

                            int exists = (int)checkCmd.ExecuteScalar();
                            if (exists > 0)
                            {
                                MessageBox.Show("This trip is already in your wishlist.",
                                                "Duplicate Entry", MessageBoxButtons.OK, MessageBoxIcon.Information);
                                return;
                            }
                        }

                        // Step 3: Insert new record into WishlistAdd
                        string insertQuery = @"
                INSERT INTO WishlistAdd (WishlistID, TravelerID, TripID, DateAdded)
                VALUES (@WishlistID, @TravelerID, @TripID, GETDATE())";

                        using (SqlCommand insertCmd = new SqlCommand(insertQuery, conn))
                        {
                            insertCmd.Parameters.AddWithValue("@WishlistID", wishlistID);
                            insertCmd.Parameters.AddWithValue("@TravelerID", travelerID);
                            insertCmd.Parameters.AddWithValue("@TripID", tripID);

                            int rows = insertCmd.ExecuteNonQuery();
                            if (rows > 0)
                            {
                                MessageBox.Show("Trip successfully added to your wishlist!",
                                                "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                            }
                            else
                            {
                                MessageBox.Show("Trip could not be added. Please try again.",
                                                "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show("An error occurred:\n" + ex.Message,
                                        "Exception", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
            }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }
    }
    }
