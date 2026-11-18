<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // [Ghi chú - Khánh]: Nếu truy cập menuadmin.jsp trực tiếp, tự động chuyển về Tổng quan (/thong-ke)
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/thong-ke");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Menu Quản lý - Rạp Chiếu Phim</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=8">
</head>
<body>
<div class="app-shell">
    <!-- MENU BÊN TRÁI -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-brand">

            <div class="brand-text">
                <h1>Rạp Chiếu Phim CINEMAX</h1>
                <span>Quản lý</span>
            </div>
        </div>

        <nav class="sidebar-menu">
            <div class="menu-group-label">Menu chức năng</div>

            <%-- [Ghi chú - Khánh]: Bấm vào Tổng quan hiển thị Thống kê kinh doanh (/thong-ke) --%>
            <a href="${pageContext.request.contextPath}/thong-ke" class="nav-item">
                <span>Tổng quan</span>
            </a>

            <a href="${pageContext.request.contextPath}/ban-ve" class="nav-item">
                <span>Bán vé tại quầy (POS)</span>
            </a>

            <div class="nav-group">
                <button type="button" class="nav-item nav-parent" onclick="toggleSubmenu(this)">
                    <span>Quản lí phim</span>
                    <span class="nav-arrow">▾</span>
                </button>
                <div class="nav-submenu">
                    <a href="${pageContext.request.contextPath}/phim/view" class="nav-subitem">Danh sách phim</a>
                    <a href="${pageContext.request.contextPath}/the-loai/view" class="nav-subitem">Quản lí thể loại</a>
                </div>
            </div>


            <div class="nav-group">
                <button type="button" class="nav-item nav-parent" onclick="toggleSubmenu(this)">
                    <span>Phòng ghế</span>
                    <span class="nav-arrow">▾</span>
                </button>
                <div class="nav-submenu">
                    <a href="${pageContext.request.contextPath}/phong-chieu/view" class="nav-subitem">Danh sách phòng chiếu</a>
                    <a href="${pageContext.request.contextPath}/ghe" class="nav-subitem">Sơ đồ & Quản lý ghế</a>
                </div>
            </div>


            <a href="${pageContext.request.contextPath}/suat-chieu/view" class="nav-item">
                <span>Quản lý lịch chiếu</span>
            </a>

            <%-- [Ghi chú - Khánh]: Đã chuyển chức năng Thống kê kinh doanh lên mục Tổng quan ở trên --%>
            <a href="${pageContext.request.contextPath}/quan-ly-san-pham" class="nav-item">
                <span>Quản lí sản phẩm</span>
            </a>

            <a href="${pageContext.request.contextPath}/quan-ly-combo" class="nav-item">
                <span>Quản lí combo</span>
            </a>

            <a href="${pageContext.request.contextPath}/khach-hang/view" class="nav-item">
                <span>Quản lí khách hàng</span>
            </a>

            <a href="${pageContext.request.contextPath}/hoa-don" class="nav-item">
                <span>Quản lí hóa đơn</span>
            </a>

            <a href="${pageContext.request.contextPath}/nhan-vien/view" class="nav-item">
                <span>Quản lí nhân viên</span>
            </a>
            <a href="${pageContext.request.contextPath}/tai-khoan/view" class="nav-item">
                <span>Quản lý tài khoản</span>
            </a>
        </nav>


        <div class="sidebar-footer">
            <div class="user-card">
                <div class="user-avatar"><%= session.getAttribute("userName") != null ? session.getAttribute("userName").toString().substring(0, 1).toUpperCase() : "QL" %></div>
                <div class="user-info">
                    <div class="name"><%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Quản lý rạp" %></div>
                    <div class="role"><%= session.getAttribute("userRole") != null ? session.getAttribute("userRole") : "QuanLy" %></div>
                </div>
            </div>

            <a href="<%= request.getContextPath() %>/logout" class="role-switch-link" style="color: #ff4757; margin-top: 8px;">Đăng xuất</a>
        </div>
    </aside>
</div>

<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=6"></script>
</body>
</html>
