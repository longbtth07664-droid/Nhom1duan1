package controller;

import entity.ChiTietCombo;
import entity.Combo;
import entity.SanPham;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.ComboRepository;
import repository.SanPhamRepository;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

// Controller điều phối toàn bộ chức năng Quản lý Combo bắp nước
// URL: /quan-ly-combo
// Chức năng: Xem danh sách, Tìm kiếm, Thêm, Sửa, Xóa, Xem chi tiết JSON
@WebServlet(name = "ComboServlet", urlPatterns = {"/quan-ly-combo"})
public class ComboServlet extends HttpServlet {

    private final ComboRepository comboRepo = new ComboRepository();
    private final SanPhamRepository sanPhamRepo = new SanPhamRepository();

    // ======================== XỬ LÝ GET ========================

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            if (req.getSession().getAttribute("comboToken") == null)
                req.getSession().setAttribute("comboToken", java.util.UUID.randomUUID().toString());
            xuLyGet(req, resp);
        }
        catch (RuntimeException e) {
            log("Không tải được combo", e);
            resp.sendError(500, "Không tải được dữ liệu combo. Vui lòng thử lại.");
        }
    }

    protected void xuLyGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        // Đọc tham số action từ URL, mặc định là "list"
        String action = req.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        // Điều hướng tới hàm xử lý tương ứng
        switch (action) {
            case "search":   timKiemCombo(req, resp);    break;  // ?action=search
            case "edit":     moFormSua(req, resp);       break;  // ?action=edit&id=CB01
            case "delete":   resp.sendError(405);        break;  // ?action=delete&id=CB01
            case "chiTiet":  traChiTietJson(req, resp);  break;  // ?action=chiTiet&id=CB01
            default:         hienThiDanhSach(req, resp); break;  // Mặc định: hiển thị danh sách
        }
    }

    // ======================== XỬ LÝ POST ========================

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        try {
            // Token bảo vệ thao tác thay đổi dữ liệu combo.
            Object token = req.getSession().getAttribute("comboToken");
            if (token == null || !token.equals(req.getParameter("token"))) {
                resp.sendError(403, "Phiên làm việc không hợp lệ. Hãy tải lại trang.");
                return;
            }
            String action = req.getParameter("action");
            if ("add".equals(action)) luuCombo(req, resp, true);
            else if ("update".equals(action)) luuCombo(req, resp, false);
            else if ("delete".equals(action)) xoaCombo(req, resp);
            else resp.sendError(400);
        } catch (RuntimeException e) {
            log("Không lưu được combo", e);
            String message = e instanceof IllegalArgumentException ? e.getMessage() : "Không thể lưu dữ liệu. Vui lòng thử lại.";
            String edit = "update".equals(req.getParameter("action")) ? "&action=edit&id="
                + java.net.URLEncoder.encode(req.getParameter("maCombo"), java.nio.charset.StandardCharsets.UTF_8) : "";
            resp.sendRedirect(req.getContextPath() + "/quan-ly-combo?msg=error" + edit + "&error="
                + java.net.URLEncoder.encode(message, java.nio.charset.StandardCharsets.UTF_8));
        }
    }

    // ======================== CÁC HÀM XỬ LÝ ========================

    // Hiển thị trang mặc định: danh sách combo + danh sách sản phẩm lẻ (để chọn khi thêm combo)
    private void hienThiDanhSach(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("dsCombo", comboRepo.getAll());           // Danh sách combo
        req.setAttribute("dsSanPham", sanPhamRepo.getAllDangKinhDoanh()); // Sản phẩm đang bán
        req.setAttribute("newId", comboRepo.generateId());         // Mã combo tiếp theo
        req.getRequestDispatcher("/quanLyCombo.jsp").forward(req, resp);
    }

    // Tìm kiếm combo theo từ khóa + lọc trạng thái
    private void timKiemCombo(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        String trangThai = req.getParameter("trangThai");

        req.setAttribute("dsCombo", comboRepo.search(keyword, trangThai));
        req.setAttribute("dsSanPham", sanPhamRepo.getAllDangKinhDoanh());
        req.setAttribute("newId", comboRepo.generateId());
        req.setAttribute("keyword", keyword);           // Giữ lại từ khóa trên ô tìm kiếm
        req.setAttribute("trangThaiLoc", trangThai);    // Giữ lại trạng thái đã chọn
        req.getRequestDispatcher("/quanLyCombo.jsp").forward(req, resp);
    }

    // Tải dữ liệu combo cần sửa lên modal
    private void moFormSua(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String maCombo = req.getParameter("id");
        Combo editCombo = comboRepo.getOne(maCombo);
        if (editCombo == null) {
            resp.sendRedirect(req.getContextPath() + "/quan-ly-combo?msg=invalid_data");
            return;
        }
        List<ChiTietCombo> editChiTiet = comboRepo.getChiTiet(maCombo);

        // Chuyển danh sách chi tiết → Map<MaSP, ChiTietCombo>
        // để JSP tra cứu nhanh xem sản phẩm nào đã tích checkbox
        Map<String, ChiTietCombo> editChiTietMap = new LinkedHashMap<>();
        if (editChiTiet != null) {
            for (ChiTietCombo ct : editChiTiet) {
                editChiTietMap.put(ct.getMaSP(), ct);
            }
        }

        req.setAttribute("dsCombo", comboRepo.getAll());
        req.setAttribute("dsSanPham", sanPhamRepo.getAllDangKinhDoanh());
        req.setAttribute("newId", comboRepo.generateId());
        req.setAttribute("editCombo", editCombo);           // Thông tin combo đang sửa
        req.setAttribute("editChiTietMap", editChiTietMap); // Map sản phẩm đã chọn
        // Giữ cả sản phẩm cũ đã ngừng bán để việc sửa không làm mất chi tiết.
        Map<String, SanPham> sanPhamChon = new LinkedHashMap<>();
        for (SanPham sp : sanPhamRepo.getAllDangKinhDoanh()) {
            sanPhamChon.put(sp.getMaSP(), sp);
        }
        for (ChiTietCombo ct : editChiTiet) {
            sanPhamChon.putIfAbsent(ct.getMaSP(), ct.getSanPham());
        }
        req.setAttribute("dsSanPhamSua", new ArrayList<>(sanPhamChon.values()));
        req.setAttribute("version", comboRepo.fingerprint(editCombo, editChiTiet));
        req.getRequestDispatcher("/quanLyCombo.jsp").forward(req, resp);
    }

    // THÊM / SỬA: đọc form, báo lỗi cụ thể và để repository tính giá từ dữ liệu thật.
    private void luuCombo(HttpServletRequest req, HttpServletResponse resp, boolean adding) throws IOException {
        String id = adding ? comboRepo.generateId() : req.getParameter("maCombo");
        Combo combo = docThongTinCombo(req, id);
        if (combo == null) throw new IllegalArgumentException("Kiểm tra tên, mô tả, trạng thái và tên ảnh .jpg.");
        if (adding) combo.setTrangThai("Đang bán");
        List<ChiTietCombo> details = docDanhSachChiTiet(req, id);
        String rate = req.getParameter("giamGia");
        int discount;
        try { discount = Integer.parseInt(rate); }
        catch (Exception e) { throw new IllegalArgumentException("Hãy chọn mức giảm giá."); }
        comboRepo.save(combo, details, discount, adding, req.getParameter("version"));
        resp.sendRedirect(req.getContextPath() + "/quan-ly-combo?msg=" + (adding ? "add_ok" : "update_ok"));
    }

    // Xóa combo — chặn nếu combo đã nằm trong hóa đơn (bảng ChiTietHoaDon)
    private void xoaCombo(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String maCombo = req.getParameter("id");

        boolean ok = comboRepo.delete(maCombo);
        resp.sendRedirect(req.getContextPath() + "/quan-ly-combo?msg=" + (ok ? "delete_ok" : "error"));
    }

    // Trả JSON danh sách sản phẩm bên trong combo — phục vụ modal Chi tiết qua AJAX/fetch
    private void traChiTietJson(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String maCombo = req.getParameter("id");
        List<ChiTietCombo> dsChiTiet = comboRepo.getChiTiet(maCombo);

        resp.setContentType("application/json;charset=UTF-8");

        // Ghép JSON thủ công (không dùng thư viện bên ngoài)
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < dsChiTiet.size(); i++) {
            ChiTietCombo ct = dsChiTiet.get(i);
            SanPham sp = ct.getSanPham();

            if (i > 0) json.append(","); // Dấu phẩy ngăn cách giữa các phần tử

            json.append("{")
                    .append("\"maSP\":\"").append(escapeJson(ct.getMaSP())).append("\",")
                    .append("\"tenSP\":\"").append(escapeJson(sp != null ? sp.getTenSP() : "")).append("\",")
                    .append("\"donViTinh\":\"").append(escapeJson(sp != null ? sp.getDonViTinh() : "")).append("\",")
                    .append("\"soLuong\":").append(ct.getSoLuong()).append(",")
                    .append("\"giaBan\":").append(sp != null && sp.getGiaBan() != null ? sp.getGiaBan().toPlainString() : "0").append(",")
                    .append("\"ghiChu\":\"").append(escapeJson(ct.getGhiChu())).append("\"")
                    .append("}");
        }
        json.append("]");
        resp.getWriter().write(json.toString());
    }

    // ======================== HÀM HỖ TRỢ ========================

    // Đọc thông tin combo từ form request → trả về Combo hợp lệ hoặc null nếu sai
    private Combo docThongTinCombo(HttpServletRequest req, String maCombo) {
        try {
            String tenCombo = req.getParameter("tenCombo");
            String giaStr = "1"; // Giá thật được tính tại repository, không tin giá gửi từ trình duyệt.
            String moTa = req.getParameter("moTa");
            String hinhAnh = req.getParameter("hinhAnh");
            String trangThai = "add".equals(req.getParameter("action")) ? "Đang bán" : req.getParameter("trangThai");

            // Bắt buộc: mã, tên, giá không được trống
            if (maCombo == null || maCombo.trim().isEmpty()
                    || tenCombo == null || tenCombo.trim().isEmpty()
                    || giaStr == null || giaStr.trim().isEmpty()) {
                return null;
            }

            // Giá phải là số dương
            BigDecimal giaCombo = new BigDecimal(giaStr.trim());
            // Trạng thái mặc định "Đang bán" nếu không truyền
            if (trangThai == null || trangThai.trim().isEmpty()) {
                trangThai = "Đang bán";
            }

            // Chuẩn hóa tên file ảnh: nếu trống → lấy "[maCombo].jpg", nếu thiếu đuôi → thêm ".jpg"
            String tenAnh = (hinhAnh != null) ? hinhAnh.trim() : "";
            if (tenAnh.isEmpty()) {
                tenAnh = maCombo.trim().toLowerCase() + ".jpg";
            } else if (!tenAnh.contains(".")) {
                tenAnh = tenAnh + ".jpg";
            }

            // Kiểm tra giới hạn cột trước khi ghi xuống cơ sở dữ liệu.
            if (maCombo.trim().length() > 20 || tenCombo.trim().length() > 100
                    || (moTa != null && moTa.trim().length() > 255)
                    || !tenAnh.toLowerCase(java.util.Locale.ROOT).endsWith(".jpg") || tenAnh.length() > 255 || tenAnh.contains("/") || tenAnh.contains("\\")
                    || !("Đang bán".equals(trangThai.trim()) || "Ngừng bán".equals(trangThai.trim()))) {
                return null;
            }
            return new Combo(maCombo.trim(), tenCombo.trim(), giaCombo,
                    moTa != null ? moTa.trim() : "", tenAnh, trangThai.trim());
        } catch (NumberFormatException e) {
            return null; // Giá không phải số → trả null
        }
    }

    // Đọc danh sách sản phẩm đã tích checkbox từ form
    // Cấu trúc form: checkbox name="ctMaSP" value="SP01"
    //                input name="ctSoLuong_SP01", input name="ctGhiChu_SP01"
    private List<ChiTietCombo> docDanhSachChiTiet(HttpServletRequest req, String maCombo) {
        String[] selectedMaSPs = req.getParameterValues("ctMaSP"); // Mảng mã SP đã tích
        Map<String, ChiTietCombo> map = new LinkedHashMap<>();     // Dùng Map tránh trùng

        if (selectedMaSPs != null) {
            for (String rawMa : selectedMaSPs) {
                String maSP = (rawMa != null) ? rawMa.trim() : "";
                if (maSP.isEmpty()) throw new IllegalArgumentException("Mã sản phẩm không hợp lệ.");

                // Đọc số lượng, mặc định = 1, tối thiểu = 1
                int sl = 0;
                String slStr = req.getParameter("ctSoLuong_" + maSP);
                try {
                    if (slStr != null && !slStr.trim().isEmpty()) {
                        sl = Integer.parseInt(slStr.trim());
                    }
                } catch (NumberFormatException ignored) {
                    throw new IllegalArgumentException("Số lượng phải là số nguyên dương.");
                }

                // Đọc ghi chú
                String ghiChu = req.getParameter("ctGhiChu_" + maSP);
                if (sl < 1 || (ghiChu != null && ghiChu.trim().length() > 100)) {
                    throw new IllegalArgumentException("Số lượng phải từ 1; ghi chú tối đa 100 ký tự.");
                }
                map.put(maSP, new ChiTietCombo(maCombo, maSP, sl, ghiChu != null ? ghiChu.trim() : ""));
            }
        }
        return new ArrayList<>(map.values());
    }

    // Escape ký tự đặc biệt khi ghép chuỗi JSON thủ công
    private String escapeJson(String s) {
        if (s == null) return "";
        StringBuilder result = new StringBuilder();
        // JSON yêu cầu escape toàn bộ ký tự điều khiển, kể cả tab trong ghi chú.
        for (char c : s.toCharArray()) {
            if (c == '"' || c == '\\') result.append('\\').append(c);
            else if (c < 32) result.append(String.format("\\u%04x", (int) c));
            else result.append(c);
        }
        return result.toString();
    }
}
