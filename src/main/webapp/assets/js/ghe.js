/* ============================================================================
 * FILE: assets/js/ghe.js
 * MỤC ĐÍCH: Xử lý tương tác sơ đồ ghế, popup sửa ghế và quản lý thêm/sửa/xóa loại ghế.
 * ============================================================================ */

// Mở popup chi tiết và sửa ghế khi người dùng click vào một ô ghế trên sơ đồ
function openSeatDetailModal(maGhe, tenGhe, maLoai, hang, so, trangThai, gia) {
    document.getElementById('editMaGhe').value = maGhe;
    document.getElementById('editTenGheTitle').innerText = tenGhe;
    document.getElementById('editHangGhe').value = hang;
    document.getElementById('editSoGhe').value = so;
    document.getElementById('editMaLoaiGhe').value = maLoai;
    document.getElementById('editTrangThai').value = trangThai;
    document.getElementById('editGia').value = gia;

    // Gán mã ghế vào form xóa ẩn
    document.getElementById('deleteMaGhe').value = maGhe;

    openModalDialog('seatDetailModal');
}

// Mở popup để thêm mới một ghế lẻ vào phòng chiếu hiện tại
function openAddSeatModal() {
    openModalDialog('addSeatModal');
}

// Mở popup Quản lý danh sách, thêm, sửa, xóa loại ghế
function openLoaiGheModal() {
    openModalDialog('loaiGheModal');
}

// Mở một popup modal bằng cách thêm class open vào modal-backdrop
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

// Xác nhận với người dùng trước khi tiến hành xóa một ghế
function confirmDeleteSeat() {
    const ten = document.getElementById('editTenGheTitle').innerText;
    if (confirm('Bạn có chắc chắn muốn xóa ghế [' + ten + '] này không?')) {
        document.getElementById('formDeleteSeat').submit();
    }
}

// Chuyển hướng xem sơ đồ ghế của phòng chiếu khi chọn từ menu thả xuống
function changeRoomFilter(selectEl) {
    const maPhong = selectEl.value;
    if (maPhong) {
        window.location.href = selectEl.getAttribute('data-context') + '/ghe?maPhong=' + encodeURIComponent(maPhong);
    }
}

// Đổ dữ liệu của loại ghế lên form để chuẩn bị cập nhật thông tin
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

// Hủy chế độ chỉnh sửa loại ghế và đặt form trở lại trạng thái thêm mới
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
