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
        if (id === 'detailPhimModal') {
            stopDetailMedia();
        }
    }
}

/**
 * Dừng phát video/iframe trailer khi đóng pop-up Chi tiết phim để tránh phát ngầm.
 */
function stopDetailMedia() {
    const trailerBox = document.getElementById('detailTrailer');
    if (trailerBox) {
        trailerBox.innerHTML = '';
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
 * Mở pop-up "Thêm phim" (#addPhimModal), xóa sạch giá trị cũ, bỏ tick thể loại và ẩn lỗi cũ.
 * Liên kết với: nút "+ Thêm" trong phim/view.jsp
 */
function openAddPhim() {
    const ids = ['addMaPhim', 'addTenPhim', 'addThoiLuong', 'addNgayKhoiChieu', 'addNgayKetThuc',
        'addDaoDien', 'addDienVien', 'addPoster', 'addTrailer', 'addMoTa'];
    ids.forEach((id) => {
        const el = document.getElementById(id);
        if (el) el.value = '';
    });
    const doTuoi = document.getElementById('addDoTuoi');
    if (doTuoi) doTuoi.value = 'P';
    document.querySelectorAll('#addPhimModal input[name="maTheLoais"]').forEach((cb) => {
        cb.checked = false;
    });
    const errBox = document.getElementById('addPhimError');
    if (errBox) errBox.style.display = 'none';
    openModal('addPhimModal');
    const maInput = document.getElementById('addMaPhim');
    if (maInput) maInput.focus();
}

/**
 * Mở pop-up "Sửa phim" (#editPhimModal) và điền sẵn toàn bộ thông tin từ dòng vừa bấm.
 * Liên kết với: nút "Sửa" ở từng dòng bảng phim trong phim/view.jsp
 */
function openEditPhimFromBtn(btn) {
    const map = {
        editMaPhim: 'data-ma',
        editTenPhim: 'data-ten',
        editThoiLuong: 'data-thoiluong',
        editNgayKhoiChieu: 'data-khoichieu',
        editNgayKetThuc: 'data-ketthuc',
        editDaoDien: 'data-daodien',
        editDienVien: 'data-dienvien',
        editDoTuoi: 'data-dotuoi',
        editPoster: 'data-poster',
        editTrailer: 'data-trailer',
        editMoTa: 'data-mota'
    };
    Object.keys(map).forEach((elId) => {
        const el = document.getElementById(elId);
        if (el) {
            const val = btn.getAttribute(map[elId]) || '';
            el.value = elId === 'editDoTuoi' ? (val || 'P') : val;
        }
    });

    const maTheLoais = (btn.getAttribute('data-matheloais') || '').split(',').map((s) => s.trim()).filter(Boolean);
    document.querySelectorAll('#editPhimModal input[name="maTheLoais"]').forEach((cb) => {
        cb.checked = maTheLoais.includes(cb.value);
    });

    const errBox = document.getElementById('editPhimError');
    if (errBox) errBox.style.display = 'none';
    openModal('editPhimModal');
    const tenInput = document.getElementById('editTenPhim');
    if (tenInput) tenInput.focus();
}

/**
 * Chuẩn hóa đường dẫn media (nhận cả link http/https lẫn tên file đặt trong thư mục assets).
 */
function resolveMediaUrl(raw, localFolder, ctx) {
    if (!raw) return '';
    if (/^https?:\/\//i.test(raw) || raw.startsWith('/')) {
        return raw;
    }
    return `${ctx}/assets/${localFolder}/${raw}`;
}

/**
 * Tách link YouTube thành link nhúng iframe nếu người dùng nhập link YouTube.
 */
function toYoutubeEmbedUrl(url) {
    const match = url.match(/(?:youtube\.com\/(?:watch\?v=|shorts\/|embed\/)|youtu\.be\/)([A-Za-z0-9_-]{11})/);
    return match ? `https://www.youtube.com/embed/${match[1]}` : null;
}

/**
 * Hiển thị hình ảnh Poster trong pop-up Chi tiết phim (có xử lý khi chưa có hoặc lỗi ảnh).
 */
function renderDetailPoster(container, rawPoster, ctx) {
    if (!container) return;
    container.innerHTML = '';
    if (!rawPoster) {
        container.innerHTML = '<div class="detail-media-fallback">Chưa cập nhật poster</div>';
        return;
    }
    const img = document.createElement('img');
    img.className = 'detail-media-img';
    img.src = resolveMediaUrl(rawPoster, 'images', ctx);
    img.alt = 'Poster phim';
    img.onerror = () => {
        container.innerHTML = '';
        const fb = document.createElement('div');
        fb.className = 'detail-media-fallback';
        fb.textContent = `Không tìm thấy ảnh poster (${rawPoster})`;
        container.appendChild(fb);
    };
    container.appendChild(img);
}

/**
 * Hiển thị trình phát Video Trailer (hỗ trợ cả file .mp4/.webm lẫn link YouTube) trong pop-up Chi tiết phim.
 */
function renderDetailTrailer(container, rawTrailer, ctx) {
    if (!container) return;
    container.innerHTML = '';
    if (!rawTrailer) {
        container.innerHTML = '<div class="detail-media-fallback">Chưa cập nhật trailer</div>';
        return;
    }

    const ytUrl = toYoutubeEmbedUrl(rawTrailer);
    if (ytUrl) {
        const iframe = document.createElement('iframe');
        iframe.className = 'detail-media-video';
        iframe.src = ytUrl;
        iframe.title = 'Trailer phim';
        iframe.allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture';
        iframe.allowFullscreen = true;
        container.appendChild(iframe);
        return;
    }

    const video = document.createElement('video');
    video.className = 'detail-media-video';
    video.controls = true;
    video.preload = 'metadata';

    const showFallback = () => {
        container.innerHTML = '';
        const fb = document.createElement('div');
        fb.className = 'detail-media-fallback';
        fb.textContent = `Chưa có file video trailer (${rawTrailer})`;
        container.appendChild(fb);
    };

    video.onerror = showFallback;
    const source = document.createElement('source');
    source.src = resolveMediaUrl(rawTrailer, 'videos', ctx);
    source.onerror = showFallback;
    video.appendChild(source);
    container.appendChild(video);
}

/**
 * Mở pop-up "Chi tiết phim" (#detailPhimModal) để xem đầy đủ thông tin phim vừa bấm.
 * Liên kết với: nút "Chi tiết" ở từng dòng/card phim trong phim/view.jsp
 */
function openDetailPhimFromBtn(btn) {
    const map = {
        detailMaPhim: 'data-ma',
        detailTenPhim: 'data-ten',
        detailTheLoai: 'data-tentheloais',
        detailThoiLuong: 'data-thoiluong-text',
        detailNgayKhoiChieu: 'data-khoichieu',
        detailNgayKetThuc: 'data-ketthuc',
        detailDoTuoi: 'data-dotuoi',
        detailDaoDien: 'data-daodien',
        detailDienVien: 'data-dienvien',
        detailMoTa: 'data-mota'
    };
    Object.keys(map).forEach((elId) => {
        const el = document.getElementById(elId);
        if (el) {
            const val = btn.getAttribute(map[elId]) || '';
            el.textContent = val !== '' ? val : 'Chưa cập nhật';
        }
    });

    const modal = document.getElementById('detailPhimModal');
    const ctx = modal ? (modal.getAttribute('data-ctx') || '') : '';
    renderDetailPoster(document.getElementById('detailPoster'), (btn.getAttribute('data-poster') || '').trim(), ctx);
    renderDetailTrailer(document.getElementById('detailTrailer'), (btn.getAttribute('data-trailer') || '').trim(), ctx);

    openModal('detailPhimModal');
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
                closeModal(backdrop.id);
            }
        });
    });

    // Đóng pop-up đang mở khi người dùng nhấn phím Escape (Esc)
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            document.querySelectorAll('.modal-backdrop.open').forEach((m) => closeModal(m.id));
        }
    });
}

// Chạy hàm initMenuActive() ngay khi toàn bộ cây DOM của trang JSP đã tải xong
document.addEventListener('DOMContentLoaded', initMenuActive);
