package entity;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

// DTO báo cáo, không phải bảng Hibernate và không thay đổi database.
/* TRA CỨU HÀM: ThongKeReport
 * JSP gửi form -> Servlet kiểm tra -> Repository đọc/ghi dữ liệu.
 * Ctrl+F "addDay(" để tìm phần xử lý.
 * Ctrl+F "getDays(" để tìm phần xử lý.
 * Ctrl+F "getFilms(" để tìm phần xử lý.
 * Ctrl+F "getProducts(" để tìm phần xử lý.
 * Ctrl+F "getRevenue(" để tìm phần xử lý.
 * Ctrl+F "getDiscount(" để tìm phần xử lý.
 * Ctrl+F "getTicketValue(" để tìm phần xử lý.
 * Ctrl+F "getProductValue(" để tìm phần xử lý.
 * Ctrl+F "getInvoices(" để tìm phần xử lý.
 * Ctrl+F "getTickets(" để tìm phần xử lý.
 * Ctrl+F "getItems(" để tìm phần xử lý.
 * Ctrl+F "getMismatches(" để tìm phần xử lý.
 * Ctrl+F "getAverage(" để tìm phần xử lý.
 * Ctrl+F "isEmpty(" để tìm phần xử lý.
 * Ctrl+F "groupBy(" để tìm phần xử lý.
 * Ctrl+F "prepareChart(" để tìm phần xử lý.
 */
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

    // Cộng các nhóm ngày đã được SQL tổng hợp độc lập, tránh nhân bản chi tiết.
    /** [ThongKeReport-addDay] Thêm một ngày vào danh sách và cộng từng chỉ tiêu vào tổng báo cáo; ngày đã được SQL tổng hợp. */
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
    /** [ThongKeReport-getAverage] Doanh thu chia số hóa đơn, làm tròn đến đồng. Nếu không có hóa đơn trả 0 để tránh chia cho 0. */
    public BigDecimal getAverage() {
        // Chưa có hóa đơn thì trả về 0, tránh chia cho 0.
        if (invoices == 0) {
            return BigDecimal.ZERO;
        }
        return revenue.divide(BigDecimal.valueOf(invoices), 0, RoundingMode.HALF_UP);
    }
    public boolean isEmpty() { return invoices == 0; }

    /** [TK-NHOM] Gom các ngày thành tháng/năm bằng vòng lặp.
     * SQL vẫn tổng hợp đúng từng hóa đơn trước; chỉ cộng lại số liệu đã có.
     * Ngày trống cũng được gom nên luôn có đủ 12 tháng hoặc các năm đã chọn.
     */
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
                old = new Day(key, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO,
                        BigDecimal.ZERO, 0, 0, 0, 0);
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

    /** [TK-CONG-NHOM] Cộng hai dòng số liệu: tiền dùng BigDecimal, số lượng dùng long.
     * Được groupBy gọi khi gom ngày vào cùng tháng hoặc cùng năm.
     */
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

    // Chuẩn hóa độ cao biểu đồ trên server, chỉ xuất số vào thuộc tính CSS.
    /** [ThongKeReport-prepareChart] Hai vòng lặp: tìm doanh thu lớn nhất rồi đổi mỗi ngày sang phần trăm chiều cao cột. */
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
