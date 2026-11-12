package filter;

import entity.TaiKhoan;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter(filterName = "AuthFilter", urlPatterns = {"/*"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = uri.substring(contextPath.length());

        // Cho phép truy cập tài nguyên tĩnh và trang login
        if (path.startsWith("/assets/") || path.equals("/login") || path.equals("/login.jsp") || path.equals("/logout")) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = request.getSession(false);
        TaiKhoan currentUser = (session != null) ? (TaiKhoan) session.getAttribute("currentUser") : null;

        // Nếu chưa đăng nhập mà truy cập trang bảo vệ
        if (currentUser == null) {
            response.sendRedirect(contextPath + "/login");
            return;
        }

        String role = currentUser.getVaiTro();

        // Phân quyền: Nhân viên không được vào trang Quản lý (menuadmin.jsp)
        if (path.contains("menuadmin.jsp")) {
            if (!"QuanLy".equalsIgnoreCase(role)) {
                response.sendRedirect(contextPath + "/menunv.jsp");
                return;
            }
        }

        // Phân quyền: Chỉ QuanLy mới được truy cập chức năng Quản lý Combo
        if (path.startsWith("/quan-ly-combo")) {
            if (!"QuanLy".equalsIgnoreCase(role)) {
                response.sendRedirect(contextPath + "/menunv.jsp");
                return;
            }
        }

        chain.doFilter(request, response);
    }
}
