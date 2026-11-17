/* ============================================================================
 * FILE: assets/js/ban-ve.js
 * MỤC ĐÍCH: Xử lý logic màn hình Bán vé tại quầy (POS)
 * - Click chọn suất chiếu trực tiếp từ thẻ phim
 * - Chọn / Hủy chọn ghế ngồi trên sơ đồ trực quan
 * - Tăng / Giảm số lượng Combo bắp nước
 * - Cập nhật chi tiết hóa đơn (Real-time Cart)
 * ============================================================================ */

const POS_STATE = {
    selectedSeats: [],  // [{ maGhe, tenGhe, loaiGhe, gia }]
    selectedCombos: {}, // { [maCombo]: { maCombo, tenCombo, gia, soLuong } }
    basePrice: 0
};

document.addEventListener('DOMContentLoaded', function () {
    const cartEl = document.getElementById('posMiniCart');
    if (cartEl && cartEl.dataset.basePrice) {
        POS_STATE.basePrice = parseFloat(cartEl.dataset.basePrice) || 0;
    }

    initStoredState();
    renderCart();
});

/**
 * 1. Click chọn trực tiếp một khung giờ suất chiếu trên thẻ phim
 * Nhảy thẳng sang Bước 2: Chọn ghế ngồi của suất chiếu đó
 */
function chonSuatDirect(maSuat) {
    const params = new URLSearchParams(window.location.search);
    params.set('maSuat', maSuat);
    params.set('step', '2'); // Sang bước chọn ghế ngay
    sessionStorage.removeItem('pos_selected_seats'); // Đổi suất thì xóa ghế cũ
    window.location.href = window.location.pathname + '?' + params.toString();
}

/**
 * 2. Điều hướng chuyển đổi giữa các bước (1, 2, 3)
 */
function goToStep(step) {
    const params = new URLSearchParams(window.location.search);
    params.set('step', step);
    window.location.href = window.location.pathname + '?' + params.toString();
}

/**
 * 3. Xử lý click chọn / hủy chọn ghế ngồi
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
 * 4. Tăng / Giảm số lượng Combo bắp nước
 */
function changeComboQty(maCombo, tenCombo, gia, delta) {
    if (!POS_STATE.selectedCombos[maCombo]) {
        POS_STATE.selectedCombos[maCombo] = {
            maCombo: maCombo,
            tenCombo: tenCombo,
            gia: parseFloat(gia) || 0,
            soLuong: 0
        };
    }

    POS_STATE.selectedCombos[maCombo].soLuong += delta;

    if (POS_STATE.selectedCombos[maCombo].soLuong <= 0) {
        delete POS_STATE.selectedCombos[maCombo];
    }

    const counterEl = document.getElementById('combo-qty-' + maCombo);
    if (counterEl) {
        counterEl.textContent = POS_STATE.selectedCombos[maCombo] ? POS_STATE.selectedCombos[maCombo].soLuong : 0;
    }

    sessionStorage.setItem('pos_selected_combos', JSON.stringify(POS_STATE.selectedCombos));
    renderCart();
}

/**
 * 5. Khôi phục trạng thái từ sessionStorage
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
            POS_STATE.selectedCombos = JSON.parse(storedCombos);
            Object.values(POS_STATE.selectedCombos).forEach(c => {
                const counterEl = document.getElementById('combo-qty-' + c.maCombo);
                if (counterEl) {
                    counterEl.textContent = c.soLuong;
                }
            });
        }
    } catch (e) {
        console.error('Lỗi khởi tạo trạng thái giỏ vé:', e);
    }
}

/**
 * 6. Cập nhật giao diện Chi tiết hóa đơn bên phải (Real-time Mini Cart)
 */
function renderCart() {
    const seatNamesText = document.getElementById('cartSeatNamesText');
    const seatCountLabel = document.getElementById('cartSeatCountLabel');
    const seatTotalText = document.getElementById('cartSeatTotalText');
    const combosListEl = document.getElementById('cartCombosList');
    const totalAmountEl = document.getElementById('cartTotalAmount');
    const btnNextStep = document.getElementById('btnNextStep');

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

    // B. Cập nhật Combo đã chọn
    if (combosListEl) {
        const comboKeys = Object.keys(POS_STATE.selectedCombos);
        if (comboKeys.length === 0) {
            combosListEl.innerHTML = '<div style="color:#94a3b8; font-size:12px; font-style:italic;">Chưa chọn combo bắp nước</div>';
        } else {
            let html = '';
            comboKeys.forEach(k => {
                const c = POS_STATE.selectedCombos[k];
                const subTotal = c.gia * c.soLuong;
                totalTienCombo += subTotal;
                html += `
                    <div class="cart-line-row">
                        <span class="label-light"><strong>${c.soLuong}x</strong> ${c.tenCombo}:</span>
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

    // D. Nút chuyển tiếp
    if (btnNextStep) {
        const currentStep = parseInt(btnNextStep.dataset.currentStep) || 1;
        if (currentStep === 2 && POS_STATE.selectedSeats.length === 0) {
            btnNextStep.disabled = true;
            btnNextStep.style.opacity = '0.5';
            btnNextStep.style.cursor = 'not-allowed';
            btnNextStep.title = 'Vui lòng chọn ít nhất 1 ghế để tiếp tục';
        } else {
            btnNextStep.disabled = false;
            btnNextStep.style.opacity = '1';
            btnNextStep.style.cursor = 'pointer';
            btnNextStep.title = '';
        }
    }
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
/* ============================================================================
 * FILE: assets/js/ban-ve.js
 * MỤC ĐÍCH: Xử lý logic màn hình Bán vé tại quầy (POS)
 * - Click chọn suất chiếu trực tiếp từ thẻ phim
 * - Chọn / Hủy chọn ghế ngồi trên sơ đồ trực quan
 * - Tăng / Giảm số lượng Combo bắp nước
 * - Cập nhật chi tiết hóa đơn (Real-time Cart)
 * ============================================================================ */

const POS_STATE = {
    selectedSeats: [],  // [{ maGhe, tenGhe, loaiGhe, gia }]
    selectedCombos: {}, // { [maCombo]: { maCombo, tenCombo, gia, soLuong } }
    basePrice: 0
};

document.addEventListener('DOMContentLoaded', function () {
    const cartEl = document.getElementById('posMiniCart');
    if (cartEl && cartEl.dataset.basePrice) {
        POS_STATE.basePrice = parseFloat(cartEl.dataset.basePrice) || 0;
    }

    initStoredState();
    renderCart();
});

/**
 * 1. Click chọn trực tiếp một khung giờ suất chiếu trên thẻ phim
 * Nhảy thẳng sang Bước 2: Chọn ghế ngồi của suất chiếu đó
 */
function chonSuatDirect(maSuat) {
    const params = new URLSearchParams(window.location.search);
    params.set('maSuat', maSuat);
    params.set('step', '2'); // Sang bước chọn ghế ngay
    sessionStorage.removeItem('pos_selected_seats'); // Đổi suất thì xóa ghế cũ
    window.location.href = window.location.pathname + '?' + params.toString();
}

/**
 * 2. Điều hướng chuyển đổi giữa các bước (1, 2, 3)
 */
function goToStep(step) {
    const params = new URLSearchParams(window.location.search);
    params.set('step', step);
    window.location.href = window.location.pathname + '?' + params.toString();
}

/**
 * 3. Xử lý click chọn / hủy chọn ghế ngồi
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
 * 4. Tăng / Giảm số lượng Combo bắp nước
 */
function changeComboQty(maCombo, tenCombo, gia, delta) {
    if (!POS_STATE.selectedCombos[maCombo]) {
        POS_STATE.selectedCombos[maCombo] = {
            maCombo: maCombo,
            tenCombo: tenCombo,
            gia: parseFloat(gia) || 0,
            soLuong: 0
        };
    }

    POS_STATE.selectedCombos[maCombo].soLuong += delta;

    if (POS_STATE.selectedCombos[maCombo].soLuong <= 0) {
        delete POS_STATE.selectedCombos[maCombo];
    }

    const counterEl = document.getElementById('combo-qty-' + maCombo);
    if (counterEl) {
        counterEl.textContent = POS_STATE.selectedCombos[maCombo] ? POS_STATE.selectedCombos[maCombo].soLuong : 0;
    }

    sessionStorage.setItem('pos_selected_combos', JSON.stringify(POS_STATE.selectedCombos));
    renderCart();
}

/**
 * 5. Khôi phục trạng thái từ sessionStorage
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
            POS_STATE.selectedCombos = JSON.parse(storedCombos);
            Object.values(POS_STATE.selectedCombos).forEach(c => {
                const counterEl = document.getElementById('combo-qty-' + c.maCombo);
                if (counterEl) {
                    counterEl.textContent = c.soLuong;
                }
            });
        }
    } catch (e) {
        console.error('Lỗi khởi tạo trạng thái giỏ vé:', e);
    }
}

/**
 * 6. Cập nhật giao diện Chi tiết hóa đơn bên phải (Real-time Mini Cart)
 */
function renderCart() {
    const seatNamesText = document.getElementById('cartSeatNamesText');
    const seatCountLabel = document.getElementById('cartSeatCountLabel');
    const seatTotalText = document.getElementById('cartSeatTotalText');
    const combosListEl = document.getElementById('cartCombosList');
    const totalAmountEl = document.getElementById('cartTotalAmount');
    const btnNextStep = document.getElementById('btnNextStep');

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

    // B. Cập nhật Combo đã chọn
    if (combosListEl) {
        const comboKeys = Object.keys(POS_STATE.selectedCombos);
        if (comboKeys.length === 0) {
            combosListEl.innerHTML = '<div style="color:#94a3b8; font-size:12px; font-style:italic;">Chưa chọn combo bắp nước</div>';
        } else {
            let html = '';
            comboKeys.forEach(k => {
                const c = POS_STATE.selectedCombos[k];
                const subTotal = c.gia * c.soLuong;
                totalTienCombo += subTotal;
                html += `
                    <div class="cart-line-row">
                        <span class="label-light"><strong>${c.soLuong}x</strong> ${c.tenCombo}:</span>
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

    // D. Nút chuyển tiếp
    if (btnNextStep) {
        const currentStep = parseInt(btnNextStep.dataset.currentStep) || 1;
        if (currentStep === 2 && POS_STATE.selectedSeats.length === 0) {
            btnNextStep.disabled = true;
            btnNextStep.style.opacity = '0.5';
            btnNextStep.style.cursor = 'not-allowed';
            btnNextStep.title = 'Vui lòng chọn ít nhất 1 ghế để tiếp tục';
        } else {
            btnNextStep.disabled = false;
            btnNextStep.style.opacity = '1';
            btnNextStep.style.cursor = 'pointer';
            btnNextStep.title = '';
        }
    }
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
