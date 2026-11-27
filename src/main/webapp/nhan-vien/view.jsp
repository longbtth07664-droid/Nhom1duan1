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
        /* Gọn gàng 2 cột giống ảnh 2, tránh bị kéo dài dọc như ảnh 1 */
        .modal-box.modal-wide {
            max-width: 760px;
            width: 92%;
        }
        .form-grid-2 {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 14px 18px;
        }
        .form-grid-2 .form-group {
            margin-bottom: 0;
        }
        .form-grid-2 .form-full {
            grid-column: 1 / -1;
        }
        @media (max-width: 640px) {
            .form-grid-2 {
                grid-template-columns: 1fr;
            }
            .form-grid-2 .form-full {
                grid-column: auto;
            }
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
<div class="modal-backdrop" id="addModal">
    <div class="modal-box modal-wide">
        <div class="modal-header">
            <h3>Thêm nhân viên mới</h3>
            <button type="button" class="modal-close" onclick="closeModal('addModal')">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/nhan-vien/add" method="post">
            <div class="form-grid-2">
                <div class="form-group">
                    <label>Họ Tên <span class="required-star">*</span></label>
                    <input type="text" name="hoTen" class="form-control" placeholder="Nhập họ tên" required>
                </div>
                <div class="form-group">
                    <label>CCCD <span class="required-star">*</span></label>
                    <input type="text" name="cccd" class="form-control" placeholder="0xxxxxxxxxxx"
                           value="<c:out value='${oldCccd}'/>"
                           pattern="0\d{11}" title="CCCD bắt buộc nhập, gồm 12 chữ số và bắt đầu bằng 0" required>
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" name="email" class="form-control" placeholder="ten@gmail.com"
                           value="<c:out value='${oldEmail}'/>" pattern="^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"
                           title="Email phải có dạng ten@domain.com">
                </div>
                <div class="form-group">
                    <label>Số Điện Thoại</label>
                    <input type="text" name="soDienThoai" class="form-control" placeholder="0xxxxxxxxx"
                           value="<c:out value='${oldSoDienThoai}'/>" pattern="0\d{9,10}" title="SĐT gồm 10-11 chữ số, bắt đầu bằng 0">
                </div>
                <div class="form-group">
                    <label>Username <span class="required-star">*</span></label>
                    <input type="text" name="username" class="form-control" placeholder="Tên đăng nhập" required>
                </div>
                <div class="form-group">
                    <label>Password <span class="required-star">*</span></label>
                    <input type="password" name="matKhau" class="form-control" placeholder="Mật khẩu" required>
                </div>
                <div class="form-group">
                    <label>Vai Trò</label>
                    <select name="vaiTro" class="form-control" style="background:var(--bg-card, #fff);">
                        <option value="NhanVien" selected>Nhân Viên</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Trạng Thái</label>
                    <input type="text" class="form-control" value="Đang làm việc" disabled style="background:var(--bg-input);">
                    <input type="hidden" name="trangThai" value="Đang làm việc">
                </div>
                <div class="form-group form-full">
                    <label>Địa Chỉ</label>
                    <input type="text" name="diaChi" class="form-control" placeholder="Nhập địa chỉ">
                </div>
                <div class="form-full" style="font-size:12px; color:var(--text-secondary);">
                    (<span class="required-star">*</span>) Trường bắt buộc nhập
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('addModal')">Hủy</button>
                <button type="submit" class="btn btn-pink">Thêm</button>
            </div>
        </form>
    </div>
</div>

<!-- ================= MODAL CHI TIẾT NHÂN VIÊN ================= -->
<div class="modal-backdrop" id="detailModal">
    <div class="modal-box modal-wide">
        <div class="modal-header">
            <h3>Chi tiết nhân viên</h3>
            <button type="button" class="modal-close" onclick="closeModal('detailModal')">&times;</button>
        </div>
        <div class="form-grid-2">
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
                <label>Email</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailEmail"></div>
            </div>
            <div class="form-group">
                <label>Số Điện Thoại</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailSoDienThoai"></div>
            </div>
            <div class="form-group">
                <label>Username</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailUsername"></div>
            </div>
            <div class="form-group">
                <label>Vai Trò</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailVaiTro"></div>
            </div>
            <div class="form-group">
                <label>Trạng Thái</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailTrangThai"></div>
            </div>
            <div class="form-group form-full">
                <label>Địa Chỉ</label>
                <div class="form-control" style="background:var(--bg-input);" id="detailDiaChi"></div>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-pink" onclick="closeModal('detailModal')">Đóng</button>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/cinema-mock.js?v=5"></script>
<script>
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
<c:if test="${openAddModal}">
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            document.getElementById('addModal').classList.add('open');
        });
    </script>
</c:if>
</body>
</html>