package servlet;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLEncoder;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/DownloadServlet")
public class DownloadServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "uploads";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Get the filename from the link
        String fileName = request.getParameter("filename");

        if (fileName == null || fileName.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Filename missing");
            return;
        }

        // 2. Find the file in the webapp's uploads directory
        String applicationPath = request.getServletContext().getRealPath("");
        String uploadFilePath = applicationPath + File.separator + UPLOAD_DIR;

        File file = new File(uploadFilePath, fileName);

        if (!file.exists()) {
            // Fallback: Check if it's in the target classpath (local dev sometimes behaves
            // differently)
            // Or simple specific error
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found: " + fileName);
            return;
        }

        // 3. Configure the Response
        response.setContentType("application/octet-stream"); // Generic file type
        response.setContentLength((int) file.length());

        // This line forces a download (or opens in browser if removed)
        response.setHeader("Content-Disposition", "inline; filename=\"" + fileName + "\"");

        // 4. Stream the file to the browser
        try (FileInputStream in = new FileInputStream(file);
                OutputStream out = response.getOutputStream()) {

            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        }
    }
}