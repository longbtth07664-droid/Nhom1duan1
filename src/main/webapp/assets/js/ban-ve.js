/* ============================================================================
 * FILE: assets/js/ban-ve.js
 * MỤC ĐÍCH: Xử lý logic chọn ghế, tính tiền realtime, chọn combo & sản phẩm bán lẻ
 * ============================================================================ */

const POS_STATE = {
    selectedSeats: [],  // [{ maGhe, tenGhe, loaiGhe, gia }]
    selectedCombos: {}, // { [itemKey]: { itemKey, maCombo, maSP, tenCombo, gia, soLuong, isProduct } }
    basePrice: 0
};

document.addEventListener('DOMContentLoaded', function () {
    const cartEl = document.getElementById('posMiniCart');
    if (cartEl && cartEl.dataset.basePrice) {
        POS_STATE.basePrice = parseFloat(cartEl.dataset.basePrice) || 0;
    }

    initStoredState();
    renderCart();

    // Bảo vệ bước 3: Nếu vào bước 3 (chọn combo/bắp nước) mà chưa có ghế ngồi -> Tự động quay lại bước 2
    if (window.location.search.includes('step=3')) {
        const storedSeats = sessionStorage.getItem('pos_selected_seats');
        if (!storedSeats || JSON.parse(storedSeats).length === 0) {
            alert('⚠️ Quý khách/Thu ngân chưa chọn ghế ngồi! Vui lòng chọn ghế trước khi chọn bắp nước.');
            goToStep(2);
        }
    }
});

/**
 * 1. Chuyển bước trong quy trình POS
 */
function goToStep(step) {
    const params = new URLSearchParams(window.location.search);
    params.set('step', step);
    window.location.href = window.location.pathname + '?' + params.toString();
}

/**
 * Kiểm tra bắt buộc phải chọn ghế trước khi sang bước Chọn Combo
 */
function proceedToCombo(nextUrl) {
    if (!POS_STATE.selectedSeats || POS_STATE.selectedSeats.length === 0) {
        alert('⚠️ Vui lòng click chọn ít nhất 1 ghế ngồi trên sơ đồ trước khi tiếp tục!');
        return false;
    }
    window.location.href = nextUrl;
    return true;
}

/**
 * 2. Xử lý click chọn / hủy chọn ghế ngồi
 */
function toggleSeat(seatEl) {
    if (seatEl.classList.contains('sold') || seatEl.classList.contains('disabled')) {
        return;
    }

    const maGhe = seatEl.dataset.maghe;
    const tenGhe = seatEl.dataset.tenghe;
    const loaiGhe = seatEl.dataset.loaighe;
    const gia = parseFloat(seatEl.dataset.gia) || 0;

    const existingIndex = POS_STATE.selectedSeats.findIndex(s => s.maGhe === maGhe);

    if (existingIndex >= 0) {
        POS_STATE.selectedSeats.splice(existingIndex, 1);
        seatEl.classList.remove('selected');
    } else {
        POS_STATE.selectedSeats.push({ maGhe, tenGhe, loaiGhe, gia });
        seatEl.classList.add('selected');
    }

    sessionStorage.setItem('pos_selected_seats', JSON.stringify(POS_STATE.selectedSeats));
    renderCart();
}

/**
 * 3. Xử lý tăng / giảm số lượng Combo & Sản phẩm bán lẻ dùng chung
 */
function changeItemQty(key, id, ten, gia, isProduct, delta) {
    if (!POS_STATE.selectedCombos[key]) {
        POS_STATE.selectedCombos[key] = {
            itemKey: key,
            maCombo: isProduct ? null : parseInt(id),
            maSP: isProduct ? parseInt(id) : null,
            tenCombo: ten,
            gia: parseFloat(gia) || 0,
            soLuong: 0,
            isProduct: !!isProduct
        };
    }

    POS_STATE.selectedCombos[key].soLuong += delta;

    if (POS_STATE.selectedCombos[key].soLuong <= 0) {
        delete POS_STATE.selectedCombos[key];
    }

    updateItemCounterUI(key);
    sessionStorage.setItem('pos_selected_combos', JSON.stringify(POS_STATE.selectedCombos));
    renderCart();
}

function updateItemCounterUI(key) {
    const qty = POS_STATE.selectedCombos[key] ? POS_STATE.selectedCombos[key].soLuong : 0;
    const el = document.getElementById('item-qty-' + key);
    if (el) el.textContent = qty;

    if (key.startsWith('combo_')) {
        const legacyEl = document.getElementById('combo-qty-' + key.replace('combo_', ''));
        if (legacyEl) legacyEl.textContent = qty;
    }
}

/**
 * Tăng / giảm gói Combo
 */
function changeComboQty(maCombo, tenCombo, gia, delta) {
    changeItemQty('combo_' + maCombo, maCombo, tenCombo, gia, false, delta);
}

/**
 * Tăng / giảm sản phẩm bán lẻ (Bắp / Nước ngọt / Đồ ăn vặt)
 */
function changeSanPhamQty(maSP, tenSP, gia, delta) {
    changeItemQty('sp_' + maSP, maSP, tenSP, gia, true, delta);
}

/**
 * Tìm kiếm nhanh combo & sản phẩm bán lẻ theo từ khóa
 */
function searchFnbItems(query) {
    const q = (query || '').toLowerCase().trim();
    const cards = document.querySelectorAll('.combo-card[data-search]');
    let countComboVisible = 0;
    let countSpVisible = 0;

    cards.forEach(card => {
        const searchText = (card.getAttribute('data-search') || '').toLowerCase();
        const matches = !q || searchText.includes(q);
        card.style.display = matches ? '' : 'none';

        if (matches) {
            if (card.classList.contains('is-combo-item')) countComboVisible++;
            if (card.classList.contains('is-sp-item')) countSpVisible++;
        }
    });

    // Ẩn/hiện tiêu đề mục nếu không có kết quả phù hợp
    const secCombos = document.getElementById('sectionCombos');
    const secProducts = document.getElementById('sectionProducts');
    const noResultMsg = document.getElementById('fnbNoResultMsg');

    if (secCombos) {
        secCombos.style.display = (countComboVisible > 0 || !q) ? 'block' : 'none';
    }
    if (secProducts) {
        secProducts.style.display = (countSpVisible > 0 || !q) ? 'block' : 'none';
    }
    if (noResultMsg) {
        noResultMsg.style.display = (q && countComboVisible === 0 && countSpVisible === 0) ? 'block' : 'none';
    }
}

/**
 * 4. Khôi phục trạng thái từ sessionStorage
 */
function initStoredState() {
    try {
        const storedSeats = sessionStorage.getItem('pos_selected_seats');
        if (storedSeats) {
            POS_STATE.selectedSeats = JSON.parse(storedSeats);
            POS_STATE.selectedSeats.forEach(s => {
                const el = document.querySelector(`.pos-seat[data-maghe="${s.maGhe}"]`);
                if (el && !el.classList.contains('sold')) {
                    el.classList.add('selected');
                }
            });
        }

        const storedCombos = sessionStorage.getItem('pos_selected_combos');
        if (storedCombos) {
            const parsed = JSON.parse(storedCombos);
            // Chuẩn hóa dữ liệu cũ nếu lưu theo maCombo trực tiếp
            Object.keys(parsed).forEach(k => {
                const item = parsed[k];
                const key = item.itemKey || (k.startsWith('combo_') || k.startsWith('sp_') ? k : ('combo_' + (item.maCombo || k)));
                POS_STATE.selectedCombos[key] = {
                    itemKey: key,
                    maCombo: item.maCombo !== undefined ? item.maCombo : (!item.isProduct ? parseInt(k) : null),
                    maSP: item.maSP !== undefined ? item.maSP : (item.isProduct ? parseInt(k) : null),
                    tenCombo: item.tenCombo || item.ten || '',
                    gia: parseFloat(item.gia) || 0,
                    soLuong: parseInt(item.soLuong) || 0,
                    isProduct: !!item.isProduct
                };
                updateItemCounterUI(key);
            });
        }
    } catch (e) {
        console.error('Lỗi khôi phục trạng thái giỏ vé:', e);
    }
}

/**
 * 5. Cập nhật giao diện Chi tiết hóa đơn bên phải (Real-time Mini Cart)
 */
function renderCart() {
    const seatNamesText = document.getElementById('cartSeatNamesText');
    const seatCountLabel = document.getElementById('cartSeatCountLabel');
    const seatTotalText = document.getElementById('cartSeatTotalText');
    const combosListEl = document.getElementById('cartCombosList');
    const totalAmountEl = document.getElementById('cartTotalAmount');

    let totalTienVe = 0;
    let totalTienCombo = 0;

    // A. Cập nhật ghế đã chọn
    if (seatNamesText && seatTotalText) {
        if (POS_STATE.selectedSeats.length === 0) {
            seatNamesText.textContent = 'Chưa chọn';
            seatNamesText.classList.remove('text-pink');
            if (seatCountLabel) seatCountLabel.textContent = 'Tiền vé (0 vé):';
            seatTotalText.textContent = '0 đ';
        } else {
            const names = POS_STATE.selectedSeats.map(s => s.tenGhe).join(', ');
            seatNamesText.textContent = names;
            seatNamesText.classList.add('text-pink');

            POS_STATE.selectedSeats.forEach(s => totalTienVe += s.gia);
            if (seatCountLabel) {
                seatCountLabel.textContent = `Tiền vé (${POS_STATE.selectedSeats.length} vé):`;
            }
            seatTotalText.textContent = formatVND(totalTienVe);
        }
    }

    // B. Cập nhật Combo & Sản phẩm lẻ đã chọn
    if (combosListEl) {
        const itemKeys = Object.keys(POS_STATE.selectedCombos);
        if (itemKeys.length === 0) {
            combosListEl.innerHTML = '<div style="color:#94a3b8; font-size:12px; font-style:italic;">Chưa chọn bắp nước / combo</div>';
        } else {
            let html = '';
            itemKeys.forEach(k => {
                const c = POS_STATE.selectedCombos[k];
                const subTotal = c.gia * c.soLuong;
                totalTienCombo += subTotal;
                const badge = c.isProduct
                    ? '<span style="font-size:10px; background:#e0f2fe; color:#0369a1; padding:1px 5px; border-radius:4px; margin-right:4px; font-weight:600;">Lẻ</span>'
                    : '<span style="font-size:10px; background:#fce7f3; color:#db2777; padding:1px 5px; border-radius:4px; margin-right:4px; font-weight:600;">Combo</span>';
                html += `
                    <div class="cart-line-row">
                        <span class="label-light"><strong>${c.soLuong}x</strong> ${badge}${c.tenCombo}:</span>
                        <span class="value-bold">${formatVND(subTotal)}</span>
                    </div>
                `;
            });
            combosListEl.innerHTML = html;
        }
    }

    // C. Tổng thanh toán
    const grandTotal = totalTienVe + totalTienCombo;
    if (totalAmountEl) {
        totalAmountEl.textContent = formatVND(grandTotal);
    }

    // D. Nút chuyển tiếp sang bước 3 (Kiểm tra ghế)
    const hasSeats = POS_STATE.selectedSeats && POS_STATE.selectedSeats.length > 0;
    const btnStep2Combo = document.getElementById('btnContinueToCombo');
    const btnCartCombo = document.getElementById('btnCartProceedToCombo');

    [btnStep2Combo, btnCartCombo].forEach(btn => {
        if (btn) {
            if (!hasSeats) {
                btn.classList.add('disabled-btn');
                btn.style.opacity = '0.55';
                btn.style.cursor = 'not-allowed';
                btn.title = 'Vui lòng chọn ít nhất 1 ghế ngồi trên sơ đồ để tiếp tục';
            } else {
                btn.classList.remove('disabled-btn');
                btn.style.opacity = '1';
                btn.style.cursor = 'pointer';
                btn.title = '';
            }
        }
    });
}

function formatVND(number) {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(number);
}

function resetBooking(contextPath, selectedNgay) {
    if (confirm('Làm mới đơn và bắt đầu giao dịch bán vé mới?')) {
        sessionStorage.removeItem('pos_selected_seats');
        sessionStorage.removeItem('pos_selected_combos');
        window.location.href = contextPath + '/ban-ve?ngayChieu=' + encodeURIComponent(selectedNgay || '');
    }
}
