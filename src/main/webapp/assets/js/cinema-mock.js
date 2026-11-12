/* ============================================================================
 * FILE: assets/js/cinema-mock.js
 * MỤC ĐÍCH: Xử lý các tương tác giao diện phía trình duyệt (menu trái & pop-up).
 * ĐANG LIÊN KẾT VỚI CÁC FILE JSP:
 *   - menuadmin.jsp         (Menu quản lý)
 *   - menunv.jsp            (Menu nhân viên)
 *   - the-loai/view.jsp     (Trang Quản lí thể loại + các pop-up Thêm / Sửa / Chi tiết)
 * ============================================================================ */

/**
 * Đóng/mở thanh menu bên trái khi xem trên màn hình nhỏ / điện thoại (<= 768px).
 * Liên kết với: nút "☰" (.mobile-menu-btn) trong the-loai/view.jsp
 */
function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    if (sidebar) {
        sidebar.classList.toggle('open');
    }
}

/**
 * Đóng/mở menu con (dropdown) của mục "Quản lí phim" ở thanh menu bên trái.
 * Liên kết với: nút "Quản lí phim ▾" (.nav-parent) trong menuadmin.jsp và the-loai/view.jsp
 */
function toggleSubmenu(btn) {
    const group = btn.closest('.nav-group');
    if (!group) return;
    group.classList.toggle('open');
}

/**
 * Hiển thị một cửa sổ pop-up (modal) theo id bằng cách thêm class "open".
 * Liên kết với: các pop-up (#addTheLoaiModal, #editTheLoaiModal, #detailTheLoaiModal) trong the-loai/view.jsp
 */
function openModal(id) {
    const modal = document.getElementById(id);
    if (modal) {
        modal.classList.add('open');
    }
}

/**
 * Đóng cửa sổ pop-up (modal) theo id bằng cách gỡ class "open".
 * Liên kết với: nút "×" và nút "Hủy / Đóng" trong các pop-up của the-loai/view.jsp
 */
function closeModal(id) {
    const modal = document.getElementById(id);
    if (modal) {
        modal.classList.remove('open');
    }
}

/**
 * Mở pop-up "Thêm thể loại" (#addTheLoaiModal), reset trắng dữ liệu cũ và ẩn thông báo lỗi cũ.
 * Liên kết với: nút "+ Thêm" trong the-loai/view.jsp
 */
function openAddTheLoai() {
    const maInput = document.getElementById('addMaTheLoai');
    const tenInput = document.getElementById('addTenTheLoai');
    const errBox = document.getElementById('addTheLoaiError');
    if (maInput) maInput.value = '';
    if (tenInput) tenInput.value = '';
    if (errBox) errBox.style.display = 'none';
    openModal('addTheLoaiModal');
    if (maInput) maInput.focus();
}

/**
 * Mở pop-up "Sửa thể loại" (#editTheLoaiModal) và tự điền sẵn Mã + Tên từ dòng vừa bấm.
 * Liên kết với: nút "Sửa" ở từng dòng trong bảng của the-loai/view.jsp (đọc từ thuộc tính data-ma, data-ten)
 */
function openEditTheLoaiFromBtn(btn) {
    const ma = btn.getAttribute('data-ma') || '';
    const ten = btn.getAttribute('data-ten') || '';
    const maInput = document.getElementById('editMaTheLoai');
    const tenInput = document.getElementById('editTenTheLoai');
    const errBox = document.getElementById('editTheLoaiError');
    if (maInput) maInput.value = ma;
    if (tenInput) tenInput.value = ten;
    if (errBox) errBox.style.display = 'none';
    openModal('editTheLoaiModal');
    if (tenInput) tenInput.focus();
}

/**
 * Mở pop-up "Chi tiết thể loại" (#detailTheLoaiModal) và hiển thị Mã + Tên của dòng vừa bấm.
 * Liên kết với: nút "Chi tiết" ở từng dòng trong bảng của the-loai/view.jsp
 */
function openDetailTheLoaiFromBtn(btn) {
    const ma = btn.getAttribute('data-ma') || '';
    const ten = btn.getAttribute('data-ten') || '';
    const maText = document.getElementById('detailMaTheLoai');
    const tenText = document.getElementById('detailTenTheLoai');
    if (maText) maText.textContent = ma;
    if (tenText) tenText.textContent = ten;
    openModal('detailTheLoaiModal');
}

/**
 * Khởi tạo các sự kiện dùng chung sau khi trang HTML/JSP tải xong:
 * 1. Đổi trạng thái tô màu hồng (class "active") khi bấm vào link trên thanh menu trái.
 *    (Liên kết với: menuadmin.jsp, menunv.jsp, the-loai/view.jsp)
 * 2. Bấm ra ngoài vùng tối của pop-up hoặc bấm phím Esc để đóng pop-up.
 *    (Liên kết với: các pop-up trong the-loai/view.jsp)
 */
function initMenuActive() {
    const links = document.querySelectorAll('.sidebar-menu a.nav-item, .sidebar-menu a.nav-subitem');
    links.forEach((link) => {
        link.addEventListener('click', () => {
            links.forEach((l) => l.classList.remove('active'));
            link.classList.add('active');
        });
    });

    // Đóng pop-up khi bấm ra vùng nền tối bên ngoài hộp thoại
    document.querySelectorAll('.modal-backdrop').forEach((backdrop) => {
        backdrop.addEventListener('click', (e) => {
            if (e.target === backdrop) {
                backdrop.classList.remove('open');
            }
        });
    });

    // Đóng pop-up đang mở khi người dùng nhấn phím Escape (Esc)
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            document.querySelectorAll('.modal-backdrop.open').forEach((m) => m.classList.remove('open'));
        }
    });
}

// Chạy hàm initMenuActive() ngay khi toàn bộ cây DOM của trang JSP đã tải xong
document.addEventListener('DOMContentLoaded', initMenuActive);
