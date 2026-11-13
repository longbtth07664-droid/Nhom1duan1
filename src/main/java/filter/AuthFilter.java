
package filter;

import entity.TaiKhoan;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter(filterName = "AuthFilter", urlPatterns = {"/*"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String path = req.getServletPath();
        String contextPath = req.getContextPath();

        // Cho phép truy cập tài nguyên tĩnh và các trang đăng nhập/đăng xuất
        if (path.startsWith("/assets/")
                || path.equals("/login")
                || path.equals("/login.jsp")
                || path.equals("/logout")
                || path.equals("/index.jsp")
                || path.equals("/favicon.ico")) {

            chain.doFilter(request, response);
            return;
        }

        // Kiểm tra người dùng đã đăng nhập chưa
        HttpSession session = req.getSession(false);

        TaiKhoan user = null;

        if (session != null) {
            Object currentUser = session.getAttribute("currentUser");

            if (currentUser instanceof TaiKhoan) {
                user = (TaiKhoan) currentUser;
            }
        }

        if (user == null) {
            res.sendRedirect(contextPath + "/login");
            return;
        }

        // Những đường dẫn chỉ dành cho Quản lý
        boolean isAdminUrl =
                path.startsWith("/the-loai/")
                        || path.startsWith("/phong-chieu/")
                        || path.startsWith("/phim/")
                        || path.startsWith("/quan-ly-combo")
                        || path.equals("/menuadmin.jsp");

        if (isAdminUrl) {

            String role = user.getVaiTro() == null
                    ? ""
                    : user.getVaiTro().trim();

            boolean isManager =
                    role.equalsIgnoreCase("QuanLy")
                            || role.equalsIgnoreCase("Quản lý");

            if (!isManager) {
                res.sendRedirect(contextPath + "/menunv.jsp");
                return;
            }
        }

        chain.doFilter(request, response);
    }
}
