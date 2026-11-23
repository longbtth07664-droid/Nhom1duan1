/* ============================================================================
 * FILE: assets/js/khach-hang.js
 * MỤC ĐÍCH: Xử lý tương tác mở/đóng popup thêm, sửa, xem chi tiết và xác nhận xóa khách hàng.
 * ============================================================================ */

// Mở popup modal bằng cách thêm class open vào modal-backdrop
function openModalDialog(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.add('open');
    }
}

// Đóng popup modal bằng cách gỡ bỏ class open khỏi modal-backdrop
function closeModalDialog(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.remove('open');
    }
}

// Mở popup thêm mới khách hàng và đặt lại các ô nhập liệu về trạng thái rỗng
function openAddModal() {
    const err = document.getElementById('addErrorMsg');
    if (err) err.style.display = 'none';

    document.getElementById('addMaKH').value = '';
    document.getElementById('addHoTen').value = '';
    document.getElementById('addSdt').value = '';
    document.getElementById('addGioiTinh').value = 'Nam';
    document.getElementById('addDiem').value = '0';

    openModalDialog('addKhachHangModal');
}

// Mở popup cập nhật và điền thông tin khách hàng từ các thuộc tính data của nút bấm
function openEditModal(btn) {
    const err = document.getElementById('editErrorMsg');
    if (err) err.style.display = 'none';

    const ma = btn.getAttribute('data-ma') || '';
    const ten = btn.getAttribute('data-ten') || '';
    const sdt = btn.getAttribute('data-sdt') || '';
    const gioitinh = btn.getAttribute('data-gioitinh') || 'Nam';
    const diem = btn.getAttribute('data-diem') || '0';

    document.getElementById('editMaKH').value = ma;
    document.getElementById('editMaKHTitle').innerText = ma;
    document.getElementById('editHoTen').value = ten;
    document.getElementById('editSdt').value = sdt;
    document.getElementById('editGioiTinh').value = gioitinh;
    document.getElementById('editDiem').value = diem;

    openModalDialog('editKhachHangModal');
}

// Mở popup xem chi tiết khách hàng và hiển thị điểm cùng hạng thành viên
function openDetailModal(btn) {
    const ma = btn.getAttribute('data-ma') || '';
    const ten = btn.getAttribute('data-ten') || '';
    const sdt = btn.getAttribute('data-sdt') || '';
    const gioitinh = btn.getAttribute('data-gioitinh') || '';
    const diem = parseInt(btn.getAttribute('data-diem') || '0');
    const hang = btn.getAttribute('data-hang') || 'Chuẩn';

    document.getElementById('detailMaKH').innerText = ma;
    document.getElementById('detailHoTen').innerText = ten;
    document.getElementById('detailSdt').innerText = sdt;
    document.getElementById('detailGioiTinh').innerText = gioitinh;
    document.getElementById('detailDiem').innerText = diem.toLocaleString('vi-VN') + ' điểm';
    document.getElementById('detailHang').innerText = hang;
    document.getElementById('detailAvatar').innerText = ten ? ten.trim().charAt(0).toUpperCase() : 'KH';

    openModalDialog('detailKhachHangModal');
}

// Tự động đóng popup khi người dùng click chuột vào vùng nền tối bên ngoài hộp thoại
window.addEventListener('click', function(e) {
    if (e.target.classList.contains('modal-backdrop') && e.target.classList.contains('open')) {
        e.target.classList.remove('open');
    }
});

// Tự động đóng popup đang mở khi người dùng nhấn phím Esc trên bàn phím
window.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        document.querySelectorAll('.modal-backdrop.open').forEach(function(m) {
            m.classList.remove('open');
        });
    }
});
