package controller;

import entity.SanPham;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.SanPhamRepository;

import java.io.IOException;
import java.math.BigDecimal;

@WebServlet(name = "SanPhamServlet", urlPatterns = {"/quan-ly-san-pham"})
public class SanPhamServlet extends HttpServlet {

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
                timKiemSanPham(req, resp);
                break;
            case "edit":
                moFormSua(req, resp);
                break;
            case "delete":
                xoaSanPham(req, resp);
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
            themSanPham(req, resp);
        } else if ("update".equals(action)) {
            capNhatSanPham(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/quan-ly-san-pham");
        }
    }

    private void hienThiDanhSach(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("dsSanPham", sanPhamRepo.getAll());
        req.setAttribute("newId", sanPhamRepo.generateId());
        req.getRequestDispatcher("/quanLySanPham.jsp").forward(req, resp);
    }

    private void timKiemSanPham(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        String trangThai = req.getParameter("trangThai");

        req.setAttribute("dsSanPham", sanPhamRepo.search(keyword, trangThai));
        req.setAttribute("newId", sanPhamRepo.generateId());
        req.setAttribute("keyword", keyword);
        req.setAttribute("trangThaiLoc", trangThai);
        req.getRequestDispatcher("/quanLySanPham.jsp").forward(req, resp);
    }

    private void themSanPham(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String maSP = req.getParameter("maSP");
        if (maSP == null || maSP.trim().isEmpty()) {
            maSP = sanPhamRepo.generateId();
        } else {
            maSP = maSP.trim();
        }

        SanPham sp = docThongTinSanPham(req, maSP);
        if (sp == null) {
            resp.sendRedirect(req.getContextPath() + "/quan-ly-san-pham?msg=invalid_data");
            return;
        }

        boolean ok = sanPhamRepo.add(sp);
        resp.sendRedirect(req.getContextPath() + "/quan-ly-san-pham?msg=" + (ok ? "add_ok" : "error"));
    }

    private void moFormSua(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String maSP = req.getParameter("id");
        req.setAttribute("editSP", sanPhamRepo.getOne(maSP));
        req.setAttribute("dsSanPham", sanPhamRepo.getAll());
        req.setAttribute("newId", sanPhamRepo.generateId());
        req.getRequestDispatcher("/quanLySanPham.jsp").forward(req, resp);
    }

    private void capNhatSanPham(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String maSP = req.getParameter("maSP");
        SanPham sp = docThongTinSanPham(req, maSP);
        if (sp == null) {
            resp.sendRedirect(req.getContextPath() + "/quan-ly-san-pham?msg=invalid_data");
            return;
        }

        boolean ok = sanPhamRepo.update(sp);
        resp.sendRedirect(req.getContextPath() + "/quan-ly-san-pham?msg=" + (ok ? "update_ok" : "error"));
    }

    private void xoaSanPham(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String maSP = req.getParameter("id");
        if (sanPhamRepo.isSanPhamUsed(maSP)) {
            resp.sendRedirect(req.getContextPath() + "/quan-ly-san-pham?msg=delete_fail");
            return;
        }
        boolean ok = sanPhamRepo.delete(maSP);
        resp.sendRedirect(req.getContextPath() + "/quan-ly-san-pham?msg=" + (ok ? "delete_ok" : "error"));
    }

    // Đọc & kiểm tra dữ liệu sản phẩm từ form
    private SanPham docThongTinSanPham(HttpServletRequest req, String maSP) {
        try {
            String tenSP = req.getParameter("tenSP");
            String loaiSP = req.getParameter("loaiSP");
            String donViTinh = req.getParameter("donViTinh");
            String giaStr = req.getParameter("giaBan");
            String tonStr = req.getParameter("soLuongTon");
            // SẢN PHẨM: thêm mới luôn đang kinh doanh, kể cả request sửa tay.
            String trangThai = "add".equals(req.getParameter("action")) ? "Đang kinh doanh" : req.getParameter("trangThai");

            if (maSP == null || maSP.trim().isEmpty()
                    || tenSP == null || tenSP.trim().isEmpty()
                    || loaiSP == null || loaiSP.trim().isEmpty()
                    || donViTinh == null || donViTinh.trim().isEmpty()
                    || giaStr == null || giaStr.trim().isEmpty()) {
                return null;
            }

            BigDecimal giaBan = new BigDecimal(giaStr.trim());
            int soLuongTon = (tonStr != null && !tonStr.trim().isEmpty()) ? Integer.parseInt(tonStr.trim()) : 0;
            if (giaBan.compareTo(BigDecimal.ZERO) <= 0 || soLuongTon < 0) {
                return null;
            }

            if (trangThai == null || trangThai.trim().isEmpty()) {
                trangThai = "Đang kinh doanh";
            }

            // Giới hạn nhập theo cột và danh mục đã có trong giao diện.
            if (maSP.length() > 20 || tenSP.trim().length() > 100
                    || !java.util.Arrays.asList("Bắp", "Nước có gas", "Nước suối", "Snack", "Đồ ăn nóng").contains(loaiSP)
                    || !java.util.Arrays.asList("Hộp", "Ly", "Chai", "Gói", "Cây").contains(donViTinh)
                    || !java.util.Arrays.asList("Đang kinh doanh", "Ngừng kinh doanh").contains(trangThai)
                    || giaBan.stripTrailingZeros().scale() > 0 || giaBan.precision() > 18) return null;
            return new SanPham(
                    maSP.trim(),
                    tenSP.trim(),
                    loaiSP.trim(),
                    donViTinh.trim(),
                    giaBan,
                    soLuongTon,
                    trangThai.trim()
            );
        } catch (NumberFormatException e) {
            return null;
        }
    }
}