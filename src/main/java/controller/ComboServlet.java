package controller;

import entity.ChiTietCombo;
import entity.Combo;
import entity.SanPham;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.ComboRepository;
import repository.SanPhamRepository;
import util.AnhDanhMuc;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

// Controller điều phối toàn bộ chức năng Quản lý Combo bắp nước
// URL: /quan-ly-combo
// Chức năng: Xem danh sách, Tìm kiếm, Thêm, Sửa, Xóa, Xem chi tiết JSON
// Tra cứu chức năng: docs/TRA_CUU_COMBO_SAN_PHAM_THONG_KE.txt
@WebServlet(name = "ComboServlet", urlPatterns = {"/quan-ly-combo"})
@MultipartConfig(maxFileSize = AnhDanhMuc.GIOI_HAN_TEP, maxRequestSize = AnhDanhMuc.GIOI_HAN_YEU_CAU)
public class ComboServlet extends HttpServlet {

    private final ComboRepository comboRepo = new ComboRepository();
    private final SanPhamRepository sanPhamRepo = new SanPhamRepository();

    // ======================== XỬ LÝ GET ========================

    @Override
    // [CB-MO-TRANG] Tạo token phiên, nhận yêu cầu xem danh sách, tìm kiếm, sửa hoặc xem chi tiết.
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
            case "edit":     moFormSua(req, resp);       break;  // ?action=edit&id=1
            case "delete":   resp.sendError(405);        break;  // Xóa chỉ nhận POST.
            case "chiTiet":  traChiTietJson(req, resp);  break;  // ?action=chiTiet&id=1
            default:         hienThiDanhSach(req, resp); break;  // Mặc định: hiển thị danh sách
        }
    }

    // ======================== XỬ LÝ POST ========================

    @Override
    // [CB-NHAN-FORM] Kiểm tra token rồi chuyển action add/update/delete đến hàm tương ứng.
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        if (!AnhDanhMuc.docForm(req, resp)) return;

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
            String message;
            if (e instanceof IllegalArgumentException) {
                message = e.getMessage();
            } else {
                message = "Không thể lưu dữ liệu. Vui lòng thử lại.";
            }
            String edit = "update".equals(req.getParameter("action")) ? "&action=edit&id="
                + java.net.URLEncoder.encode(java.util.Objects.toString(req.getParameter("maCombo"), ""), java.nio.charset.StandardCharsets.UTF_8) : "";
            resp.sendRedirect(req.getContextPath() + "/quan-ly-combo?msg=error" + edit + "&error="
                + java.net.URLEncoder.encode(message, java.nio.charset.StandardCharsets.UTF_8));
        }
    }

    // ======================== CÁC HÀM XỬ LÝ ========================

    // Hiển thị trang mặc định: danh sách combo + danh sách sản phẩm lẻ (để chọn khi thêm combo)
    // [CB-DANH-SACH] Lấy combo và sản phẩm đang bán, chuyển sang quanLyCombo.jsp.
    private void hienThiDanhSach(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("dsCombo", comboRepo.getAll());           // Danh sách combo
        req.setAttribute("dsSanPham", sanPhamRepo.getAllDangKinhDoanh()); // Sản phẩm đang bán
        req.getRequestDispatcher("/quanLyCombo.jsp").forward(req, resp);
    }

    // Tìm kiếm combo theo từ khóa + lọc trạng thái
    // [CB-TIM-KIEM] Đọc keyword/trangThai, tìm trong database và giữ lại bộ lọc trên form.
    private void timKiemCombo(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        String trangThai = req.getParameter("trangThai");

        req.setAttribute("dsCombo", comboRepo.search(keyword, trangThai));
        req.setAttribute("dsSanPham", sanPhamRepo.getAllDangKinhDoanh());
        req.setAttribute("keyword", keyword);           // Giữ lại từ khóa trên ô tìm kiếm
        req.setAttribute("trangThaiLoc", trangThai);    // Giữ lại trạng thái đã chọn
        req.getRequestDispatcher("/quanLyCombo.jsp").forward(req, resp);
    }

    // Tải dữ liệu combo cần sửa lên modal
    // [CB-MO-SUA] Đọc combo, thành phần và dấu phiên bản; giữ cả món cũ đã ngừng bán.
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
        Map<Integer, ChiTietCombo> editChiTietMap = new LinkedHashMap<>();
        if (editChiTiet != null) {
            for (ChiTietCombo ct : editChiTiet) {
                editChiTietMap.put(ct.getMaSP(), ct);
            }
        }

        req.setAttribute("dsCombo", comboRepo.getAll());
        req.setAttribute("editCombo", editCombo);           // Thông tin combo đang sửa
        req.setAttribute("editChiTietMap", editChiTietMap); // Map sản phẩm đã chọn
        // Giữ cả sản phẩm cũ đã ngừng bán để việc sửa không làm mất chi tiết.
        Map<Integer, SanPham> sanPhamChon = new LinkedHashMap<>();
        List<SanPham> dangBan = sanPhamRepo.getAllDangKinhDoanh();
        req.setAttribute("dsSanPham", dangBan);
        for (SanPham sp : dangBan) {
            sanPhamChon.put(sp.getMaSP(), sp);
        }
        for (ChiTietCombo ct : editChiTiet) {
            if (!sanPhamChon.containsKey(ct.getMaSP())) {
                sanPhamChon.put(ct.getMaSP(), ct.getSanPham());
            }
        }
        req.setAttribute("dsSanPhamSua", new ArrayList<>(sanPhamChon.values()));
        req.setAttribute("version", comboRepo.fingerprint(editCombo, editChiTiet));
        req.getRequestDispatcher("/quanLyCombo.jsp").forward(req, resp);
    }

    // THÊM / SỬA: đọc form, báo lỗi cụ thể và để repository tính giá từ dữ liệu thật.
    // [CB-LUU] Đọc form, thành phần, ảnh; gọi save để lưu trong một giao dịch.
    private void luuCombo(HttpServletRequest req, HttpServletResponse resp, boolean adding)
            throws IOException, ServletException {
        String id;
        if (adding) {
            id = null;
        } else {
            id = req.getParameter("maCombo");
        }
        Combo combo = docThongTinCombo(req, id);
        if (combo == null) throw new IllegalArgumentException("Kiểm tra mã, tên, mô tả, trạng thái và tên ảnh (jpg, jpeg, png, webp).");
        if (adding) combo.setTrangThai("Đang bán");
        List<ChiTietCombo> details = docDanhSachChiTiet(req, combo.getMaCombo());
        String rate = req.getParameter("giamGia");
        int discount;
        try { discount = Integer.parseInt(rate); }
        catch (Exception e) { throw new IllegalArgumentException("Hãy chọn mức giảm giá."); }
        // [CB-ANH] Tên upload mới thay ảnh cũ. Nếu không chọn ảnh thì repository giữ ảnh gốc.
        String anhMoi = AnhDanhMuc.luu(req);
        if (anhMoi != null) combo.setHinhAnh(anhMoi);
        boolean daLuu = false;
        try {
            daLuu = comboRepo.save(combo, details, discount, adding, req.getParameter("version"));
        } finally {
            if (!daLuu) AnhDanhMuc.huyTepMoi(anhMoi);
        }
        resp.sendRedirect(req.getContextPath() + "/quan-ly-combo?msg=" + (adding ? "add_ok" : "update_ok"));
    }

    // Xóa combo — chặn nếu combo đã nằm trong hóa đơn (bảng ChiTietHoaDon)
    // [CB-XOA] Gửi mã combo cho repository kiểm tra và xóa.
    private void xoaCombo(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String maCombo = req.getParameter("id");

        boolean ok = comboRepo.delete(maCombo);
        resp.sendRedirect(req.getContextPath() + "/quan-ly-combo?msg=" + (ok ? "delete_ok" : "error"));
    }

    // Trả JSON danh sách sản phẩm bên trong combo — phục vụ modal Chi tiết qua AJAX/fetch
    // [CB-CHI-TIET] Trả danh sách món dạng JSON để JavaScript mở hộp chi tiết.
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
                    .append("\"maSP\":\"").append(ct.getMaSP()).append("\",")
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
    // [CB-DOC-FORM] Kiểm tra tên, mô tả, mã, ảnh và trạng thái; sai trả null.
    private Combo docThongTinCombo(HttpServletRequest req, String maCombo) {
        try {
            String tenCombo = req.getParameter("tenCombo");
            String moTa = req.getParameter("moTa");
            String hinhAnh = req.getParameter("hinhAnh");
            String trangThai;
            if ("add".equals(req.getParameter("action"))) {
                trangThai = "Đang bán";
            } else {
                trangThai = req.getParameter("trangThai");
            }

            // [CB-KIEM-TRA] Mã sửa phải hợp lệ; mã thêm do SQL tự cấp.
            Integer comboId;
            if ("add".equals(req.getParameter("action"))) {
                comboId = null;
            } else {
                comboId = util.DatabaseId.parse(maCombo);
            }
            if (tenCombo == null || tenCombo.trim().isEmpty()) {
                return null;
            }
            // Trạng thái mặc định "Đang bán" nếu không truyền
            if (trangThai == null || trangThai.trim().isEmpty()) {
                trangThai = "Đang bán";
            }

            // Tên ảnh tĩnh do form cũ gửi lên vẫn được hỗ trợ. Form mới gửi file tepAnh.
            String tenAnh;
            if (hinhAnh != null) {
                tenAnh = hinhAnh.trim();
            } else {
                tenAnh = "";
            }
            if (!tenAnh.isEmpty() && !tenAnh.contains(".")) {
                tenAnh = tenAnh + ".jpg";
            }

            // Kiểm tra giới hạn cột trước khi ghi xuống cơ sở dữ liệu.
            if (tenCombo.trim().length() > 100
                    || (moTa != null && moTa.trim().length() > 255)
                    || (!tenAnh.isEmpty() && !tenAnh.toLowerCase(java.util.Locale.ROOT).matches(".+\\.(jpg|jpeg|png|webp)"))
                    || tenAnh.length() > 255 || tenAnh.contains("/") || tenAnh.contains("\\") || AnhDanhMuc.laAnhDaTai(tenAnh)
                    || !("Đang bán".equals(trangThai.trim()) || "Ngừng bán".equals(trangThai.trim()))) {
                return null;
            }
            // Giá tạm bằng 0; repository tính lại từ giá sản phẩm trong database trước khi lưu.
            return new Combo(comboId, tenCombo.trim(), BigDecimal.ZERO,
                    moTa != null ? moTa.trim() : "", tenAnh, trangThai.trim());
        } catch (IllegalArgumentException e) {
            return null; // Mã hoặc dữ liệu form không hợp lệ.
        }
    }

    // Đọc danh sách sản phẩm đã tích checkbox từ form
    // Cấu trúc form: checkbox name="ctMaSP" value="1"
    //                input name="ctSoLuong_1", input name="ctGhiChu_1"
    // [CB-DOC-MON] Duyệt checkbox, kiểm tra số lượng và ghi chú; Map loại mã sản phẩm lặp.
    private List<ChiTietCombo> docDanhSachChiTiet(HttpServletRequest req, Integer maCombo) {
        String[] selectedMaSPs = req.getParameterValues("ctMaSP"); // Mảng mã SP đã tích
        Map<Integer, ChiTietCombo> map = new LinkedHashMap<>();     // Dùng Map tránh trùng

        if (selectedMaSPs != null) {
            for (String rawMa : selectedMaSPs) {
                Integer maSP = util.DatabaseId.parse(rawMa);

                // Số lượng bắt buộc là số nguyên từ 1 trở lên.
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
    // [CB-JSON] Đổi dấu nháy, gạch chéo và ký tự điều khiển thành chuỗi JSON hợp lệ.
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
