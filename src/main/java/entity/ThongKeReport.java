package entity;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

// DTO báo cáo, không phải bảng Hibernate và không thay đổi database.
// Tra cứu chức năng: docs/TRA_CUU_COMBO_SAN_PHAM_THONG_KE.txt
public class ThongKeReport {
    // 1. Danh sách dùng cho biểu đồ, bảng theo ngày và hai bảng xếp hạng.
    private final List<Day> days = new ArrayList<>();
    private final List<Ranking> films = new ArrayList<>();
    private final List<Ranking> products = new ArrayList<>();
    // 2. Tổng tiền dùng BigDecimal để không bị sai số khi cộng tiền.
    private BigDecimal revenue = BigDecimal.ZERO;
    private BigDecimal discount = BigDecimal.ZERO;
    private BigDecimal ticketValue = BigDecimal.ZERO;
    private BigDecimal productValue = BigDecimal.ZERO;
    private long invoices, tickets, items, mismatches;

    // [TK-CONG-TONG] Tổng doanh thu và các chỉ số trên đầu báo cáo được cộng ở đâu?
    // Mỗi lần addDay thêm một dòng, nó cộng các chỉ số của dòng đó vào tổng toàn kỳ.
    public void addDay(Day day) {
        days.add(day);
        revenue = revenue.add(day.revenue);
        discount = discount.add(day.discount);
        ticketValue = ticketValue.add(day.ticketValue);
        productValue = productValue.add(day.productValue);
        invoices += day.invoices;
        tickets += day.tickets;
        items += day.items;
        mismatches += day.mismatches;
    }
    public List<Day> getDays() { return days; }
    public List<Ranking> getFilms() { return films; }
    public List<Ranking> getProducts() { return products; }
    public BigDecimal getRevenue() { return revenue; }
    public BigDecimal getDiscount() { return discount; }
    public BigDecimal getTicketValue() { return ticketValue; }
    public BigDecimal getProductValue() { return productValue; }
    public long getInvoices() { return invoices; }
    public long getTickets() { return tickets; }
    public long getItems() { return items; }
    public long getMismatches() { return mismatches; }
    // [TK-TRUNG-BINH] Giá trị trung bình một hóa đơn tính ở đâu?
    // getAverage chia doanh thu cho số hóa đơn và làm tròn tới đồng. Nếu có 0 hóa đơn thì trả 0.
    public BigDecimal getAverage() {
        // Chưa có hóa đơn thì trả về 0, tránh chia cho 0.
        if (invoices == 0) {
            return BigDecimal.ZERO;
        }
        return revenue.divide(BigDecimal.valueOf(invoices), 0, RoundingMode.HALF_UP);
    }
    public boolean isEmpty() { return invoices == 0; }

    // [TK-NHOM] Sau khi SQL trả số liệu theo ngày, đoạn nào gom thành tháng hoặc năm?
    // groupBy dùng ngày đầu tháng hoặc ngày đầu năm làm khóa Map. Các dòng cùng khóa được cộng với nhau.
    // Chế độ ngày giữ nguyên báo cáo. Chế độ tháng/năm giữ bảng top của toàn kỳ và tính lại chiều cao cột.
    public ThongKeReport groupBy(String mode) {
        if ("day".equals(mode)) return this;
        if (!"month".equals(mode) && !"year".equals(mode))
            throw new IllegalArgumentException("Chế độ thống kê không hợp lệ.");
        java.util.Map<LocalDate, Day> groups = new java.util.LinkedHashMap<>();
        for (Day day : days) {
            LocalDate key = day.date.withDayOfMonth(1);
            if ("year".equals(mode)) key = key.withDayOfYear(1);
            Day old = groups.get(key);
            if (old == null) {
                old = Day.empty(key);
            }
            Day sum = congSoLieu(key, old, day);
            sum.mode = mode;
            groups.put(key, sum);
        }
        ThongKeReport result = new ThongKeReport();
        for (Day row : groups.values()) result.addDay(row);
        result.films.addAll(films);
        result.products.addAll(products);
        result.prepareChart();
        return result;
    }

    // [TK-CONG-NHOM] Các dòng có cùng tháng hoặc năm được cộng như thế nào?
    // congSoLieu cộng từng khoản tiền bằng BigDecimal và từng số đếm bằng long.
    private Day congSoLieu(LocalDate ngayDauKy, Day cu, Day moi) {
        BigDecimal doanhThu = cu.revenue.add(moi.revenue);
        BigDecimal giamGia = cu.discount.add(moi.discount);
        BigDecimal tienVe = cu.ticketValue.add(moi.ticketValue);
        BigDecimal tienMon = cu.productValue.add(moi.productValue);
        long soHoaDon = cu.invoices + moi.invoices;
        long soVe = cu.tickets + moi.tickets;
        long soMon = cu.items + moi.items;
        long soSaiLech = cu.mismatches + moi.mismatches;
        return new Day(ngayDauKy, doanhThu, giamGia, tienVe, tienMon,
                soHoaDon, soVe, soMon, soSaiLech);
    }

    // [TK-BIEU-DO] Đoạn nào quyết định chiều cao từng cột doanh thu?
    // prepareChart tìm kỳ có doanh thu cao nhất, rồi lấy doanh thu mỗi kỳ chia cho mức đó × 100.
    // Ví dụ kỳ cao nhất 200.000 đồng thì kỳ 100.000 đồng có cột cao 50%. Mức không dương có cột cao 0%.
    public void prepareChart() {
        // Bước 1: tìm doanh thu lớn nhất để làm cột cao 100%.
        BigDecimal maxRevenue = BigDecimal.ZERO;
        for (Day day : days) {
            if (day.revenue.compareTo(maxRevenue) > 0) {
                maxRevenue = day.revenue;
            }
        }

        // Bước 2: tính chiều cao từng cột theo tỷ lệ với ngày cao nhất.
        for (Day day : days) {
            if (maxRevenue.signum() <= 0 || day.revenue.signum() <= 0) {
                day.height = 0;
                continue;
            }
            BigDecimal percent = day.revenue.multiply(BigDecimal.valueOf(100))
                    .divide(maxRevenue, 0, RoundingMode.HALF_UP);
            // Có doanh thu thì cột cao ít nhất 1% để vẫn nhìn thấy.
            day.height = Math.max(1, percent.intValue());
        }
    }

    // 3. Một dòng số liệu của một ngày.
    public static class Day {
        private final LocalDate date;
        private final BigDecimal revenue, discount, ticketValue, productValue;
        private final long invoices, tickets, items, mismatches;
        private int height;
        private String mode = "day";
        public Day(LocalDate date, BigDecimal revenue, BigDecimal discount, BigDecimal ticketValue,
                   BigDecimal productValue, long invoices, long tickets, long items, long mismatches) {
            this.date = date;
            this.revenue = revenue;
            this.discount = discount;
            this.ticketValue = ticketValue;
            this.productValue = productValue;
            this.invoices = invoices;
            this.tickets = tickets;
            this.items = items;
            this.mismatches = mismatches;
        }
        // [TK-NGAY-TRONG] Ngày không bán hàng vẫn có một dòng giá trị 0.
        public static Day empty(LocalDate date) {
            return new Day(date, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO,
                    BigDecimal.ZERO, 0, 0, 0, 0);
        }
        public String getDate() {
            if ("month".equals(mode)) return date.format(DateTimeFormatter.ofPattern("MM/yyyy"));
            if ("year".equals(mode)) return String.valueOf(date.getYear());
            return date.toString();
        }
        public String getLabel() {
            if (!"day".equals(mode)) return getDate();
            return date.format(DateTimeFormatter.ofPattern("dd/MM"));
        }
        public BigDecimal getRevenue() { return revenue; }
        public BigDecimal getDiscount() { return discount; }
        public BigDecimal getTicketValue() { return ticketValue; }
        public BigDecimal getProductValue() { return productValue; }
        public long getInvoices() { return invoices; }
        public long getTickets() { return tickets; }
        public long getItems() { return items; }
        public int getHeight() { return height; }
    }

    // 4. Một dòng trong bảng top phim hoặc sản phẩm/combo.
    public static class Ranking {
        private final String name, type;
        private final long quantity;
        private final BigDecimal value;
        public Ranking(String name, String type, long quantity, BigDecimal value) {
            this.name = name;
            this.type = type;
            this.quantity = quantity;
            this.value = value;
        }
        public String getName() { return name; }
        public String getType() { return type; }
        public long getQuantity() { return quantity; }
        public BigDecimal getValue() { return value; }
    }
}
