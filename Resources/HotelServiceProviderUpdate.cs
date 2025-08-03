using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace DB_Project.Resources
{
    public partial class HotelServiceProviderUpdate : Form
    {
        public HotelServiceProviderUpdate()
        {
            InitializeComponent();
        }

        private void button5_Click(object sender, EventArgs e)
        {
            HotelServiceProviderHomePage HSPH = new HotelServiceProviderHomePage();
            this.Hide();
            HSPH.Show();
        }
    }
}
