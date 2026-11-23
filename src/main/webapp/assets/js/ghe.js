/* ============================================================================
 * FILE: assets/js/ghe.js
 * MỤC ĐÍCH: Xử lý tương tác sơ đồ ghế, popup sửa ghế và quản lý thêm/sửa/xóa loại ghế.
 * ============================================================================ */

// Mở popup chi tiết & sửa ghế từ phần tử DOM
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

// Mở popup chi tiết và sửa ghế khi người dùng click vào một ô ghế trên sơ đồ
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
        modal.style.display = 'flex';
        modal.classList.add('open');
    }
}

// Đóng popup modal bằng cách gỡ bỏ class open khỏi modal-backdrop
function closeModalDialog(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.style.display = 'none';
        modal.classList.remove('open');
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
document.addEventListener('click', function(e) {
    if (e.target && e.target.classList && e.target.classList.contains('modal-backdrop')) {
        closeModalDialog(e.target.id);
    }
}, true);

// Tự động đóng popup đang mở khi người dùng nhấn phím Esc trên bàn phím
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape' || e.keyCode === 27) {
        document.querySelectorAll('.modal-backdrop').forEach(function(m) {
            closeModalDialog(m.id);
        });
    }
}, true);
