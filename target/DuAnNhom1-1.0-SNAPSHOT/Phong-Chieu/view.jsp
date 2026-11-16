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
                    <a href="${pageContext.request.contextPath}/phong-chieu/view" class="nav-subitem active">Danh sách phòng chiếu</a>
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
                        <div class="card-subtitle">Hiển thị 5 phòng chiếu trên mỗi trang</div>
                    </div>
                    <div style="display:flex; align-items:center; gap:10px;">
                        <button type="button" class="btn btn-outline" onclick="openModal('loaiPhongModal')">Quản lý loại phòng</button>
                        <button type="button" class="btn btn-pink" onclick="openAddPhongChieu()">+ Thêm</button>
                        <span class="badge-pink">${totalItems} phòng chiếu</span>
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
                                <td>${(currentPage - 1) * 5 + st.index + 1}</td>
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
                        <c:if test="${empty listPhongChieu}">
                            <tr>
                                <td colspan="6" style="text-align: center; color: var(--text-muted); padding: 30px;">
                                    Chưa có phòng chiếu nào!
                                </td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>

                <!-- THANH PHÂN TRANG (5 PHÒNG / 1 TRANG) -->
                <div style="display: flex; justify-content: space-between; align-items: center; padding: 14px 20px; border-top: 1px solid var(--border-subtle); flex-wrap: wrap; gap: 10px;">
                    <div style="color: var(--text-secondary); font-size: 13px;">
                        Trang <strong>${currentPage}</strong> / <strong>${totalPages}</strong> (Tổng cộng: <strong>${totalItems}</strong> phòng chiếu)
                    </div>

                    <div style="display: flex; gap: 6px; align-items: center;">
                        <%-- Nút về trang đầu và trang trước --%>
                        <c:if test="${currentPage > 1}">
                            <a href="${pageContext.request.contextPath}/phong-chieu/view?page=1" class="btn btn-ghost btn-sm">&laquo; Đầu</a>
                            <a href="${pageContext.request.contextPath}/phong-chieu/view?page=${currentPage - 1}" class="btn btn-ghost btn-sm">&lsaquo; Trước</a>
                        </c:if>

                        <%-- Các số trang 1, 2, 3... --%>
                        <c:forEach begin="1" end="${totalPages}" var="p">
                            <a href="${pageContext.request.contextPath}/phong-chieu/view?page=${p}"
                               class="btn btn-sm ${currentPage == p ? 'btn-pink' : 'btn-ghost'}"
                               style="min-width: 32px; justify-content: center; font-weight: ${currentPage == p ? '700' : '400'};">
                                ${p}
                            </a>
                        </c:forEach>

                        <%-- Nút sang trang sau và trang cuối --%>
                        <c:if test="${currentPage < totalPages}">
                            <a href="${pageContext.request.contextPath}/phong-chieu/view?page=${currentPage + 1}" class="btn btn-ghost btn-sm">Sau &rsaquo;</a>
                            <a href="${pageContext.request.contextPath}/phong-chieu/view?page=${totalPages}" class="btn btn-ghost btn-sm">Cuối &raquo;</a>
                        </c:if>
                    </div>
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
                    <label for="addLoaiPhong">Loại phòng chiếu<span class="required-star">*</span></label>
                    <select id="addLoaiPhong" name="loaiPhong" class="form-control">
                        <option value="">-- Chọn loại phòng chiếu --</option>
                        <c:forEach items="${listLoaiPhong}" var="lp">
                            <option value="${lp.maLoaiPhong}" ${openModal == 'add' && pc.loaiPhong == lp.maLoaiPhong ? 'selected' : ''}>
                                <c:out value="${lp.maLoaiPhong}"/> - <c:out value="${lp.tenLoaiPhong}"/>
                            </option>
                        </c:forEach>
                        <c:if test="${empty listLoaiPhong}">
                            <option value="2D" ${openModal == 'add' && pc.loaiPhong == '2D' ? 'selected' : ''}>2D (Tiêu chuẩn)</option>
                            <option value="3D" ${openModal == 'add' && pc.loaiPhong == '3D' ? 'selected' : ''}>3D (Kính 3D)</option>
                            <option value="IMAX" ${openModal == 'add' && pc.loaiPhong == 'IMAX' ? 'selected' : ''}>IMAX (Màn hình siêu lớn)</option>
                            <option value="4DX" ${openModal == 'add' && pc.loaiPhong == '4DX' ? 'selected' : ''}>4DX (Ghế chuyển động & hiệu ứng)</option>
                            <option value="VIP" ${openModal == 'add' && pc.loaiPhong == 'VIP' ? 'selected' : ''}>VIP (Ghế sofa cao cấp)</option>
                            <option value="ScreenX" ${openModal == 'add' && pc.loaiPhong == 'ScreenX' ? 'selected' : ''}>ScreenX (Chiếu 3 màn hình)</option>
                        </c:if>
                    </select>
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
                    <label for="editLoaiPhong">Loại phòng chiếu<span class="required-star">*</span></label>
                    <select id="editLoaiPhong" name="loaiPhong" class="form-control">
                        <option value="">-- Chọn loại phòng chiếu --</option>
                        <c:forEach items="${listLoaiPhong}" var="lp">
                            <option value="${lp.maLoaiPhong}">
                                <c:out value="${lp.maLoaiPhong}"/> - <c:out value="${lp.tenLoaiPhong}"/>
                            </option>
                        </c:forEach>
                        <c:if test="${empty listLoaiPhong}">
                            <option value="2D">2D (Tiêu chuẩn)</option>
                            <option value="3D">3D (Kính 3D)</option>
                            <option value="IMAX">IMAX (Màn hình siêu lớn)</option>
                            <option value="4DX">4DX (Ghế chuyển động & hiệu ứng)</option>
                            <option value="VIP">VIP (Ghế sofa cao cấp)</option>
                            <option value="ScreenX">ScreenX (Chiếu 3 màn hình)</option>
                        </c:if>
                    </select>
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
                <label>Loại phòng chiếu</label>
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

<!-- POP-UP QUẢN LÝ LOẠI PHÒNG (DANH SÁCH, THÊM, SỬA, XÓA) -->
<div class="modal-backdrop ${param.openModal == 'loaiPhong' ? 'open' : ''}" id="loaiPhongModal">
    <div class="modal-box" style="max-width: 680px; width: 95%;">
        <div class="modal-header">
            <h3>Quản lý loại phòng chiếu</h3>
            <button type="button" class="modal-close" onclick="closeModal('loaiPhongModal')">&times;</button>
        </div>

        <!-- THÔNG BÁO KẾT QUẢ THAO TÁC TRONG MODAL -->
        <c:if test="${param.lpMsg == 'add_ok'}">
            <div class="alert-success" style="padding: 10px 14px; margin-bottom: 12px; font-size: 13px; background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; border-radius: var(--radius-sm); font-weight: 500;">
                ✓ Thêm loại phòng thành công!
            </div>
        </c:if>
        <c:if test="${param.lpMsg == 'update_ok'}">
            <div class="alert-success" style="padding: 10px 14px; margin-bottom: 12px; font-size: 13px; background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; border-radius: var(--radius-sm); font-weight: 500;">
                ✓ Cập nhật loại phòng thành công!
            </div>
        </c:if>
        <c:if test="${param.lpMsg == 'delete_ok'}">
            <div class="alert-success" style="padding: 10px 14px; margin-bottom: 12px; font-size: 13px; background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; border-radius: var(--radius-sm); font-weight: 500;">
                ✓ Xóa loại phòng thành công!
            </div>
        </c:if>
        <c:if test="${param.lpMsg == 'in_use'}">
            <div class="alert-error" style="padding: 10px 14px; margin-bottom: 12px; font-size: 13px;">
                ✕ Không thể xóa vì loại phòng này đang được sử dụng bởi phòng chiếu!
            </div>
        </c:if>
        <c:if test="${param.lpMsg == 'duplicate'}">
            <div class="alert-error" style="padding: 10px 14px; margin-bottom: 12px; font-size: 13px;">
                ✕ Mã loại phòng đã tồn tại!
            </div>
        </c:if>
        <c:if test="${param.lpMsg == 'empty'}">
            <div class="alert-error" style="padding: 10px 14px; margin-bottom: 12px; font-size: 13px;">
                ✕ Vui lòng nhập đầy đủ Mã loại phòng và Tên loại phòng!
            </div>
        </c:if>
        <c:if test="${param.lpMsg == 'error'}">
            <div class="alert-error" style="padding: 10px 14px; margin-bottom: 12px; font-size: 13px;">
                ✕ Có lỗi xảy ra trong quá trình xử lý! Vui lòng thử lại.
            </div>
        </c:if>

        <!-- FORM THÊM / CẬP NHẬT LOẠI PHÒNG -->
        <div style="background: var(--bg-input); padding: 14px 16px; border-radius: var(--radius-sm); margin-bottom: 16px; border: 1px solid var(--border-subtle);">
            <div id="lpFormTitle" style="font-weight: 600; font-size: 13px; margin-bottom: 10px; color: var(--text-primary);">
                + Thêm loại phòng mới
            </div>
            <form id="loaiPhongForm" action="${pageContext.request.contextPath}/phong-chieu/loai-phong-add" method="post" style="display: flex; gap: 10px; align-items: flex-end; flex-wrap: wrap;">
                <div style="flex: 1; min-width: 130px;">
                    <label for="lpMaLoai" style="display:block; font-size: 12px; margin-bottom: 4px; font-weight: 500;">Mã loại phòng<span class="required-star">*</span></label>
                    <input type="text" id="lpMaLoai" name="maLoaiPhong" class="form-control" placeholder="VD: 2D, IMAX..." required style="height: 38px;">
                </div>
                <div style="flex: 2; min-width: 200px;">
                    <label for="lpTenLoai" style="display:block; font-size: 12px; margin-bottom: 4px; font-weight: 500;">Tên loại phòng<span class="required-star">*</span></label>
                    <input type="text" id="lpTenLoai" name="tenLoaiPhong" class="form-control" placeholder="VD: Phòng chiếu IMAX Laser" required style="height: 38px;">
                </div>
                <div style="display: flex; gap: 6px;">
                    <button type="submit" id="lpBtnSubmit" class="btn btn-pink" style="height: 38px;">Thêm</button>
                    <button type="button" id="lpBtnCancel" class="btn btn-ghost" style="height: 38px; display: none;" onclick="cancelEditLoaiPhong()">Hủy</button>
                </div>
            </form>
        </div>

        <!-- DANH SÁCH BẢNG LOẠI PHÒNG -->
        <div class="table-wrap" style="max-height: 260px; overflow-y: auto; border: 1px solid var(--border-subtle); border-radius: var(--radius-sm);">
            <table>
                <thead>
                <tr>
                    <th style="width: 50px;">STT</th>
                    <th style="width: 140px;">Mã loại phòng</th>
                    <th>Tên loại phòng</th>
                    <th style="width: 140px; text-align: center;">Hành động</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${listLoaiPhong}" var="item" varStatus="st">
                    <tr>
                        <td>${st.index + 1}</td>
                        <td><strong><c:out value="${item.maLoaiPhong}"/></strong></td>
                        <td><c:out value="${item.tenLoaiPhong}"/></td>
                        <td style="text-align: center;">
                            <div class="action-group" style="justify-content: center; gap: 4px;">
                                <button type="button"
                                        class="btn btn-outline btn-sm"
                                        data-ma="<c:out value='${item.maLoaiPhong}'/>"
                                        data-ten="<c:out value='${item.tenLoaiPhong}'/>"
                                        onclick="startEditLoaiPhong(this)">Sửa</button>
                                <a href="${pageContext.request.contextPath}/phong-chieu/loai-phong-delete?id=${item.maLoaiPhong}"
                                   class="btn btn-sm"
                                   style="background: #fff1f2; color: #e11d48; border: 1px solid #fda4af;"
                                   onclick="return confirm('Bạn có chắc chắn muốn xóa loại phòng [${item.maLoaiPhong} - ${item.tenLoaiPhong}] không?');">Xóa</a>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty listLoaiPhong}">
                    <tr>
                        <td colspan="4" style="text-align: center; color: var(--text-muted); padding: 25px;">
                            Chưa có loại phòng nào!
                        </td>
                    </tr>
                </c:if>
                </tbody>
            </table>
        </div>

        <div class="modal-footer" style="margin-top: 16px;">
            <button type="button" class="btn btn-pink" onclick="closeModal('loaiPhongModal')">Đóng</button>
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

        const loaiVal = btn.getAttribute('data-loai') || '';
        const selectLoai = document.getElementById('editLoaiPhong');
        selectLoai.value = loaiVal;

        // Nếu giá trị trong database chưa có trong các option mặc định, tự động thêm vào
        if (loaiVal && selectLoai.value !== loaiVal) {
            const opt = document.createElement('option');
            opt.value = loaiVal;
            opt.textContent = loaiVal;
            opt.selected = true;
            selectLoai.appendChild(opt);
        }

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

    function startEditLoaiPhong(btn) {
        const ma = btn.getAttribute('data-ma') || '';
        const ten = btn.getAttribute('data-ten') || '';

        const form = document.getElementById('loaiPhongForm');
        form.action = '${pageContext.request.contextPath}/phong-chieu/loai-phong-update';

        const maInput = document.getElementById('lpMaLoai');
        maInput.value = ma;
        maInput.readOnly = true;

        const tenInput = document.getElementById('lpTenLoai');
        tenInput.value = ten;
        tenInput.focus();

        document.getElementById('lpFormTitle').textContent = 'Chỉnh sửa loại phòng: ' + ma;
        document.getElementById('lpBtnSubmit').textContent = 'Lưu';
        document.getElementById('lpBtnCancel').style.display = 'inline-flex';
    }

    function cancelEditLoaiPhong() {
        const form = document.getElementById('loaiPhongForm');
        form.action = '${pageContext.request.contextPath}/phong-chieu/loai-phong-add';

        const maInput = document.getElementById('lpMaLoai');
        maInput.value = '';
        maInput.readOnly = false;

        document.getElementById('lpTenLoai').value = '';

        document.getElementById('lpFormTitle').textContent = '+ Thêm loại phòng mới';
        document.getElementById('lpBtnSubmit').textContent = 'Thêm';
        document.getElementById('lpBtnCancel').style.display = 'none';
    }
</script>
</body>
</html>
