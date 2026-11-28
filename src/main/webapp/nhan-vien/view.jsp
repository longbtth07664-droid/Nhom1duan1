<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix = "c" uri = "http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý nhân viên - Rạp Chiếu Phim CINEMAX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=7">
    <style>
        .nv-modal-compact {
            max-width: 640px !important;
            width: 94vw !important;
            padding: 18px 22px !important;
        }
        .nv-grid-2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px 14px;
        }
        .nv-grid-2 .full-col {
            grid-column: 1 / -1;
        }
        .nv-grid-2 .form-group {
            margin-bottom: 0;
        }
        .nv-grid-2 .form-group label {
            font-size: 12px;
            margin-bottom: 4px;
        }
        .nv-grid-2 .form-control {
            height: 36px;
            padding: 6px 10px;
            font-size: 13px;
        }
        @media (max-width: 600px) {
            .nv-grid-2 { grid-template-columns: 1fr; }
        }
        .alert-error-box {
            background: #FEF2F2; border: 1px solid #FECACA; color: #DC2626;
            padding: 9px 12px; border-radius: 8px; font-size: 12.5px; font-weight: 600; margin-bottom: 12px;
        }
        .alert-success-box {
            background: #ECFDF5; border: 1px solid #A7F3D0; color: #047857;
            padding: 10px 14px; border-radius: 8px; font-size: 13px; font-weight: 600; margin-bottom: 14px;
        }
    </style>
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

    <!-- NỘI DUNG CHÍNH -->
    <div class="main-wrapper">
        <header class="topbar">
            <div class="topbar-left">
                <button type="button" class="mobile-menu-btn" onclick="toggleSidebar()">☰</button>
                <div class="page-title-wrap">
                    <h2>Quản lý nhân viên</h2>
                </div>
            </div>
            <div class="topbar-right">
                <a href="${pageContext.request.contextPath}/menuadmin.jsp" class="btn btn-ghost btn-sm">Menu chính</a>
            </div>
        </header>

        <main class="content-area">
            <c:if test="${param.msg == 'add_ok'}">
                <div class="alert-success-box">Thêm nhân viên mới thành công!</div>
            </c:if>
            <c:if test="${param.msg == 'update_ok'}">
                <div class="alert-success-box">Cập nhật thông tin nhân viên thành công!</div>
            </c:if>
            <div class="card">
                <div class="card-header">
                    <div>
                        <div class="card-title">Danh sách nhân viên</div>
                        <div class="card-subtitle">Quản lý tài khoản và thông tin nhân sự làm việc tại rạp</div>
                    </div>
                    <div style="display:flex; align-items:center; gap:10px;">
                        <button type="button" class="btn btn-pink" onclick="openAddModal()">+ Thêm</button>
                        <span class="badge-pink">${listNhanVien.size()} nhân viên</span>
                    </div>
                </div>

                <!-- Bảng danh sách -->
                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th>STT</th>
                            <th>MÃ TK</th>
                            <th>HỌ TÊN</th>
                            <th>USERNAME</th>
                            <th>SĐT</th>
                            <th>VAI TRÒ</th>
                            <th>TRẠNG THÁI</th>
                            <th>HÀNH ĐỘNG</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${listNhanVien}" var="nv" varStatus="status">
                            <tr>
                                <td>${status.index + 1}</td>
                                <td><strong><c:out value="${nv.id}"/></strong></td>
                                <td><c:out value="${nv.hoTen}"/></td>
                                <td><c:out value="${nv.username}"/></td>
                                <td><c:out value="${nv.soDienThoai}"/></td>
                                <td>
                                    <span style="padding: 4px 8px; border-radius: 4px; font-size: 12px; background: ${nv.vaiTro == 'QuanLy' ? '#ffe3e3; color: #c92a2a;' : '#e7f5ff; color: #1864ab;'};">
                                        <c:out value="${nv.vaiTro}"/>
                                    </span>
                                </td>
                                <td><c:out value="${nv.trangThai}"/></td>
                                <td>
                                    <div class="action-group">
                                        <button type="button" class="btn btn-ghost btn-sm"
                                                data-id="<c:out value='${nv.id}'/>"
                                                data-hoten="<c:out value='${nv.hoTen}'/>"
                                                data-cccd="<c:out value='${nv.cccd}'/>"
                                                data-email="<c:out value='${nv.email}'/>"
                                                data-sdt="<c:out value='${nv.soDienThoai}'/>"
                                                data-diachi="<c:out value='${nv.diaChi}'/>"
                                                data-username="<c:out value='${nv.username}'/>"
                                                data-vaitro="<c:out value='${nv.vaiTro}'/>"
                                                data-trangthai="<c:out value='${nv.trangThai}'/>"
                                                onclick="openDetailModal(event, this)">Chi tiết</button>

                                        <a href="${pageContext.request.contextPath}/nhan-vien/view-update?id=${nv.id}" class="btn btn-outline btn-sm">Sửa</a>
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

<!-- ================= MODAL THÊM NHÂN VIÊN ================= -->
<div class="modal-backdrop ${openAddModal ? 'open' : ''}" id="addModal">
    <div class="modal-box nv-modal-compact">
        <div class="modal-header" style="margin-bottom:12px;">
            <h3>Thêm nhân viên mới</h3>
            <button type="button" class="modal-close" onclick="closeModal('addModal')">&times;</button>
        </div>
        <c:if test="${not empty addError}">
            <div class="alert-error-box"><c:out value="${addError}"/></div>
        </c:if>
        <form action="${pageContext.request.contextPath}/nhan-vien/add" method="post">
            <div class="nv-grid-2">
                <div class="form-group full-col">
                    <label>Họ Tên <span class="required-star">*</span></label>
                    <input type="text" name="hoTen" class="form-control" value="${formNv.hoTen}" placeholder="Nhập họ tên" required minlength="2" maxlength="100">
                </div>
                <div class="form-group">
                    <label>CCCD (12 số) <span class="required-star">*</span></label>
                    <input type="text" name="cccd" class="form-control" value="${formNv.cccd}" placeholder="12 chữ số" required pattern="\d{12}" title="CCCD gồm đúng 12 chữ số">
                </div>
                <div class="form-group">
                    <label>Số Điện Thoại <span class="required-star">*</span></label>
                    <input type="text" name="soDienThoai" class="form-control" value="${formNv.soDienThoai}" placeholder="VD: 0912345678" required pattern="0\d{9}" title="10 số bắt đầu bằng 0">
                </div>
                <div class="form-group">
                    <label>Email <span class="required-star">*</span></label>
                    <input type="email" name="email" class="form-control" value="${formNv.email}" placeholder="VD: nv@cinemax.vn" required>
                </div>
                <div class="form-group full-col">
                    <label>Địa Chỉ (34 Tỉnh/Thành mới)</label>
                    <div style="display:grid; grid-template-columns: 1fr 1fr 1fr; gap:8px;">
                        <select id="addProvince" class="form-control"></select>
                        <select id="addWard" class="form-control">
                            <option value="">-- Phường / Xã --</option>
                        </select>
                        <input type="text" id="addAddressDetail" class="form-control" placeholder="Số nhà, đường..." maxlength="150">
                    </div>
                    <input type="hidden" name="diaChi" id="addDiaChiHidden" value="${formNv.diaChi}">
                </div>
                <div class="form-group">
                    <label>Username <span class="required-star">*</span></label>
                    <input type="text" name="username" class="form-control" value="${formNv.username}" placeholder="Tên đăng nhập" required pattern="[a-zA-Z0-9_]{3,50}" title="3-50 ký tự chữ, số hoặc _">
                </div>
                <div class="form-group">
                    <label>Password <span class="required-star">*</span></label>
                    <input type="password" name="matKhau" class="form-control" placeholder="Tối thiểu 6 ký tự" required minlength="6">
                </div>
                <div class="form-group">
                    <label>Vai Trò</label>
                    <input type="text" class="form-control" value="Nhân Viên" readonly style="background:var(--bg-input);">
                    <input type="hidden" name="vaiTro" value="NhanVien">
                </div>
                <div class="form-group">
                    <label>Trạng Thái</label>
                    <input type="text" class="form-control" value="Đang làm việc" readonly style="background:var(--bg-input);">
                    <input type="hidden" name="trangThai" value="Đang làm việc">
                </div>
                <div class="full-col" style="font-size:11.5px; color:var(--text-secondary);">
                    (<span class="required-star">*</span>) Trường bắt buộc nhập
                </div>
            </div>
            <div class="modal-footer" style="margin-top:14px;">
                <button type="button" class="btn btn-ghost" onclick="closeModal('addModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Thêm</button>
            </div>
        </form>
    </div>
</div>

<!-- ================= MODAL CHI TIẾT NHÂN VIÊN ================= -->
<div class="modal-backdrop" id="detailModal">
    <div class="modal-box nv-modal-compact">
        <div class="modal-header" style="margin-bottom:12px;">
            <h3>Chi tiết nhân viên</h3>
            <button type="button" class="modal-close" onclick="closeModal('detailModal')">&times;</button>
        </div>
        <div class="nv-grid-2">
            <div class="form-group">
                <label>Mã tài khoản</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailId"></div>
            </div>
            <div class="form-group">
                <label>Họ Tên</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailHoTen"></div>
            </div>
            <div class="form-group">
                <label>CCCD</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailCccd"></div>
            </div>
            <div class="form-group">
                <label>Số Điện Thoại</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailSoDienThoai"></div>
            </div>
            <div class="form-group">
                <label>Email</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailEmail"></div>
            </div>
            <div class="form-group">
                <label>Địa Chỉ</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailDiaChi"></div>
            </div>
            <div class="form-group">
                <label>Username</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailUsername"></div>
            </div>
            <div class="form-group">
                <label>Vai Trò</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailVaiTro"></div>
            </div>
            <div class="form-group full-col">
                <label>Trạng Thái</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailTrangThai"></div>
            </div>
        </div>
        <div class="modal-footer" style="margin-top:14px;">
            <button type="button" class="btn btn-pink" onclick="closeModal('detailModal')">Đóng</button>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=5"></script>
<script src="${pageContext.request.contextPath}/assets/js/vn-address-34.js?v=1"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        initVnAddress34({
            contextPath: '${pageContext.request.contextPath}',
            provinceSelectId: 'addProvince',
            wardSelectId: 'addWard',
            detailInputId: 'addAddressDetail',
            hiddenInputId: 'addDiaChiHidden',
            initialAddress: '${formNv.diaChi}'
        });
    });
    function openAddModal(event) {
        if (event) event.preventDefault();
        document.getElementById('addModal').classList.add('open');
    }

    function openDetailModal(event, btn) {
        if (event) event.preventDefault();

        document.getElementById('detailId').textContent = btn.getAttribute('data-id');
        document.getElementById('detailHoTen').textContent = btn.getAttribute('data-hoten');
        document.getElementById('detailCccd').textContent = btn.getAttribute('data-cccd');
        document.getElementById('detailEmail').textContent = btn.getAttribute('data-email');
        document.getElementById('detailSoDienThoai').textContent = btn.getAttribute('data-sdt');
        document.getElementById('detailDiaChi').textContent = btn.getAttribute('data-diachi');
        document.getElementById('detailUsername').textContent = btn.getAttribute('data-username');
        document.getElementById('detailVaiTro').textContent = btn.getAttribute('data-vaitro');
        document.getElementById('detailTrangThai').textContent = btn.getAttribute('data-trangthai');

        document.getElementById('detailModal').classList.add('open');
    }

    function closeModal(modalId) {
        document.getElementById(modalId).classList.remove('open');
    }
</script>
</body>
</html>
