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
    public partial class TourOperatorAddActivities : Form
    {
        private int operatorID;
        public TourOperatorAddActivities(int id)
        {
            InitializeComponent();
            operatorID = id;
        }

        private void button4_Click(object sender, EventArgs e)
        {
            TourOperatorHomePage TOHP = new TourOperatorHomePage(operatorID);
            this.Hide();
            TOHP.Show();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            try
            {
                int tripId;
                if (!int.TryParse(textBox9.Text.Trim(), out tripId))
                {
                    MessageBox.Show("Please enter a valid Trip ID.");
                    return;
                }

                string activityDesc = textBox2.Text.Trim();
                if (string.IsNullOrWhiteSpace(activityDesc))
                {
                    MessageBox.Show("Please enter an activity description.");
                    return;
                }

                DateTime activityDate = dateTimePicker1.Value.Date;

                using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
                {
                    conn.Open();

                    // Check if Trip exists and is created by this operator
                    string checkTripQuery = "SELECT COUNT(*) FROM Trip WHERE TripID = @TripID AND OperatorID = @OperatorID";
                    SqlCommand checkCmd = new SqlCommand(checkTripQuery, conn);
                    checkCmd.Parameters.AddWithValue("@TripID", tripId);
                    checkCmd.Parameters.AddWithValue("@OperatorID", operatorID);

                    int tripExists = (int)checkCmd.ExecuteScalar();
                    if (tripExists == 0)
                    {
                        MessageBox.Show("This Trip ID does not belong to the logged-in operator.");
                        return;
                    }

                    // Generate next ActivityID
                    string getNextActivityIDQuery = "SELECT ISNULL(MAX(ActivityID), 0) + 1 FROM Activities";
                    SqlCommand idCmd = new SqlCommand(getNextActivityIDQuery, conn);
                    int nextActivityId = (int)idCmd.ExecuteScalar();

                    // Insert into Activities table
                    string insertActivityQuery = @"
                INSERT INTO Activities (ActivityID, TripID, ActivityDescription, ActivityDate)
                VALUES (@ActivityID, @TripID, @Description, @ActivityDate)";

                    SqlCommand insertCmd = new SqlCommand(insertActivityQuery, conn);
                    insertCmd.Parameters.AddWithValue("@ActivityID", nextActivityId);
                    insertCmd.Parameters.AddWithValue("@TripID", tripId);
                    insertCmd.Parameters.AddWithValue("@Description", activityDesc);
                    insertCmd.Parameters.AddWithValue("@ActivityDate", activityDate);

                    insertCmd.ExecuteNonQuery();
                    MessageBox.Show("Activity successfully added!");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message);
            }
        }


        private void textBox1_TextChanged(object sender, EventArgs e)
        {
        }

        private void TourOperatorAddActivities_Load(object sender, EventArgs e)
        {
            // TODO: This line of code loads data into the 'travelEaseDataSet20.Activities' table. You can move, or remove it, as needed.
            this.activitiesTableAdapter.Fill(this.travelEaseDataSet20.Activities);
            try
            {
                using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
                {
                    conn.Open();

                    string getactivityIDQuery = @"
                SELECT ISNULL(MAX(ActivityID), 0) + 1 
                FROM Activities";

                    SqlCommand activityIdCmd = new SqlCommand(getactivityIDQuery, conn);

                    int nextactivityID = (int)activityIdCmd.ExecuteScalar();
                    textBox1.Text = nextactivityID.ToString();
                    textBox1.ReadOnly = true;

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

        private void textBox9_TextChanged(object sender, EventArgs e)
        {

        }

        private void button2_Click(object sender, EventArgs e)
        {
            try
            {
                int tripId;
                if (!int.TryParse(textBox9.Text.Trim(), out tripId))
                {
                    MessageBox.Show("Please enter a valid Trip ID.");
                    return;
                }

                using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
                {
                    conn.Open();

                    // Check if the TripID belongs to the logged-in operator
                    string checkTripQuery = "SELECT COUNT(*) FROM Trip WHERE TripID = @TripID AND OperatorID = @OperatorID";
                    using (SqlCommand checkCmd = new SqlCommand(checkTripQuery, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@TripID", tripId);
                        checkCmd.Parameters.AddWithValue("@OperatorID", operatorID);

                        int exists = (int)checkCmd.ExecuteScalar();
                        if (exists == 0)
                        {
                            MessageBox.Show("This Trip ID does not belong to the logged-in operator.");
                            return;
                        }
                    }

                    // Fetch activities for this trip
                    string fetchActivitiesQuery = @"
                SELECT ActivityID, ActivityDescription, ActivityDate 
                FROM Activities 
                WHERE TripID = @TripID";

                    using (SqlCommand fetchCmd = new SqlCommand(fetchActivitiesQuery, conn))
                    {
                        fetchCmd.Parameters.AddWithValue("@TripID", tripId);

                        SqlDataAdapter adapter = new SqlDataAdapter(fetchCmd);
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);

                        if (dt.Rows.Count == 0)
                        {
                            MessageBox.Show("No activities found for this Trip ID.");
                        }

                        dataGridView1.DataSource = dt;
                        dataGridView1.Visible = true;
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message);
            }
        }

    }
}
