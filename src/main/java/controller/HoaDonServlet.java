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

        // 2. API Thu tiền hóa đơn Chờ thanh toán
        if ("payNow".equalsIgnoreCase(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            String idStr = req.getParameter("id");
            String phuongThuc = req.getParameter("phuongThuc");
            if (idStr == null || idStr.trim().isEmpty()) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Thiếu mã hóa đơn cần thu tiền!\"}");
                return;
            }
            try {
                int id = Integer.parseInt(idStr.trim());
                boolean ok = hoaDonRepo.hoanTatThanhToan(id, phuongThuc);
                if (ok) {
                    resp.getWriter().write("{\"success\":true,\"message\":\"Đã thu tiền và hoàn tất hóa đơn #" + id + " thành công!\",\"maDatVe\":" + id + "}");
                } else {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Không thể cập nhật thanh toán cho hóa đơn #" + id + "\"}");
                }
            } catch (Exception e) {
                e.printStackTrace();
                resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi: " + escapeJson(e.getMessage()) + "\"}");
            }
            return;
        }

        // 3. API Hủy đơn hàng Chờ thanh toán
        if ("cancel".equalsIgnoreCase(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            String idStr = req.getParameter("id");
            if (idStr == null || idStr.trim().isEmpty()) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Thiếu mã hóa đơn cần hủy!\"}");
                return;
            }
            try {
                int id = Integer.parseInt(idStr.trim());
                boolean ok = hoaDonRepo.huyHoaDon(id);
                if (ok) {
                    resp.getWriter().write("{\"success\":true,\"message\":\"Đã hủy hóa đơn #" + id + " và giải phóng ghế thành công!\"}");
                } else {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Không thể hủy hóa đơn #" + id + "\"}");
                }
            } catch (Exception e) {
                e.printStackTrace();
                resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi: " + escapeJson(e.getMessage()) + "\"}");
            }
            return;
        }

        // 3.5 API Đổi suất chiếu (Phương án B: Bảo lưu vé khi suất cũ bị hủy hoặc khách xin đổi)
        if ("exchangeInfo".equalsIgnoreCase(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            try {
                int id = Integer.parseInt(req.getParameter("id").trim());
                Map<String, Object> info = hoaDonRepo.getExchangeInfo(id);
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> showtimes = (List<Map<String, Object>>) info.get("showtimes");
                StringBuilder sb = new StringBuilder();
                sb.append("{\"success\":true,");
                sb.append("\"ticketCount\":").append(info.get("ticketCount")).append(",");
                sb.append("\"tenPhim\":\"").append(escapeJson((String) info.get("tenPhim"))).append("\",");
                sb.append("\"showtimes\":[");
                for (int i = 0; i < showtimes.size(); i++) {
                    Map<String, Object> st = showtimes.get(i);
                    if (i > 0) sb.append(",");
                    sb.append("{")
                      .append("\"maSuat\":").append(st.get("maSuat")).append(",")
                      .append("\"ngayChieu\":\"").append(escapeJson((String) st.get("ngayChieu"))).append("\",")
                      .append("\"gioBatDau\":\"").append(escapeJson((String) st.get("gioBatDau"))).append("\",")
                      .append("\"tenPhong\":\"").append(escapeJson((String) st.get("tenPhong"))).append("\",")
                      .append("\"dinhDang\":\"").append(escapeJson((String) st.get("dinhDang"))).append("\"")
                      .append("}");
                }
                sb.append("]}");
                resp.getWriter().write(sb.toString());
            } catch (Exception e) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Không tải được danh sách suất thay thế!\"}");
            }
            return;
        }

        if ("exchangeSeats".equalsIgnoreCase(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            try {
                int maSuat = Integer.parseInt(req.getParameter("maSuat").trim());
                List<Map<String, Object>> seats = hoaDonRepo.getFreeSeatsForShowtime(maSuat);
                StringBuilder sb = new StringBuilder("{\"success\":true,\"seats\":[");
                for (int i = 0; i < seats.size(); i++) {
                    Map<String, Object> s = seats.get(i);
                    if (i > 0) sb.append(",");
                    sb.append("{\"maGhe\":").append(s.get("maGhe"))
                      .append(",\"tenGhe\":\"").append(escapeJson((String) s.get("tenGhe"))).append("\"")
                      .append(",\"loaiGhe\":\"").append(escapeJson((String) s.get("loaiGhe"))).append("\"}");
                }
                sb.append("]}");
                resp.getWriter().write(sb.toString());
            } catch (Exception e) {
                resp.getWriter().write("{\"success\":false,\"seats\":[]}");
            }
            return;
        }

        if ("confirmExchange".equalsIgnoreCase(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            try {
                int id = Integer.parseInt(req.getParameter("id").trim());
                int newMaSuat = Integer.parseInt(req.getParameter("maSuat").trim());
                String seatIdsStr = req.getParameter("seatIds");
                List<Integer> newSeatIds = new java.util.ArrayList<>();
                if (seatIdsStr != null && !seatIdsStr.trim().isEmpty()) {
                    for (String p : seatIdsStr.split(",")) {
                        if (!p.trim().isEmpty()) newSeatIds.add(Integer.parseInt(p.trim()));
                    }
                }
                boolean ok = hoaDonRepo.doiSuatChieu(id, newMaSuat, newSeatIds);
                if (ok) {
                    resp.getWriter().write("{\"success\":true,\"message\":\"Đổi suất chiếu & cấp mã QR mới cho hóa đơn #" + id + " thành công!\"}");
                } else {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Đổi suất thất bại! Vui lòng kiểm tra lại số ghế chọn hoặc ghế đã bị đặt.\"}");
                }
            } catch (Exception e) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Dữ liệu đổi suất không hợp lệ!\"}");
            }
            return;
        }

        // 4. Mặc định: Hiển thị trang Quản lý hóa đơn & Thống kê
        String keyword = req.getParameter("keyword");
        String fromDate = req.getParameter("fromDate");
        String toDate = req.getParameter("toDate");
        String phuongThuc = req.getParameter("phuongThuc");
        String trangThai = req.getParameter("trangThai");

        Map<String, Object> thongKe = hoaDonRepo.getThongKe();
        List<HoaDon> list = hoaDonRepo.getAll(keyword, fromDate, toDate, phuongThuc, trangThai);

        // Phân trang (Pagination) - Mặc định 10 hóa đơn / trang
        int pageSize = 10;
        String pageSizeParam = req.getParameter("pageSize");
        if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) {
            try {
                int ps = Integer.parseInt(pageSizeParam.trim());
                if (ps > 0 && ps <= 100) pageSize = ps;
            } catch (NumberFormatException ignored) {}
        }

        int totalItems = list.size();
        int totalPages = (int) Math.ceil((double) totalItems / pageSize);
        if (totalPages <= 0) totalPages = 1;

        int currentPage = 1;
        String pageParam = req.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageParam.trim());
            } catch (NumberFormatException ignored) {}
        }
        if (currentPage < 1) currentPage = 1;
        if (currentPage > totalPages) currentPage = totalPages;

        int fromIndex = (currentPage - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalItems);
        List<HoaDon> pagedList = (totalItems > 0 && fromIndex < totalItems)
                ? list.subList(fromIndex, toIndex)
                : java.util.Collections.emptyList();

        req.setAttribute("thongKe", thongKe);
        req.setAttribute("danhSachHoaDon", pagedList);
        req.setAttribute("currentPage", currentPage);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("totalItems", totalItems);
        req.setAttribute("fromIndex", totalItems > 0 ? (fromIndex + 1) : 0);
        req.setAttribute("toIndex", toIndex);
        req.setAttribute("keyword", keyword);
        req.setAttribute("fromDate", fromDate);
        req.setAttribute("toDate", toDate);
        req.setAttribute("phuongThuc", phuongThuc);
        req.setAttribute("trangThai", trangThai);

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
