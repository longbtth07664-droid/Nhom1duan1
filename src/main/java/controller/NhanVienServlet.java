package controller;

import entity.NhanVien;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.NhanVienRepository;

import java.io.IOException;

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
        String hoTen = req.getParameter("hoTen");
        String cccd = req.getParameter("cccd");
        String email = req.getParameter("email");
        String soDienThoai = req.getParameter("soDienThoai");
        String diaChi = req.getParameter("diaChi");
        String username = req.getParameter("username");
        String matKhau = req.getParameter("matKhau");

        String vaiTro = "NhanVien";
        String trangThai = "Đang làm việc";

        String error = nhanVienRepository.validateFormat(cccd, email, soDienThoai);
        if (error != null) {
            req.setAttribute("errorMessage", error);
            req.setAttribute("openAddModal", true);
            req.setAttribute("oldHoTen", hoTen);
            req.setAttribute("oldCccd", cccd);
            req.setAttribute("oldEmail", email);
            req.setAttribute("oldSoDienThoai", soDienThoai);
            req.setAttribute("oldDiaChi", diaChi);
            req.setAttribute("oldUsername", username);
            req.setAttribute("listNhanVien", nhanVienRepository.getAll());
            req.getRequestDispatcher("/nhan-vien/view.jsp").forward(req, resp);
            return;
        }

        NhanVien nv = new NhanVien();
        nv.setHoTen(hoTen != null ? hoTen.trim() : null);
        nv.setCccd(cccd != null ? cccd.trim() : null);
        nv.setEmail(email != null ? email.trim() : null);
        nv.setSoDienThoai(soDienThoai != null ? soDienThoai.trim() : null);
        nv.setDiaChi(diaChi != null ? diaChi.trim() : null);
        nv.setUsername(username != null ? username.trim() : null);
        nv.setMatKhau(matKhau);
        nv.setVaiTro(vaiTro);
        nv.setTrangThai(trangThai);

        nhanVienRepository.add(nv);
        resp.sendRedirect(req.getContextPath() + "/nhan-vien/view");
    }

    private void update(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer id = Integer.valueOf(req.getParameter("id"));
        String hoTen = req.getParameter("hoTen");
        String cccd = req.getParameter("cccd");
        String email = req.getParameter("email");
        String soDienThoai = req.getParameter("soDienThoai");
        String diaChi = req.getParameter("diaChi");
        String username = req.getParameter("username");
        String matKhau = req.getParameter("matKhau");
        String vaiTro = req.getParameter("vaiTro");
        String trangThai = req.getParameter("trangThai");

        String error = nhanVienRepository.validateFormat(cccd, email, soDienThoai);
        if (error != null) {
            NhanVien nvForm = new NhanVien();
            nvForm.setId(id);
            nvForm.setHoTen(hoTen);
            nvForm.setCccd(cccd);
            nvForm.setEmail(email);
            nvForm.setSoDienThoai(soDienThoai);
            nvForm.setDiaChi(diaChi);
            nvForm.setUsername(username);
            nvForm.setMatKhau(matKhau);
            nvForm.setVaiTro(vaiTro);
            nvForm.setTrangThai(trangThai);

            req.setAttribute("nv", nvForm);
            req.setAttribute("errorMessage", error);
            req.getRequestDispatcher("/nhan-vien/view-update.jsp").forward(req, resp);
            return;
        }

        NhanVien nv = new NhanVien();
        nv.setId(id);
        nv.setHoTen(hoTen != null ? hoTen.trim() : null);
        nv.setCccd(cccd != null ? cccd.trim() : null);
        nv.setEmail(email != null ? email.trim() : null);
        nv.setSoDienThoai(soDienThoai != null ? soDienThoai.trim() : null);
        nv.setDiaChi(diaChi != null ? diaChi.trim() : null);
        nv.setUsername(username != null ? username.trim() : null);
        nv.setMatKhau(matKhau);
        nv.setVaiTro(vaiTro);
        nv.setTrangThai(trangThai);

        nhanVienRepository.update(nv);
        resp.sendRedirect(req.getContextPath() + "/nhan-vien/view");
    }
}