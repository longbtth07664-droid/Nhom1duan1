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

@WebServlet(name = "ComboServlet", urlPatterns = {"/quan-ly-combo"})
public class ComboServlet extends HttpServlet {

    private final ComboRepository comboRepo = new ComboRepository();
    private final SanPhamRepository sanPhamRepo = new SanPhamRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        switch (action) {
            case "search":
                timKiemCombo(req, resp);
                break;
            case "edit":
                moFormSua(req, resp);
                break;
            case "delete":
                xoaCombo(req, resp);
                break;
            case "chiTiet":
                traChiTietJson(req, resp);
                break;
            default:
                hienThiDanhSach(req, resp);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");
        if ("add".equals(action)) {
            themCombo(req, resp);
        } else if ("update".equals(action)) {
            capNhatCombo(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/quan-ly-combo");
        }
    }

    // Hiển thị danh sách Combo + Sản phẩm đang kinh doanh
    private void hienThiDanhSach(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("dsCombo", comboRepo.getAll());
        req.setAttribute("dsSanPham", sanPhamRepo.getAllDangKinhDoanh());
        req.setAttribute("newId", comboRepo.generateId());
        req.getRequestDispatcher("/quanLyCombo.jsp").forward(req, resp);
    }

    // Tìm kiếm & lọc theo trạng thái
    private void timKiemCombo(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        String trangThai = req.getParameter("trangThai");

        req.setAttribute("dsCombo", comboRepo.search(keyword, trangThai));
        req.setAttribute("dsSanPham", sanPhamRepo.getAllDangKinhDoanh());
        req.setAttribute("newId", comboRepo.generateId());
        req.setAttribute("keyword", keyword);
        req.setAttribute("trangThaiLoc", trangThai);
        req.getRequestDispatcher("/quanLyCombo.jsp").forward(req, resp);
    }

    // Thêm Combo mới (bắt buộc chọn ít nhất 1 sản phẩm)
    private void themCombo(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String maCombo = req.getParameter("maCombo");
        if (maCombo == null || maCombo.trim().isEmpty()) {
            maCombo = comboRepo.generateId();
        } else {
            maCombo = maCombo.trim();
        }

        if (comboRepo.getOne(maCombo) != null) {
            resp.sendRedirect(req.getContextPath() + "/quan-ly-combo?msg=duplicate_id");
            return;
        }

        Combo combo = docThongTinCombo(req, maCombo);
        if (combo == null) {
            resp.sendRedirect(req.getContextPath() + "/quan-ly-combo?msg=invalid_data");
            return;
        }

        List<ChiTietCombo> dsChiTiet = docDanhSachChiTiet(req, maCombo);
        if (dsChiTiet.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/quan-ly-combo?msg=empty_products");
            return;
        }

        boolean ok = comboRepo.addComboVaChiTiet(combo, dsChiTiet);
        resp.sendRedirect(req.getContextPath() + "/quan-ly-combo?msg=" + (ok ? "add_ok" : "error"));
    }

    // Tải dữ liệu Combo lên modal Sửa (kèm Map sản phẩm đã chọn trước đó)
    private void moFormSua(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String maCombo = req.getParameter("id");
        Combo editCombo = comboRepo.getOne(maCombo);
        List<ChiTietCombo> editChiTiet = comboRepo.getChiTiet(maCombo);

        // Chuyển danh sách chi tiết sang Map<MaSP, ChiTietCombo> để JSP tích sẵn checkbox
        Map<String, ChiTietCombo> editChiTietMap = new LinkedHashMap<>();
        for (ChiTietCombo ct : editChiTiet) {
            editChiTietMap.put(ct.getMaSP(), ct);
        }

        req.setAttribute("dsCombo", comboRepo.getAll());
        req.setAttribute("dsSanPham", sanPhamRepo.getAllDangKinhDoanh());
        req.setAttribute("newId", comboRepo.generateId());
        req.setAttribute("editCombo", editCombo);
        req.setAttribute("editChiTietMap", editChiTietMap);
        req.getRequestDispatcher("/quanLyCombo.jsp").forward(req, resp);
    }

    // Cập nhật Combo + danh sách sản phẩm đã chọn
    private void capNhatCombo(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String maCombo = req.getParameter("maCombo");
        Combo combo = docThongTinCombo(req, maCombo);
        if (combo == null) {
            resp.sendRedirect(req.getContextPath() + "/quan-ly-combo?msg=invalid_data");
            return;
        }

        List<ChiTietCombo> dsChiTiet = docDanhSachChiTiet(req, maCombo);
        if (dsChiTiet.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/quan-ly-combo?msg=empty_products");
            return;
        }

        boolean ok = comboRepo.updateComboVaChiTiet(combo, dsChiTiet);
        resp.sendRedirect(req.getContextPath() + "/quan-ly-combo?msg=" + (ok ? "update_ok" : "error"));
    }

    // Xóa Combo (chặn nếu đã có trong hóa đơn)
    private void xoaCombo(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String maCombo = req.getParameter("id");
        if (comboRepo.isComboInHoaDon(maCombo)) {
            resp.sendRedirect(req.getContextPath() + "/quan-ly-combo?msg=delete_fail");
            return;
        }
        boolean ok = comboRepo.delete(maCombo);
        resp.sendRedirect(req.getContextPath() + "/quan-ly-combo?msg=" + (ok ? "delete_ok" : "error"));
    }

    // Trả JSON chi tiết các món bên trong Combo
    private void traChiTietJson(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String maCombo = req.getParameter("id");
        List<ChiTietCombo> dsChiTiet = comboRepo.getChiTiet(maCombo);

        resp.setContentType("application/json;charset=UTF-8");
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < dsChiTiet.size(); i++) {
            ChiTietCombo ct = dsChiTiet.get(i);
            SanPham sp = ct.getSanPham();
            if (i > 0) {
                json.append(",");
            }
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

    // Đọc thông tin Combo từ form & chuẩn hóa tên file ảnh đuôi .jpg
    private Combo docThongTinCombo(HttpServletRequest req, String maCombo) {
        try {
            String tenCombo = req.getParameter("tenCombo");
            String giaStr = req.getParameter("giaCombo");
            String moTa = req.getParameter("moTa");
            String hinhAnh = req.getParameter("hinhAnh");
            String trangThai = req.getParameter("trangThai");

            if (maCombo == null || maCombo.trim().isEmpty()
                    || tenCombo == null || tenCombo.trim().isEmpty()
                    || giaStr == null || giaStr.trim().isEmpty()) {
                return null;
            }

            BigDecimal giaCombo = new BigDecimal(giaStr.trim());
            if (giaCombo.compareTo(BigDecimal.ZERO) <= 0) {
                return null;
            }

            if (trangThai == null || trangThai.trim().isEmpty()) {
                trangThai = "Đang bán";
            }

            // Chuẩn hóa tên file ảnh .jpg (nếu để trống thì tự lấy theo MaCombo.jpg)
            String tenAnh = (hinhAnh != null) ? hinhAnh.trim() : "";
            if (tenAnh.isEmpty()) {
                tenAnh = maCombo.trim().toLowerCase() + ".jpg";
            } else if (!tenAnh.contains(".")) {
                tenAnh = tenAnh + ".jpg";
            }

            return new Combo(
                    maCombo.trim(),
                    tenCombo.trim(),
                    giaCombo,
                    moTa != null ? moTa.trim() : "",
                    tenAnh,
                    trangThai.trim()
            );
        } catch (NumberFormatException e) {
            return null;
        }
    }

    // Đọc danh sách các sản phẩm đã được tích Checkbox (tên field: ctSoLuong_<MaSP>, ctGhiChu_<MaSP>)
    private List<ChiTietCombo> docDanhSachChiTiet(HttpServletRequest req, String maCombo) {
        String[] selectedMaSPs = req.getParameterValues("ctMaSP");
        Map<String, ChiTietCombo> map = new LinkedHashMap<>();

        if (selectedMaSPs != null) {
            for (String rawMa : selectedMaSPs) {
                String maSP = (rawMa != null) ? rawMa.trim() : "";
                if (maSP.isEmpty()) continue;

                int sl = 1;
                String slStr = req.getParameter("ctSoLuong_" + maSP);
                try {
                    if (slStr != null && !slStr.trim().isEmpty()) {
                        sl = Math.max(1, Integer.parseInt(slStr.trim()));
                    }
                } catch (NumberFormatException ignored) {
                }

                String ghiChu = req.getParameter("ctGhiChu_" + maSP);
                map.put(maSP, new ChiTietCombo(maCombo, maSP, sl, ghiChu != null ? ghiChu.trim() : ""));
            }
        }
        return new ArrayList<>(map.values());
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}