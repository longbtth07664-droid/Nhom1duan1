<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lí thể loại - Rạp Chiếu Phim CINEMAX</title>
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

    <!-- NỘI DUNG QUẢN LÍ THỂ LOẠI -->
    <div class="main-wrapper">
        <header class="topbar">
            <div class="topbar-left">
                <button type="button" class="mobile-menu-btn" onclick="toggleSidebar()">☰</button>
                <div class="page-title-wrap">
                    <h2>Quản lí thể loại</h2>
                </div>
            </div>
            <div class="topbar-right">
                <a href="${pageContext.request.contextPath}/menuadmin.jsp" class="btn btn-ghost btn-sm">Menu chính</a>
            </div>
        </header>

        <main class="content-area">
            <div class="card">
                <div class="card-header">
                    <div>
                        <div class="card-title">Danh sách thể loại</div>
                        <div class="card-subtitle">Quản lý các thể loại phim đang chiếu tại rạp</div>
                    </div>
                    <div style="display:flex; align-items:center; gap:10px;">
                        <button type="button" class="btn btn-pink" onclick="openAddTheLoai()">+ Thêm</button>
                        <span class="badge-pink">${listTheLoai.size()} thể loại</span>
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
                                <td><strong><c:out value="${item.maTheLoai}"/></strong></td>
                                <td><c:out value="${item.tenTheLoai}"/></td>
                                <td>
                                    <div class="action-group">
                                        <button type="button"
                                                class="btn btn-ghost btn-sm"
                                                data-ma="<c:out value='${item.maTheLoai}'/>"
                                                data-ten="<c:out value='${item.tenTheLoai}'/>"
                                                onclick="openDetailTheLoaiFromBtn(this)">Chi tiết</button>
                                        <button type="button"
                                                class="btn btn-outline btn-sm"
                                                data-ma="<c:out value='${item.maTheLoai}'/>"
                                                data-ten="<c:out value='${item.tenTheLoai}'/>"
                                                onclick="openEditTheLoaiFromBtn(this)">Sửa</button>
                                    </div>
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

<!-- POP-UP THÊM THỂ LOẠI -->
<div class="modal-backdrop ${openModal == 'add' ? 'open' : ''}" id="addTheLoaiModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Thêm thể loại</h3>
            <button type="button" class="modal-close" onclick="closeModal('addTheLoaiModal')">&times;</button>
        </div>

        <c:if test="${openModal == 'add' and not empty error}">
            <div class="alert-error" id="addTheLoaiError"><c:out value="${error}"/></div>
        </c:if>

        <form action="${pageContext.request.contextPath}/the-loai/add" method="post">
            <div class="form-stack">
                <div class="form-group">
                    <label for="addMaTheLoai">Mã thể loại<span class="required-star">*</span></label>
                    <input type="text" id="addMaTheLoai" name="maTheLoai" class="form-control"
                           value="${openModal == 'add' ? tl.maTheLoai : ''}"
                           placeholder="VD: TL11" required>
                </div>
                <div class="form-group">
                    <label for="addTenTheLoai">Tên thể loại<span class="required-star">*</span></label>
                    <input type="text" id="addTenTheLoai" name="tenTheLoai" class="form-control"
                           value="${openModal == 'add' ? tl.tenTheLoai : ''}"
                           placeholder="VD: Cổ Trang" required>
                </div>
                <div style="font-size:12px; color:var(--text-secondary);">
                    (<span class="required-star">*</span>) Trường bắt buộc nhập
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('addTheLoaiModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Thêm</button>
            </div>
        </form>
    </div>
</div>

<!-- POP-UP SỬA THỂ LOẠI -->
<div class="modal-backdrop ${openModal == 'update' ? 'open' : ''}" id="editTheLoaiModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Sửa thể loại</h3>
            <button type="button" class="modal-close" onclick="closeModal('editTheLoaiModal')">&times;</button>
        </div>

        <c:if test="${openModal == 'update' and not empty error}">
            <div class="alert-error" id="editTheLoaiError"><c:out value="${error}"/></div>
        </c:if>

        <form action="${pageContext.request.contextPath}/the-loai/update" method="post">
            <div class="form-stack">
                <div class="form-group">
                    <label for="editMaTheLoai">Mã thể loại<span class="required-star">*</span></label>
                    <input type="text" id="editMaTheLoai" name="maTheLoai" class="form-control"
                           value="${openModal == 'update' ? tl.maTheLoai : ''}" readonly required>
                </div>
                <div class="form-group">
                    <label for="editTenTheLoai">Tên thể loại<span class="required-star">*</span></label>
                    <input type="text" id="editTenTheLoai" name="tenTheLoai" class="form-control"
                           value="${openModal == 'update' ? tl.tenTheLoai : ''}" required>
                </div>
                <div style="font-size:12px; color:var(--text-secondary);">
                    (<span class="required-star">*</span>) Trường bắt buộc nhập
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('editTheLoaiModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Lưu cập nhật</button>
            </div>
        </form>
    </div>
</div>

<!-- POP-UP CHI TIẾT THỂ LOẠI -->
<div class="modal-backdrop ${openModal == 'detail' ? 'open' : ''}" id="detailTheLoaiModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Chi tiết thể loại</h3>
            <button type="button" class="modal-close" onclick="closeModal('detailTheLoaiModal')">&times;</button>
        </div>
        <div class="form-stack">
            <div class="form-group">
                <label>Mã thể loại</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailMaTheLoai"><c:out value="${tl.maTheLoai}"/></div>
            </div>
            <div class="form-group">
                <label>Tên thể loại</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailTenTheLoai"><c:out value="${tl.tenTheLoai}"/></div>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-pink" onclick="closeModal('detailTheLoaiModal')">Đóng</button>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=5"></script>
</body>
</html>
