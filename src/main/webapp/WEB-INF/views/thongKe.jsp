<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Tổng quan · CINEMAX</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cinema-theme.css?v=8">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/thongKe.css?v=1">
    </head>
    <body>
        <div class="app-shell thong-ke">
            <%-- 1. MENU ĐIỀU HƯỚNG --%>
            <aside class="sidebar" id="sidebar">
                <div class="sidebar-brand">
                    <div class="brand-text">
                        <h1>Rạp Chiếu Phim CINEMAX</h1>
                        <span>Quản lý</span>
                    </div>
                </div>
                <nav class="sidebar-menu">
                    <div class="menu-group-label">Menu chức năng</div>
                    <%-- [Ghi chú - Khánh]: Thống kê kinh doanh hiển thị tại mục Tổng quan --%>
                    <a href="${pageContext.request.contextPath}/thong-ke" class="nav-item active" aria-current="page">
                        <span>Tổng quan</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/ban-ve" class="nav-item"><span>Bán vé tại quầy (POS)</span></a>
                    <a href="${pageContext.request.contextPath}/hoa-don" class="nav-item"><span>Quản lí hóa đơn</span></a>
                    <div class="nav-group">
                        <button type="button" class="nav-item nav-parent" onclick="toggleSubmenu(this)">
                            <span>Quản lí phim</span>
                            <span class="nav-arrow">▾</span>
                        </button>
                        <div class="nav-submenu">
                            <a href="${pageContext.request.contextPath}/phim/view" class="nav-subitem">Danh sách phim</a>
                            <a href="${pageContext.request.contextPath}/the-loai/view" class="nav-subitem">Quản lí thể loại</a>
                        </div>
                    </div>
                    <div class="nav-group">
                        <button type="button" class="nav-item nav-parent" onclick="toggleSubmenu(this)">
                            <span>Phòng ghế</span>
                            <span class="nav-arrow">▾</span>
                        </button>
                        <div class="nav-submenu">
                            <a href="${pageContext.request.contextPath}/phong-chieu/view" class="nav-subitem">Danh sách phòng chiếu</a>
                            <a href="${pageContext.request.contextPath}/ghe" class="nav-subitem">Sơ đồ & Quản lý ghế</a>
                        </div>
                    </div>
                    <a href="${pageContext.request.contextPath}/suat-chieu/view" class="nav-item">
                        <span>Quản lý lịch chiếu</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/quan-ly-san-pham" class="nav-item">
                        <span>Quản lí sản phẩm</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/quan-ly-combo" class="nav-item">
                        <span>Quản lí combo</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/khach-hang/view" class="nav-item">
                        <span>Quản lí khách hàng</span>
                    </a>
                </nav>
                <div class="sidebar-footer">
                    <div class="user-card">
                        <div class="user-avatar">QL</div>
                        <div class="user-info">
                            <div class="name">
                                <c:out value="${sessionScope.userName}" default="Quản lý rạp"/>
                            </div>
                            <div class="role">Quản lý</div>
                        </div>
                    </div>
                    <a href="<%= request.getContextPath() %>/logout" class="role-switch-link" style="color: #ff4757; margin-top: 8px;">Đăng xuất</a>
                </div>
            </aside>
            <div class="main-wrapper">
                <header class="topbar">
                    <div class="topbar-left">
                        <button class="mobile-menu-btn" type="button" onclick="toggleSidebar()" aria-label="Mở menu">☰</button>
                        <strong>Tổng quan</strong>
                    </div>
                    <a class="btn btn-ghost" href="${pageContext.request.contextPath}/thong-ke">Làm mới</a>
                </header>
                <main class="content-area">
                    <%-- 2. TIÊU ĐỀ BÁO CÁO --%>
                    <section class="tk-hero">
                        <div>
                            <span class="tk-eyebrow">CINEMAX / BÁO CÁO KINH DOANH</span>
                            <h1>Nhìn lại hiệu quả của rạp.</h1>
                            <p>Doanh thu, lượt vé và bắp nước trong một góc nhìn.</p>
                        </div>
                        <span class="tk-status">● Hóa đơn hoàn tất · Đã thanh toán</span>
                    </section>
                    <%-- THỐNG KÊ: bộ lọc dùng GET; server kiểm tra ngày và giới hạn khoảng xem. --%>
                    <section class="card tk-filter">
                        <form method="get" action="${pageContext.request.contextPath}/thong-ke">
                            <%-- [TK-GIAODIEN] Server quyết định khoảng ngày thật; JS chỉ đổi ô nhập. --%>
                            <div class="form-group">
                                <label for="tkMode">Thống kê theo</label>
                                <select class="form-control" id="tkMode" name="mode" onchange="doiCheDoThongKe()">
                                    <option value="day" ${mode == 'day' ? 'selected' : ''}>Ngày</option>
                                    <option value="month" ${mode == 'month' ? 'selected' : ''}>Tháng</option>
                                    <option value="year" ${mode == 'year' ? 'selected' : ''}>Năm</option>
                                </select>
                            </div>
                            <div class="form-group" data-mode="month">
                                <label for="tkYear">Năm cần xem (12 tháng)</label>
                                <input class="form-control" type="number" id="tkYear" name="year" min="1900" max="9998" value="${selectedYear}" required>
                            </div>
                            <div class="form-group" data-mode="year">
                                <label for="tkStartYear">Từ năm</label>
                                <input class="form-control" type="number" id="tkStartYear" name="startYear" min="1900" max="9998" value="${startYear}" required>
                            </div>
                            <div class="form-group" data-mode="year">
                                <label for="tkEndYear">Đến năm</label>
                                <input class="form-control" type="number" id="tkEndYear" name="endYear" min="1900" max="9998" value="${endYear}" required>
                            </div>
                            <div class="form-group" data-mode="day">
                                <label for="tkFrom">Từ ngày</label>
                                <input class="form-control" type="date" id="tkFrom" name="from" value="${from}" required>
                            </div>
                            <div class="form-group" data-mode="day">
                                <label for="tkTo">Đến ngày</label>
                                <input class="form-control" type="date" id="tkTo" name="to" value="${to}" required>
                            </div>
                            <button class="btn btn-pink" type="submit">Xem thống kê</button>
                        </form>
                        <div class="tk-shortcuts">
                            <a href="?from=${today}&amp;to=${today}">Hôm nay</a>
                            <a href="?from=${weekStart}&amp;to=${today}">7 ngày qua</a>
                            <a href="?from=${monthStart}&amp;to=${today}">Tháng này</a>
                            <a href="?from=${previousStart}&amp;to=${previousEnd}">Tháng trước</a>
                            <a href="?mode=month">Năm nay (12 tháng)</a>
                            <a href="?mode=year">5 năm gần đây</a>
                            <span>Theo ngày: tối đa 366 ngày · Theo tháng: 12 tháng · Theo năm: tối đa 10 năm</span>
                        </div>
                    </section>
                    <c:choose>
                        <c:when test="${not empty error}">
                            <section class="tk-message tk-error" role="alert">
                                <strong>Chưa thể hiển thị báo cáo</strong>
                                <p>
                                    <c:out value="${error}"/>
                                </p>
                            </section>
                        </c:when>
                        <c:otherwise>
                            <%-- TongTien là số tiền sau giảm; không trừ TienGiam lần thứ hai. --%>
                            <%-- 3. BỐN CHỈ SỐ TỔNG QUAN --%>
                            <section class="tk-kpis">
                                <article class="tk-kpi tk-primary">
                                    <span>DOANH THU SAU GIẢM</span>
                                    <h2>
                                        <fmt:formatNumber value="${report.revenue}" pattern="#,##0"/>
                                        <small>đ</small>
                                    </h2>
                                    <p>Theo ngày lập hóa đơn</p>
                                </article>
                                <article class="tk-kpi">
                                    <span>HÓA ĐƠN HOÀN TẤT</span>
                                    <h2>
                                        <fmt:formatNumber value="${report.invoices}" pattern="#,##0"/>
                                    </h2>
                                    <p>Đã thanh toán thành công</p>
                                </article>
                                <article class="tk-kpi">
                                    <span>VÉ ĐÃ BÁN</span>
                                    <h2>
                                        <fmt:formatNumber value="${report.tickets}" pattern="#,##0"/>
                                    </h2>
                                    <p>Không gồm vé hủy / hoàn</p>
                                </article>
                                <article class="tk-kpi">
                                    <span>SẢN PHẨM &amp; COMBO</span>
                                    <h2>
                                        <fmt:formatNumber value="${report.items}" pattern="#,##0"/>
                                    </h2>
                                    <p>Một combo là một đơn vị bán</p>
                                </article>
                            </section>
                            <c:if test="${report.invoices == 0}">
                                <section class="tk-message">
                                    <strong>Chưa có giao dịch trong khoảng ngày này</strong>
                                    <p>Hãy chọn khoảng ngày khác. Báo cáo có dữ liệu khi hóa đơn hoàn tất và thanh toán thành công.</p>
                                </section>
                            </c:if>
                            <c:if test="${report.mismatches > 0}">
                                <section class="tk-message tk-warning">
                                    <strong>Cần đối chiếu <c:out value="${report.mismatches}"/> hóa đơn</strong>
                                    <p>Tổng tiền sau giảm + tiền giảm chưa khớp giá trị vé và bắp nước. Báo cáo giữ nguyên tổng tiền đã lưu trên hóa đơn.</p>
                                </section>
                            </c:if>
                            <%-- 4. BIỂU ĐỒ THEO NGÀY VÀ CƠ CẤU GIÁ TRỊ BÁN --%>
                            <section class="tk-overview">
                                <article class="card tk-chart-card">
                                    <div class="tk-heading">
                                        <div>
                                            <span class="tk-eyebrow">DIỄN BIẾN KINH DOANH</span>
                                            <h2>Doanh thu theo ${periodName}</h2>
                                        </div>
                                        <span class="tk-legend">● Sau giảm giá</span>
                                    </div>
                                    <p class="tk-muted">Từ ${from} đến ${to} · Đơn vị: VNĐ</p>
                                    <div class="tk-chart-scroll" tabindex="0" aria-label="Biểu đồ doanh thu. Cuộn ngang để xem thêm; số liệu ở bảng bên dưới.">
                                        <div class="tk-chart">
                                            <c:forEach items="${report.days}" var="day">
                                                <fmt:formatNumber value="${day.revenue}" pattern="#,##0" var="dayMoney"/>
                                                <div class="tk-column" title="${day.date}: ${dayMoney} đ">
                                                    <div class="tk-bar-track">
                                                        <div class="tk-bar" style="height:${day.height}%">
                                                        </div>
                                                    </div>
                                                    <span>${day.label}</span>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </article>
                                <article class="card tk-summary">
                                    <span class="tk-eyebrow">CHI TIẾT GIÁ TRỊ BÁN</span>
                                    <h2>Cơ cấu giao dịch</h2>
                                    <dl>
                                        <div>
                                            <dt>Giá trị vé</dt>
                                            <dd>
                                                <fmt:formatNumber value="${report.ticketValue}" pattern="#,##0"/> đ</dd>
                                        </div>
                                        <div>
                                            <dt>Giá trị bắp nước</dt>
                                            <dd>
                                                <fmt:formatNumber value="${report.productValue}" pattern="#,##0"/> đ</dd>
                                        </div>
                                        <div>
                                            <dt>Giảm giá hóa đơn</dt>
                                            <dd>
                                                <fmt:formatNumber value="${report.discount}" pattern="#,##0"/> đ</dd>
                                        </div>
                                        <div class="tk-average">
                                            <dt>Trung bình / hóa đơn</dt>
                                            <dd>
                                                <fmt:formatNumber value="${report.average}" pattern="#,##0"/> đ</dd>
                                        </div>
                                    </dl>
                                    <p class="tk-muted">Giá trị vé và bắp nước tính theo đơn giá lúc bán, trước giảm giá hóa đơn. Không cộng thêm các khoản này vào doanh thu.</p>
                                </article>
                            </section>
                            <%-- 5. BẢNG TOP PHIM VÀ SẢN PHẨM/COMBO --%>
                            <section class="tk-rankings">
                                <article class="card tk-ranking">
                                    <div class="tk-heading">
                                        <div>
                                            <span class="tk-eyebrow">TOP 10 · GIÁ TRỊ TRƯỚC GIẢM HÓA ĐƠN</span>
                                            <h2>Phim theo suất chiếu hiện tại</h2>
                                            <%-- Chưa có dữ liệu phim chốt lúc bán vé: không gọi đây là lịch sử phim. --%>
                                            <p class="tk-muted">Nếu suất chiếu đã đổi phim, vé cũ sẽ được nhóm theo phim hiện đang gắn với suất đó.</p>
                                        </div>
                                    </div>
                                    <div class="table-wrap">
                                        <table>
                                            <thead>
                                                <tr>
                                                    <th>#</th>
                                                    <th>Phim</th>
                                                    <th>Số lượng</th>
                                                    <th>Giá trị bán</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach items="${report.films}" var="row" varStatus="st">
                                                    <tr>
                                                        <td>
                                                            <span class="tk-rank">${st.count}</span>
                                                        </td>
                                                        <td>
                                                            <strong>
                                                                <c:out value="${row.name}"/>
                                                            </strong>
                                                            <small class="tk-type">
                                                                <c:out value="${row.type}"/>
                                                            </small>
                                                        </td>
                                                        <td>
                                                            <fmt:formatNumber value="${row.quantity}" pattern="#,##0"/>
                                                        </td>
                                                        <td>
                                                            <fmt:formatNumber value="${row.value}" pattern="#,##0"/> đ</td>
                                                    </tr>
                                                </c:forEach>
                                                <c:if test="${empty report.films}">
                                                    <tr>
                                                        <td colspan="4" class="tk-no-rows">Chưa có dữ liệu trong khoảng ngày đã chọn.</td>
                                                    </tr>
                                                </c:if>
                                            </tbody>
                                        </table>
                                    </div>
                                </article>
                                <article class="card tk-ranking">
                                    <div class="tk-heading">
                                        <div>
                                            <span class="tk-eyebrow">TOP 10 · GIÁ TRỊ TRƯỚC GIẢM HÓA ĐƠN</span>
                                            <h2>Bắp nước bán chạy</h2>
                                        </div>
                                    </div>
                                    <div class="table-wrap">
                                        <table>
                                            <thead>
                                                <tr>
                                                    <th>#</th>
                                                    <th>Sản phẩm / Combo</th>
                                                    <th>Số lượng</th>
                                                    <th>Giá trị bán</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach items="${report.products}" var="row" varStatus="st">
                                                    <tr>
                                                        <td>
                                                            <span class="tk-rank">${st.count}</span>
                                                        </td>
                                                        <td>
                                                            <strong>
                                                                <c:out value="${row.name}"/>
                                                            </strong>
                                                            <small class="tk-type">
                                                                <c:out value="${row.type}"/>
                                                            </small>
                                                        </td>
                                                        <td>
                                                            <fmt:formatNumber value="${row.quantity}" pattern="#,##0"/>
                                                        </td>
                                                        <td>
                                                            <fmt:formatNumber value="${row.value}" pattern="#,##0"/> đ</td>
                                                    </tr>
                                                </c:forEach>
                                                <c:if test="${empty report.products}">
                                                    <tr>
                                                        <td colspan="4" class="tk-no-rows">Chưa có dữ liệu trong khoảng ngày đã chọn.</td>
                                                    </tr>
                                                </c:if>
                                            </tbody>
                                        </table>
                                    </div>
                                </article>
                            </section>
                            <%-- 6. BẢNG CHI TIẾT DÙNG ĐỂ ĐỐI CHIẾU --%>
                            <section class="card tk-daily">
                                <div class="tk-heading">
                                    <div>
                                        <span class="tk-eyebrow">ĐỐI CHIẾU SỐ LIỆU</span>
                                        <h2>Chi tiết từng ${periodName}</h2>
                                    </div>
                                    <span class="tk-muted">Gồm cả kỳ không phát sinh</span>
                                </div>
                                <div class="table-wrap tk-table-scroll">
                                    <table>
                                        <thead>
                                            <tr>
                                                <th>Kỳ thống kê</th>
                                                <th>Hóa đơn</th>
                                                <th>Vé</th>
                                                <th>SP / Combo</th>
                                                <th>Giảm giá</th>
                                                <th>Doanh thu sau giảm</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach items="${report.days}" var="day">
                                                <tr>
                                                    <td>${day.date}</td>
                                                    <td>${day.invoices}</td>
                                                    <td>${day.tickets}</td>
                                                    <td>${day.items}</td>
                                                    <td>
                                                        <fmt:formatNumber value="${day.discount}" pattern="#,##0"/> đ</td>
                                                    <td>
                                                        <strong>
                                                            <fmt:formatNumber value="${day.revenue}" pattern="#,##0"/> đ</strong>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                        <tfoot>
                                            <tr>
                                                <th>Tổng cộng</th>
                                                <th>${report.invoices}</th>
                                                <th>${report.tickets}</th>
                                                <th>${report.items}</th>
                                                <th>
                                                    <fmt:formatNumber value="${report.discount}" pattern="#,##0"/> đ</th>
                                                <th>
                                                    <fmt:formatNumber value="${report.revenue}" pattern="#,##0"/> đ</th>
                                            </tr>
                                        </tfoot>
                                    </table>
                                </div>
                            </section>
                            <p class="tk-footnote">Số liệu được đọc khi mở báo cáo; nếu đang có giao dịch mới, hãy tải lại trước khi đối chiếu tổng quan với bảng xếp hạng. Báo cáo chưa đối soát hoàn tiền. Phạm vi: ngày lập hóa đơn theo giờ Việt Nam. Chỉ tính hóa đơn “Đã hoàn tất” có thanh toán “Thành công”; vé hợp lệ gồm “Chưa in”, “Đã in”, “Đã soát vé”.</p>
                        </c:otherwise>
                    </c:choose>
                </main>
            </div>
        </div>
<script>
    // [TK-DOICHE DO] Chỉ gửi các ô thuộc chế độ đang chọn, tránh required ở ô ẩn.
    function doiCheDoThongKe() {
        var mode = document.getElementById('tkMode').value;
        var groups = document.querySelectorAll('[data-mode]');
        for (var i = 0; i < groups.length; i++) {
            var active = groups[i].getAttribute('data-mode') === mode;
            groups[i].hidden = !active;
            groups[i].style.display = active ? '' : 'none';
            var inputs = groups[i].querySelectorAll('input');
            for (var j = 0; j < inputs.length; j++) inputs[j].disabled = !active;
        }
    }
    doiCheDoThongKe();
    // Menu dùng riêng tại trang này, giữ nguyên mã menu của các module khác.
    function toggleSidebar() {
        document.getElementById('sidebar').classList.toggle('open');
    }
    function toggleSubmenu(button) {
        button.closest('.nav-group').classList.toggle('open');
    }
</script>
</body></html>
