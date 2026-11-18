<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh Toán & Xuất Vé - Rạp Chiếu Phim CINEMAX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=12">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .checkout-layout {
            display: grid;
            grid-template-columns: 1.15fr 0.85fr;
            gap: 24px;
            align-items: flex-start;
        }
        @media (max-width: 1024px) {
            .checkout-layout {
                grid-template-columns: 1fr;
            }
        }
        .checkout-card {
            background: #ffffff;
            border-radius: var(--radius-md);
            padding: 20px;
            margin-bottom: 20px;
            border: 1px solid var(--border-subtle);
            box-shadow: 0 1px 3px rgba(0,0,0,0.03);
        }
        .card-heading {
            font-size: 14px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 14px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .movie-summary-box {
            background: #fff1f2;
            border: 1px solid #fecdd3;
            border-radius: 12px;
            padding: 16px;
            margin-bottom: 16px;
        }
        .movie-title {
            font-size: 18px;
            font-weight: 800;
            color: #e11d48;
            margin-bottom: 6px;
        }
        .movie-meta-item {
            font-size: 13px;
            color: #475569;
            margin-bottom: 4px;
        }
        .movie-meta-item strong {
            color: #0f172a;
        }

        .item-list-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px dashed var(--border-subtle);
            font-size: 13px;
        }
        .item-list-row:last-child {
            border-bottom: none;
        }
        .seat-tag {
            display: inline-block;
            background: #ffe4e6;
            color: #e11d48;
            font-weight: 700;
            padding: 2px 8px;
            border-radius: 6px;
            margin-right: 6px;
            font-size: 12px;
        }

        /* KHÁCH HÀNG THÂN THIẾT */
        .member-search-wrap {
            display: flex;
            gap: 10px;
            margin-bottom: 12px;
        }
        .member-input {
            flex: 1;
            height: 38px;
            padding: 0 12px;
            border: 1px solid var(--border-strong);
            border-radius: var(--radius-sm);
            background: var(--bg-input);
            font-size: 13px;
            outline: none;
        }
        .member-input:focus {
            border-color: var(--pink);
            background: #fff;
        }
        .member-result-card {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 12px;
            font-size: 13px;
            display: none;
        }

        /* TABS PHƯƠNG THỨC THANH TOÁN */
        .pay-tabs {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 8px;
            margin-bottom: 20px;
        }
        .pay-tab-btn {
            border: 2px solid var(--border-subtle);
            background: #ffffff;
            border-radius: 10px;
            padding: 14px 8px;
            text-align: center;
            cursor: pointer;
            transition: all 0.2s ease;
            font-weight: 600;
            font-size: 13px;
            color: var(--text-secondary);
        }
        .pay-tab-btn i {
            display: block;
            font-size: 22px;
            margin-bottom: 6px;
        }
        .pay-tab-btn.active {
            border-color: #e11d48;
            background: #fff1f2;
            color: #e11d48;
        }

        .pay-tab-content {
            display: none;
        }
        .pay-tab-content.active {
            display: block;
        }

        /* Nút tiền nhanh */
        .quick-cash-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 8px;
            margin: 12px 0;
        }
        .quick-cash-btn {
            background: #f1f5f9;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            padding: 8px 0;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            color: #334155;
            transition: all 0.15s ease;
        }
        .quick-cash-btn:hover {
            background: #e2e8f0;
            border-color: #94a3b8;
        }

        .change-return-box {
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            border-radius: 10px;
            padding: 14px 18px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 16px;
        }
        .change-return-box .val {
            font-size: 20px;
            font-weight: 800;
            color: #16a34a;
        }

        /* VIETQR */
        .qr-display-box {
            background: #ffffff;
            border: 1px dashed #cbd5e1;
            border-radius: 12px;
            padding: 20px;
            text-align: center;
        }
        .qr-img {
            width: 220px;
            height: 220px;
            object-fit: contain;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
            margin: 0 auto 12px auto;
            display: block;
        }

        /* TỔNG KẾT TIỀN */
        .order-sum-box {
            background: #f8fafc;
            border-radius: 12px;
            padding: 16px;
            border: 1px solid var(--border-subtle);
        }
        .sum-line {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-size: 13px;
            color: #475569;
        }
        .sum-line.total {
            font-size: 18px;
            font-weight: 800;
            color: #e11d48;
            margin-top: 10px;
            padding-top: 10px;
            border-top: 2px dashed #cbd5e1;
        }

        .btn-checkout-submit {
            width: 100%;
            height: 52px;
            background: #e11d48;
            color: #ffffff;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            box-shadow: 0 4px 12px rgba(225, 29, 72, 0.3);
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            margin-top: 16px;
        }
        .btn-checkout-submit:hover {
            background: #be123c;
            transform: translateY(-1px);
        }

        /* MODAL HÓA ĐƠN K80 */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(15, 23, 42, 0.65);
            backdrop-filter: blur(4px);
            z-index: 1000;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .modal-overlay.active {
            display: flex;
        }
        .modal-receipt {
            background: #ffffff;
            width: 100%;
            max-width: 440px;
            max-height: 90vh;
            border-radius: 16px;
            overflow-y: auto;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            display: flex;
            flex-direction: column;
        }
        .receipt-body {
            padding: 24px 28px;
            font-family: 'Courier New', Courier, monospace;
            color: #1e293b;
        }
        .receipt-cinema-name {
            font-size: 18px;
            font-weight: 800;
            text-align: center;
            letter-spacing: 1px;
            color: #0f172a;
        }
        .receipt-sub {
            font-size: 11px;
            text-align: center;
            color: #64748b;
            margin-top: 2px;
        }
        .receipt-divider {
            border-top: 1px dashed #94a3b8;
            margin: 14px 0;
        }
        .receipt-row {
            display: flex;
            justify-content: space-between;
            font-size: 12px;
            margin-bottom: 5px;
        }
        .receipt-row.grand-total {
            font-size: 16px;
            font-weight: 800;
            color: #e11d48;
            margin-top: 6px;
        }
        .receipt-barcode {
            text-align: center;
            margin-top: 16px;
            padding-top: 12px;
            border-top: 1px dashed #cbd5e1;
        }
        .barcode-stripes {
            font-family: 'Libre Barcode 128', cursive, monospace;
            font-size: 38px;
            letter-spacing: 2px;
            line-height: 1;
        }
        .modal-actions {
            background: #f8fafc;
            padding: 14px 24px;
            border-top: 1px solid var(--border-subtle);
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }

        @media print {
            body * {
                visibility: hidden;
            }
            #printableReceipt, #printableReceipt * {
                visibility: visible;
            }
            #printableReceipt {
                position: absolute;
                left: 0;
                top: 0;
                width: 80mm;
                padding: 5mm;
                margin: 0;
                box-shadow: none;
            }
            .modal-actions, .app-shell, .checkout-layout, .topbar {
                display: none !important;
            }
        }
    </style>
</head>
<body>
<div class="app-shell">
    <!-- MENU BÊN TRÁI -->
    <c:choose>
        <c:when test="${sessionScope.userRole == 'NhanVien' || sessionScope.userRole == 'Nhân viên'}">
            <jsp:include page="/menunv.jsp" />
        </c:when>
        <c:otherwise>
            <jsp:include page="/menuadmin.jsp" />
        </c:otherwise>
    </c:choose>

    <!-- NỘI DUNG CHÍNH -->
    <main class="main-content">
        <!-- TOPBAR -->
        <header class="topbar" style="margin-bottom:20px; display:flex; justify-content:space-between; align-items:center;">
            <div style="display:flex; align-items:center; gap:16px;">
                <a href="${pageContext.request.contextPath}/ban-ve?maSuat=${selectedSuat.maSuat}&step=3" class="btn btn-outline">
                    ← Quay lại Giỏ hàng
                </a>
                <div>
                    <h2 style="font-size:20px; font-weight:800; color:var(--text-primary); margin:0;">
                        THANH TOÁN ĐƠN VÉ & XUẤT HÓA ĐƠN
                    </h2>
                    <span style="font-size:13px; color:var(--text-secondary);">
                        Thu tiền khách hàng, tích điểm thành viên và in phiếu vé K80
                    </span>
                </div>
            </div>
            <div style="font-size:13px; font-weight:600; color:#e11d48; background:#fff1f2; padding:6px 14px; border-radius:20px;">
                <i class="fa-solid fa-clock" style="margin-right:6px;"></i> Giữ ghế trong 10:00
            </div>
        </header>

        <!-- LAYOUT 2 CỘT -->
        <div class="checkout-layout">
            <!-- CỘT TRÁI: TÓM TẮT ĐƠN HÀNG -->
            <div class="left-col">
                <!-- THÔNG TIN PHIM & SUẤT CHIẾU -->
                <div class="movie-summary-box">
                    <div class="movie-title">
                        <c:out value="${not empty selectedPhim ? selectedPhim.tenPhim : 'Phim chiếu rạp'}"/>
                    </div>
                    <div class="movie-meta-item">
                        Suất chiếu: <strong>${selectedSuat != null ? selectedSuat.gioBatDau.toString().substring(0,5) : '--:--'}</strong>
                        • Ngày: <strong>${selectedSuat != null ? selectedSuat.ngayChieu : ''}</strong>
                    </div>
                    <div class="movie-meta-item">
                        Phòng: <strong><c:out value="${selectedSuat != null && selectedSuat.phongChieu != null ? selectedSuat.phongChieu.tenPhong : 'Phòng tiêu chuẩn'}"/></strong>
                        (${selectedSuat != null ? selectedSuat.dinhDang : '2D Phụ đề'})
                    </div>
                </div>

                <!-- DANH SÁCH GHẾ NGỒI ĐÃ CHỌN -->
                <div class="checkout-card">
                    <div class="card-heading">
                        <span>🎟️ Ghế ngồi (<span id="txtSeatCount">0</span> vé)</span>
                        <span id="txtSeatSubtotal" style="color:#0f172a; font-weight:700;">0 đ</span>
                    </div>
                    <div id="seatsSummaryContainer">
                        <div style="color:#94a3b8; font-size:13px; font-style:italic;">Đang tải thông tin ghế...</div>
                    </div>
                </div>

                <!-- DANH SÁCH BẮP NƯỚC COMBO -->
                <div class="checkout-card">
                    <div class="card-heading">
                        <span>🍿 Combo bắp nước (F&B)</span>
                        <span id="txtComboSubtotal" style="color:#0f172a; font-weight:700;">0 đ</span>
                    </div>
                    <div id="combosSummaryContainer">
                        <div style="color:#94a3b8; font-size:13px; font-style:italic;">Chưa chọn combo bắp nước</div>
                    </div>
                </div>

                <!-- KHÁCH HÀNG THÂN THIẾT -->
                <div class="checkout-card">
                    <div class="card-heading">
                        <span>👑 Khách hàng thành viên</span>
                    </div>
                    <div class="member-search-wrap">
                        <input type="text" id="memberPhone" class="member-input"
                               placeholder="Nhập số điện thoại khách hàng (VD: 0912345678)..."
                               onkeyup="handlePhoneLookup(this.value)">
                        <button type="button" class="btn btn-outline" onclick="triggerCustomerLookup()">
                            <i class="fa-solid fa-magnifying-glass"></i> Kiểm tra
                        </button>
                    </div>

                    <!-- KẾT QUẢ TÌM THẤY -->
                    <div class="member-result-card" id="memberResultCard">
                        <div style="display:flex; justify-content:space-between; align-items:center;">
                            <div>
                                <strong id="memberFoundName" style="color:#0f172a; font-size:14px;">Nguyễn Văn A</strong>
                                <div style="font-size:12px; color:#64748b; margin-top:2px;">
                                    Điểm tích lũy: <strong id="memberFoundPoints" style="color:#16a34a; font-size:14px;">0</strong> điểm
                                </div>
                            </div>
                            <label style="display:flex; align-items:center; gap:6px; cursor:pointer; font-weight:600; color:#e11d48;">
                                <input type="checkbox" id="chkUsePoints" onchange="toggleUsePoints(this.checked)">
                                Dùng điểm giảm giá
                            </label>
                        </div>
                    </div>

                    <!-- NẾU LÀ KHÁCH MỚI -->
                    <div id="newMemberBox" style="display:none; margin-top:10px;">
                        <input type="text" id="newMemberName" class="member-input"
                               placeholder="Khách mới: Nhập Họ tên khách hàng để đăng ký tích điểm...">
                    </div>
                </div>
            </div>

            <!-- CỘT PHẢI: PHƯƠNG THỨC THANH TOÁN & THU TIỀN -->
            <div class="right-col">
                <div class="checkout-card" style="border-top: 4px solid #e11d48;">
                    <div class="card-heading">
                        <span>💳 PHƯƠNG THỨC THANH TOÁN</span>
                    </div>

                    <!-- TABS -->
                    <div class="pay-tabs">
                        <div class="pay-tab-btn active" onclick="switchPayTab('cash')">
                            <i class="fa-solid fa-money-bill-wave"></i>
                            Tiền mặt
                        </div>
                        <div class="pay-tab-btn" onclick="switchPayTab('vietqr')">
                            <i class="fa-solid fa-qrcode"></i>
                            Chuyển khoản QR
                        </div>
                        <div class="pay-tab-btn" onclick="switchPayTab('card')">
                            <i class="fa-solid fa-credit-card"></i>
                            Thẻ POS
                        </div>
                    </div>

                    <!-- TAB 1: TIỀN MẶT -->
                    <div class="pay-tab-content active" id="tabContent_cash">
                        <label style="font-size:12px; font-weight:700; color:#475569; display:block; margin-bottom:6px;">
                            TIỀN KHÁCH ĐƯA (VND)
                        </label>
                        <input type="text" id="inputCashGiven" class="member-input"
                               style="font-size:18px; font-weight:700; color:#0f172a; height:46px;"
                               placeholder="Nhập số tiền khách đưa..."
                               oninput="handleCashInput(this.value)">

                        <!-- Nút tiền nhanh -->
                        <div class="quick-cash-grid">
                            <button type="button" class="quick-cash-btn" onclick="setExactCash()">Đúng số tiền</button>
                            <button type="button" class="quick-cash-btn" onclick="setCashAmount(100000)">100.000 đ</button>
                            <button type="button" class="quick-cash-btn" onclick="setCashAmount(200000)">200.000 đ</button>
                            <button type="button" class="quick-cash-btn" onclick="setCashAmount(300000)">300.000 đ</button>
                            <button type="button" class="quick-cash-btn" onclick="setCashAmount(500000)">500.000 đ</button>
                            <button type="button" class="quick-cash-btn" onclick="setCashAmount(1000000)">1.000.000 đ</button>
                        </div>

                        <!-- Tiền thối lại -->
                        <div class="change-return-box">
                            <span style="font-size:13px; font-weight:700; color:#166534;">TIỀN THỐI LẠI:</span>
                            <span class="val" id="txtChangeReturn">0 đ</span>
                        </div>
                    </div>

                    <!-- TAB 2: CHUYỂN KHOẢN VIETQR -->
                    <div class="pay-tab-content" id="tabContent_vietqr">
                        <div class="qr-display-box">
                            <img id="vietQrImg" src="" alt="Mã VietQR" class="qr-img">
                            <div style="font-size:13px; font-weight:700; color:#0f172a;">QUÉT MÃ ĐỂ THANH TOÁN</div>
                            <div style="font-size:12px; color:#64748b; margin-top:2px;">
                                Ngân hàng: <strong>MBBank</strong> • STK: <strong>0912345678</strong>
                            </div>
                            <div style="font-size:12px; color:#e11d48; margin-top:2px;">
                                Nội dung CK: <strong id="txtQrMemo">CINEMAX</strong>
                            </div>
                        </div>
                    </div>

                    <!-- TAB 3: THẺ NGÂN HÀNG -->
                    <div class="pay-tab-content" id="tabContent_card">
                        <div style="background:#f8fafc; border:1px solid #e2e8f0; border-radius:10px; padding:16px;">
                            <label style="font-size:12px; font-weight:700; color:#475569; display:block; margin-bottom:6px;">
                                MÃ CHUẨN CHI / GIAO DỊCH POS
                            </label>
                            <input type="text" id="cardAuthCode" class="member-input"
                                   placeholder="Nhập mã chuẩn chi từ bill POS (VD: 048291)...">
                            <div style="font-size:11px; color:#64748b; margin-top:6px;">
                                Vui lòng quẹt thẻ khách trên thiết bị POS của ngân hàng trước khi xác nhận.
                            </div>
                        </div>
                    </div>

                    <!-- TỔNG KẾT TIỀN ĐƠN HÀNG -->
                    <div class="order-sum-box" style="margin-top:20px;">
                        <div class="sum-line">
                            <span>Tạm tính tiền vé:</span>
                            <span id="sumTicket">0 đ</span>
                        </div>
                        <div class="sum-line">
                            <span>Tạm tính combo:</span>
                            <span id="sumCombo">0 đ</span>
                        </div>
                        <div class="sum-line" id="discountRow" style="display:none; color:#16a34a;">
                            <span>Giảm giá (Điểm tích lũy):</span>
                            <span id="sumDiscount">-0 đ</span>
                        </div>
                        <div class="sum-line total">
                            <span>TỔNG THANH TOÁN:</span>
                            <span id="sumGrandTotal">0 đ</span>
                        </div>
                    </div>

                    <!-- NÚT XÁC NHẬN THANH TOÁN -->
                    <button type="button" class="btn-checkout-submit" onclick="executeCheckout()">
                        <i class="fa-solid fa-check"></i> XÁC NHẬN THANH TOÁN & IN VÉ (F9)
                    </button>
                </div>
            </div>
        </div>
    </main>
</div>

<!-- MODAL HÓA ĐƠN K80 HOÀN TẤT -->
<div class="modal-overlay <c:if test='${isCompleted}'>active</c:if>' id="completedReceiptModal">
    <div class="modal-receipt">
        <div class="receipt-body" id="printableReceipt">
            <div class="receipt-cinema-name">CINEMAX CINEMA</div>
            <div class="receipt-sub">Tầng 5, TTTM Vincom Center • Hotline: 1900 6868</div>
            <div class="receipt-sub" style="margin-bottom:8px;">--- PHIẾU VÉ & HÓA ĐƠN K80 ---</div>

            <div class="receipt-divider"></div>

            <div class="receipt-row">
                <span>Số HĐ:</span>
                <strong id="k80Code">#HD${hoaDon != null ? hoaDon.maDatVe : '00'}</strong>
            </div>
            <div class="receipt-row">
                <span>Ngày in:</span>
                <span id="k80Date">${hoaDon != null ? hoaDon.ngayDatFormatted : ''}</span>
            </div>
            <div class="receipt-row">
                <span>Thu ngân:</span>
                <span id="k80Cashier">${hoaDon != null && hoaDon.tenThuNgan != null ? hoaDon.tenThuNgan : 'Thu ngân'}</span>
            </div>
            <div class="receipt-row">
                <span>Hình thức:</span>
                <span id="k80Method">${hoaDon != null ? hoaDon.phuongThuc : 'Tiền mặt'}</span>
            </div>

            <div class="receipt-divider"></div>

            <!-- DANH SÁCH VÉ -->
            <div style="font-weight:700; margin-bottom:6px; font-size:12px; text-transform:uppercase;">
                🎬 VÉ XEM PHIM
            </div>
            <div id="k80TicketsContainer">
                <c:forEach items="${hoaDon.danhSachVe}" var="v">
                    <div style="margin-bottom:8px; padding-bottom:6px; border-bottom:1px dotted #e2e8f0;">
                        <div style="font-weight:700;">${v.tenPhim}</div>
                        <div style="font-size:11px; color:#475569;">
                            Suất: <strong>${v.gioChieu}</strong> • ${v.ngayChieu} | Phòng: ${v.tenPhong}
                        </div>
                        <div class="receipt-row" style="margin-top:2px;">
                            <span>Ghế: <strong style="font-size:13px; color:#e11d48;">${v.tenGhe}</strong></span>
                            <span>${v.giaVeFormatted}</span>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- DANH SÁCH COMBO -->
            <c:if test="${not empty hoaDon.danhSachChiTiet}">
                <div style="font-weight:700; margin-top:10px; margin-bottom:6px; font-size:12px; text-transform:uppercase;">
                    🍿 COMBO BẮP NƯỚC (F&B)
                </div>
                <div id="k80CombosContainer">
                    <c:forEach items="${hoaDon.danhSachChiTiet}" var="c">
                        <div class="receipt-row">
                            <span><strong>${c.soLuong}x</strong> ${c.tenCombo}</span>
                            <span>${c.thanhTienFormatted}</span>
                        </div>
                    </c:forEach>
                </div>
            </c:if>

            <div class="receipt-divider"></div>

            <div class="receipt-row grand-total">
                <span>TỔNG CỘNG:</span>
                <span id="k80Total">${hoaDon != null ? hoaDon.tongTienFormatted : '0 đ'}</span>
            </div>
            <div style="font-size:10px; color:#64748b; font-style:italic; text-align:right;">(Giá đã bao gồm 8% thuế GTGT)</div>

            <div class="receipt-barcode">
                <div class="barcode-stripes">||||||||||||||||||||</div>
                <div style="font-size:11px; margin-top:4px;" id="k80BarcodeText">CINEMAX-HD${hoaDon != null ? hoaDon.maDatVe : '00'}</div>
                <div style="font-size:11px; color:#64748b; margin-top:8px;">
                    Vui lòng xuất trình mã QR/Barcode tại cổng soát vé trước giờ chiếu 10 phút.
                </div>
                <div style="font-size:12px; font-weight:700; margin-top:6px;">
                    Cảm ơn quý khách & Hẹn gặp lại!
                </div>
            </div>
        </div>

        <div class="modal-actions">
            <a href="${pageContext.request.contextPath}/ban-ve" class="btn btn-ghost" onclick="clearCartSession()">
                + Bán đơn mới
            </a>
            <button type="button" class="btn btn-pink" onclick="window.print()">
                <i class="fa-solid fa-print" style="margin-right:6px;"></i> In Vé (K80)
            </button>
        </div>
    </div>
</div>

<script>
    const CHECKOUT_STATE = {
        selectedSeats: [],
        selectedCombos: {},
        currentMethod: 'Tiền mặt',
        ticketTotal: 0,
        comboTotal: 0,
        discount: 0,
        grandTotal: 0,
        customer: null,
        maSuat: ${selectedSuat != null ? selectedSuat.maSuat : 1}
    };

    document.addEventListener('DOMContentLoaded', function () {
        loadDataFromSession();
        updateTotals();
        updateVietQr();

        // Phím tắt F9 để thanh toán
        document.addEventListener('keydown', function (e) {
            if (e.key === 'F9') {
                e.preventDefault();
                executeCheckout();
            }
        });
    });

    function loadDataFromSession() {
        try {
            const seatsStr = sessionStorage.getItem('pos_selected_seats');
            if (seatsStr) {
                CHECKOUT_STATE.selectedSeats = JSON.parse(seatsStr);
            }
            const combosStr = sessionStorage.getItem('pos_selected_combos');
            if (combosStr) {
                CHECKOUT_STATE.selectedCombos = JSON.parse(combosStr);
            }
        } catch (e) {
            console.error(e);
        }

        renderSeatsSummary();
        renderCombosSummary();
    }

    function renderSeatsSummary() {
        const container = document.getElementById('seatsSummaryContainer');
        const txtCount = document.getElementById('txtSeatCount');
        const txtSubtotal = document.getElementById('txtSeatSubtotal');

        if (CHECKOUT_STATE.selectedSeats.length === 0) {
            container.innerHTML = '<div style="color:#94a3b8; font-size:13px; font-style:italic;">Chưa chọn ghế ngồi nào</div>';
            txtCount.textContent = '0';
            txtSubtotal.textContent = '0 đ';
            CHECKOUT_STATE.ticketTotal = 0;
            return;
        }

        let html = '';
        let total = 0;
        txtCount.textContent = CHECKOUT_STATE.selectedSeats.length;

        CHECKOUT_STATE.selectedSeats.forEach(s => {
            const price = parseFloat(s.gia) || 0;
            total += price;
            html += `
                <div class="item-list-row">
                    <div>
                        <span class="seat-tag">\${s.tenGhe}</span>
                        <span style="color:#64748b; font-size:12px;">\${s.loaiGhe || 'Ghế thường'}</span>
                    </div>
                    <strong>\${formatVND(price)}</strong>
                </div>
            `;
        });

        container.innerHTML = html;
        txtSubtotal.textContent = formatVND(total);
        CHECKOUT_STATE.ticketTotal = total;
    }

    function renderCombosSummary() {
        const container = document.getElementById('combosSummaryContainer');
        const txtSubtotal = document.getElementById('txtComboSubtotal');
        const comboKeys = Object.keys(CHECKOUT_STATE.selectedCombos);

        if (comboKeys.length === 0) {
            container.innerHTML = '<div style="color:#94a3b8; font-size:13px; font-style:italic;">Chưa chọn combo bắp nước</div>';
            txtSubtotal.textContent = '0 đ';
            CHECKOUT_STATE.comboTotal = 0;
            return;
        }

        let html = '';
        let total = 0;

        comboKeys.forEach(k => {
            const c = CHECKOUT_STATE.selectedCombos[k];
            const sub = c.gia * c.soLuong;
            total += sub;
            html += `
                <div class="item-list-row">
                    <div>
                        <strong>\${c.soLuong}x</strong> \${c.tenCombo}
                    </div>
                    <strong>\${formatVND(sub)}</strong>
                </div>
            `;
        });

        container.innerHTML = html;
        txtSubtotal.textContent = formatVND(total);
        CHECKOUT_STATE.comboTotal = total;
    }

    function updateTotals() {
        const rawTotal = CHECKOUT_STATE.ticketTotal + CHECKOUT_STATE.comboTotal;
        CHECKOUT_STATE.grandTotal = Math.max(0, rawTotal - CHECKOUT_STATE.discount);

        document.getElementById('sumTicket').textContent = formatVND(CHECKOUT_STATE.ticketTotal);
        document.getElementById('sumCombo').textContent = formatVND(CHECKOUT_STATE.comboTotal);
        document.getElementById('sumGrandTotal').textContent = formatVND(CHECKOUT_STATE.grandTotal);

        const discountRow = document.getElementById('discountRow');
        if (CHECKOUT_STATE.discount > 0) {
            discountRow.style.display = 'flex';
            document.getElementById('sumDiscount').textContent = '-' + formatVND(CHECKOUT_STATE.discount);
        } else {
            discountRow.style.display = 'none';
        }

        if (!document.getElementById('inputCashGiven').value) {
            setExactCash();
        } else {
            calculateChange();
        }
        updateVietQr();
    }

    function switchPayTab(method) {
        document.querySelectorAll('.pay-tab-btn').forEach(btn => btn.classList.remove('active'));
        document.querySelectorAll('.pay-tab-content').forEach(c => c.classList.remove('active'));

        if (method === 'cash') {
            document.querySelector('.pay-tab-btn:nth-child(1)').classList.add('active');
            document.getElementById('tabContent_cash').classList.add('active');
            CHECKOUT_STATE.currentMethod = 'Tiền mặt';
        } else if (method === 'vietqr') {
            document.querySelector('.pay-tab-btn:nth-child(2)').classList.add('active');
            document.getElementById('tabContent_vietqr').classList.add('active');
            CHECKOUT_STATE.currentMethod = 'Chuyển khoản (VietQR)';
            updateVietQr();
        } else if (method === 'card') {
            document.querySelector('.pay-tab-btn:nth-child(3)').classList.add('active');
            document.getElementById('tabContent_card').classList.add('active');
            CHECKOUT_STATE.currentMethod = 'Thẻ ngân hàng';
        }
    }

    function handleCashInput(val) {
        calculateChange();
    }

    function setCashAmount(amt) {
        document.getElementById('inputCashGiven').value = new Intl.NumberFormat('vi-VN').format(amt);
        calculateChange();
    }

    function setExactCash() {
        setCashAmount(CHECKOUT_STATE.grandTotal);
    }

    function calculateChange() {
        const inputVal = document.getElementById('inputCashGiven').value.replace(/[^0-9]/g, '');
        const given = parseFloat(inputVal) || 0;
        const change = given - CHECKOUT_STATE.grandTotal;

        const el = document.getElementById('txtChangeReturn');
        if (change >= 0) {
            el.textContent = formatVND(change);
            el.style.color = '#16a34a';
        } else {
            el.textContent = 'Còn thiếu ' + formatVND(Math.abs(change));
            el.style.color = '#dc2626';
        }
    }

    function updateVietQr() {
        const amt = CHECKOUT_STATE.grandTotal;
        const memo = 'CINEMAX ' + CHECKOUT_STATE.maSuat;
        const qrUrl = 'https://api.vietqr.io/image/970422-0912345678-compact.png?amount=' + amt + '&addInfo=' + encodeURIComponent(memo) + '&accountName=RAP%20PHIM%20CINEMAX';
        const img = document.getElementById('vietQrImg');
        if (img) img.src = qrUrl;
        const memoEl = document.getElementById('txtQrMemo');
        if (memoEl) memoEl.textContent = memo;
    }

    function handlePhoneLookup(phone) {
        if (phone && phone.trim().length >= 10) {
            triggerCustomerLookup();
        }
    }

    function triggerCustomerLookup() {
        const phone = document.getElementById('memberPhone').value.trim();
        if (!phone) return;

        fetch('${pageContext.request.contextPath}/thanh-toan?action=checkCustomer&sdt=' + encodeURIComponent(phone))
            .then(res => res.json())
            .then(data => {
                const resCard = document.getElementById('memberResultCard');
                const newBox = document.getElementById('newMemberBox');

                if (data.found) {
                    CHECKOUT_STATE.customer = data;
                    document.getElementById('memberFoundName').textContent = data.hoTen;
                    document.getElementById('memberFoundPoints').textContent = data.diemTichLuy;
                    resCard.style.display = 'block';
                    newBox.style.display = 'none';
                } else {
                    CHECKOUT_STATE.customer = null;
                    resCard.style.display = 'none';
                    newBox.style.display = 'block';
                }
            })
            .catch(console.error);
    }

    function toggleUsePoints(use) {
        if (!use || !CHECKOUT_STATE.customer) {
            CHECKOUT_STATE.discount = 0;
        } else {
            // 1 điểm = 1.000 đ, tối đa 50% đơn hàng
            const maxAllowed = (CHECKOUT_STATE.ticketTotal + CHECKOUT_STATE.comboTotal) * 0.5;
            const pointValue = (CHECKOUT_STATE.customer.diemTichLuy || 0) * 1000;
            CHECKOUT_STATE.discount = Math.min(maxAllowed, pointValue);
        }
        updateTotals();
    }

    function executeCheckout() {
        if (CHECKOUT_STATE.selectedSeats.length === 0) {
            alert('Vui lòng chọn ít nhất 1 ghế ngồi để thanh toán!');
            return;
        }

        // Kiểm tra tiền khách đưa nếu là tiền mặt
        if (CHECKOUT_STATE.currentMethod === 'Tiền mặt') {
            const inputVal = document.getElementById('inputCashGiven').value.replace(/[^0-9]/g, '');
            let given = parseFloat(inputVal) || 0;
            if (given === 0) {
                setExactCash();
                given = CHECKOUT_STATE.grandTotal;
            }
            if (given < CHECKOUT_STATE.grandTotal) {
                alert('Số tiền khách đưa chưa đủ để thanh toán!');
                document.getElementById('inputCashGiven').focus();
                return;
            }
        }

        const phone = document.getElementById('memberPhone').value.trim();
        const newName = document.getElementById('newMemberName') ? document.getElementById('newMemberName').value.trim() : '';
        const hoTen = (CHECKOUT_STATE.customer && CHECKOUT_STATE.customer.hoTen) ? CHECKOUT_STATE.customer.hoTen : newName;

        const payload = {
            maSuat: CHECKOUT_STATE.maSuat,
            sdt: phone,
            hoTen: hoTen,
            phuongThuc: CHECKOUT_STATE.currentMethod,
            tongTien: CHECKOUT_STATE.grandTotal,
            tienGiam: CHECKOUT_STATE.discount,
            seatsData: JSON.stringify(CHECKOUT_STATE.selectedSeats),
            combosData: JSON.stringify(Object.values(CHECKOUT_STATE.selectedCombos))
        };

        const btn = document.querySelector('.btn-checkout-submit');
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang xử lý giao dịch...';

        fetch('${pageContext.request.contextPath}/thanh-toan', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json;charset=UTF-8' },
            body: JSON.stringify(payload)
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                // Xóa giỏ hàng
                sessionStorage.removeItem('pos_selected_seats');
                sessionStorage.removeItem('pos_selected_combos');
                // Chuyển tới trang xem phiếu in
                window.location.href = data.redirectUrl;
            } else {
                alert(data.message || 'Thanh toán thất bại!');
                btn.disabled = false;
                btn.innerHTML = '<i class="fa-solid fa-check"></i> XÁC NHẬN THANH TOÁN & IN VÉ (F9)';
            }
        })
        .catch(err => {
            console.error(err);
            alert('Lỗi kết nối tới máy chủ!');
            btn.disabled = false;
            btn.innerHTML = '<i class="fa-solid fa-check"></i> XÁC NHẬN THANH TOÁN & IN VÉ (F9)';
        });
    }

    function clearCartSession() {
        sessionStorage.removeItem('pos_selected_seats');
        sessionStorage.removeItem('pos_selected_combos');
    }

    function formatVND(num) {
        return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(num);
    }
</script>
</body>
</html>
