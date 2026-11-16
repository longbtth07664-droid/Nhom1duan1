package controller;

import entity.KhachHang;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.KhachHangRepository;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "KhachHangServlet", urlPatterns = {
        "/khach-hang",
        "/khach-hang/",
        "/khach-hang/view",
        "/khach-hang/detail",
        "/khach-hang/add",
        "/khach-hang/update",
        "/khach-hang/delete"
})
public class KhachHangServlet extends HttpServlet {

    private final KhachHangRepository repo = new KhachHangRepository();
    private static final String VIEW = "/khach-hang/view.jsp";
    private static final int PAGE_SIZE = 5;

    // Tiếp nhận và xử lý các yêu cầu GET (xem danh sách, tìm kiếm, phân trang và xóa khách hàng)
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String path = req.getServletPath();

        // Xử lý thao tác xóa một khách hàng
        if (path.equals("/khach-hang/delete")) {
            handleDelete(req, resp);
            return;
        }

        // Tải danh sách khách hàng có hỗ trợ tìm kiếm và phân trang
        loadData(req);

        // Hiển thị thông báo kết quả trả về từ URL tham số msg
        String msg = req.getParameter("msg");
        if ("add_ok".equals(msg)) {
            req.setAttribute("successMsg", "Thêm mới khách hàng thành công!");
        } else if ("update_ok".equals(msg)) {
            req.setAttribute("successMsg", "Cập nhật thông tin khách hàng thành công!");
        } else if ("delete_ok".equals(msg)) {
            req.setAttribute("successMsg", "Đã xóa khách hàng thành công!");
        } else if ("error".equals(msg)) {
            req.setAttribute("errorMsg", "Có lỗi xảy ra trong quá trình xử lý!");
        }

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    // Tiếp nhận và phân phối các form POST (thêm mới hoặc cập nhật thông tin khách hàng)
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String path = req.getServletPath();

        if (path.equals("/khach-hang/add")) {
            handleAdd(req, resp);
        } else if (path.equals("/khach-hang/update")) {
            handleUpdate(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/khach-hang/view");
        }
    }

    // ==================== XỬ LÝ THÊM MỚI KHÁCH HÀNG ====================

    // Kiểm tra dữ liệu đầu vào và thêm mới một khách hàng vào cơ sở dữ liệu
    private void handleAdd(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String maKH = getParam(req, "maKH").toUpperCase();
        String hoTen = getParam(req, "hoTen");
        String sdt = getParam(req, "sdt");
        String gioiTinh = getParam(req, "gioiTinh");
        String diemStr = getParam(req, "diemTichLuy");

        Integer diemTichLuy = 0;
        String error = null;

        if (maKH.isEmpty() || hoTen.isEmpty() || sdt.isEmpty() || gioiTinh.isEmpty()) {
            error = "Vui lòng nhập đầy đủ Mã KH, Họ tên, Số điện thoại và Giới tính!";
        } else if (!sdt.matches("^0[0-9]{9,10}$")) {
            error = "Số điện thoại không hợp lệ! Vui lòng nhập từ 10-11 chữ số bắt đầu bằng số 0.";
        }

        if (error == null && !diemStr.isEmpty()) {
            try {
                diemTichLuy = Integer.parseInt(diemStr);
                if (diemTichLuy < 0) error = "Điểm tích lũy không được là số âm!";
            } catch (NumberFormatException e) {
                error = "Điểm tích lũy phải là số nguyên!";
            }
        }

        if (error == null && repo.getById(maKH) != null) {
            error = "Mã khách hàng [" + maKH + "] đã tồn tại trên hệ thống!";
        }

        if (error == null && repo.existsBySdt(sdt, null)) {
            error = "Số điện thoại [" + sdt + "] đã được đăng ký bởi khách hàng khác!";
        }

        KhachHang kh = new KhachHang(maKH, hoTen, sdt, diemTichLuy, gioiTinh);

        if (error != null) {
            forwardWithError(req, resp, kh, "add", error);
            return;
        }

        boolean ok = repo.add(kh);
        if (!ok) {
            forwardWithError(req, resp, kh, "add", "Thêm khách hàng thất bại! Vui lòng kiểm tra lại kết nối CSDL.");
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/khach-hang/view?msg=add_ok");
    }

    // ==================== XỬ LÝ CẬP NHẬT KHÁCH HÀNG ====================

    // Kiểm tra dữ liệu và cập nhật thông tin họ tên, SĐT, giới tính hoặc điểm tích lũy
    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String maKH = getParam(req, "maKH").toUpperCase();
        String hoTen = getParam(req, "hoTen");
        String sdt = getParam(req, "sdt");
        String gioiTinh = getParam(req, "gioiTinh");
        String diemStr = getParam(req, "diemTichLuy");

        Integer diemTichLuy = 0;
        String error = null;

        if (maKH.isEmpty() || hoTen.isEmpty() || sdt.isEmpty() || gioiTinh.isEmpty()) {
            error = "Vui lòng nhập đầy đủ Họ tên, Số điện thoại và Giới tính!";
        } else if (!sdt.matches("^0[0-9]{9,10}$")) {
            error = "Số điện thoại không hợp lệ! Vui lòng nhập từ 10-11 chữ số bắt đầu bằng số 0.";
        }

        if (error == null) {
            try {
                diemTichLuy = diemStr.isEmpty() ? 0 : Integer.parseInt(diemStr);
                if (diemTichLuy < 0) error = "Điểm tích lũy không được là số âm!";
            } catch (NumberFormatException e) {
                error = "Điểm tích lũy phải là số nguyên!";
            }
        }

        if (error == null && repo.getById(maKH) == null) {
            error = "Khách hàng không tồn tại!";
        }

        if (error == null && repo.existsBySdt(sdt, maKH)) {
            error = "Số điện thoại [" + sdt + "] đã thuộc về một khách hàng khác!";
        }

        KhachHang kh = new KhachHang(maKH, hoTen, sdt, diemTichLuy, gioiTinh);

        if (error != null) {
            forwardWithError(req, resp, kh, "update", error);
            return;
        }

        boolean ok = repo.update(kh);
        if (!ok) {
            forwardWithError(req, resp, kh, "update", "Cập nhật thất bại! Vui lòng thử lại.");
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/khach-hang/view?msg=update_ok");
    }

    // ==================== XỬ LÝ XÓA KHÁCH HÀNG ====================

    // Xóa khách hàng khỏi hệ thống nếu không có ràng buộc dữ liệu
    private void handleDelete(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String id = getParam(req, "id");
        if (id.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/khach-hang/view?msg=error");
            return;
        }

        boolean ok = repo.delete(id);
        resp.sendRedirect(req.getContextPath() + "/khach-hang/view?msg=" + (ok ? "delete_ok" : "error"));
    }

    // ==================== CÁC HÀM HỖ TRỢ ====================

    // Tải và tính toán danh sách khách hàng phân trang kết hợp tìm kiếm theo từ khóa
    private void loadData(HttpServletRequest req) {
        String keyword = getParam(req, "keyword");

        int page = 1;
        String pageParam = req.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam.trim());
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        int totalItems = repo.countSearch(keyword);
        int totalPages = (int) Math.ceil((double) totalItems / PAGE_SIZE);
        if (totalPages <= 0) totalPages = 1;
        if (page < 1) page = 1;
        if (page > totalPages) page = totalPages;

        List<KhachHang> list = repo.search(keyword, page, PAGE_SIZE);

        req.setAttribute("listKhachHang", list);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalItems", totalItems);
        req.setAttribute("totalAll", repo.count());
        req.setAttribute("keyword", keyword);
    }

    // Đọc tham số từ HTTP Request và loại bỏ khoảng trắng hai đầu
    private String getParam(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return v != null ? v.trim() : "";
    }

    // Chuyển hướng về giao diện view kèm đối tượng lỗi và tự động mở lại modal tương ứng
    private void forwardWithError(HttpServletRequest req, HttpServletResponse resp,
                                  KhachHang kh, String openModal, String error)
            throws ServletException, IOException {
        req.setAttribute("kh", kh);
        req.setAttribute("openModal", openModal);
        req.setAttribute("error", error);
        loadData(req);
        req.getRequestDispatcher(VIEW).forward(req, resp);
    }
}
