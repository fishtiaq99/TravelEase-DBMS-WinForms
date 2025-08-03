using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace DB_Project
{
    public partial class WebsiteHomePage : Form
    {
        public WebsiteHomePage()
        {
            InitializeComponent();
        }

        private void button4_Click(object sender, EventArgs e)
        {
            TravelerLoginPage TLP = new TravelerLoginPage();
            this.Hide();
            TLP.Show();
        }

        private void button1_Click(object sender, EventArgs e)
        {

            Travelersignup TSP = new Travelersignup();
            this.Hide();
            TSP.Show();
        }

        private void label4_Click(object sender, EventArgs e)
        {
            AdminLoginPagecs ALP = new AdminLoginPagecs();
            this.Hide();
            ALP.Show();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            TourOperatorLogin TOL = new TourOperatorLogin();
            this.Hide();
            TOL.Show();
        }

        private void button3_Click(object sender, EventArgs e)
        {
            TourOperatorSignup TOL = new TourOperatorSignup();
            this.Hide();
            TOL.Show();
        }

        private void label5_Click(object sender, EventArgs e)
        {
            HotelServiceProviderLogin HSP = new HotelServiceProviderLogin();
            this.Hide();
            HSP.Show();
        }
    }
}
