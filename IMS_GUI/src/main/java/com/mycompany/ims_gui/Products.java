
package com.mycompany.ims_gui;

/**
 *
 * @author Beki
 */
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.ResultSet;
import java.util.logging.Logger;
import java.sql.SQLException;
import java.util.logging.Level;

public class Products {
    Connection con = MySqlConnector.connect();
    PreparedStatement ps;
    
    public int getMax()
    {
    int id = 0;
    Statement st;
    try{
    st = con.createStatement();
    ResultSet rs = st.executeQuery("select max(id) from products");
    while(rs.next())
    {
    id = rs.getInt(1);
    }
    }
    catch (SQLException e)
    {
    Logger.getLogger(Products.class.getName()).log(Level.SEVERE, null, e)
            ;
    }
    return id + 1;
    }
}
