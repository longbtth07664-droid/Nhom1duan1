<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cập nhật thể loại - Rạp Chiếu Phim CINEMAX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=7">
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

            <a href="${pageContext.request.contextPath}/menuadmin.jsp" class="nav-item">
                <span>Tổng quan</span>
            </a>

            <div class="nav-group open">
                <button type="button" class="nav-item nav-parent" onclick="toggleSubmenu(this)">
                    <span>Quản lí phim</span>
                    <span class="nav-arrow">▾</span>
                </button>
                <div class="nav-submenu">
                    <a href="#" class="nav-subitem">Danh sách phim</a>
                    <a href="${pageContext.request.contextPath}/the-loai/view" class="nav-subitem active">Quản lí thể loại</a>
                </div>
            </div>

            <a href="#" class="nav-item">
                <span>Phòng ghế</span>
            </a>

            <a href="#" class="nav-item">
                <span>Lịch chiếu bán vé</span>
            </a>
        </nav>

        <div class="sidebar-footer">
            <div class="user-card">
                <div class="user-avatar">QL</div>
                <div class="user-info">
                    <div class="name">Quản lý rạp</div>
                    <div class="role">Admin</div>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/menunv.jsp" class="role-switch-link">Chuyển sang Nhân viên</a>
            <a href="${pageContext.request.contextPath}/index.jsp" class="role-switch-link">Trang chủ chọn vai trò</a>
        </div>
    </aside>

    <!-- NỘI DUNG CẬP NHẬT -->
    <div class="main-wrapper">
        <header class="topbar">
            <div class="topbar-left">
                <button type="button" class="mobile-menu-btn" onclick="toggleSidebar()">☰</button>
                <div class="page-title-wrap">
                    <h2>Cập nhật thể loại</h2>
                </div>
            </div>
            <div class="topbar-right">
                <a href="${pageContext.request.contextPath}/the-loai/view" class="btn btn-ghost btn-sm">Quay lại danh sách</a>
            </div>
        </header>

        <main class="content-area">
            <div class="card">
                <div class="card-header">
                    <div>
                        <div class="card-title">Chỉnh sửa thông tin thể loại</div>
                        <div class="card-subtitle">Mã thể loại là khóa chính nên được giữ cố định</div>
                    </div>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert-error">${error}</div>
                </c:if>

                <form action="${pageContext.request.contextPath}/the-loai/update" method="post">
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="maTheLoai">Mã thể loại</label>
                            <input type="text" id="maTheLoai" name="maTheLoai" class="form-control"
                                   value="${tl.maTheLoai}" readonly>
                        </div>
                        <div class="form-group">
                            <label for="tenTheLoai">Tên thể loại</label>
                            <input type="text" id="tenTheLoai" name="tenTheLoai" class="form-control"
                                   value="${tl.tenTheLoai}">
                        </div>
                    </div>
                    <div class="form-actions">
                        <button type="submit" class="btn btn-pink">Lưu cập nhật</button>
                        <a href="${pageContext.request.contextPath}/the-loai/view" class="btn btn-outline">Hủy</a>
                    </div>
                </form>
            </div>

            <div class="card">
                <div class="card-header">
                    <div>
                        <div class="card-title">Danh sách thể loại hiện có</div>
                    </div>
                </div>
                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th>STT</th>
                            <th>Mã thể loại</th>
                            <th>Tên thể loại</th>
                            <th>Hành động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${listTheLoai}" var="item" varStatus="st">
                            <tr>
                                <td>${st.index + 1}</td>
                                <td><strong>${item.maTheLoai}</strong></td>
                                <td>${item.tenTheLoai}</td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/the-loai/view-update?id=${item.maTheLoai}"
                                       class="btn btn-outline btn-sm">Sửa</a>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=4"></script>
</body>
</html>
