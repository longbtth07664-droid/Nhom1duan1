<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cập nhật tài khoản - Rạp Chiếu Phim CINEMAX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=7">
</head>
<body>
<div class="app-shell">
    <div class="main-wrapper" style="width: 100%;">
        <header class="topbar">
            <div class="topbar-left">
                <div class="page-title-wrap">
                    <h2>Quản lý tài khoản</h2>
                </div>
            </div>
            <div class="topbar-right">
                <a href="${pageContext.request.contextPath}/tai-khoan/view" class="btn btn-ghost btn-sm">← Quay lại danh sách</a>
            </div>
        </header>

        <main class="content-area">
            <div class="card" style="max-width: 600px; margin: 0 auto;">
                <div class="card-header">
                    <div>
                        <div class="card-title">Cập nhật thông tin tài khoản</div>
                        <div class="card-subtitle">Mã tài khoản hệ thống: #${tk.maTK}</div>
                    </div>
                </div>

                <form action="${pageContext.request.contextPath}/tai-khoan/update" method="post" style="padding: 20px;">
                    <!-- ID ẩn để định danh khi update -->
                    <input type="hidden" name="maTK" value="${tk.maTK}">

                    <div class="form-stack">
                        <!-- Hiển thị Họ Tên nhưng ở chế độ chỉ đọc (readonly) -->
                        <div class="form-group">
                            <label>Họ Tên (Nhân sự sở hữu)</label>
                            <input type="text" class="form-control" value="<c:out value='${tk.hoTen}'/>" readonly style="background: #f1f3f5; color: #495057; cursor: not-allowed;">
                        </div>

                        <div class="form-group">
                            <label>Username <span class="required-star">*</span></label>
                            <input type="text" name="username" class="form-control" value="<c:out value='${tk.username}'/>" required>
                        </div>
                        <div class="form-group">
                            <label>Password <span class="required-star">*</span></label>
                            <input type="text" name="password" class="form-control" value="<c:out value='${tk.password}'/>" required>
                        </div>
                        <div class="form-group">
                            <label>Vai Trò</label>
                            <select name="vaiTro" class="form-control" style="background:var(--bg-card, #fff);">
                                <option value="NhanVien" ${tk.vaiTro == 'NhanVien' ? 'selected' : ''}>Nhân Viên</option>
                                <option value="QuanLy" ${tk.vaiTro == 'QuanLy' ? 'selected' : ''}>Quản Lý</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Trạng Thái</label>
                            <select name="trangThai" class="form-control" style="background:var(--bg-card, #fff);">
                                <option value="Đang làm việc" ${tk.trangThai == 'Đang làm việc' ? 'selected' : ''}>Đang làm việc</option>
                                <option value="Đã khóa" ${tk.trangThai == 'Đã khóa' ? 'selected' : ''}>Đã khóa</option>
                            </select>
                        </div>
                    </div>

                    <div class="modal-footer" style="margin-top: 25px;">
                        <a href="${pageContext.request.contextPath}/tai-khoan/view" class="btn btn-ghost">Hủy</a>
                        <button type="submit" class="btn btn-pink">Lưu thay đổi</button>
                    </div>
                </form>
            </div>
        </main>
    </div>
</div>
</body>
</html>