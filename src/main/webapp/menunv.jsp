<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // [Ghi chú - Nhóm 1]: Nếu truy cập menunv.jsp trực tiếp, tự động chuyển về Bán vé (/ban-ve)
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/ban-ve");
        return;
    }
%>
<!-- MENU ĐIỀU HƯỚNG BÊN TRÁI DÀNH CHO NHÂN VIÊN QUẦY (FRAGMENT INCLUDE) -->
<aside class="sidebar" id="sidebar">
    <div class="sidebar-brand">
        <div class="brand-text">
            <h1>Rạp Chiếu Phim CINEMAX</h1>
            <span>Nhân viên quầy</span>
        </div>
    </div>

    <nav class="sidebar-menu">
        <div class="menu-group-label">Menu quầy vé</div>

        <a href="${pageContext.request.contextPath}/ban-ve" class="nav-item">
            <span>Bán vé tại quầy (POS)</span>
        </a>

        <a href="${pageContext.request.contextPath}/check-in" class="nav-item">
            <span>Soát vé (Check-in)</span>
        </a>

        <a href="${pageContext.request.contextPath}/hoa-don" class="nav-item">
            <span>Quản lí hóa đơn</span>
        </a>
    </nav>

    <div class="sidebar-footer">
        <div class="user-card">
            <div class="user-avatar"><%= session.getAttribute("userName") != null ? session.getAttribute("userName").toString().substring(0, 1).toUpperCase() : "NV" %></div>
            <div class="user-info">
                <div class="name"><%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Nhân viên quầy" %></div>
                <div class="role"><%= session.getAttribute("userRole") != null ? session.getAttribute("userRole") : "NhanVien" %></div>
            </div>
        </div>
        <a href="<%= request.getContextPath() %>/logout" class="role-switch-link" style="color: #ff4757; margin-top: 8px;">Đăng xuất</a>
    </div>
</aside>

<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=16"></script>
<script>
    if (typeof initSidebarHighlight === 'function') {
        initSidebarHighlight();
    }
</script>
