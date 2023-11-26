
package com.mycompany.ims_gui;

import java.sql.Connection;

import java.sql.DriverManager;
import javax.swing.JOptionPane;

public class MySqlConnector {
    
     public static Connection connect()
    {
    try
    {
    String url = "jdbc:mysql://localhost:3306/ims2";
    String username = "root";
    String password1 = "Kir@4242Sj";
    
    Class.forName("con.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(url,username,password1);
    return conn;
    }
    catch(Exception e)
    {
    JOptionPane.showMessageDialog(null,e);
    }
    return null;
    
    }
     
     public static void main(String Args[])
     {
     JOptionPane.showMessageDialog(null, "Connected");
     }
    
}
