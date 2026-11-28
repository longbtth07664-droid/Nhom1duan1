package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.AnhDanhMuc;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Path;
import java.util.Locale;

/**
 * Servlet cung cấp ảnh danh mục sản phẩm và combo qua đường dẫn: /anh-danh-muc?ten=...
 */
@WebServlet(name = "AnhDanhMucServlet", urlPatterns = {"/anh-danh-muc"})
public class AnhDanhMucServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String ten = req.getParameter("ten");
        if (ten == null || ten.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        ten = ten.trim();
        // Chỉ nhận tên tệp ảnh của danh mục trước khi tra trong các thư mục ảnh.
        if (AnhDanhMuc.laAnhDaTai(ten) || ten.indexOf(':') >= 0 || ten.chars().anyMatch(Character::isISOControl)
                || !ten.toLowerCase(Locale.ROOT).matches(".+\\.(jpg|jpeg|png|webp)")) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // 1. Tìm trong thư mục lưu trữ persistent (cinemax.anh.dir hoặc ~/.cinemax/anh-danh-muc)
        Path storageDir = AnhDanhMuc.getDuongDanLuuTru();
        Path targetPath = storageDir.resolve(ten);
        File file = targetPath.toFile();

        // 2. Nếu chưa có trên đĩa persistent, thử tìm trong thư mục tĩnh webapp (fallback ảnh mẫu cũ)
        if (!file.exists() || !file.isFile()) {
            String fallback1 = req.getServletContext().getRealPath("/assets/images/combo/" + ten);
            if (fallback1 != null) {
                File fb1 = new File(fallback1);
                if (fb1.exists() && fb1.isFile()) {
                    file = fb1;
                }
            }
        }
        if (!file.exists() || !file.isFile()) {
            String fallback2 = req.getServletContext().getRealPath("/assets/images/" + ten);
            if (fallback2 != null) {
                File fb2 = new File(fallback2);
                if (fb2.exists() && fb2.isFile()) {
                    file = fb2;
                }
            }
        }

        if (!file.exists() || !file.isFile()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String mime = req.getServletContext().getMimeType(file.getName());
        if (mime == null) {
            String lower = file.getName().toLowerCase();
            if (lower.endsWith(".png")) mime = "image/png";
            else if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) mime = "image/jpeg";
            else if (lower.endsWith(".webp")) mime = "image/webp";
            else mime = "application/octet-stream";
        }

        resp.setContentType(mime);
        resp.setContentLengthLong(file.length());
        resp.setHeader("Cache-Control", "public, max-age=86400");

        try (FileInputStream in = new FileInputStream(file); OutputStream out = resp.getOutputStream()) {
            byte[] buf = new byte[8192];
            int len;
            while ((len = in.read(buf)) != -1) {
                out.write(buf, 0, len);
            }
        }
    }
}
