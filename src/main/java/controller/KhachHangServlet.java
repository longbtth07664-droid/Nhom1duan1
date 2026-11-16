package controller;

import entity.KhachHang;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.KhachHangRepository;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "KhachHangServlet", urlPatterns = {
        "/khach-hang/view",
        "/khach-hang/detail",
        "/khach-hang/add",
        "/khach-hang/update"
})
public class KhachHangServlet extends HttpServlet {

    private final KhachHangRepository repo = new KhachHangRepository();
    private static final String VIEW = "/khach-hang/view.jsp";
    private static final int PAGE_SIZE = 5;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getServletPath();

        if (path.equals("/khach-hang/view")) {
            loadPaging(req);
            req.getRequestDispatcher(VIEW).forward(req, resp);

        } else if (path.equals("/khach-hang/detail")) {
            String id = getParam(req, "id");
            KhachHang kh = repo.getById(id);
            if (kh == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy khách hàng!");
                return;
            }
            req.setAttribute("kh", kh);
            req.setAttribute("openModal", "detail");
            loadPaging(req);
            req.getRequestDispatcher(VIEW).forward(req, resp);

        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String path = req.getServletPath();

        if (path.equals("/khach-hang/add")) {
            handleAdd(req, resp);
        } else if (path.equals("/khach-hang/update")) {
            handleUpdate(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // ==================== XỬ LÝ THÊM ====================
    private void handleAdd(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String maKH   = getParam(req, "maKH");
        String hoTen  = getParam(req, "hoTen");
        String sdt    = getParam(req, "sdt");
        String gioiTinh = getParam(req, "gioiTinh");
        String diemStr = getParam(req, "diemTichLuy");

        // Điểm tích lũy mặc định = 0 khi thêm mới
        Integer diemTichLuy = 0;
        String error = null;

        if (maKH.isEmpty() || hoTen.isEmpty() || sdt.isEmpty() || gioiTinh.isEmpty()) {
            error = "Vui lòng nhập đầy đủ Mã, Họ tên, Số điện thoại và Giới tính!";
        }

        if (error == null && !diemStr.isEmpty()) {
            try {
                diemTichLuy = Integer.parseInt(diemStr);
                if (diemTichLuy < 0) error = "Điểm tích lũy không được âm!";
            } catch (NumberFormatException e) {
                error = "Điểm tích lũy phải là số nguyên!";
            }
        }

        if (error == null && repo.getById(maKH) != null) {
            error = "Mã khách hàng [" + maKH + "] đã tồn tại!";
        }

        if (error == null && repo.existsBySdt(sdt, null)) {
            error = "Số điện thoại [" + sdt + "] đã được đăng ký!";
        }

        KhachHang kh = new KhachHang(maKH, hoTen, sdt, diemTichLuy, gioiTinh);

        if (error != null) {
            forwardWithError(req, resp, kh, "add", error);
            return;
        }

        if (!repo.add(kh)) {
            forwardWithError(req, resp, kh, "add", "Thêm khách hàng thất bại! Vui lòng kiểm tra kết nối CSDL.");
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/khach-hang/view");
    }

    // ==================== XỬ LÝ CẬP NHẬT ====================
    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String maKH   = getParam(req, "maKH");
        String hoTen  = getParam(req, "hoTen");
        String sdt    = getParam(req, "sdt");
        String gioiTinh = getParam(req, "gioiTinh");
        String diemStr  = getParam(req, "diemTichLuy");

        Integer diemTichLuy = 0;
        String error = null;

        if (maKH.isEmpty() || hoTen.isEmpty() || sdt.isEmpty() || gioiTinh.isEmpty()) {
            error = "Vui lòng nhập đầy đủ Họ tên, Số điện thoại và Giới tính!";
        }

        if (error == null) {
            try {
                diemTichLuy = diemStr.isEmpty() ? 0 : Integer.parseInt(diemStr);
                if (diemTichLuy < 0) error = "Điểm tích lũy không được âm!";
            } catch (NumberFormatException e) {
                error = "Điểm tích lũy phải là số nguyên!";
            }
        }

        if (error == null && repo.getById(maKH) == null) {
            error = "Khách hàng không tồn tại!";
        }

        if (error == null && repo.existsBySdt(sdt, maKH)) {
            error = "Số điện thoại [" + sdt + "] đã được đăng ký bởi khách hàng khác!";
        }

        KhachHang kh = new KhachHang(maKH, hoTen, sdt, diemTichLuy, gioiTinh);

        if (error != null) {
            forwardWithError(req, resp, kh, "update", error);
            return;
        }

        if (!repo.update(kh)) {
            forwardWithError(req, resp, kh, "update", "Cập nhật thất bại! Vui lòng kiểm tra kết nối CSDL.");
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/khach-hang/view");
    }

    // ==================== HÀM HỖ TRỢ ====================

    // Phân trang: 5 khách hàng / 1 trang
    private void loadPaging(HttpServletRequest req) {
        int page = 1;
        String pageParam = req.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try { page = Integer.parseInt(pageParam.trim()); } catch (NumberFormatException e) { page = 1; }
        }

        int totalItems = repo.count();
        int totalPages = (int) Math.ceil((double) totalItems / PAGE_SIZE);
        if (totalPages <= 0) totalPages = 1;
        if (page < 1) page = 1;
        if (page > totalPages) page = totalPages;

        List<KhachHang> all = repo.getAll();
        int start = (page - 1) * PAGE_SIZE;
        int end = Math.min(start + PAGE_SIZE, totalItems);
        List<KhachHang> pagedList = (start < totalItems) ? all.subList(start, end) : Collections.emptyList();

        req.setAttribute("listKhachHang", pagedList);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalItems", totalItems);
    }

    // Lấy param và trim
    private String getParam(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return v != null ? v.trim() : "";
    }

    // Quay lại view với thông báo lỗi và mở modal tương ứng
    private void forwardWithError(HttpServletRequest req, HttpServletResponse resp,
                                  KhachHang kh, String openModal, String error)
            throws ServletException, IOException {
        req.setAttribute("kh", kh);
        req.setAttribute("openModal", openModal);
        req.setAttribute("error", error);
        loadPaging(req);
        req.getRequestDispatcher(VIEW).forward(req, resp);
    }
}
