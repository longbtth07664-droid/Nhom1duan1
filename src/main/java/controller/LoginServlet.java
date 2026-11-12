package controller;

import entity.TaiKhoan;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import repository.TaiKhoanRepository;

import java.io.IOException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final TaiKhoanRepository taiKhoanRepository = new TaiKhoanRepository();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            TaiKhoan tk = (TaiKhoan) session.getAttribute("currentUser");
            if ("QuanLy".equalsIgnoreCase(tk.getVaiTro())) {
                response.sendRedirect(request.getContextPath() + "/menuadmin.jsp");
            } else {
                response.sendRedirect(request.getContextPath() + "/menunv.jsp");
            }
            return;
        }
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu!");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        TaiKhoan tk = taiKhoanRepository.checkLogin(username, password);

        if (tk != null) {
            // Kiểm tra trạng thái làm việc
            if (tk.getTrangThai() != null && tk.getTrangThai().toLowerCase().contains("nghỉ")) {
                request.setAttribute("error", "Tài khoản này đã nghỉ việc, không thể đăng nhập!");
                request.setAttribute("username", username);
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", tk);
            session.setAttribute("userRole", tk.getVaiTro());
            session.setAttribute("userName", tk.getHoTen());

            if ("QuanLy".equalsIgnoreCase(tk.getVaiTro())) {
                response.sendRedirect(request.getContextPath() + "/menuadmin.jsp");
            } else {
                response.sendRedirect(request.getContextPath() + "/menunv.jsp");
            }
        } else {
            request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không chính xác!");
            request.setAttribute("username", username);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
