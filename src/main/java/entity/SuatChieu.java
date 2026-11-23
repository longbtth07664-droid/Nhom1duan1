package entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "SuatChieu")
public class SuatChieu {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaSuat", nullable = false)
    private Integer maSuat;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "MaPhim", nullable = false)
    private Phim phim;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "MaPhong", nullable = false)
    private PhongChieu phongChieu;

    @Column(name = "DinhDang", length = 20)
    private String dinhDang = "2D";

    @Column(name = "NgayChieu", nullable = false)
    private LocalDate ngayChieu;

    @Column(name = "GioBatDau", nullable = false)
    private LocalTime gioBatDau;

    @Column(name = "GioKetThuc", nullable = false)
    private LocalTime gioKetThuc;

    @Column(name = "GiaVeCoBan")
    private BigDecimal giaVeCoBan = BigDecimal.valueOf(80000);

    @Column(name = "TrangThai", length = 30)
    private String trangThai = "Đang mở bán";

    @Column(name = "LyDoHuy", length = 255)
    private String lyDoHuy;

    public String getMaSuatFormatted() {
        if (maSuat == null) return "SC000";
        return String.format("SC%03d", maSuat);
    }

    // Kiểm tra suất chiếu đã qua giờ chiếu hay chưa (phục vụ chặn bán vé quá giờ)
    public boolean isQuaGio() {
        if (ngayChieu == null || gioBatDau == null) return false;
        LocalDate today = LocalDate.now();
        if (ngayChieu.isBefore(today)) return true;
        if (ngayChieu.isEqual(today)) {
            // Suất chiếu trong ngày hôm nay nếu đã qua giờ bắt đầu thì không cho bán vé nữa
            return LocalTime.now().isAfter(gioBatDau);
        }
        return false;
    }
}
