using DB_Project.Resources;
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
    public partial class TourOperatorHomePage : Form
    {
        private int operatorID;
        public TourOperatorHomePage(int id)
        {
            InitializeComponent();
            operatorID = id;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            TourOperatorQuery TOQ = new TourOperatorQuery(operatorID);
            this.Hide();
            TOQ.Show();
        }

        private void button8_Click(object sender, EventArgs e)
        {
            TourOperatorCreateTrip TOCT = new TourOperatorCreateTrip(operatorID);
            this.Hide();
            TOCT.Show();
        }

        private void button4_Click(object sender, EventArgs e)
        {
            TourOperatorUpdate TOU = new TourOperatorUpdate(operatorID);
            this.Hide();
            TOU.Show();
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void TourOperatorHomePage_Load(object sender, EventArgs e)
        {
            // TODO: This line of code loads data into the 'travelEaseDataSet19.TourOperator' table. You can move, or remove it, as needed.
            this.tourOperatorTableAdapter.Fill(this.travelEaseDataSet19.TourOperator);
            try
            {
                using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
                {
                    conn.Open();

                    // Query to get company name of the current operator
                    string query = "SELECT CompanyName FROM TourOperator WHERE OperatorID = @OperatorID";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@OperatorID", operatorID);

                    SqlDataReader reader = cmd.ExecuteReader();
                    if (reader.Read())
                    {
                        textBox1.Text = operatorID.ToString();
                        textBox9.Text = reader["CompanyName"].ToString();

                        // Make both boxes read-only
                        textBox1.ReadOnly = true;
                        textBox9.ReadOnly = true;
                    }
                    else
                    {
                        MessageBox.Show("Operator not found in the database.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }

                    reader.Close();
                    conn.Close();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("An error occurred: " + ex.Message);
            }
        }


        private void textBox9_TextChanged(object sender, EventArgs e)
        {

        }

        private void button3_Click(object sender, EventArgs e)
        {
            try
            {
                int id;
                if (!int.TryParse(textBox1.Text, out id))
                {
                    MessageBox.Show("Invalid Operator ID.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }

                using (SqlConnection conn = new SqlConnection(DB_Config.ConnectionString))
                {
                    conn.Open();

                    string query = "SELECT OperatorID, CompanyName, CompanyAddress, ContactPhone, ContactEmail, TripsOffered FROM TourOperator WHERE OperatorID = @OperatorID";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@OperatorID", id);

                    SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                    DataTable table = new DataTable();
                    adapter.Fill(table);

                    if (table.Rows.Count == 0)
                    {
                        MessageBox.Show("No data found for this Operator ID.", "Info", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        return;
                    }

                    dataGridView1.DataSource = table;
                    dataGridView1.Visible = true; // Enable grid view visibility
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("An error occurred: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void button5_Click(object sender, EventArgs e)
        {
            WebsiteHomePage WHP = new WebsiteHomePage();
            this.Hide();
            WHP.Show();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            TourOperatorAddActivities TOAA = new TourOperatorAddActivities(operatorID);
            this.Hide();
            TOAA.Show();
        }
    }
}
