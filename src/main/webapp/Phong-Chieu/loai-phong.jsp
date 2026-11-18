<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lí loại phòng - Rạp Chiếu Phim CINEMAX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=8">
    <style>
        .alert-success {
            padding: 12px 16px;
            border-radius: var(--radius-sm);
            background-color: #ecfdf5;
            color: #065f46;
            border: 1px solid #a7f3d0;
            margin-bottom: 16px;
            font-size: 13px;
            font-weight: 500;
        }
        .btn-danger-outline {
            background: #fff1f2;
            color: #e11d48;
            border: 1px solid #fda4af;
        }
        .btn-danger-outline:hover {
            background: #ffe4e6;
            color: #be123c;
            border-color: #f43f5e;
        }
    </style>
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
                    <a href="${pageContext.request.contextPath}/phim/view" class="nav-subitem">Danh sách phim</a>
                    <a href="${pageContext.request.contextPath}/the-loai/view" class="nav-subitem">Quản lí thể loại</a>
                </div>
            </div>

            <div class="nav-group open">
                <button type="button" class="nav-item nav-parent active" onclick="toggleSubmenu(this)">
                    <span>Phòng ghế</span>
                    <span class="nav-arrow">▾</span>
                </button>
                <div class="nav-submenu">
                    <a href="${pageContext.request.contextPath}/phong-chieu/view" class="nav-subitem">Danh sách phòng chiếu</a>
                    <a href="${pageContext.request.contextPath}/loai-phong/view" class="nav-subitem active">Quản lí loại phòng</a>
                </div>
            </div>

            <a href="#" class="nav-item">
                <span>Lịch chiếu bán vé</span>
            </a>

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

    <!-- NỘI DUNG QUẢN LÍ LOẠI PHÒNG -->
    <div class="main-wrapper">
        <header class="topbar">
            <div class="topbar-left">
                <button type="button" class="mobile-menu-btn" onclick="toggleSidebar()">☰</button>
                <div class="page-title-wrap">
                    <h2>Quản lí loại phòng chiếu</h2>
                </div>
            </div>
            <div class="topbar-right">
                <a href="${pageContext.request.contextPath}/phong-chieu/view" class="btn btn-outline btn-sm" style="margin-right: 8px;">
                    &lsaquo; Danh sách phòng chiếu
                </a>
                <a href="${pageContext.request.contextPath}/menuadmin.jsp" class="btn btn-ghost btn-sm">Menu chính</a>
            </div>
        </header>

        <main class="content-area">
            <!-- THÔNG BÁO TRẠNG THÁI -->
            <c:if test="${param.msg == 'add_ok'}">
                <div class="alert-success">✓ Thêm loại phòng mới thành công!</div>
            </c:if>
            <c:if test="${param.msg == 'update_ok'}">
                <div class="alert-success">✓ Cập nhật thông tin loại phòng thành công!</div>
            </c:if>
            <c:if test="${param.msg == 'delete_ok'}">
                <div class="alert-success">✓ Đã xóa loại phòng thành công!</div>
            </c:if>
            <c:if test="${param.msg == 'in_use'}">
                <div class="alert-error">✕ Không thể xóa loại phòng này vì đang được sử dụng bởi một hoặc nhiều phòng chiếu!</div>
            </c:if>
            <c:if test="${param.msg == 'error'}">
                <div class="alert-error">✕ Đã có lỗi xảy ra! Vui lòng thử lại sau.</div>
            </c:if>

            <div class="card">
                <div class="card-header">
                    <div>
                        <div class="card-title">Danh sách loại phòng chiếu</div>
                        <div class="card-subtitle">Quản lý các định dạng, công nghệ trình chiếu và phân loại phòng của rạp</div>
                    </div>
                    <div style="display:flex; align-items:center; gap:10px;">
                        <button type="button" class="btn btn-pink" onclick="openAddLoaiPhong()">+ Thêm loại phòng</button>
                        <span class="badge-pink">${listLoaiPhong.size()} loại phòng</span>
                    </div>
                </div>

                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th style="width: 50px;">STT</th>
                            <th style="width: 140px;">Mã loại phòng</th>
                            <th style="width: 220px;">Tên loại phòng</th>
                            <th>Mô tả / Đặc điểm kỹ thuật</th>
                            <th style="width: 200px; text-align: center;">Hành động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${listLoaiPhong}" var="item" varStatus="st">
                            <tr>
                                <td>${st.index + 1}</td>
                                <td><strong><c:out value="${item.maLoaiPhong}"/></strong></td>
                                <td><c:out value="${item.tenLoaiPhong}"/></td>
                                <td style="color: var(--text-secondary);"><c:out value="${not empty item.moTa ? item.moTa : 'Chưa có mô tả'}"/></td>
                                <td style="text-align: center;">
                                    <div class="action-group" style="justify-content: center;">
                                        <button type="button"
                                                class="btn btn-ghost btn-sm"
                                                data-ma="<c:out value='${item.maLoaiPhong}'/>"
                                                data-ten="<c:out value='${item.tenLoaiPhong}'/>"
                                                data-mota="<c:out value='${item.moTa}'/>"
                                                onclick="openDetailLoaiPhongFromBtn(this)">Chi tiết</button>
                                        <button type="button"
                                                class="btn btn-outline btn-sm"
                                                data-ma="<c:out value='${item.maLoaiPhong}'/>"
                                                data-ten="<c:out value='${item.tenLoaiPhong}'/>"
                                                data-mota="<c:out value='${item.moTa}'/>"
                                                onclick="openEditLoaiPhongFromBtn(this)">Sửa</button>
                                        <a href="${pageContext.request.contextPath}/loai-phong/delete?id=${item.maLoaiPhong}"
                                           class="btn btn-sm btn-danger-outline"
                                           onclick="return confirm('Bạn có chắc chắn muốn xóa loại phòng [${item.maLoaiPhong} - ${item.tenLoaiPhong}] không?');">Xóa</a>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty listLoaiPhong}">
                            <tr>
                                <td colspan="5" style="text-align: center; color: var(--text-muted); padding: 30px;">
                                    Chưa có loại phòng chiếu nào!
                                </td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</div>

<!-- POP-UP THÊM LOẠI PHÒNG -->
<div class="modal-backdrop ${openModal == 'add' ? 'open' : ''}" id="addLoaiPhongModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Thêm loại phòng chiếu</h3>
            <button type="button" class="modal-close" onclick="closeModal('addLoaiPhongModal')">&times;</button>
        </div>

        <c:if test="${openModal == 'add' and not empty error}">
            <div class="alert-error" id="addLoaiPhongError"><c:out value="${error}"/></div>
        </c:if>

        <form action="${pageContext.request.contextPath}/loai-phong/add" method="post">
            <div class="form-stack">
                <div class="form-group">
                    <label for="addMaLoaiPhong">Mã loại phòng<span class="required-star">*</span></label>
                    <input type="text" id="addMaLoaiPhong" name="maLoaiPhong" class="form-control"
                           value="${openModal == 'add' ? lp.maLoaiPhong : ''}"
                           placeholder="VD: 2D, 3D, IMAX, 4DX, VIP">
                </div>
                <div class="form-group">
                    <label for="addTenLoaiPhong">Tên loại phòng<span class="required-star">*</span></label>
                    <input type="text" id="addTenLoaiPhong" name="tenLoaiPhong" class="form-control"
                           value="${openModal == 'add' ? lp.tenLoaiPhong : ''}"
                           placeholder="VD: Phòng chiếu IMAX Laser">
                </div>
                <div class="form-group">
                    <label for="addMoTa">Mô tả / Đặc điểm kỹ thuật</label>
                    <textarea id="addMoTa" name="moTa" class="form-control" rows="3"
                              placeholder="VD: Màn hình cong siêu lớn, máy chiếu đôi Laser sắc nét">${openModal == 'add' ? lp.moTa : ''}</textarea>
                </div>
                <div style="font-size:12px; color:var(--text-secondary);">
                    (<span class="required-star">*</span>) Trường bắt buộc nhập
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('addLoaiPhongModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Thêm</button>
            </div>
        </form>
    </div>
</div>

<!-- POP-UP SỬA LOẠI PHÒNG -->
<div class="modal-backdrop ${openModal == 'update' ? 'open' : ''}" id="editLoaiPhongModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Sửa loại phòng chiếu</h3>
            <button type="button" class="modal-close" onclick="closeModal('editLoaiPhongModal')">&times;</button>
        </div>

        <c:if test="${openModal == 'update' and not empty error}">
            <div class="alert-error" id="editLoaiPhongError"><c:out value="${error}"/></div>
        </c:if>

        <form action="${pageContext.request.contextPath}/loai-phong/update" method="post">
            <div class="form-stack">
                <div class="form-group">
                    <label for="editMaLoaiPhong">Mã loại phòng<span class="required-star">*</span></label>
                    <input type="text" id="editMaLoaiPhong" name="maLoaiPhong" class="form-control"
                           value="${openModal == 'update' ? lp.maLoaiPhong : ''}" readonly>
                </div>
                <div class="form-group">
                    <label for="editTenLoaiPhong">Tên loại phòng<span class="required-star">*</span></label>
                    <input type="text" id="editTenLoaiPhong" name="tenLoaiPhong" class="form-control"
                           value="${openModal == 'update' ? lp.tenLoaiPhong : ''}" required>
                </div>
                <div class="form-group">
                    <label for="editMoTa">Mô tả / Đặc điểm kỹ thuật</label>
                    <textarea id="editMoTa" name="moTa" class="form-control" rows="3">${openModal == 'update' ? lp.moTa : ''}</textarea>
                </div>
                <div style="font-size:12px; color:var(--text-secondary);">
                    (<span class="required-star">*</span>) Trường bắt buộc nhập
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('editLoaiPhongModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Lưu cập nhật</button>
            </div>
        </form>
    </div>
</div>

<!-- POP-UP CHI TIẾT LOẠI PHÒNG -->
<div class="modal-backdrop ${openModal == 'detail' ? 'open' : ''}" id="detailLoaiPhongModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Chi tiết loại phòng chiếu</h3>
            <button type="button" class="modal-close" onclick="closeModal('detailLoaiPhongModal')">&times;</button>
        </div>
        <div class="form-stack">
            <div class="form-group">
                <label>Mã loại phòng</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailMaLoaiPhong"><c:out value="${lp.maLoaiPhong}"/></div>
            </div>
            <div class="form-group">
                <label>Tên loại phòng</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailTenLoaiPhong"><c:out value="${lp.tenLoaiPhong}"/></div>
            </div>
            <div class="form-group">
                <label>Mô tả / Đặc điểm</label>
                <div class="form-control" style="background:var(--bg-input); min-height: 70px; white-space: pre-wrap;" id="detailMoTa"><c:out value="${lp.moTa}"/></div>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-pink" onclick="closeModal('detailLoaiPhongModal')">Đóng</button>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=8"></script>
<script>
    function openAddLoaiPhong() {
        const err = document.getElementById('addLoaiPhongError');
        if (err) err.style.display = 'none';
        document.getElementById('addMaLoaiPhong').value = '';
        document.getElementById('addTenLoaiPhong').value = '';
        document.getElementById('addMoTa').value = '';
        document.getElementById('addLoaiPhongModal').classList.add('open');
    }

    function openEditLoaiPhongFromBtn(btn) {
        const err = document.getElementById('editLoaiPhongError');
        if (err) err.style.display = 'none';
        document.getElementById('editMaLoaiPhong').value = btn.getAttribute('data-ma') || '';
        document.getElementById('editTenLoaiPhong').value = btn.getAttribute('data-ten') || '';
        document.getElementById('editMoTa').value = btn.getAttribute('data-mota') || '';
        document.getElementById('editLoaiPhongModal').classList.add('open');
    }

    function openDetailLoaiPhongFromBtn(btn) {
        document.getElementById('detailMaLoaiPhong').textContent = btn.getAttribute('data-ma') || '';
        document.getElementById('detailTenLoaiPhong').textContent = btn.getAttribute('data-ten') || '';
        document.getElementById('detailMoTa').textContent = btn.getAttribute('data-mota') || 'Chưa có mô tả';
        document.getElementById('detailLoaiPhongModal').classList.add('open');
    }
</script>
</body>
</html>
