package controller;

import entity.NhanVien;
import entity.TaiKhoan;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import repository.NhanVienRepository;

import java.io.IOException;
import java.util.regex.Pattern;

@WebServlet(name = "NhanVienServlet", value = {
        "/nhan-vien/view",
        "/nhan-vien/detail",
        "/nhan-vien/view-update",
        "/nhan-vien/update",
        "/nhan-vien/add"
})
public class NhanVienServlet extends HttpServlet {
    private NhanVienRepository nhanVienRepository = new NhanVienRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String uri = req.getRequestURI();
        if (uri.contains("view-update")) {
            viewUpdate(req, resp);
        } else if (uri.contains("detail")) {
            detail(req, resp);
        } else if (uri.contains("view")) {
            view(req, resp);
        }
    }

    private void view(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("listNhanVien", nhanVienRepository.getAll());
        req.getRequestDispatcher("/nhan-vien/view.jsp").forward(req, resp);
    }

    private void detail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer id = Integer.valueOf(req.getParameter("id"));
        NhanVien nv = nhanVienRepository.getOne(id);
        req.setAttribute("nv", nv);
        req.setAttribute("listNhanVien", nhanVienRepository.getAll());
        req.setAttribute("openDetailModal", true); // Bật cờ để hiển thị Modal Chi tiết
        req.getRequestDispatcher("/nhan-vien/view.jsp").forward(req, resp);
    }

    private void viewUpdate(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer id = Integer.valueOf(req.getParameter("id"));
        NhanVien nv = nhanVienRepository.getOne(id);
        req.setAttribute("nv", nv);
        req.getRequestDispatcher("/nhan-vien/view-update.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String uri = req.getRequestURI();
        if (uri.contains("add")) {
            this.add(req, resp);
        } else if (uri.contains("update")) {
            this.update(req, resp);
        }
    }

    private void add(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String hoTen = trim(req.getParameter("hoTen"));
        String cccd = trim(req.getParameter("cccd"));
        String email = trim(req.getParameter("email"));
        String soDienThoai = trim(req.getParameter("soDienThoai"));
        String diaChi = trim(req.getParameter("diaChi"));
        String username = trim(req.getParameter("username"));
        String matKhau = trim(req.getParameter("matKhau"));

        // Ép cứng vai trò là NhanVien và trạng thái mặc định là Đang làm việc khi thêm mới
        String vaiTro = "NhanVien";
        String trangThai = "Đang làm việc";

        NhanVien nv = new NhanVien();
        nv.setHoTen(hoTen);
        nv.setCccd(cccd);
        nv.setEmail(email);
        nv.setSoDienThoai(soDienThoai);
        nv.setDiaChi(diaChi);
        nv.setUsername(username);
        nv.setMatKhau(matKhau);
        nv.setVaiTro(vaiTro);
        nv.setTrangThai(trangThai);

        String error = validateNhanVien(nv, null);
        if (error != null) {
            req.setAttribute("addError", error);
            req.setAttribute("formNv", nv);
            req.setAttribute("openAddModal", true);
            req.setAttribute("listNhanVien", nhanVienRepository.getAll());
            req.getRequestDispatcher("/nhan-vien/view.jsp").forward(req, resp);
            return;
        }

        nhanVienRepository.add(nv);
        resp.sendRedirect(req.getContextPath() + "/nhan-vien/view?msg=add_ok");
    }

    private void update(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer id = Integer.valueOf(req.getParameter("id"));
        NhanVien oldNv = nhanVienRepository.getOne(id);
        if (oldNv == null) {
            resp.sendRedirect(req.getContextPath() + "/nhan-vien/view");
            return;
        }

        String hoTen = trim(req.getParameter("hoTen"));
        String cccd = trim(req.getParameter("cccd"));
        String email = trim(req.getParameter("email"));
        String soDienThoai = trim(req.getParameter("soDienThoai"));
        String diaChi = trim(req.getParameter("diaChi"));
        String username = trim(req.getParameter("username"));
        String matKhau = trim(req.getParameter("matKhau"));
        String trangThai = trim(req.getParameter("trangThai"));

        // Nghiệp vụ: KHÔNG cho phép tự ý đổi Vai Trò tại màn hình Sửa thông tin nhân viên
        String vaiTro = oldNv.getVaiTro();

        // Nghiệp vụ: Không cho phép tự chuyển tài khoản đang đăng nhập sang trạng thái Nghỉ việc
        HttpSession session = req.getSession(false);
        TaiKhoan currentUser = (session != null && session.getAttribute("currentUser") instanceof TaiKhoan)
                ? (TaiKhoan) session.getAttribute("currentUser") : null;

        NhanVien nv = new NhanVien();
        nv.setId(id);
        nv.setHoTen(hoTen);
        nv.setCccd(cccd);
        nv.setEmail(email);
        nv.setSoDienThoai(soDienThoai);
        nv.setDiaChi(diaChi);
        nv.setUsername(username);
        nv.setMatKhau(matKhau.isEmpty() ? oldNv.getMatKhau() : matKhau);
        nv.setVaiTro(vaiTro);
        nv.setTrangThai(trangThai.isEmpty() ? oldNv.getTrangThai() : trangThai);

        String error = null;
        if (currentUser != null && currentUser.getMaTK() != null && currentUser.getMaTK().equals(id)) {
            if (!"Đang làm việc".equalsIgnoreCase(nv.getTrangThai()) && !"Hoạt động".equalsIgnoreCase(nv.getTrangThai())) {
                error = "Không thể tự chuyển trạng thái Nghỉ việc cho chính tài khoản đang đăng nhập!";
            }
        }
        if (error == null) {
            error = validateNhanVien(nv, id);
        }

        if (error != null) {
            req.setAttribute("error", error);
            req.setAttribute("nv", nv);
            req.getRequestDispatcher("/nhan-vien/view-update.jsp").forward(req, resp);
            return;
        }

        nhanVienRepository.update(nv);
        resp.sendRedirect(req.getContextPath() + "/nhan-vien/view?msg=update_ok");
    }

    private String validateNhanVien(NhanVien nv, Integer excludeId) {
        if (nv.getHoTen().isEmpty() || nv.getHoTen().length() < 2 || nv.getHoTen().length() > 100) {
            return "Họ tên phải từ 2 đến 100 ký tự!";
        }
        if (!Pattern.matches("^\\d{12}$", nv.getCccd())) {
            return "CCCD bắt buộc phải gồm đúng 12 chữ số!";
        }
        if (nhanVienRepository.existsByCccd(nv.getCccd(), excludeId)) {
            return "Số CCCD [" + nv.getCccd() + "] đã tồn tại trên hệ thống!";
        }
        if (!Pattern.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", nv.getEmail())) {
            return "Email không đúng định dạng hợp lệ!";
        }
        if (nhanVienRepository.existsByEmail(nv.getEmail(), excludeId)) {
            return "Email [" + nv.getEmail() + "] đã được tài khoản khác sử dụng!";
        }
        if (!Pattern.matches("^0\\d{9}$", nv.getSoDienThoai())) {
            return "Số điện thoại phải gồm 10 chữ số và bắt đầu bằng số 0!";
        }
        if (!Pattern.matches("^[a-zA-Z0-9_]{3,50}$", nv.getUsername())) {
            return "Username phải từ 3-50 ký tự, chỉ gồm chữ, số và dấu gạch dưới (_), không chứa khoảng trắng!";
        }
        if (nhanVienRepository.existsByUsername(nv.getUsername(), excludeId)) {
            return "Username [" + nv.getUsername() + "] đã tồn tại! Vui lòng chọn tên đăng nhập khác.";
        }
        if (nv.getMatKhau().length() < 6) {
            return "Mật khẩu phải có ít nhất 6 ký tự!";
        }
        return null;
    }

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }
}