<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Soát Vé (Check-in) - Rạp Chiếu Phim CINEMAX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=12">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Thư viện quét mã QR bằng camera html5-qrcode -->
    <script src="https://unpkg.com/html5-qrcode" type="text/javascript"></script>
    <style>
        .checkin-layout {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
            margin-bottom: 24px;
        }
        @media (max-width: 992px) {
            .checkin-layout {
                grid-template-columns: 1fr;
            }
        }
        .scan-card {
            background: #ffffff;
            border-radius: var(--radius-md);
            padding: 24px;
            border: 1px solid var(--border-subtle);
            box-shadow: 0 1px 4px rgba(0,0,0,0.04);
        }
        .card-title {
            font-size: 15px;
            font-weight: 700;
            color: var(--text-primary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .scan-input-group {
            display: flex;
            gap: 10px;
            margin-bottom: 14px;
        }
        .scan-input {
            flex: 1;
            height: 48px;
            padding: 0 16px;
            font-size: 16px;
            font-weight: 600;
            border: 2px solid var(--pink);
            border-radius: 10px;
            outline: none;
            background: #fff;
            color: #0f172a;
            box-shadow: 0 0 0 3px rgba(225, 29, 72, 0.1);
        }
        .scan-input:focus {
            box-shadow: 0 0 0 4px rgba(225, 29, 72, 0.2);
        }
        .scan-btn {
            height: 48px;
            padding: 0 20px;
            font-size: 14px;
            font-weight: 700;
            background: #e11d48;
            color: #ffffff;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
        }
        .scan-btn:hover {
            background: #be123c;
        }

        /* KHUNG HIỂN THỊ KẾT QUẢ SOÁT VÉ */
        .result-box {
            border-radius: 16px;
            padding: 24px;
            text-align: center;
            border: 2px dashed #cbd5e1;
            background: #f8fafc;
            min-height: 280px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            transition: all 0.3s ease;
        }
        .result-box.state-ready {
            border-color: #cbd5e1;
            background: #f8fafc;
            color: #64748b;
        }
        .result-box.state-success {
            border-color: #16a34a;
            border-style: solid;
            background: #f0fdf4;
            color: #14532d;
        }
        .result-box.state-warning {
            border-color: #dc2626;
            border-style: solid;
            background: #fef2f2;
            color: #991b1b;
        }
        .result-box.state-amber {
            border-color: #d97706;
            border-style: solid;
            background: #fffbeb;
            color: #92400e;
        }

        .badge-status-lg {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 18px;
            border-radius: 30px;
            font-size: 15px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 16px;
        }
        .badge-success-lg { background: #dcfce7; color: #15803d; border: 1px solid #86efac; }
        .badge-danger-lg { background: #fee2e2; color: #b91c1c; border: 1px solid #fca5a5; }
        .badge-warning-lg { background: #fef3c7; color: #b45309; border: 1px solid #fde68a; }

        .ticket-highlight-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 16px 20px;
            width: 100%;
            text-align: left;
            margin-top: 14px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
            border: 1px solid rgba(0,0,0,0.06);
        }
        .highlight-title {
            font-size: 18px;
            font-weight: 800;
            color: #0f172a;
            margin-bottom: 6px;
        }
        .highlight-meta {
            font-size: 13px;
            color: #475569;
            margin-bottom: 4px;
        }
        .highlight-seat-badge {
            display: inline-block;
            font-size: 20px;
            font-weight: 800;
            color: #e11d48;
            background: #ffe4e6;
            padding: 4px 14px;
            border-radius: 8px;
            border: 1px solid #fecdd3;
        }

        /* BẢNG LỊCH SỬ */
        .log-table-panel {
            background: #ffffff;
            border-radius: var(--radius-md);
            padding: 20px;
            border: 1px solid var(--border-subtle);
            box-shadow: 0 1px 3px rgba(0,0,0,0.03);
        }
        .custom-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }
        .custom-table th {
            background: #f8fafc;
            padding: 12px 16px;
            font-size: 12px;
            font-weight: 700;
            color: var(--text-secondary);
            text-transform: uppercase;
            border-bottom: 1px solid var(--border-subtle);
        }
        .custom-table td {
            padding: 12px 16px;
            border-bottom: 1px solid var(--border-subtle);
            font-size: 13px;
            vertical-align: middle;
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
            <div>
                <h2 style="font-size:22px; font-weight:800; color:var(--text-primary); margin:0;">
                    <i class="fa-solid fa-qrcode" style="color:#e11d48; margin-right:8px;"></i> SOÁT VÉ VÀO PHÒNG CHIẾU (CHECK-IN)
                </h2>
                <span style="font-size:13px; color:var(--text-secondary);">
                    Quét mã QR / Barcode hoặc nhập mã vé để xác thực khách vào rạp
                </span>
            </div>
            <div style="font-size:13px; font-weight:700; color:#0f172a; background:#f1f5f9; padding:8px 16px; border-radius:20px; display:flex; align-items:center; gap:8px;">
                <i class="fa-solid fa-clock" style="color:#e11d48;"></i>
                <span id="liveClock">--:--:--</span>
            </div>
        </header>

        <!-- LAYOUT 2 CỘT -->
        <div class="checkin-layout">
            <!-- CỘT TRÁI: KHUNG QUÉT MÃ -->
            <div class="scan-card">
                <div class="card-title">
                    <span><i class="fa-solid fa-barcode" style="color:#e11d48; margin-right:6px;"></i> Quét vé hoặc nhập mã</span>
                    <span style="font-size:12px; font-weight:600; color:#16a34a;">
                        <i class="fa-solid fa-circle" style="font-size:8px;"></i> Máy quét tự động sẵn sàng
                    </span>
                </div>

                <div class="scan-input-group">
                    <input type="text" id="txtTicketCode" class="scan-input" autofocus
                           placeholder="Quét mã QR bằng máy quét hoặc gõ mã vé rồi ấn Enter..."
                           onkeydown="if(event.key === 'Enter') submitCheckIn();">
                    <button type="button" class="scan-btn" onclick="submitCheckIn()">
                        <i class="fa-solid fa-check"></i> Kiểm tra (Enter)
                    </button>
                </div>

                <div style="display:flex; justify-content:space-between; align-items:center; margin-top:10px;">
                    <button type="button" class="btn btn-outline btn-sm" id="btnToggleCamera" onclick="toggleCameraScanner()">
                        <i class="fa-solid fa-camera" style="margin-right:6px;"></i> Bật Camera quét QR
                    </button>
                    <button type="button" class="btn btn-ghost btn-sm" onclick="clearInput()">
                        <i class="fa-solid fa-eraser" style="margin-right:4px;"></i> Xóa ô nhập
                    </button>
                </div>

                <!-- KHUNG CAMERA QUÉT MÃ QR (ẨN MẶC ĐỊNH) -->
                <div id="qrScannerContainer" style="display:none; margin-top:16px; border-radius:12px; overflow:hidden; border:2px dashed #94a3b8; padding:10px; background:#0f172a;">
                    <div id="reader" style="width:100%;"></div>
                    <div style="text-align:center; margin-top:8px;">
                        <button type="button" class="btn btn-sm btn-ghost" style="color:#fff;" onclick="toggleCameraScanner()">
                            ✕ Đóng camera
                        </button>
                    </div>
                </div>

                <!-- HƯỚNG DẪN THAO TÁC -->
                <div style="margin-top:20px; padding:14px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:10px; font-size:12px; color:#64748b; line-height:1.6;">
                    <strong style="color:#334155; display:block; margin-bottom:4px;">
                        💡 MẸO DÀNH CHO NHÂN VIÊN SOÁT VÉ:
                    </strong>
                    • Máy quét mã vạch cầm tay (USB/Bluetooth) sẽ tự động điền mã và bấm Enter.<br>
                    • Bạn có thể gõ trực tiếp <strong>Mã vé</strong> (VD: 1, 15) hoặc <strong>Mã QR</strong> trên phiếu in.<br>
                    • Hệ thống tự động ngăn chặn vé bị quét 2 lần để tránh gian lận vào rạp.
                </div>
            </div>

            <!-- CỘT PHẢI: KẾT QUẢ SOÁT VÉ TRỰC QUAN -->
            <div class="scan-card">
                <div class="card-title">
                    <span><i class="fa-solid fa-shield-halved" style="color:#e11d48; margin-right:6px;"></i> Kết quả xác thực</span>
                    <span id="txtCheckInTime" style="font-size:12px; color:#64748b;">--:--:--</span>
                </div>

                <div class="result-box state-ready" id="resultBox">
                    <div id="resultIcon" style="font-size:48px; margin-bottom:12px; color:#94a3b8;">
                        <i class="fa-solid fa-ticket"></i>
                    </div>
                    <div class="badge-status-lg" id="resultBadge" style="display:none;"></div>
                    <div id="resultMessage" style="font-size:16px; font-weight:700; margin-bottom:6px;">
                        Sẵn sàng soát vé. Vui lòng đưa vé vào máy quét!
                    </div>
                    <div id="resultSub" style="font-size:13px; color:#64748b;">
                        Hệ thống sẽ kiểm tra trạng thái thanh toán và ngăn chặn vé dùng lại.
                    </div>

                    <!-- THÔNG TIN VÉ CHI TIẾT (KHI QUÉT THÀNH CÔNG) -->
                    <div class="ticket-highlight-card" id="ticketCard" style="display:none;">
                        <div class="highlight-title" id="hlMovie">Tên phim chiếu rạp</div>
                        <div class="highlight-meta">
                            Suất: <strong id="hlTime">--:--</strong> • <span id="hlDate">--/--/----</span> | Phòng: <strong id="hlRoom">Phòng 1</strong>
                        </div>
                        <div style="display:flex; justify-content:space-between; align-items:center; margin-top:10px; border-top:1px dashed #e2e8f0; padding-top:10px;">
                            <div>
                                <span style="font-size:12px; color:#64748b; display:block;">VỊ TRÍ GHẾ:</span>
                                <div class="highlight-seat-badge" id="hlSeat">A0</div>
                            </div>
                            <div style="text-align:right;">
                                <span style="font-size:12px; color:#64748b; display:block;">MÃ VÉ:</span>
                                <strong style="font-size:14px; color:#0f172a;" id="hlTicketId">#00</strong>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- BẢNG LỊCH SỬ SOÁT VÉ GẦN ĐÂY -->
        <div class="log-table-panel">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:14px;">
                <h3 style="font-size:15px; font-weight:700; color:var(--text-primary); margin:0; text-transform:uppercase;">
                    <i class="fa-solid fa-list-check" style="color:#e11d48; margin-right:6px;"></i> Danh sách vé vừa check-in gần nhất
                </h3>
                <span style="font-size:12px; color:#64748b;">Hiển thị 15 vé gần nhất trong ca trực</span>
            </div>

            <table class="custom-table">
                <thead>
                <tr>
                    <th style="width:90px;">Mã Vé</th>
                    <th>Tên Phim</th>
                    <th>Phòng Chiếu</th>
                    <th>Suất Chiếu</th>
                    <th>Ghế Ngồi</th>
                    <th>Mã QR</th>
                    <th>Trạng Thái</th>
                </tr>
                </thead>
                <tbody id="logTableBody">
                <c:choose>
                    <c:when test="${empty lichSuCheckIn}">
                        <tr id="emptyLogRow">
                            <td colspan="7" style="text-align:center; padding:30px; color:#94a3b8;">
                                <i class="fa-solid fa-inbox" style="font-size:24px; margin-bottom:8px; display:block;"></i>
                                Chưa có lượt check-in nào trong ca trực hôm nay.
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach items="${lichSuCheckIn}" var="v">
                            <tr>
                                <td>
                                    <span style="font-weight:700; color:#e11d48; background:#ffe4e6; padding:2px 8px; border-radius:6px;">
                                        #VE${v.maVe}
                                    </span>
                                </td>
                                <td><strong><c:out value="${v.tenPhim}"/></strong></td>
                                <td><c:out value="${v.tenPhong}"/></td>
                                <td><strong>${v.gioChieu}</strong> • ${v.ngayChieu}</td>
                                <td>
                                    <span style="display:inline-block; font-weight:800; color:#e11d48; background:#fff1f2; padding:2px 8px; border-radius:6px; border:1px solid #fecdd3;">
                                        ${v.tenGhe}
                                    </span>
                                </td>
                                <td style="font-family:monospace; font-size:11px; color:#64748b;">${v.maQR}</td>
                                <td>
                                    <span style="background:#dcfce7; color:#15803d; border:1px solid #86efac; font-size:11px; padding:3px 8px; border-radius:12px; font-weight:700;">
                                        ● Đã check-in
                                    </span>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </main>
</div>

<script>
    // Đồng hồ thời gian thực
    function updateClock() {
        const now = new Date();
        const timeStr = now.toLocaleTimeString('vi-VN');
        const el = document.getElementById('liveClock');
        if (el) el.textContent = timeStr;
    }
    setInterval(updateClock, 1000);
    updateClock();

    function clearInput() {
        const inp = document.getElementById('txtTicketCode');
        if (inp) {
            inp.value = '';
            inp.focus();
        }
    }

    // Gửi yêu cầu soát vé
    function submitCheckIn(codeParam) {
        const input = document.getElementById('txtTicketCode');
        const code = codeParam ? codeParam.trim() : (input ? input.value.trim() : '');

        if (!code) {
            alert('Vui lòng nhập hoặc quét mã vé!');
            if (input) input.focus();
            return;
        }

        const resultBox = document.getElementById('resultBox');
        const resultIcon = document.getElementById('resultIcon');
        const resultBadge = document.getElementById('resultBadge');
        const resultMessage = document.getElementById('resultMessage');
        const resultSub = document.getElementById('resultSub');
        const ticketCard = document.getElementById('ticketCard');

        // Hiển thị trạng thái đang kiểm tra
        resultBox.className = 'result-box state-ready';
        resultIcon.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i>';
        resultBadge.style.display = 'none';
        resultMessage.textContent = 'Đang tra cứu dữ liệu vé...';
        resultSub.textContent = 'Mã quét: ' + code;
        ticketCard.style.display = 'none';

        fetch('${pageContext.request.contextPath}/check-in', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
            body: 'code=' + encodeURIComponent(code)
        })
        .then(res => res.json())
        .then(data => {
            document.getElementById('txtCheckInTime').textContent = data.thoiGianCheckIn || '';

            if (data.success && data.statusCode === 'SUCCESS') {
                // 1. THÀNH CÔNG: Vé hợp lệ, cho vào phòng chiếu
                resultBox.className = 'result-box state-success';
                resultIcon.innerHTML = '<i class="fa-solid fa-circle-check" style="color:#16a34a;"></i>';
                resultBadge.className = 'badge-status-lg badge-success-lg';
                resultBadge.innerHTML = '<i class="fa-solid fa-check"></i> CHECK-IN HỢP LỆ';
                resultBadge.style.display = 'inline-flex';
                resultMessage.textContent = 'Xác thực thành công! Mời quý khách vào xem phim.';
                resultSub.textContent = data.message || '';

                if (data.ve) {
                    document.getElementById('hlMovie').textContent = data.ve.tenPhim || 'Phim chiếu rạp';
                    document.getElementById('hlTime').textContent = data.ve.gioChieu || '--:--';
                    document.getElementById('hlDate').textContent = data.ve.ngayChieu || '';
                    document.getElementById('hlRoom').textContent = data.ve.tenPhong || 'Phòng chiếu';
                    document.getElementById('hlSeat').textContent = data.ve.tenGhe || '--';
                    document.getElementById('hlTicketId').textContent = '#VE' + data.ve.maVe;
                    ticketCard.style.display = 'block';

                    // Thêm dòng mới vào đầu bảng nhật ký
                    prependLogRow(data.ve);
                }

                // Phát âm thanh thông báo thành công (Web Audio API)
                playSuccessSound();

            } else if (data.statusCode === 'ALREADY_CHECKED_IN') {
                // 2. CẢNH BÁO: Vé đã soát vé trước đó
                resultBox.className = 'result-box state-warning';
                resultIcon.innerHTML = '<i class="fa-solid fa-triangle-exclamation" style="color:#dc2626;"></i>';
                resultBadge.className = 'badge-status-lg badge-danger-lg';
                resultBadge.innerHTML = '<i class="fa-solid fa-triangle-exclamation"></i> VÉ ĐÃ ĐƯỢC CHECK-IN!';
                resultBadge.style.display = 'inline-flex';
                resultMessage.textContent = 'CẢNH BÁO: Vé này ĐÃ ĐƯỢC SOÁT VÉ trước đó!';
                resultSub.textContent = 'Vui lòng kiểm tra lại khách hàng, không được phép vào cửa lại.';

                if (data.ve) {
                    document.getElementById('hlMovie').textContent = data.ve.tenPhim || 'Phim chiếu rạp';
                    document.getElementById('hlTime').textContent = data.ve.gioChieu || '--:--';
                    document.getElementById('hlDate').textContent = data.ve.ngayChieu || '';
                    document.getElementById('hlRoom').textContent = data.ve.tenPhong || 'Phòng chiếu';
                    document.getElementById('hlSeat').textContent = data.ve.tenGhe || '--';
                    document.getElementById('hlTicketId').textContent = '#VE' + data.ve.maVe;
                    ticketCard.style.display = 'block';
                }

                playErrorSound();

            } else if (data.statusCode === 'NOT_PAID') {
                // 3. CHƯA THANH TOÁN
                resultBox.className = 'result-box state-amber';
                resultIcon.innerHTML = '<i class="fa-solid fa-hourglass-half" style="color:#d97706;"></i>';
                resultBadge.className = 'badge-status-lg badge-warning-lg';
                resultBadge.innerHTML = '<i class="fa-solid fa-clock"></i> ĐƠN CHƯA THANH TOÁN';
                resultBadge.style.display = 'inline-flex';
                resultMessage.textContent = 'Hóa đơn của vé này chưa được thanh toán!';
                resultSub.textContent = 'Khách cần hoàn tất thanh toán tại quầy thu ngân trước khi vào rạp.';

                if (data.ve) {
                    document.getElementById('hlMovie').textContent = data.ve.tenPhim || 'Phim chiếu rạp';
                    document.getElementById('hlTime').textContent = data.ve.gioChieu || '--:--';
                    document.getElementById('hlDate').textContent = data.ve.ngayChieu || '';
                    document.getElementById('hlRoom').textContent = data.ve.tenPhong || 'Phòng chiếu';
                    document.getElementById('hlSeat').textContent = data.ve.tenGhe || '--';
                    document.getElementById('hlTicketId').textContent = '#VE' + data.ve.maVe;
                    ticketCard.style.display = 'block';
                }

                playErrorSound();

            } else {
                // 4. LỖI KHÁC HOẶC KHÔNG TÌM THẤY VÉ
                resultBox.className = 'result-box state-warning';
                resultIcon.innerHTML = '<i class="fa-solid fa-circle-xmark" style="color:#dc2626;"></i>';
                resultBadge.className = 'badge-status-lg badge-danger-lg';
                resultBadge.innerHTML = '<i class="fa-solid fa-xmark"></i> VÉ KHÔNG HỢP LỆ';
                resultBadge.style.display = 'inline-flex';
                resultMessage.textContent = data.message || 'Không tìm thấy thông tin vé!';
                resultSub.textContent = 'Vui lòng kiểm tra lại mã vé hoặc mã QR trên phiếu in.';
                ticketCard.style.display = 'none';

                playErrorSound();
            }

            // Xóa và tự động focus lại ô nhập để sẵn sàng quét vé tiếp theo
            if (input) {
                input.value = '';
                input.focus();
            }
        })
        .catch(err => {
            console.error(err);
            resultBox.className = 'result-box state-warning';
            resultIcon.innerHTML = '<i class="fa-solid fa-triangle-exclamation" style="color:#dc2626;"></i>';
            resultMessage.textContent = 'Lỗi kết nối tới máy chủ!';
            resultSub.textContent = err.message;
            if (input) input.focus();
        });
    }

    // Thêm dòng mới vào đầu bảng log
    function prependLogRow(ve) {
        const tbody = document.getElementById('logTableBody');
        if (!tbody) return;

        const emptyRow = document.getElementById('emptyLogRow');
        if (emptyRow) emptyRow.remove();

        const tr = document.createElement('tr');
        tr.style.background = '#f0fdf4';
        tr.innerHTML = `
            <td>
                <span style="font-weight:700; color:#e11d48; background:#ffe4e6; padding:2px 8px; border-radius:6px;">
                    #VE\${ve.maVe}
                </span>
            </td>
            <td><strong>\${ve.tenPhim || ''}</strong></td>
            <td>\${ve.tenPhong || ''}</td>
            <td><strong>\${ve.gioChieu || ''}</strong> • \${ve.ngayChieu || ''}</td>
            <td>
                <span style="display:inline-block; font-weight:800; color:#e11d48; background:#fff1f2; padding:2px 8px; border-radius:6px; border:1px solid #fecdd3;">
                    \${ve.tenGhe || ''}
                </span>
            </td>
            <td style="font-family:monospace; font-size:11px; color:#64748b;">\${ve.maQR || ''}</td>
            <td>
                <span style="background:#dcfce7; color:#15803d; border:1px solid #86efac; font-size:11px; padding:3px 8px; border-radius:12px; font-weight:700;">
                    ● Đã check-in
                </span>
            </td>
        `;
        tbody.insertBefore(tr, tbody.firstChild);

        // Hiệu ứng mờ dần màu nền xanh sau 2 giây
        setTimeout(function() {
            tr.style.transition = 'background 1s ease';
            tr.style.background = '#ffffff';
        }, 2000);
    }

    // Phát âm thanh bip bíp thành công bằng Web Audio API thuần (không cần file mp3)
    function playSuccessSound() {
        try {
            const ctx = new (window.AudioContext || window.webkitAudioContext)();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.type = 'sine';
            osc.frequency.setValueAtTime(880, ctx.currentTime); // nốt A5
            gain.gain.setValueAtTime(0.1, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.2);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start();
            osc.stop(ctx.currentTime + 0.2);
        } catch (e) {}
    }

    function playErrorSound() {
        try {
            const ctx = new (window.AudioContext || window.webkitAudioContext)();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.type = 'sawtooth';
            osc.frequency.setValueAtTime(220, ctx.currentTime); // âm trầm cảnh báo
            gain.gain.setValueAtTime(0.15, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.35);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start();
            osc.stop(ctx.currentTime + 0.35);
        } catch (e) {}
    }

    // Camera QR Scanner với Html5Qrcode
    let html5QrCode = null;
    let isCameraActive = false;

    function toggleCameraScanner() {
        const container = document.getElementById('qrScannerContainer');
        const btn = document.getElementById('btnToggleCamera');

        if (!isCameraActive) {
            container.style.display = 'block';
            btn.innerHTML = '<i class="fa-solid fa-video-slash" style="margin-right:6px;"></i> Tắt Camera';

            if (!html5QrCode) {
                html5QrCode = new Html5Qrcode("reader");
            }

            html5QrCode.start(
                { facingMode: "environment" },
                {
                    fps: 10,
                    qrbox: { width: 250, height: 250 }
                },
                (decodedText, decodedResult) => {
                    // Quét thành công
                    submitCheckIn(decodedText);
                    // Dừng quét tạm thời 2 giây để tránh quét liên tục cùng 1 mã
                    if (html5QrCode) {
                        html5QrCode.pause();
                        setTimeout(() => {
                            if (html5QrCode && isCameraActive) html5QrCode.resume();
                        }, 2500);
                    }
                },
                (errorMessage) => {
                    // Đang quét...
                }
            ).catch(err => {
                alert('Không thể mở Camera: ' + err);
                container.style.display = 'none';
                btn.innerHTML = '<i class="fa-solid fa-camera" style="margin-right:6px;"></i> Bật Camera quét QR';
                isCameraActive = false;
            });

            isCameraActive = true;
        } else {
            if (html5QrCode) {
                html5QrCode.stop().then(() => {
                    container.style.display = 'none';
                    btn.innerHTML = '<i class="fa-solid fa-camera" style="margin-right:6px;"></i> Bật Camera quét QR';
                    isCameraActive = false;
                }).catch(err => {
                    container.style.display = 'none';
                    btn.innerHTML = '<i class="fa-solid fa-camera" style="margin-right:6px;"></i> Bật Camera quét QR';
                    isCameraActive = false;
                });
            } else {
                container.style.display = 'none';
                btn.innerHTML = '<i class="fa-solid fa-camera" style="margin-right:6px;"></i> Bật Camera quét QR';
                isCameraActive = false;
            }
        }
    }
</script>
</body>
</html>
