<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix = "c" uri = "http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sửa thông tin nhân viên - Rạp Chiếu Phim CINEMAX</title>
    <!-- Giữ lại Bootstrap hoặc đổi sang link cinema-theme.css tùy bạn chọn -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-secondary bg-opacity-25">
<div class="container d-flex justify-content-center align-items-center min-vh-100 py-4">
    <div class="card shadow p-4 bg-white rounded" style="width: 550px;">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h5 class="fw-bold mb-0">Sửa thông tin nhân viên</h5>
            <!-- Thêm contextPath cho nút đóng (x) -->
            <a href="${pageContext.request.contextPath}/nhan-vien/view" class="btn-close" aria-label="Close"></a>
        </div>

        <!-- Thêm contextPath vào action của form -->
        <form action="${pageContext.request.contextPath}/nhan-vien/update?id=${nv.id}" method="post">
            <div class="mb-3">
                <label class="form-label fw-bold">Mã tài khoản</label>
                <input type="text" class="form-control bg-light" value="${nv.id}" readonly>
            </div>
            <div class="mb-3">
                <label class="form-label fw-bold">Họ Tên <span class="text-danger">*</span></label>
                <input type="text" name="hoTen" class="form-control" value="${nv.hoTen}" required>
            </div>
            <!-- Đã bổ sung trường CCCD -->
            <div class="mb-3">
                <label class="form-label fw-bold">CCCD</label>
                <input type="text" name="cccd" class="form-control" value="${nv.cccd}">
            </div>
            <!-- Đã bổ sung trường Email -->
            <div class="mb-3">
                <label class="form-label fw-bold">Email</label>
                <input type="email" name="email" class="form-control" value="${nv.email}">
            </div>
            <div class="mb-3">
                <label class="form-label fw-bold">Số Điện Thoại</label>
                <input type="text" name="soDienThoai" class="form-control" value="${nv.soDienThoai}">
            </div>
            <!-- Đã bổ sung trường Địa chỉ -->
            <div class="mb-3">
                <label class="form-label fw-bold">Địa Chỉ</label>
                <input type="text" name="diaChi" class="form-control" value="${nv.diaChi}">
            </div>
            <div class="mb-3">
                <label class="form-label fw-bold">Username <span class="text-danger">*</span></label>
                <input type="text" name="username" class="form-control" value="${nv.username}" required>
            </div>
            <div class="mb-3">
                <label class="form-label fw-bold">Password <span class="text-danger">*</span></label>
                <input type="password" name="matKhau" class="form-control" value="${nv.matKhau}" required>
            </div>
            <div class="mb-3">
                <label class="form-label fw-bold">Vai Trò</label>
                <select name="vaiTro" class="form-select">
                    <option value="NhanVien" ${nv.vaiTro == 'NhanVien' ? 'selected' : ''}>Nhân Viên</option>
                    <option value="QuanLy" ${nv.vaiTro == 'QuanLy' ? 'selected' : ''}>Quản Lý</option>
                </select>
            </div>
            <div class="mb-3">
                <label class="form-label fw-bold">Trạng Thái</label>
                <select name="trangThai" class="form-select">
                    <option value="Đang làm việc" ${nv.trangThai == 'Đang làm việc' ? 'selected' : ''}>Đang làm việc</option>
                    <option value="Nghỉ việc" ${nv.trangThai == 'Nghỉ việc' ? 'selected' : ''}>Nghỉ việc</option>
                </select>
            </div>

            <div class="d-flex justify-content-end gap-2 mt-4">
                <!-- Thêm contextPath cho nút Hủy -->
                <a href="${pageContext.request.contextPath}/nhan-vien/view" class="btn btn-light px-4">Hủy</a>
                <button type="submit" class="btn btn-danger px-4">Lưu cập nhật</button>
            </div>
        </form>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>