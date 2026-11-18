package controller;

import entity.TaiKhoan;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import repository.TaiKhoanRepository;

import java.io.IOException;

@WebServlet(name = "TaiKhoanServlet", value = {
        "/tai-khoan/view",
        "/tai-khoan/detail",
        "/tai-khoan/view-update",
        "/tai-khoan/update",
        "/tai-khoan/add"
})
public class TaiKhoanServlet extends HttpServlet {
    private final TaiKhoanRepository taiKhoanRepository = new TaiKhoanRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String uri = req.getRequestURI();

        // Ưu tiên kiểm tra các đường dẫn đặc thù trước để tránh nhầm với "view"
        if (uri.contains("view-update")) {
            viewUpdate(req, resp);
        } else if (uri.contains("detail")) {
            detail(req, resp);
        } else if (uri.contains("view")) {
            view(req, resp);
        }
    }

    private void view(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("listTaiKhoan", taiKhoanRepository.getAll());
        req.getRequestDispatcher("/tai-khoan/view.jsp").forward(req, resp);
    }

    private void detail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Ép kiểu id từ String sang Integer
        Integer id = Integer.valueOf(req.getParameter("id"));
        req.setAttribute("tk", taiKhoanRepository.getOne(id));
        req.setAttribute("listTaiKhoan", taiKhoanRepository.getAll());
        req.setAttribute("openDetailModal", true);
        req.getRequestDispatcher("/tai-khoan/view.jsp").forward(req, resp);
    }

    private void viewUpdate(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Ép kiểu id từ String sang Integer
        Integer id = Integer.valueOf(req.getParameter("id"));
        req.setAttribute("tk", taiKhoanRepository.getOne(id));
        req.getRequestDispatcher("/tai-khoan/view-update.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String uri = req.getRequestURI();
        if (uri.contains("add")) {
            add(req, resp);
        } else if (uri.contains("update")) {
            update(req, resp);
        }
    }

    private void add(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        TaiKhoan tk = new TaiKhoan();
        tk.setHoTen(req.getParameter("hoTen"));
        tk.setCccd(req.getParameter("cccd"));
        tk.setEmail(req.getParameter("email"));
        tk.setSoDienThoai(req.getParameter("soDienThoai"));
        tk.setDiaChi(req.getParameter("diaChi"));
        tk.setVaiTro(req.getParameter("vaiTro"));
        tk.setUsername(req.getParameter("username"));
        tk.setPassword(req.getParameter("password"));
        tk.setTrangThai("Đang làm việc"); // Mặc định khi thêm mới

        taiKhoanRepository.add(tk);
        resp.sendRedirect(req.getContextPath() + "/tai-khoan/view");
    }

    private void update(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            String idStr = req.getParameter("maTK");
            if (idStr != null && !idStr.isEmpty()) {
                TaiKhoan tk = new TaiKhoan();
                // Ép kiểu sang Integer để khớp với thuộc tính maTK kiểu Integer trong Entity & Database
                tk.setMaTK(Integer.valueOf(idStr));
                tk.setUsername(req.getParameter("username"));
                tk.setPassword(req.getParameter("password"));
                tk.setVaiTro(req.getParameter("vaiTro"));
                tk.setTrangThai(req.getParameter("trangThai"));

                taiKhoanRepository.update(tk);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        resp.sendRedirect(req.getContextPath() + "/tai-khoan/view");
    }
}