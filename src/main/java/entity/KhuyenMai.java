package entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.Period;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "KhuyenMai")
public class KhuyenMai {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaKM", nullable = false)
    private Integer maKM;

    @Column(name = "TenKM", length = 100, nullable = false)
    private String tenKM;

    @Column(name = "MaCode", length = 50, nullable = false, unique = true)
    private String maCode;

    @Column(name = "PhanTramGiam", precision = 5, scale = 2, nullable = false)
    private BigDecimal phanTramGiam = BigDecimal.ZERO;

    @Column(name = "SoTienGiamToiDa", precision = 18, scale = 2, nullable = false)
    private BigDecimal soTienGiamToiDa = BigDecimal.ZERO;

    @Column(name = "DonToiThieu", precision = 18, scale = 2, nullable = false)
    private BigDecimal donToiThieu = BigDecimal.ZERO;

    // --- Điều kiện Khung giờ chiếu (Theo giờ) ---
    @Column(name = "GioChieuTu")
    private LocalTime gioChieuTu; // VD: 08:00 (Early Bird)

    @Column(name = "GioChieuDen")
    private LocalTime gioChieuDen; // VD: 12:00

    // --- Điều kiện Thứ trong tuần (Chuỗi VD: '2,3,4,5' hoặc 'ALL') ---
    @Column(name = "ThuTrongTuan", length = 50)
    private String thuTrongTuan = "ALL";

    // --- Điều kiện Độ tuổi (Theo tuổi khách hàng) ---
    @Column(name = "TuoiToiThieu")
    private Integer tuoiToiThieu; // VD: 12 (Từ 12 tuổi)

    @Column(name = "TuoiToiDa")
    private Integer tuoiToiDa; // VD: 22 (U22 Học sinh Sinh viên)

    // --- Điều kiện Số lượng vé tối thiểu & Định dạng ---
    @Column(name = "SoVeToiThieu", nullable = false)
    private int soVeToiThieu = 1;

    @Column(name = "MaDinhDangApDung")
    private Integer maDinhDangApDung; // NULL = Mọi định dạng

    // --- Thời hạn chương trình ---
    @Column(name = "NgayBatDau", nullable = false)
    private LocalDateTime ngayBatDau;

    @Column(name = "NgayKetThuc", nullable = false)
    private LocalDateTime ngayKetThuc;

    @Column(name = "TrangThai", length = 30, nullable = false)
    private String trangThai = "Đang áp dụng";

    // Lớp kết quả kiểm tra tính hợp lệ của mã
    public static class ValidationResult {
        private final boolean valid;
        private final String message;
        private final BigDecimal tienGiam;

        public ValidationResult(boolean valid, String message, BigDecimal tienGiam) {
            this.valid = valid;
            this.message = message;
            this.tienGiam = tienGiam != null ? tienGiam : BigDecimal.ZERO;
        }

        public boolean isValid() { return valid; }
        public String getMessage() { return message; }
        public BigDecimal getTienGiam() { return tienGiam; }
    }

    /**
     * Kiểm tra toàn diện tất cả các tiêu chí điều kiện:
     * - Trạng thái & Hạn sử dụng
     * - Đơn tối thiểu & Số vé tối thiểu
     * - Khung giờ chiếu (Early Bird / Midnight / Happy Hour)
     * - Thứ trong tuần (Thứ 3 vui vẻ, ngày trong tuần vs cuối tuần)
     * - Độ tuổi khách hàng (HSSV / Trẻ em / Người cao tuổi)
     */
    public ValidationResult validate(SuatChieu sc, KhachHang kh, int soLuongVe, BigDecimal tongTien) {
        LocalDateTime now = LocalDateTime.now();

        // 1. Kiểm tra trạng thái
        if (!"Đang áp dụng".equalsIgnoreCase(trangThai)) {
            return new ValidationResult(false, "Mã giảm giá này hiện đang tạm dừng hoặc không còn áp dụng!", BigDecimal.ZERO);
        }

        // 2. Kiểm tra thời hạn
        if (ngayBatDau != null && now.isBefore(ngayBatDau)) {
            return new ValidationResult(false, "Chương trình khuyến mãi này chưa bắt đầu!", BigDecimal.ZERO);
        }
        if (ngayKetThuc != null && now.isAfter(ngayKetThuc)) {
            return new ValidationResult(false, "Mã giảm giá này đã hết hạn sử dụng!", BigDecimal.ZERO);
        }

        // 3. Kiểm tra đơn hàng tối thiểu
        if (donToiThieu != null && donToiThieu.compareTo(BigDecimal.ZERO) > 0) {
            if (tongTien == null || tongTien.compareTo(donToiThieu) < 0) {
                return new ValidationResult(false, "Đơn hàng chưa đạt mức tối thiểu " + formatMoney(donToiThieu) + " để áp dụng mã!", BigDecimal.ZERO);
            }
        }

        // 4. Kiểm tra số lượng vé tối thiểu
        if (soLuongVe < soVeToiThieu) {
            return new ValidationResult(false, "Mã ưu đãi này yêu cầu mua tối thiểu từ " + soVeToiThieu + " vé xem phim trở lên!", BigDecimal.ZERO);
        }

        // 5. KIỂM TRA KHUNG GIỜ CHIẾU (Theo giờ bắt đầu suất chiếu)
        if (sc != null && sc.getGioBatDau() != null) {
            LocalTime gioChieu = sc.getGioBatDau();
            if (gioChieuTu != null && gioChieu.isBefore(gioChieuTu)) {
                return new ValidationResult(false, "Mã chỉ áp dụng cho suất chiếu từ " + gioChieuTu + " đến " + (gioChieuDen != null ? gioChieuDen : "23:59") + ". Suất chiếu này bắt đầu lúc " + gioChieu + "!", BigDecimal.ZERO);
            }
            if (gioChieuDen != null && gioChieu.isAfter(gioChieuDen)) {
                return new ValidationResult(false, "Mã chỉ áp dụng cho suất chiếu trước " + gioChieuDen + ". Suất chiếu này bắt đầu lúc " + gioChieu + "!", BigDecimal.ZERO);
            }
        }

        // 6. KIỂM TRA THỨ TRONG TUẦN
        if (sc != null && sc.getNgayChieu() != null) {
            LocalDate ngay = sc.getNgayChieu();
            int dayOfWeek = ngay.getDayOfWeek().getValue(); // 1 (Mon) - 7 (Sun)
            int thuVn = (dayOfWeek == 7) ? 8 : (dayOfWeek + 1); // 2..7, 8 (CN)
            String thuStr = (thuVn == 8) ? "CN" : String.valueOf(thuVn);

            if (thuTrongTuan != null && !thuTrongTuan.trim().isEmpty() && !"ALL".equalsIgnoreCase(thuTrongTuan.trim())) {
                boolean matched = false;
                for (String t : thuTrongTuan.split(",")) {
                    if (t.trim().equalsIgnoreCase(thuStr) || t.trim().equalsIgnoreCase(String.valueOf(thuVn))) {
                        matched = true;
                        break;
                    }
                }
                if (!matched) {
                    return new ValidationResult(false, "Mã giảm giá chỉ áp dụng vào các ngày (" + formatThu(thuTrongTuan) + "). Suất chiếu vào " + (thuVn == 8 ? "Chủ Nhật" : "Thứ " + thuVn) + " không thỏa điều kiện!", BigDecimal.ZERO);
                }
            }
        }

        // 7. KIỂM TRA ĐỘ TUỔI KHÁCH HÀNG (Dựa trên ngày sinh hoặc giấy tờ)
        if (tuoiToiThieu != null || tuoiToiDa != null) {
            if (kh == null || kh.getNgaySinh() == null) {
                return new ValidationResult(false, "Mã giảm giá này yêu cầu thành viên có Ngày sinh hợp lệ (hoặc xuất trình Thẻ HSSV/CCCD tại quầy)!", BigDecimal.ZERO);
            }
            int tuoi = kh.getTuoi();
            if (tuoiToiThieu != null && tuoi < tuoiToiThieu) {
                return new ValidationResult(false, "Mã ưu đãi yêu cầu độ tuổi từ " + tuoiToiThieu + " tuổi trở lên (Tuổi hiện tại của khách: " + tuoi + ")!", BigDecimal.ZERO);
            }
            if (tuoiToiDa != null && tuoi > tuoiToiDa) {
                return new ValidationResult(false, "Mã ưu đãi chỉ dành cho độ tuổi tối đa " + tuoiToiDa + " tuổi (Tuổi hiện tại của khách: " + tuoi + ")!", BigDecimal.ZERO);
            }
        }

        // 8. TÍNH TOÁN SỐ TIỀN GIẢM HỢP LỆ
        BigDecimal tienGiam = BigDecimal.ZERO;
        if (phanTramGiam != null && phanTramGiam.compareTo(BigDecimal.ZERO) > 0 && tongTien != null) {
            tienGiam = tongTien.multiply(phanTramGiam).divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
        }
        if (soTienGiamToiDa != null && soTienGiamToiDa.compareTo(BigDecimal.ZERO) > 0) {
            if (tienGiam.compareTo(soTienGiamToiDa) > 0) {
                tienGiam = soTienGiamToiDa;
            }
        }

        return new ValidationResult(true, "Áp dụng thành công mã [" + maCode + "]! Đã giảm " + formatMoney(tienGiam), tienGiam);
    }

    private String formatMoney(BigDecimal amount) {
        if (amount == null) return "0 đ";
        return String.format("%,d đ", amount.longValue());
    }

    private String formatThu(String thuStr) {
        if (thuStr == null) return "";
        return thuStr.replace("8", "Chủ Nhật").replace("2", "Thứ 2").replace("3", "Thứ 3")
                .replace("4", "Thứ 4").replace("5", "Thứ 5").replace("6", "Thứ 6").replace("7", "Thứ 7");
    }
}
