package com.vehicle;

import java.sql.*;

public class DbConnection {

	public Connection makeConnection() throws ClassNotFoundException, SQLException {
		String dbDriver = "com.mysql.cj.jdbc.Driver";

		// ✅ Added 'allowPublicKeyRetrieval=true' to fix your error
		String dbURL = "jdbc:mysql://localhost:3306/vehicle?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";

		String dbUsername = "root";
		String dbPassword = System.getProperty("DB_PASSWORD", "Sandeep#933"); // Use environment variable or default

		Class.forName(dbDriver);
		Connection con = DriverManager.getConnection(dbURL, dbUsername, dbPassword);
		System.out.println("✅ Database connected successfully!");
		return con;
	}
}
