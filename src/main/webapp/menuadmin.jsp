<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // [Ghi chú - Nhóm 1]: Nếu truy cập menuadmin.jsp trực tiếp qua URL, tự động chuyển về Tổng quan (/thong-ke)
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/thong-ke");
        return;
    }
%>
<!-- MENU ĐIỀU HƯỚNG BÊN TRÁI DÀNH CHO QUẢN LÝ (FRAGMENT INCLUDE) -->
<aside class="sidebar" id="sidebar">
    <div class="sidebar-brand">
        <div class="brand-text">
            <h1>Rạp Chiếu Phim CINEMAX</h1>
            <span>Quản lý</span>
        </div>
    </div>

    <nav class="sidebar-menu">
        <div class="menu-group-label">Menu chức năng</div>

        <%-- 1. Tổng quan (Thống kê doanh thu & hoạt động) --%>
        <a href="${pageContext.request.contextPath}/thong-ke" class="nav-item">
            <span>Tổng quan</span>
        </a>

        <%-- 2. Bán vé tại quầy (POS) --%>
        <a href="${pageContext.request.contextPath}/ban-ve" class="nav-item">
            <span>Bán vé tại quầy (POS)</span>
        </a>

        <%-- 3. Soát vé vào phòng chiếu (Check-in) --%>
        <a href="${pageContext.request.contextPath}/check-in" class="nav-item">
            <span>Soát vé (Check-in)</span>
        </a>

        <%-- 4. Quản lí hóa đơn & giao dịch --%>
        <a href="${pageContext.request.contextPath}/hoa-don" class="nav-item">
            <span>Quản lí hóa đơn</span>
        </a>

        <%-- 5. Quản lí phim & Thể loại --%>
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

        <%-- 6. Phòng chiếu & Ghế --%>
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

        <%-- 7. Lịch chiếu suất phim --%>
        <a href="${pageContext.request.contextPath}/suat-chieu/view" class="nav-item">
            <span>Quản lý lịch chiếu</span>
        </a>

        <%-- 8. Sản phẩm F&B --%>
        <a href="${pageContext.request.contextPath}/quan-ly-san-pham" class="nav-item">
            <span>Quản lí sản phẩm</span>
        </a>

        <%-- 9. Combo bắp nước --%>
        <a href="${pageContext.request.contextPath}/quan-ly-combo" class="nav-item">
            <span>Quản lí combo</span>
        </a>

        <%-- 10. Khách hàng thành viên --%>
        <a href="${pageContext.request.contextPath}/khach-hang/view" class="nav-item">
            <span>Quản lí khách hàng</span>
        </a>

        <%-- 11. Nhân viên --%>
        <a href="${pageContext.request.contextPath}/nhan-vien/view" class="nav-item">
            <span>Quản lí nhân viên</span>
        </a>

        <%-- 12. Tài khoản người dùng --%>
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

<!-- Tự động kích hoạt highlight chính xác menu theo trang đang mở -->
<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=16"></script>
<script>
    if (typeof initSidebarHighlight === 'function') {
        initSidebarHighlight();
    }
</script>
