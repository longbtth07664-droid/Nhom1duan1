package controller;

import entity.Ve;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.HoaDonRepository;

import java.io.BufferedReader;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Controller Soát vé (Check-in) trước khi vào phòng chiếu phim CINEMAX
 * Nghiệp vụ:
 * 1. Nhận mã vé hoặc mã QR từ máy quét mã vạch / camera / thu ngân gõ tay
 * 2. Kiểm tra tính hợp lệ: Vé tồn tại? Đã thanh toán chưa? Có bị hủy không?
 * 3. Chống gian lận: Kiểm tra vé đã check-in vào phòng trước đó hay chưa (tránh 1 vé dùng nhiều lần)
 * 4. Nếu hợp lệ: Cập nhật trạng thái vé thành "Đã check-in", trả về thông tin phim, phòng, ghế để khách vào
 */
@WebServlet(name = "CheckInServlet", value = "/check-in")
public class CheckInServlet extends HttpServlet {

    private final HoaDonRepository hoaDonRepo = new HoaDonRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        // Lấy danh sách 15 vé vừa soát vé gần nhất để hiển thị bảng lịch sử ca trực
        List<Ve> lichSuCheckIn = hoaDonRepo.getLichSuCheckIn();
        req.setAttribute("lichSuCheckIn", lichSuCheckIn);

        // Chuyển tiếp tới giao diện soát vé
        req.getRequestDispatcher("/check-in/view.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        // Đọc mã QR / mã vé gửi lên (Hỗ trợ cả form POST lẫn JSON body)
        String code = req.getParameter("code");

        String contentType = req.getContentType();
        if (contentType != null && contentType.contains("application/json")) {
            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = req.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
            }
            String jsonBody = sb.toString();
            code = extractJsonField(jsonBody, "code");
        }

        if (code == null || code.trim().isEmpty()) {
            resp.getWriter().write("{\"success\":false,\"statusCode\":\"INVALID_INPUT\",\"message\":\"Vui lòng nhập hoặc quét mã vé!\"}");
            return;
        }

        // Gọi Repository để kiểm tra và thực hiện check-in vé
        Map<String, Object> result = hoaDonRepo.kiemTraVaCheckInVe(code.trim());

        boolean success = Boolean.TRUE.equals(result.get("success"));
        String statusCode = (String) result.get("statusCode");
        String message = (String) result.get("message");
        Ve ve = (Ve) result.get("ve");

        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss dd/MM/yyyy");
        String nowStr = sdf.format(new Date());

        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"success\":").append(success).append(",");
        json.append("\"statusCode\":\"").append(escapeJson(statusCode)).append("\",");
        json.append("\"message\":\"").append(escapeJson(message)).append("\",");
        json.append("\"thoiGianCheckIn\":\"").append(escapeJson(nowStr)).append("\"");

        if (ve != null) {
            json.append(",\"ve\":{");
            json.append("\"maVe\":").append(ve.getMaVe()).append(",");
            json.append("\"maDatVe\":").append(ve.getMaDatVe()).append(",");
            json.append("\"tenGhe\":\"").append(escapeJson(ve.getTenGhe())).append("\",");
            json.append("\"tenPhim\":\"").append(escapeJson(ve.getTenPhim())).append("\",");
            json.append("\"tenPhong\":\"").append(escapeJson(ve.getTenPhong())).append("\",");
            json.append("\"gioChieu\":\"").append(escapeJson(ve.getGioChieu())).append("\",");
            json.append("\"ngayChieu\":\"").append(escapeJson(ve.getNgayChieu())).append("\",");
            json.append("\"giaVeFormatted\":\"").append(escapeJson(ve.getGiaVeFormatted())).append("\",");
            json.append("\"maQR\":\"").append(escapeJson(ve.getMaQR())).append("\",");
            json.append("\"trangThai\":\"").append(escapeJson(ve.getTrangThai())).append("\"");
            json.append("}");
        }

        json.append("}");

        resp.getWriter().write(json.toString());
    }

    private String extractJsonField(String json, String field) {
        if (json == null) return null;
        Pattern p = Pattern.compile("\"" + field + "\"\\s*:\\s*\"?([^,\"}]+)\"?");
        Matcher m = p.matcher(json);
        if (m.find()) {
            return m.group(1).trim();
        }
        return null;
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
