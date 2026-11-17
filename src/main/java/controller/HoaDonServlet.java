package controller;

import entity.ChiTietHoaDon;
import entity.HoaDon;
import entity.Ve;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.HoaDonRepository;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.DecimalFormat;
import java.util.List;
import java.util.Map;

@WebServlet(name = "HoaDonServlet", value = "/hoa-don")
public class HoaDonServlet extends HttpServlet {

    private final HoaDonRepository hoaDonRepo = new HoaDonRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");

        // 1. API trả về JSON chi tiết hóa đơn (cho modal xem lại & in vé)
        if ("detail".equalsIgnoreCase(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            String idStr = req.getParameter("id");
            if (idStr == null || idStr.trim().isEmpty()) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Thiếu mã hóa đơn\"}");
                return;
            }

            try {
                int id = Integer.parseInt(idStr.trim());
                HoaDon hd = hoaDonRepo.getById(id);
                if (hd == null) {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy hóa đơn #" + id + "\"}");
                    return;
                }

                DecimalFormat df = new DecimalFormat("#,##0");
                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"success\":true,");
                json.append("\"maDatVe\":").append(hd.getMaDatVe()).append(",");
                json.append("\"maHienThi\":\"").append(hd.getMaHienThi()).append("\",");
                json.append("\"ngayDat\":\"").append(escapeJson(hd.getNgayDatFormatted())).append("\",");
                json.append("\"tongTien\":").append(hd.getTongTien() != null ? hd.getTongTien() : 0).append(",");
                json.append("\"tongTienFormatted\":\"").append(escapeJson(hd.getTongTienFormatted())).append("\",");
                json.append("\"tenThuNgan\":\"").append(escapeJson(hd.getTenThuNgan() != null ? hd.getTenThuNgan() : "Thu ngân")).append("\",");
                json.append("\"phuongThuc\":\"").append(escapeJson(hd.getPhuongThuc())).append("\",");
                json.append("\"trangThai\":\"").append(escapeJson(hd.getTrangThai())).append("\",");

                // Danh sách Vé
                json.append("\"veList\":[");
                List<Ve> veList = hd.getDanhSachVe();
                for (int i = 0; i < veList.size(); i++) {
                    Ve v = veList.get(i);
                    if (i > 0) json.append(",");
                    json.append("{");
                    json.append("\"maVe\":").append(v.getMaVe()).append(",");
                    json.append("\"tenGhe\":\"").append(escapeJson(v.getTenGhe())).append("\",");
                    json.append("\"tenPhim\":\"").append(escapeJson(v.getTenPhim())).append("\",");
                    json.append("\"tenPhong\":\"").append(escapeJson(v.getTenPhong())).append("\",");
                    json.append("\"ngayChieu\":\"").append(escapeJson(v.getNgayChieu())).append("\",");
                    json.append("\"gioChieu\":\"").append(escapeJson(v.getGioChieu())).append("\",");
                    json.append("\"giaVeFormatted\":\"").append(escapeJson(v.getGiaVeFormatted())).append("\",");
                    json.append("\"maQR\":\"").append(escapeJson(v.getMaQR())).append("\"");
                    json.append("}");
                }
                json.append("],");

                // Danh sách Combo
                json.append("\"comboList\":[");
                List<ChiTietHoaDon> comboList = hd.getDanhSachChiTiet();
                for (int i = 0; i < comboList.size(); i++) {
                    ChiTietHoaDon c = comboList.get(i);
                    if (i > 0) json.append(",");
                    json.append("{");
                    json.append("\"maCombo\":").append(c.getMaCombo()).append(",");
                    json.append("\"tenCombo\":\"").append(escapeJson(c.getTenCombo())).append("\",");
                    json.append("\"soLuong\":").append(c.getSoLuong()).append(",");
                    json.append("\"donGiaFormatted\":\"").append(escapeJson(c.getDonGiaFormatted())).append("\",");
                    json.append("\"thanhTienFormatted\":\"").append(escapeJson(c.getThanhTienFormatted())).append("\"");
                    json.append("}");
                }
                json.append("]");

                json.append("}");

                resp.getWriter().write(json.toString());
            } catch (Exception e) {
                e.printStackTrace();
                resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi máy chủ: " + escapeJson(e.getMessage()) + "\"}");
            }
            return;
        }

        // 2. Mặc định: Hiển thị trang Quản lý hóa đơn & Thống kê
        String keyword = req.getParameter("keyword");
        String fromDate = req.getParameter("fromDate");
        String toDate = req.getParameter("toDate");
        String phuongThuc = req.getParameter("phuongThuc");

        Map<String, Object> thongKe = hoaDonRepo.getThongKe();
        List<HoaDon> list = hoaDonRepo.getAll(keyword, fromDate, toDate, phuongThuc);

        req.setAttribute("thongKe", thongKe);
        req.setAttribute("danhSachHoaDon", list);
        req.setAttribute("keyword", keyword);
        req.setAttribute("fromDate", fromDate);
        req.setAttribute("toDate", toDate);
        req.setAttribute("phuongThuc", phuongThuc);

        req.getRequestDispatcher("/hoa-don/view.jsp").forward(req, resp);
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
