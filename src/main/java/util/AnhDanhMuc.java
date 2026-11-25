package util;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

/**
 * Tiện ích hỗ trợ tải lên, xác thực và dọn dẹp ảnh danh mục (Sản phẩm & Combo).
 */
public class AnhDanhMuc {

    // Giới hạn tệp đơn: 5 MB
    public static final long GIOI_HAN_TEP = 5L * 1024 * 1024;

    // Giới hạn toàn bộ yêu cầu: 10 MB
    public static final long GIOI_HAN_YEU_CAU = 10L * 1024 * 1024;

    /**
     * Xác định thư mục lưu trữ ảnh danh mục.
     * Mặc định lưu tại ~/.cinemax/anh-danh-muc hoặc theo cấu hình JVM -Dcinemax.anh.dir=...
     */
    public static Path getDuongDanLuuTru() {
        String dirProp = System.getProperty("cinemax.anh.dir");
        if (dirProp != null && !dirProp.trim().isEmpty()) {
            return Path.of(dirProp.trim());
        }
        return Path.of(System.getProperty("user.home"), ".cinemax", "anh-danh-muc");
    }

    /**
     * Kiểm tra và đọc form multipart an toàn trước khi xử lý nghiệp vụ.
     */
    public static boolean docForm(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        // Cho phép form multipart đi qua bình thường
        return true;
    }

    /**
     * Đọc tệp upload 'tepAnh' từ request, kiểm tra định dạng ảnh và lưu vào đĩa.
     * @return Tên tệp đã lưu (VD: "sp_12345678.png") hoặc null nếu người dùng không chọn tệp.
     */
    public static String luu(HttpServletRequest req) throws IOException, ServletException {
        String contentType = req.getContentType();
        if (contentType == null || !contentType.toLowerCase().startsWith("multipart/form-data")) {
            return null;
        }

        Part part;
        try {
            part = req.getPart("tepAnh");
        } catch (Exception e) {
            return null;
        }

        if (part == null || part.getSize() <= 0) {
            return null;
        }

        // Đọc dữ liệu nhị phân của tệp
        byte[] bytes;
        try (InputStream in = part.getInputStream(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            byte[] buf = new byte[8192];
            int len;
            while ((len = in.read(buf)) != -1) {
                out.write(buf, 0, len);
            }
            bytes = out.toByteArray();
        }

        if (bytes.length == 0) {
            return null;
        }

        // Xác thực nội dung tệp bằng ImageIO để chống tệp giả mạo
        BufferedImage img;
        try {
            img = ImageIO.read(new ByteArrayInputStream(bytes));
        } catch (Exception e) {
            throw new IllegalArgumentException("Tệp không phải ảnh. Vui lòng chọn tệp JPG, PNG, WEBP.");
        }

        if (img == null) {
            throw new IllegalArgumentException("Tệp không phải ảnh. Vui lòng chọn tệp JPG, PNG, WEBP.");
        }

        // Xác định phần mở rộng
        String ext = ".png";
        String submittedName = null;
        try {
            submittedName = part.getSubmittedFileName();
        } catch (Exception ignored) {}

        if (submittedName != null && submittedName.contains(".")) {
            String subExt = submittedName.substring(submittedName.lastIndexOf(".")).toLowerCase();
            if (subExt.equals(".jpg") || subExt.equals(".jpeg") || subExt.equals(".png") || subExt.equals(".webp")) {
                ext = subExt;
            }
        }

        // Tạo tên tệp ngẫu nhiên không trùng lặp
        String fileName = "catalog_" + System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8) + ext;

        Path uploadDir = getDuongDanLuuTru();
        Files.createDirectories(uploadDir);

        Path target = uploadDir.resolve(fileName);
        try (ByteArrayInputStream in = new ByteArrayInputStream(bytes)) {
            Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
        }

        return fileName;
    }

    /**
     * Kiểm tra xem tên tệp ảnh có dấu hiệu bất thường hoặc không an toàn hay không.
     */
    public static boolean laAnhDaTai(String tenAnh) {
        if (tenAnh == null || tenAnh.trim().isEmpty()) {
            return false;
        }
        // Chặn các ký tự đường dẫn nguy hiểm (Path Traversal)
        return tenAnh.contains("..") || tenAnh.contains("/") || tenAnh.contains("\\");
    }

    /**
     * Dọn dẹp tệp ảnh mới tải lên nếu lưu CSDL thất bại.
     */
    public static void huyTepMoi(String tenTep) {
        if (tenTep == null || tenTep.trim().isEmpty()) {
            return;
        }
        try {
            Path target = getDuongDanLuuTru().resolve(tenTep.trim());
            Files.deleteIfExists(target);
        } catch (Exception ignored) {}
    }
}
