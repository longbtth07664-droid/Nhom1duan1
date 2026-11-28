<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sửa thông tin nhân viên - Rạp Chiếu Phim CINEMAX</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        .form-label { font-size: 12.5px; margin-bottom: 4px; color: #334155; }
        .form-control, .form-select { font-size: 13.5px; padding: 7px 10px; border-radius: 8px; }
    </style>
</head>
<body class="bg-secondary bg-opacity-25">
<div class="container d-flex justify-content-center align-items-center min-vh-100 py-3">
    <div class="card shadow p-4 bg-white rounded-4 border-0" style="width: 680px; max-width: 96vw;">
        <div class="d-flex justify-content-between align-items-center mb-3 pb-2 border-bottom">
            <h5 class="fw-bold mb-0 text-dark">Sửa thông tin nhân viên</h5>
            <a href="${pageContext.request.contextPath}/nhan-vien/view" class="btn-close" aria-label="Close"></a>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-danger py-2 px-3 small fw-semibold mb-3">${error}</div>
        </c:if>

        <c:set var="isSelf" value="${sessionScope.currentUser != null && sessionScope.currentUser.maTK == nv.id}" />

        <form action="${pageContext.request.contextPath}/nhan-vien/update?id=${nv.id}" method="post">
            <div class="row g-2.5" style="row-gap: 10px;">
                <div class="col-md-4">
                    <label class="form-label fw-bold">Mã tài khoản</label>
                    <input type="text" class="form-control bg-light fw-bold" value="${nv.id}" readonly>
                </div>
                <div class="col-md-8">
                    <label class="form-label fw-bold">Họ Tên <span class="text-danger">*</span></label>
                    <input type="text" name="hoTen" class="form-control" value="${nv.hoTen}" required minlength="2" maxlength="100">
                </div>

                <div class="col-md-6">
                    <label class="form-label fw-bold">CCCD (12 số) <span class="text-danger">*</span></label>
                    <input type="text" name="cccd" class="form-control" value="${nv.cccd}" required pattern="\d{12}" title="CCCD gồm đúng 12 chữ số">
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold">Số Điện Thoại <span class="text-danger">*</span></label>
                    <input type="text" name="soDienThoai" class="form-control" value="${nv.soDienThoai}" required pattern="0\d{9}" title="SĐT gồm 10 chữ số, bắt đầu bằng 0">
                </div>

                <div class="col-md-6">
                    <label class="form-label fw-bold">Email <span class="text-danger">*</span></label>
                    <input type="email" name="email" class="form-control" value="${nv.email}" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold">Địa Chỉ</label>
                    <input type="text" name="diaChi" class="form-control" value="${nv.diaChi}" maxlength="255">
                </div>

                <div class="col-md-6">
                    <label class="form-label fw-bold">Username <span class="text-danger">*</span></label>
                    <input type="text" name="username" class="form-control" value="${nv.username}" required pattern="[a-zA-Z0-9_]{3,50}" title="3-50 ký tự chữ, số hoặc dấu _">
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold">Password <span class="text-danger">*</span></label>
                    <input type="password" name="matKhau" class="form-control" value="${nv.matKhau}" required minlength="6" title="Tối thiểu 6 ký tự">
                </div>

                <div class="col-md-6">
                    <label class="form-label fw-bold">Vai Trò <span class="text-muted fw-normal">(Không đổi quyền tại đây)</span></label>
                    <input type="text" class="form-control bg-light fw-semibold"
                           value="${nv.vaiTro == 'QuanLy' ? 'Quản Lý' : 'Nhân Viên'}" readonly>
                    <input type="hidden" name="vaiTro" value="${nv.vaiTro}">
                </div>

                <div class="col-md-6">
                    <label class="form-label fw-bold">Trạng Thái</label>
                    <c:choose>
                        <c:when test="${isSelf}">
                            <input type="text" class="form-control bg-light fw-semibold" value="${nv.trangThai}" readonly title="Không thể tự khóa tài khoản đang đăng nhập">
                            <input type="hidden" name="trangThai" value="${nv.trangThai}">
                        </c:when>
                        <c:otherwise>
                            <select name="trangThai" class="form-select">
                                <option value="Đang làm việc" ${nv.trangThai == 'Đang làm việc' || nv.trangThai == 'Hoạt động' ? 'selected' : ''}>Đang làm việc</option>
                                <option value="Nghỉ việc" ${nv.trangThai == 'Nghỉ việc' ? 'selected' : ''}>Nghỉ việc</option>
                            </select>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="d-flex justify-content-end gap-2 mt-4 pt-2 border-top">
                <a href="${pageContext.request.contextPath}/nhan-vien/view" class="btn btn-light px-4">Hủy</a>
                <button type="submit" class="btn btn-danger px-4 fw-semibold">Lưu cập nhật</button>
            </div>
        </form>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
