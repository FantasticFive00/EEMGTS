package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DatabaseConnection {

    public static Connection getConnection() throws Exception {
        // Get database URL from environment variable (Heroku) or use default
        String dbUrl = System.getenv("DATABASE_URL");

        if (dbUrl != null && !dbUrl.isEmpty()) {
            // Heroku PostgreSQL URL format: postgres://user:password@host:port/database
            // Convert to JDBC format: jdbc:postgresql://host:port/database
            dbUrl = dbUrl.replace("postgres://", "jdbc:postgresql://");

            // Parse credentials from URL
            java.net.URI dbUri = new java.net.URI(dbUrl.replace("jdbc:postgresql://", "postgres://"));
            String username = dbUri.getUserInfo().split(":")[0];
            String password = dbUri.getUserInfo().split(":")[1];
            String jdbcUrl = "jdbc:postgresql://" + dbUri.getHost() + ':' + dbUri.getPort() + dbUri.getPath();

            Class.forName("org.postgresql.Driver");
            return DriverManager.getConnection(jdbcUrl, username, password);
        } else {
            // Local development
            String url = "jdbc:postgresql://localhost:5432/eems";
            String user = "postgres";
            String password = "oracle";

            Class.forName("org.postgresql.Driver");
            return DriverManager.getConnection(url, user, password);
        }
    }
}
