package controller;

import entity.SanPham;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.SanPhamRepository;
import util.AnhDanhMuc;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ConcurrentModificationException;
import java.util.UUID;

@WebServlet(name = "SanPhamServlet", urlPatterns = {"/quan-ly-san-pham"})
@MultipartConfig(maxFileSize = AnhDanhMuc.GIOI_HAN_TEP, maxRequestSize = AnhDanhMuc.GIOI_HAN_YEU_CAU)
public class SanPhamServlet extends HttpServlet {

    private final SanPhamRepository sanPhamRepo = new SanPhamRepository();

    @Override
    /** [SanPhamServlet-doGet] Nhận yêu cầu mở trang. Đọc bộ lọc, gọi hàm xử lý rồi chuyển dữ liệu sang JSP. */
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            if (req.getSession().getAttribute("sanPhamToken") == null) {
                req.getSession().setAttribute("sanPhamToken", UUID.randomUUID().toString());
            }
            xuLyGet(req, resp);
        } catch (IllegalArgumentException e) {
            resp.sendRedirect(req.getContextPath() + "/quan-ly-san-pham?msg=invalid_data");
        } catch (RuntimeException e) {
            log("Không tải được sản phẩm", e);
            resp.sendError(503, "Không tải được dữ liệu sản phẩm. Vui lòng kiểm tra kết nối cơ sở dữ liệu.");
        }
    }

    private void xuLyGet(HttpServletRequest req, HttpServletResponse resp)
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
                resp.sendError(405);
                break;
            default:
                hienThiDanhSach(req, resp);
                break;
        }
    }

    @Override
    /** [SanPhamServlet-doPost] Nhận dữ liệu form gửi lên. Xác định action và gọi chức năng thêm, sửa hoặc xóa. */
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        if (!AnhDanhMuc.docForm(req, resp)) return;

        // [SP-POST] Tất cả thao tác ghi đi qua POST và phải có token của phiên quản lý.
        Object token = req.getSession().getAttribute("sanPhamToken");
        if (token == null || !token.equals(req.getParameter("token"))) {
            resp.sendError(403, "Phiên làm việc không hợp lệ. Hãy tải lại trang.");
            return;
        }
        try {
            String action = req.getParameter("action");
            if ("add".equals(action)) themSanPham(req, resp);
            else if ("update".equals(action)) capNhatSanPham(req, resp);
            else if ("delete".equals(action)) xoaSanPham(req, resp);
            else resp.sendError(400);
        } catch (IllegalArgumentException e) {
            log("Dữ liệu sản phẩm không hợp lệ", e);
            resp.sendRedirect(req.getContextPath() + "/quan-ly-san-pham?msg=invalid_data&error="
                    + java.net.URLEncoder.encode(e.getMessage() == null ? "Dữ liệu không hợp lệ." : e.getMessage(),
                    java.nio.charset.StandardCharsets.UTF_8));
        } catch (RuntimeException e) {
            log("Không lưu được sản phẩm", e);
            resp.sendRedirect(req.getContextPath() + "/quan-ly-san-pham?msg=error");
        }
    }

    /** [SanPhamServlet-hienThiDanhSach] Lấy danh sách từ repository, đặt vào request bằng setAttribute, forward sang JSP. */
    private void hienThiDanhSach(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("dsSanPham", sanPhamRepo.getAll());
        req.getRequestDispatcher("/quanLySanPham.jsp").forward(req, resp);
    }

    private void timKiemSanPham(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        String trangThai = req.getParameter("trangThai");

        req.setAttribute("dsSanPham", sanPhamRepo.search(keyword, trangThai));
        req.setAttribute("keyword", keyword);
        req.setAttribute("trangThaiLoc", trangThai);
        req.getRequestDispatcher("/quanLySanPham.jsp").forward(req, resp);
    }

    private void themSanPham(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        SanPham sp = docThongTinSanPham(req, null);
        if (sp == null) {
            resp.sendRedirect(req.getContextPath() + "/quan-ly-san-pham?msg=invalid_data");
            return;
        }

        boolean ok = luuSanPhamCoAnh(req, sp, true);
        resp.sendRedirect(req.getContextPath() + "/quan-ly-san-pham?msg=" + (ok ? "add_ok" : "error"));
    }

    /** [SanPhamServlet-moFormSua] Lấy bản hiện có và danh sách cho form; đặt editSP/editCombo vào request để JSP mở hộp sửa. */
    private void moFormSua(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String maSP = req.getParameter("id");
        SanPham product = sanPhamRepo.getOne(maSP);
        if (product == null) {
            resp.sendRedirect(req.getContextPath() + "/quan-ly-san-pham?msg=invalid_data");
            return;
        }
        req.setAttribute("editSP", product);
        req.setAttribute("version", sanPhamRepo.fingerprint(product));
        req.setAttribute("dsSanPham", sanPhamRepo.getAll());
        req.getRequestDispatcher("/quanLySanPham.jsp").forward(req, resp);
    }

    private void capNhatSanPham(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        String maSP = req.getParameter("maSP");
        SanPham sp = docThongTinSanPham(req, maSP);
        if (sp == null) {
            resp.sendRedirect(req.getContextPath() + "/quan-ly-san-pham?msg=invalid_data");
            return;
        }

        try {
            boolean ok = luuSanPhamCoAnh(req, sp, false);
            resp.sendRedirect(req.getContextPath() + "/quan-ly-san-pham?msg=" + (ok ? "update_ok" : "error"));
        } catch (ConcurrentModificationException e) {
            resp.sendRedirect(req.getContextPath() + "/quan-ly-san-pham?msg=stale");
        }
    }

    // [SP-ANH] Dọn tệp mới nếu SQL từ chối lưu, kể cả khi form sửa đã cũ.
    private boolean luuSanPhamCoAnh(HttpServletRequest req, SanPham sp, boolean themMoi)
            throws IOException, ServletException {
        String anhMoi = AnhDanhMuc.luu(req);
        sp.setHinhAnh(anhMoi);
        boolean daLuu = false;
        try {
            if (themMoi) daLuu = sanPhamRepo.add(sp);
            else daLuu = sanPhamRepo.update(sp, req.getParameter("version"));
            return daLuu;
        } finally {
            if (!daLuu) AnhDanhMuc.huyTepMoi(anhMoi);
        }
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
    /** [SanPhamServlet-docThongTinSanPham] Đọc tên, loại, đơn vị, giá, tồn kho, trạng thái. Kiểm tra bắt buộc, danh mục và giới hạn cột rồi tạo SanPham; sai trả null. */
    private SanPham docThongTinSanPham(HttpServletRequest req, String maSP) {
        try {
            String tenSP = req.getParameter("tenSP");
            String loaiSP = req.getParameter("loaiSP");
            String donViTinh = req.getParameter("donViTinh");
            String giaStr = req.getParameter("giaBan");
            String tonStr = req.getParameter("soLuongTon");
            // SẢN PHẨM: thêm mới luôn đang kinh doanh, kể cả request sửa tay.
            String trangThai = "add".equals(req.getParameter("action")) ? "Đang kinh doanh" : req.getParameter("trangThai");

            Integer productId = "add".equals(req.getParameter("action")) ? null : util.DatabaseId.parse(maSP);
            if (productId != null && (tonStr == null || tonStr.isBlank()
                    || trangThai == null || trangThai.isBlank())) return null;
            if (tenSP == null || tenSP.trim().isEmpty()
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
            if (tenSP.trim().length() > 100
                    || !namTrongDanhSach(loaiSP, new String[]{"Bắp", "Nước có gas", "Nước suối", "Snack", "Đồ ăn nóng"})
                    || !namTrongDanhSach(donViTinh, new String[]{"Hộp", "Ly", "Chai", "Gói", "Cây"})
                    || !namTrongDanhSach(trangThai, new String[]{"Đang kinh doanh", "Ngừng kinh doanh"})
                    || giaBan.stripTrailingZeros().scale() > 0
                    || giaBan.compareTo(new BigDecimal("999999999999999999")) > 0) return null;
            giaBan = giaBan.setScale(0);
            return new SanPham(
                    productId,
                    tenSP.trim(),
                    loaiSP.trim(),
                    donViTinh.trim(),
                    giaBan,
                    soLuongTon,
                    trangThai.trim()
            );
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
    // [SP-DANHMUC] Duyệt từng giá trị cho phép; bằng một giá trị thì hợp lệ.
    private boolean namTrongDanhSach(String giaTri, String[] danhSach) {
        for (String phanTu : danhSach) {
            if (phanTu.equals(giaTri)) {
                return true;
            }
        }
        return false;
    }}
