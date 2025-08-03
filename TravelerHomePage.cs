using DB_Project.Resources;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Reflection.Emit;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;











namespace DB_Project
{
    public partial class TravelerHomePage : Form
    {
        private int travelerID;
        public TravelerHomePage(int id)
        {
            InitializeComponent();
            travelerID = id;
        }
        
        private void TravelerHomePage_Load(object sender, EventArgs e)
        {
            // TODO: This line of code loads data into the 'travelEaseDataSet16.Traveler' table. You can move, or remove it, as needed.
            this.travelerTableAdapter.Fill(this.travelEaseDataSet16.Traveler);
            textBox1.Text = travelerID.ToString();
            textBox1.ReadOnly = true;
            using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
            {
                conn.Open();

                string query = "SELECT Name FROM Traveler WHERE TravelerID = @id";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@id", travelerID);

                    object result = cmd.ExecuteScalar();

                    if (result != null)
                    {
                        textBox9.Text = result.ToString();
                    }
                    else
                    {
                        textBox9.Text = "Name not found";
                    }

                    textBox9.ReadOnly = true;
                }

                conn.Close();
            }


        }

        private void button4_Click(object sender, EventArgs e)
        {
            TravelerWishlist TWL = new TravelerWishlist(travelerID);
            this.Hide();
            TWL.Show();
        }

        private void button8_Click(object sender, EventArgs e)
        {
            TravelerBooking TB = new TravelerBooking(travelerID);
            this.Hide();
            TB.Show();
        }

        private void button7_Click(object sender, EventArgs e)
        {
            TravelerReview TR = new TravelerReview(travelerID);
            this.Hide();
            TR.Show();
        }

        private void button6_Click(object sender, EventArgs e)
        {
            TravelerUpdate TU = new TravelerUpdate(travelerID);
            this.Hide();
            TU.Show();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
                {
                    conn.Open();

                    string query = "SELECT * FROM Trip";

                    SqlDataAdapter adapter = new SqlDataAdapter(query, conn);
                    DataTable tripsTable = new DataTable();
                    adapter.Fill(tripsTable);

                    dataGridViewTrips.DataSource = tripsTable;
                    dataGridViewTrips.Visible = true;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error loading trips: " + ex.Message);
            }
        }

        

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox9_TextChanged(object sender, EventArgs e)
        {

        }

        private void button3_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
                {
                    conn.Open();

                    string query = @"SELECT TravelerID, Name, Password, Address, Gender, Nationality, DOB, TravelHistory, PreferredTripTypes 
                         FROM Traveler 
                         WHERE TravelerID = @travelerID";

                    SqlDataAdapter adapter = new SqlDataAdapter(query, conn);
                    adapter.SelectCommand.Parameters.AddWithValue("@travelerID", travelerID);

                    DataTable dt = new DataTable();
                    adapter.Fill(dt);

                    dataGridView1.DataSource = dt;
                    dataGridView1.Visible = true;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Failed to load traveler data.\n\n" + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }

        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void button2_Click(object sender, EventArgs e)
        {
            TravelerQueryPage TQP = new TravelerQueryPage(travelerID);
            this.Hide();
            TQP.Show();
        }
    }
}
