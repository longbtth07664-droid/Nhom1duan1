<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lí phòng chiếu - Rạp Chiếu Phim CINEMAX</title>
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

            <div class="nav-group">
                <button type="button" class="nav-item nav-parent" onclick="toggleSubmenu(this)">
                    <span>Quản lí phim</span>
                    <span class="nav-arrow">▾</span>
                </button>
                <div class="nav-submenu">
                    <a href="#" class="nav-subitem">Danh sách phim</a>
                    <a href="${pageContext.request.contextPath}/the-loai/view" class="nav-subitem">Quản lí thể loại</a>
                </div>
            </div>

            <a href="${pageContext.request.contextPath}/phong-chieu/view" class="nav-item active">
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
                    <div class="name"><%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Quản lý rạp" %></div>
                    <div class="role"><%= session.getAttribute("userRole") != null ? session.getAttribute("userRole") : "Admin" %></div>
                </div>
            </div>

            <a href="<%= request.getContextPath() %>/logout" class="role-switch-link" style="color: #ff4757; margin-top: 8px;">Đăng xuất</a>
        </div>
    </aside>

    <!-- NỘI DUNG QUẢN LÍ PHÒNG CHIẾU -->
    <div class="main-wrapper">
        <header class="topbar">
            <div class="topbar-left">
                <button type="button" class="mobile-menu-btn" onclick="toggleSidebar()">☰</button>
                <div class="page-title-wrap">
                    <h2>Quản lí phòng chiếu</h2>
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
                        <div class="card-title">Danh sách phòng chiếu</div>
                        <div class="card-subtitle">Quản lý các phòng chiếu và sức chứa tại rạp</div>
                    </div>
                    <div style="display:flex; align-items:center; gap:10px;">
                        <button type="button" class="btn btn-pink" onclick="openAddPhongChieu()">+ Thêm</button>
                        <span class="badge-pink">${listPhongChieu.size()} phòng chiếu</span>
                    </div>
                </div>

                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th>STT</th>
                            <th>Mã phòng</th>
                            <th>Tên phòng</th>
                            <th>Loại phòng</th>
                            <th>Sức chứa</th>
                            <th>Hành động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${listPhongChieu}" var="item" varStatus="st">
                            <tr>
                                <td>${st.index + 1}</td>
                                <td><strong><c:out value="${item.maPhong}"/></strong></td>
                                <td><c:out value="${item.tenPhong}"/></td>
                                <td><c:out value="${item.loaiPhong}"/></td>
                                <td><c:out value="${item.sucChua}"/> ghế</td>
                                <td>
                                    <div class="action-group">
                                        <button type="button"
                                                class="btn btn-ghost btn-sm"
                                                data-ma="<c:out value='${item.maPhong}'/>"
                                                data-ten="<c:out value='${item.tenPhong}'/>"
                                                data-loai="<c:out value='${item.loaiPhong}'/>"
                                                data-succhua="<c:out value='${item.sucChua}'/>"
                                                onclick="openDetailPhongChieuFromBtn(this)">Chi tiết</button>
                                        <button type="button"
                                                class="btn btn-outline btn-sm"
                                                data-ma="<c:out value='${item.maPhong}'/>"
                                                data-ten="<c:out value='${item.tenPhong}'/>"
                                                data-loai="<c:out value='${item.loaiPhong}'/>"
                                                data-succhua="<c:out value='${item.sucChua}'/>"
                                                onclick="openEditPhongChieuFromBtn(this)">Sửa</button>
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

<!-- POP-UP THÊM PHÒNG CHIẾU -->
<div class="modal-backdrop ${openModal == 'add' ? 'open' : ''}" id="addPhongChieuModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Thêm phòng chiếu</h3>
            <button type="button" class="modal-close" onclick="closeModal('addPhongChieuModal')">&times;</button>
        </div>

        <c:if test="${openModal == 'add' and not empty error}">
            <div class="alert-error" id="addPhongChieuError"><c:out value="${error}"/></div>
        </c:if>

        <form action="${pageContext.request.contextPath}/phong-chieu/add" method="post">
            <div class="form-stack">
                <div class="form-group">
                    <label for="addMaPhong">Mã phòng<span class="required-star">*</span></label>
                    <input type="text" id="addMaPhong" name="maPhong" class="form-control"
                           value="${openModal == 'add' ? pc.maPhong : ''}"
                           placeholder="VD: PC11">
                </div>
                <div class="form-group">
                    <label for="addTenPhong">Tên phòng<span class="required-star">*</span></label>
                    <input type="text" id="addTenPhong" name="tenPhong" class="form-control"
                           value="${openModal == 'add' ? pc.tenPhong : ''}"
                           placeholder="VD: Phòng 11 - Tiêu Chuẩn">
                </div>
                <div class="form-group">
                    <label for="addLoaiPhong">Loại phòng<span class="required-star">*</span></label>
                    <input type="text" id="addLoaiPhong" name="loaiPhong" class="form-control"
                           value="${openModal == 'add' ? pc.loaiPhong : ''}"
                           placeholder="VD: 2D, 3D, IMAX, 2D VIP, VIP">
                </div>
                <div class="form-group">
                    <label for="addSucChua">Sức chứa<span class="required-star">*</span></label>
                    <input type="number" id="addSucChua" name="sucChua" class="form-control" min="1"
                           value="${openModal == 'add' ? pc.sucChua : ''}"
                           placeholder="VD: 120">
                </div>
                <div style="font-size:12px; color:var(--text-secondary);">
                    (<span class="required-star">*</span>) Trường bắt buộc nhập
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('addPhongChieuModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Thêm</button>
            </div>
        </form>
    </div>
</div>

<!-- POP-UP SỬA PHÒNG CHIẾU -->
<div class="modal-backdrop ${openModal == 'update' ? 'open' : ''}" id="editPhongChieuModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Sửa phòng chiếu</h3>
            <button type="button" class="modal-close" onclick="closeModal('editPhongChieuModal')">&times;</button>
        </div>

        <c:if test="${openModal == 'update' and not empty error}">
            <div class="alert-error" id="editPhongChieuError"><c:out value="${error}"/></div>
        </c:if>

        <form action="${pageContext.request.contextPath}/phong-chieu/update" method="post">
            <div class="form-stack">
                <div class="form-group">
                    <label for="editMaPhong">Mã phòng<span class="required-star">*</span></label>
                    <input type="text" id="editMaPhong" name="maPhong" class="form-control"
                           value="${openModal == 'update' ? pc.maPhong : ''}" readonly>
                </div>
                <div class="form-group">
                    <label for="editTenPhong">Tên phòng<span class="required-star">*</span></label>
                    <input type="text" id="editTenPhong" name="tenPhong" class="form-control"
                           value="${openModal == 'update' ? pc.tenPhong : ''}">
                </div>
                <div class="form-group">
                    <label for="editLoaiPhong">Loại phòng<span class="required-star">*</span></label>
                    <input type="text" id="editLoaiPhong" name="loaiPhong" class="form-control"
                           value="${openModal == 'update' ? pc.loaiPhong : ''}">
                </div>
                <div class="form-group">
                    <label for="editSucChua">Sức chứa<span class="required-star">*</span></label>
                    <input type="number" id="editSucChua" name="sucChua" class="form-control" min="1"
                           value="${openModal == 'update' ? pc.sucChua : ''}">
                </div>
                <div style="font-size:12px; color:var(--text-secondary);">
                    (<span class="required-star">*</span>) Trường bắt buộc nhập
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('editPhongChieuModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Lưu cập nhật</button>
            </div>
        </form>
    </div>
</div>

<!-- POP-UP CHI TIẾT PHÒNG CHIẾU -->
<div class="modal-backdrop ${openModal == 'detail' ? 'open' : ''}" id="detailPhongChieuModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Chi tiết phòng chiếu</h3>
            <button type="button" class="modal-close" onclick="closeModal('detailPhongChieuModal')">&times;</button>
        </div>
        <div class="form-stack">
            <div class="form-group">
                <label>Mã phòng</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailMaPhong"><c:out value="${pc.maPhong}"/></div>
            </div>
            <div class="form-group">
                <label>Tên phòng</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailTenPhong"><c:out value="${pc.tenPhong}"/></div>
            </div>
            <div class="form-group">
                <label>Loại phòng</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailLoaiPhong"><c:out value="${pc.loaiPhong}"/></div>
            </div>
            <div class="form-group">
                <label>Sức chứa</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailSucChua"><c:out value="${pc.sucChua}"/></div>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-pink" onclick="closeModal('detailPhongChieuModal')">Đóng</button>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=5"></script>
<script>
    function openAddPhongChieu() {
        const err = document.getElementById('addPhongChieuError');
        if (err) err.style.display = 'none';
        document.getElementById('addMaPhong').value = '';
        document.getElementById('addTenPhong').value = '';
        document.getElementById('addLoaiPhong').value = '';
        document.getElementById('addSucChua').value = '';
        document.getElementById('addPhongChieuModal').classList.add('open');
    }

    function openEditPhongChieuFromBtn(btn) {
        const err = document.getElementById('editPhongChieuError');
        if (err) err.style.display = 'none';
        document.getElementById('editMaPhong').value = btn.getAttribute('data-ma') || '';
        document.getElementById('editTenPhong').value = btn.getAttribute('data-ten') || '';
        document.getElementById('editLoaiPhong').value = btn.getAttribute('data-loai') || '';
        document.getElementById('editSucChua').value = btn.getAttribute('data-succhua') || '';
        document.getElementById('editPhongChieuModal').classList.add('open');
    }

    function openDetailPhongChieuFromBtn(btn) {
        document.getElementById('detailMaPhong').textContent = btn.getAttribute('data-ma') || '';
        document.getElementById('detailTenPhong').textContent = btn.getAttribute('data-ten') || '';
        document.getElementById('detailLoaiPhong').textContent = btn.getAttribute('data-loai') || '';
        document.getElementById('detailSucChua').textContent = (btn.getAttribute('data-succhua') || '') + ' ghế';
        document.getElementById('detailPhongChieuModal').classList.add('open');
    }
</script>
</body>
</html>