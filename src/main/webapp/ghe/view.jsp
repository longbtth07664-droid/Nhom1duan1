<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sơ Đồ & Quản Lý Ghế - Rạp Chiếu Phim CINEMAX</title>
    <!-- Nhúng file CSS giao diện chung của rạp phim CINEMAX -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=8">
    <!-- Nhúng file CSS định dạng riêng cho sơ đồ ghế -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/ghe.css?v=20261123_2">
</head>
<body>
<div class="app-shell">
    <!-- MENU BÊN TRÁI HỆ THỐNG (ĐỒNG BỘ ĐẦY ĐỦ 100% CHỨC NĂNG) -->
    <c:choose>
        <c:when test="${sessionScope.userRole == 'NhanVien' || sessionScope.userRole == 'Nhân viên'}">
            <jsp:include page="/menunv.jsp" />
        </c:when>
        <c:otherwise>
            <jsp:include page="/menuadmin.jsp" />
        </c:otherwise>
    </c:choose>

    <!-- NỘI DUNG CHÍNH CỦA TRANG -->
    <div class="main-wrapper">
        <!-- Thanh tiêu đề phía trên cùng -->
        <header class="topbar">
            <div class="topbar-left">
                <button type="button" class="mobile-menu-btn" onclick="toggleSidebar()">☰</button>
                <div class="page-title-wrap">
                    <h2>Sơ đồ & Quản lý ghế ngồi</h2>
                </div>
            </div>
            <div class="topbar-right">
                <a href="${pageContext.request.contextPath}/phong-chieu/view" class="btn btn-ghost btn-sm">Quay lại Phòng Chiếu</a>
            </div>
        </header>

        <!-- Khu vực hiển thị nội dung chính -->
        <main class="content-area">

            <!-- Thông báo trạng thái thao tác trên ghế -->
            <c:if test="${msg == 'add_ok'}">
                <div style="background:#ecfdf5; border:1px solid #a7f3d0; color:#047857; padding:12px 16px; border-radius:8px; margin-bottom:16px; font-weight:600;">
                    ✓ Thêm ghế mới vào phòng thành công!
                </div>
            </c:if>
            <c:if test="${msg == 'update_ok'}">
                <div style="background:#ecfdf5; border:1px solid #a7f3d0; color:#047857; padding:12px 16px; border-radius:8px; margin-bottom:16px; font-weight:600;">
                    ✓ Cập nhật thông tin ghế thành công!
                </div>
            </c:if>
            <c:if test="${msg == 'duplicate_seat'}">
                <div style="background:#fef2f2; border:1px solid #fecaca; color:#dc2626; padding:12px 16px; border-radius:8px; margin-bottom:16px; font-weight:600;">
                    ✕ Vị trí hàng ghế và số ghế này đã tồn tại trong phòng chiếu!
                </div>
            </c:if>
            <c:if test="${msg == 'full_capacity'}">
                <div style="background:#fef2f2; border:1px solid #fecaca; color:#dc2626; padding:12px 16px; border-radius:8px; margin-bottom:16px; font-weight:600;">
                    ✕ Không thể thêm ghế! Phòng chiếu đã đạt giới hạn sức chứa tối đa (${selectedPhong.sucChua} chỗ). Vui lòng không thêm vượt quá quy định!
                </div>
            </c:if>
            <c:if test="${msg == 'exceed_capacity'}">
                <div style="background:#fef2f2; border:1px solid #fecaca; color:#dc2626; padding:12px 16px; border-radius:8px; margin-bottom:16px; font-weight:600;">
                    ✕ Không thể đổi sang loại ghế này vì sẽ vượt quá sức chứa tối đa của phòng chiếu (${selectedPhong.sucChua} chỗ)!
                </div>
            </c:if>

            <!-- Thanh chọn phòng chiếu và nút quản lý loại ghế, thêm ghế lẻ -->
            <div class="room-picker-bar">
                <div style="display:flex; align-items:center; gap:12px; flex-wrap:wrap;">
                    <label for="roomSelect" style="font-weight:700; font-size:14px; color:var(--text-primary);">Chọn phòng chiếu:</label>
                    <select id="roomSelect" class="form-control" style="width:260px; font-weight:600;"
                            data-context="${pageContext.request.contextPath}"
                            onchange="changeRoomFilter(this)">
                        <c:forEach items="${listPhong}" var="p">
                            <option value="${p.maPhong}" ${p.maPhong == selectedPhong.maPhong ? 'selected' : ''}>
                                <c:out value="${p.tenPhong}"/> (${p.loaiPhong} - ${p.sucChua} chỗ)
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <!-- Các nút hành động: Quản lý loại ghế và Thêm ghế lẻ (chặn khi phòng đã đủ sức chứa) -->
                <div style="display:flex; align-items:center; gap:10px;">
                    <button type="button" class="btn btn-outline btn-sm" onclick="openLoaiGheModal()">Quản lý loại ghế</button>
                    <c:choose>
                        <c:when test="${totalChoNgoi >= selectedPhong.sucChua}">
                            <button type="button" class="btn btn-sm"
                                    style="background:#f1f5f9; color:#94a3b8; border:1px solid #cbd5e1; cursor:not-allowed;"
                                    title="Phòng chiếu đã đủ sức chứa (${totalChoNgoi}/${selectedPhong.sucChua} chỗ)"
                                    onclick="alert('Phòng chiếu này đã đạt giới hạn sức chứa tối đa (${totalChoNgoi}/${selectedPhong.sucChua} chỗ)! Không thể thêm ghế mới.')">
                                + Đã đủ sức chứa (${totalChoNgoi}/${selectedPhong.sucChua})
                            </button>
                        </c:when>
                        <c:otherwise>
                            <button type="button" class="btn btn-pink btn-sm" onclick="openAddSeatModal()">+ Thêm ghế lẻ</button>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Các thẻ viên thuốc thống kê số lượng ghế theo từng loại -->
            <div class="seat-stats-strip">
                <div class="stat-mini-pill" style="${totalChoNgoi >= selectedPhong.sucChua ? 'border-color:#a7f3d0; background:#f0fdf4;' : ''}">
                    <span>Tổng số: <strong>${totalChoNgoi} chỗ</strong> / Sức chứa: <strong>${selectedPhong.sucChua} chỗ</strong> (${totalGhe} ghế)</span>
                    <c:if test="${totalChoNgoi >= selectedPhong.sucChua}">
                        <span style="background:#dcfce7; color:#15803d; padding:2px 8px; border-radius:99px; font-size:11px; font-weight:700; margin-left:6px;">Đủ sức chứa</span>
                    </c:if>
                </div>
                <div class="stat-mini-pill">
                    <span class="stat-dot" style="background:#3b82f6;"></span>
                    <span>Ghế Thường: <strong>${cntThuong}</strong></span>
                </div>
                <div class="stat-mini-pill">
                    <span class="stat-dot" style="background:#f59e0b;"></span>
                    <span>Ghế VIP: <strong>${cntVip}</strong></span>
                </div>
                <div class="stat-mini-pill">
                    <span class="stat-dot" style="background:#06b6d4;"></span>
                    <span>Ghế Đôi (x2 chỗ): <strong>${cntDoi}</strong> (${cntDoi * 2} chỗ)</span>
                </div>
                <c:if test="${cntBaoTri > 0}">
                    <div class="stat-mini-pill" style="border-color:#fca5a5;">
                        <span class="stat-dot" style="background:#e2e8f0; border:1px solid #94a3b8;"></span>
                        <span>Bảo trì: <strong style="color:#ef4444;">${cntBaoTri}</strong></span>
                    </div>
                </c:if>
            </div>

            <!-- SƠ ĐỒ TRỰC QUAN KHÁN PHÒNG RẠP CHIẾU PHIM -->
            <div id="visualSeatMapArea" class="auditorium-wrapper">

                <!-- Màn hình vòm cong rạp chiếu phim -->
                <div class="screen-container">
                    <div class="cinema-screen"></div>
                    <div class="screen-label">MÀN HÌNH CHÍNH</div>
                </div>

                <!-- Danh sách các hàng ghế xếp theo thứ tự A, B, C, D, E... -->
                <c:choose>
                    <c:when test="${empty mapHangGhe}">
                        <div style="text-align:center; padding:50px 20px; color:var(--text-secondary);">
                            <p style="font-size:16px; margin-bottom:12px;">Phòng chiếu này chưa có ghế nào được thiết lập!</p>
                            <button type="button" class="btn btn-pink" onclick="openAddSeatModal()">+ Bấm vào đây để thêm ghế vào phòng</button>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach items="${mapHangGhe}" var="rowEntry">
                            <div class="seat-row">
                                <div class="row-label">Hàng ${rowEntry.key}</div>
                                <div class="row-seats">
                                    <c:forEach items="${rowEntry.value}" var="seat">
                                        <c:set var="seatClass" value="type-thuong"/>
                                        <c:choose>
                                            <c:when test="${seat.trangThai == 'Bảo trì' || seat.trangThai == 'Hỏng'}">
                                                <c:set var="seatClass" value="status-baotri"/>
                                            </c:when>
                                            <c:when test="${seat.isGheDoi()}">
                                                <c:set var="seatClass" value="type-doi"/>
                                            </c:when>
                                            <c:when test="${seat.loaiGhe != null && seat.loaiGhe.maLoaiGhe == 2}">
                                                <c:set var="seatClass" value="type-vip"/>
                                            </c:when>
                                            <c:otherwise>
                                                <c:set var="seatClass" value="type-thuong"/>
                                            </c:otherwise>
                                        </c:choose>

                                        <!-- Ô ghế ngồi có thể click để mở popup chỉnh sửa -->
                                        <div class="seat-box ${seatClass}"
                                             data-maghe="${seat.maGhe}"
                                             data-tenghe="<c:out value='${seat.tenGhe}'/>"
                                             data-maloai="${seat.loaiGhe != null ? seat.loaiGhe.maLoaiGhe : ''}"
                                             data-hang="<c:out value='${seat.hangGhe}'/>"
                                             data-so="${seat.soGhe}"
                                             data-trangthai="<c:out value='${seat.trangThai}'/>"
                                             data-gia="${seat.gia}"
                                             title="Ghế ${seat.tenGhe} - ${seat.loaiGhe.tenLoaiGhe} (${seat.trangThai}) - Giá: <fmt:formatNumber value='${seat.gia}' pattern='#,##0'/> đ"
                                             onclick="openSeatDetailModalFromEl(this)">
                                            <c:out value="${seat.tenGhe}"/>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>

                <!-- Bảng chú thích ký hiệu màu sắc các loại ghế -->
                <div class="seat-legend">
                    <div class="legend-item">
                        <span class="legend-color" style="background:#3b82f6;"></span>
                        <span>Ghế thường</span>
                    </div>
                    <div class="legend-item">
                        <span class="legend-color" style="background:#f59e0b;"></span>
                        <span>Ghế VIP</span>
                    </div>
                    <div class="legend-item">
                        <span class="legend-color" style="background:#06b6d4; width:36px;"></span>
                        <span>Ghế Đôi (Sweetbox - 2 chỗ)</span>
                    </div>
                    <div class="legend-item">
                        <span class="legend-color" style="background:#e2e8f0; border:1px solid #cbd5e1;"></span>
                        <span>Ghế bảo trì / ngưng phục vụ</span>
                    </div>
                </div>
            </div>

        </main>
    </div>
</div>

<!-- ==================== POPUP 1: CHI TIẾT & CHỈNH SỬA GHẾ ==================== -->
<div class="modal-backdrop" id="seatDetailModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Chi tiết & Sửa Ghế [<span id="editTenGheTitle" style="color:var(--pink);"></span>]</h3>
            <button type="button" class="modal-close" onclick="closeModalDialog('seatDetailModal')">×</button>
        </div>
        <form action="${pageContext.request.contextPath}/ghe/update" method="post">
            <div class="modal-body">
                <input type="hidden" name="maGhe" id="editMaGhe">
                <input type="hidden" name="maPhong" value="${selectedPhong.maPhong}">
                <input type="hidden" id="deleteMaGhe" name="deleteMaGhe">

                <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:12px;">
                    <div>
                        <label class="form-label" style="font-weight:600; font-size:13px;">Hàng ghế (*):</label>
                        <input type="text" name="hangGhe" id="editHangGhe" class="form-control" maxlength="2" required style="text-transform:uppercase;">
                    </div>
                    <div>
                        <label class="form-label" style="font-weight:600; font-size:13px;">Số ghế (*):</label>
                        <input type="number" name="soGhe" id="editSoGhe" class="form-control" min="1" max="50" required>
                    </div>
                </div>

                <div class="form-group" style="margin-bottom:12px;">
                    <label class="form-label" style="font-weight:600; font-size:13px;">Loại ghế (*):</label>
                    <select name="maLoaiGhe" id="editMaLoaiGhe" class="form-control" required>
                        <c:forEach items="${listLoaiGhe}" var="lg">
                            <option value="${lg.maLoaiGhe}">
                                <c:out value="${lg.tenLoaiGhe}"/> (Phụ thu: <fmt:formatNumber value="${lg.phuThu}" pattern="#,##0"/> đ)
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group" style="margin-bottom:12px;">
                    <label class="form-label" style="font-weight:600; font-size:13px;">Giá ghế (VNĐ):</label>
                    <input type="text" name="gia" id="editGia" class="form-control" placeholder="80000">
                </div>

                <div class="form-group">
                    <label class="form-label" style="font-weight:600; font-size:13px;">Trạng thái:</label>
                    <select name="trangThai" id="editTrangThai" class="form-control">
                        <option value="Hoạt động">Hoạt động</option>
                        <option value="Bảo trì">Bảo trì (Tạm ngưng phục vụ)</option>
                        <option value="Hỏng">Hỏng</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer" style="display:flex; justify-content:flex-end; gap:8px;">
                <button type="button" class="btn btn-ghost" onclick="closeModalDialog('seatDetailModal')">Đóng</button>
                <button type="submit" class="btn btn-pink">Lưu thay đổi</button>
            </div>
        </form>
    </div>
</div>

<!-- ==================== POPUP 2: THÊM GHẾ MỚI ==================== -->
<div class="modal-backdrop" id="addSeatModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3>Thêm Ghế Mới [<c:out value="${selectedPhong.tenPhong}"/>]</h3>
            <button type="button" class="modal-close" onclick="closeModalDialog('addSeatModal')">×</button>
        </div>
        <form action="${pageContext.request.contextPath}/ghe/add" method="post">
            <div class="modal-body">
                <input type="hidden" name="maPhong" value="${selectedPhong.maPhong}">

                <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:12px;">
                    <div>
                        <label class="form-label" style="font-weight:600; font-size:13px;">Hàng ghế (*):</label>
                        <input type="text" name="hangGhe" class="form-control" placeholder="A, B, C..." maxlength="2" required style="text-transform:uppercase;">
                    </div>
                    <div>
                        <label class="form-label" style="font-weight:600; font-size:13px;">Số ghế (*):</label>
                        <input type="number" name="soGhe" class="form-control" placeholder="1, 2, 3..." min="1" max="50" required>
                    </div>
                </div>

                <div class="form-group" style="margin-bottom:12px;">
                    <label class="form-label" style="font-weight:600; font-size:13px;">Loại ghế (*):</label>
                    <select name="maLoaiGhe" class="form-control" required>
                        <c:forEach items="${listLoaiGhe}" var="lg">
                            <option value="${lg.maLoaiGhe}">
                                <c:out value="${lg.tenLoaiGhe}"/> (Phụ thu: <fmt:formatNumber value="${lg.phuThu}" pattern="#,##0"/> đ)
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group" style="margin-bottom:12px;">
                    <label class="form-label" style="font-weight:600; font-size:13px;">Giá ghế (VNĐ):</label>
                    <input type="text" name="gia" class="form-control" value="80000">
                </div>

                <div class="form-group">
                    <label class="form-label" style="font-weight:600; font-size:13px;">Trạng thái:</label>
                    <select name="trangThai" class="form-control">
                        <option value="Hoạt động" selected>Hoạt động</option>
                        <option value="Bảo trì">Bảo trì</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModalDialog('addSeatModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Thêm ghế</button>
            </div>
        </form>
    </div>
</div>

<!-- ==================== POPUP 3: QUẢN LÝ LOẠI GHẾ (DANH SÁCH, THÊM, SỬA) ==================== -->
<div class="modal-backdrop ${openModal == 'loaiGhe' ? 'open' : ''}" id="loaiGheModal">
    <div class="modal-box" style="max-width: 680px; width: 95%;">
        <div class="modal-header">
            <h3>Quản lý loại ghế & phụ thu rạp</h3>
            <button type="button" class="modal-close" onclick="closeModalDialog('loaiGheModal')">×</button>
        </div>

        <!-- Thông báo kết quả thao tác loại ghế -->
        <c:if test="${lgMsg == 'add_ok'}">
            <div style="background:#ecfdf5; border:1px solid #a7f3d0; color:#047857; padding:10px 14px; border-radius:8px; margin-bottom:12px; font-size:13px; font-weight:600;">
                ✓ Thêm loại ghế mới thành công!
            </div>
        </c:if>
        <c:if test="${lgMsg == 'update_ok'}">
            <div style="background:#ecfdf5; border:1px solid #a7f3d0; color:#047857; padding:10px 14px; border-radius:8px; margin-bottom:12px; font-size:13px; font-weight:600;">
                ✓ Cập nhật loại ghế thành công!
            </div>
        </c:if>
        <c:if test="${lgMsg == 'delete_ok'}">
            <div style="background:#ecfdf5; border:1px solid #a7f3d0; color:#047857; padding:10px 14px; border-radius:8px; margin-bottom:12px; font-size:13px; font-weight:600;">
                ✓ Đã xóa loại ghế thành công!
            </div>
        </c:if>
        <c:if test="${lgMsg == 'in_use'}">
            <div style="background:#fef2f2; border:1px solid #fecaca; color:#dc2626; padding:10px 14px; border-radius:8px; margin-bottom:12px; font-size:13px; font-weight:600;">
                ✕ Không thể xóa vì loại ghế này đang được sử dụng bởi các ghế trong rạp!
            </div>
        </c:if>
        <c:if test="${lgMsg == 'duplicate'}">
            <div style="background:#fef2f2; border:1px solid #fecaca; color:#dc2626; padding:10px 14px; border-radius:8px; margin-bottom:12px; font-size:13px; font-weight:600;">
                ✕ Tên loại ghế này đã tồn tại!
            </div>
        </c:if>
        <c:if test="${lgMsg == 'empty'}">
            <div style="background:#fef2f2; border:1px solid #fecaca; color:#dc2626; padding:10px 14px; border-radius:8px; margin-bottom:12px; font-size:13px; font-weight:600;">
                ✕ Vui lòng nhập đầy đủ tên loại ghế!
            </div>
        </c:if>
        <c:if test="${lgMsg == 'error'}">
            <div style="background:#fef2f2; border:1px solid #fecaca; color:#dc2626; padding:10px 14px; border-radius:8px; margin-bottom:12px; font-size:13px; font-weight:600;">
                ✕ Có lỗi xảy ra trong quá trình xử lý! Vui lòng thử lại.
            </div>
        </c:if>

        <!-- Form thêm hoặc cập nhật Loại ghế -->
        <div style="background: var(--bg-input, #f8fafc); padding: 14px 16px; border-radius: 10px; margin-bottom: 16px; border: 1px solid var(--border-subtle, #e2e8f0);">
            <div id="lgFormTitle" style="font-weight: 700; font-size: 13px; margin-bottom: 10px; color: var(--text-primary, #0f172a);">
                + Thêm loại ghế mới
            </div>
            <form id="loaiGheForm"
                  action="${pageContext.request.contextPath}/ghe/loai-ghe-add"
                  data-context="${pageContext.request.contextPath}"
                  method="post"
                  style="display: flex; gap: 10px; align-items: flex-end; flex-wrap: wrap;">
                <input type="hidden" name="maPhong" value="${selectedPhong.maPhong}">
                <input type="hidden" name="maLoaiGhe" id="lgMaLoaiGhe">

                <div style="flex: 2; min-width: 180px;">
                    <label for="lgTenLoaiGhe" style="display:block; font-size: 12px; margin-bottom: 4px; font-weight: 600;">Tên loại ghế (*):</label>
                    <input type="text" id="lgTenLoaiGhe" name="tenLoaiGhe" class="form-control" placeholder="VD: Ghế VIP Diamond, Sweetbox..." required style="height: 38px;">
                </div>
                <div style="flex: 1; min-width: 140px;">
                    <label for="lgPhuThu" style="display:block; font-size: 12px; margin-bottom: 4px; font-weight: 600;">Phụ thu (VNĐ):</label>
                    <input type="number" id="lgPhuThu" name="phuThu" class="form-control" placeholder="0" min="0" step="1000" value="0" style="height: 38px;">
                </div>
                <div style="display: flex; gap: 6px;">
                    <button type="submit" id="lgBtnSubmit" class="btn btn-pink" style="height: 38px;">Thêm</button>
                    <button type="button" id="lgBtnCancel" class="btn btn-ghost" style="height: 38px; display: none;" onclick="cancelEditLoaiGhe()">Hủy</button>
                </div>
            </form>
        </div>

        <!-- Bảng danh sách Loại ghế hiện có -->
        <div class="table-wrap" style="max-height: 240px; overflow-y: auto; border: 1px solid var(--border-subtle, #e2e8f0); border-radius: 8px;">
            <table>
                <thead>
                <tr>
                    <th style="width: 50px;">STT</th>
                    <th style="width: 100px;">Mã loại</th>
                    <th>Tên loại ghế</th>
                    <th style="width: 130px;">Phụ thu</th>
                    <th style="width: 140px; text-align: center;">Hành động</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${listLoaiGhe}" var="item" varStatus="st">
                    <tr>
                        <td>${st.index + 1}</td>
                        <td><strong>#${item.maLoaiGhe}</strong></td>
                        <td><span style="font-weight:600;"><c:out value="${item.tenLoaiGhe}"/></span></td>
                        <td><fmt:formatNumber value="${item.phuThu}" pattern="#,##0"/> đ</td>
                        <td style="text-align: center;">
                            <div class="action-group" style="justify-content: center; gap: 4px;">
                                <button type="button"
                                        class="btn btn-outline btn-sm"
                                        data-ma="${item.maLoaiGhe}"
                                        data-ten="<c:out value='${item.tenLoaiGhe}'/>"
                                        data-phuthu="${item.phuThu}"
                                        onclick="startEditLoaiGhe(this)">Sửa</button>
                                <a href="${pageContext.request.contextPath}/ghe/loai-ghe-delete?id=${item.maLoaiGhe}&maPhong=${selectedPhong.maPhong}"
                                   class="btn btn-sm"
                                   style="background: #fff1f2; color: #e11d48; border: 1px solid #fda4af;"
                                   onclick="return confirm('Bạn có chắc chắn muốn xóa loại ghế [${item.tenLoaiGhe}] không?');">Xóa</a>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty listLoaiGhe}">
                    <tr>
                        <td colspan="5" style="text-align: center; color: var(--text-muted); padding: 25px;">
                            Chưa có loại ghế nào!
                        </c:if>
                </tbody>
            </table>
        </div>

        <div class="modal-footer" style="margin-top: 16px;">
            <button type="button" class="btn btn-pink" onclick="closeModalDialog('loaiGheModal')">Đóng</button>
        </div>
    </div>
</div>

<!-- Nhúng file JavaScript tương tác dùng chung của hệ thống -->
<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=8"></script>
<!-- Nhúng file JavaScript xử lý riêng cho sơ đồ ghế và loại ghế -->
<script src="${pageContext.request.contextPath}/assets/js/ghe.js?v=20261123_2"></script>

<script>
    // Hàm mở popup chi tiết & sửa ghế từ phần tử DOM (hạn chế lỗi tham số chuỗi)
    function openSeatDetailModalFromEl(el) {
        if (!el) return;
        const maGhe = el.getAttribute('data-maghe') || '';
        const tenGhe = el.getAttribute('data-tenghe') || '';
        const maLoai = el.getAttribute('data-maloai') || '';
        const hang = el.getAttribute('data-hang') || '';
        const so = el.getAttribute('data-so') || '';
        const trangThai = el.getAttribute('data-trangthai') || 'Hoạt động';
        const gia = el.getAttribute('data-gia') || '';
        openSeatDetailModal(maGhe, tenGhe, maLoai, hang, so, trangThai, gia);
    }

    // Mở popup chi tiết và sửa ghế với kiểm tra an toàn từng phần tử
    function openSeatDetailModal(maGhe, tenGhe, maLoai, hang, so, trangThai, gia) {
        try {
            const setVal = function(id, val) {
                const el = document.getElementById(id);
                if (el) el.value = (val !== undefined && val !== null) ? val : '';
            };
            const setText = function(id, txt) {
                const el = document.getElementById(id);
                if (el) el.innerText = (txt !== undefined && txt !== null) ? txt : '';
            };

            setVal('editMaGhe', maGhe);
            setText('editTenGheTitle', tenGhe);
            setVal('editHangGhe', hang);
            setVal('editSoGhe', so);
            setVal('editMaLoaiGhe', maLoai);
            setVal('editTrangThai', trangThai);
            setVal('editGia', gia);
            setVal('deleteMaGhe', maGhe);

            openModalDialog('seatDetailModal');
        } catch (err) {
            console.error('Lỗi khi mở modal chi tiết ghế:', err);
        }
    }

    // Mở modal dialog bảo đảm luôn hiển thị
    function openModalDialog(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.style.display = 'flex';
            modal.classList.add('open');
        }
    }

    // Đóng modal dialog bảo đảm luôn ẩn
    function closeModalDialog(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.style.display = 'none';
            modal.classList.remove('open');
        }
    }

    // Đồng bộ hàm closeModal của cinema-mock.js
    window.closeModal = function(id) {
        closeModalDialog(id);
    };

    // Mở modal thêm ghế mới
    function openAddSeatModal() {
        openModalDialog('addSeatModal');
    }

    // Mở modal quản lý loại ghế
    function openLoaiGheModal() {
        openModalDialog('loaiGheModal');
    }

    // Chuyển phòng chiếu
    function changeRoomFilter(selectEl) {
        const maPhong = selectEl.value;
        if (maPhong) {
            window.location.href = selectEl.getAttribute('data-context') + '/ghe?maPhong=' + encodeURIComponent(maPhong);
        }
    }

    // Đổ dữ liệu sửa loại ghế
    function startEditLoaiGhe(btn) {
        const ma = btn.getAttribute('data-ma');
        const ten = btn.getAttribute('data-ten');
        const phuthu = btn.getAttribute('data-phuthu');

        document.getElementById('lgMaLoaiGhe').value = ma;
        document.getElementById('lgTenLoaiGhe').value = ten;
        document.getElementById('lgPhuThu').value = phuthu;

        document.getElementById('lgFormTitle').innerText = '✎ Cập nhật loại ghế [#' + ma + ' - ' + ten + ']';
        document.getElementById('lgBtnSubmit').innerText = 'Cập nhật';
        document.getElementById('lgBtnCancel').style.display = 'inline-block';

        const form = document.getElementById('loaiGheForm');
        const ctx = form.getAttribute('data-context');
        form.action = ctx + '/ghe/loai-ghe-update';
    }

    // Hủy sửa loại ghế
    function cancelEditLoaiGhe() {
        document.getElementById('lgMaLoaiGhe').value = '';
        document.getElementById('lgTenLoaiGhe').value = '';
        document.getElementById('lgPhuThu').value = '0';

        document.getElementById('lgFormTitle').innerText = '+ Thêm loại ghế mới';
        document.getElementById('lgBtnSubmit').innerText = 'Thêm';
        document.getElementById('lgBtnCancel').style.display = 'none';

        const form = document.getElementById('loaiGheForm');
        const ctx = form.getAttribute('data-context');
        form.action = ctx + '/ghe/loai-ghe-add';
    }

    // Đóng khi click ra ngoài backdrop (dùng capture để chạy trước các script khác)
    document.addEventListener('click', function(e) {
        if (e.target && e.target.classList && e.target.classList.contains('modal-backdrop')) {
            closeModalDialog(e.target.id);
        }
    }, true);

    // Đóng khi ấn Esc
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' || e.keyCode === 27) {
            document.querySelectorAll('.modal-backdrop').forEach(function(m) {
                closeModalDialog(m.id);
            });
        }
    }, true);
</script>
</body>
</html>
