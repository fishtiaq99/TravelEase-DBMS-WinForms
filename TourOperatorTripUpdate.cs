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
    public partial class TourOperatorTripUpdate : Form
    {
        private int operatorID;
        public TourOperatorTripUpdate(int id)
        {
            InitializeComponent();
            operatorID = id;
        }

        private void button5_Click(object sender, EventArgs e)
        {
            TourOperatorHomePage TOHP = new TourOperatorHomePage(operatorID);
            this.Hide();
            TOHP.Show();
        }


        private void button4_Click(object sender, EventArgs e)
        {

        }
    }
}
