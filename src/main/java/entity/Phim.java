package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.stream.Collectors;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "Phim")
public class Phim {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaPhim", nullable = false)
    private Integer maPhim;

    @Column(name = "TenPhim", length = 200, nullable = false)
    private String tenPhim;

    @Column(name = "MoTa")
    private String moTa;

    @Column(name = "ThoiLuong", nullable = false)
    private Integer thoiLuong;

    @Column(name = "NgayKhoiChieu", nullable = false)
    private LocalDate ngayKhoiChieu;

    @Column(name = "NgayKetThuc", nullable = false)
    private LocalDate ngayKetThuc;

    @Column(name = "DaoDien", length = 100)
    private String daoDien;

    @Column(name = "DienVien", length = 255)
    private String dienVien;

    @Column(name = "QuocGia", length = 100)
    private String quocGia;

    @Column(name = "Poster")
    private String poster;

    @Column(name = "Trailer")
    private String trailer;

    @Column(name = "DoTuoi", length = 20)
    private String doTuoi;

    @Column(name = "TrangThai", length = 50)
    private String trangThai;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "Phim_TheLoai",
            joinColumns = @JoinColumn(name = "MaPhim"),
            inverseJoinColumns = @JoinColumn(name = "MaTheLoai")
    )
    private Set<TheLoai> theLoais = new LinkedHashSet<>();

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "Phim_DinhDang",
            joinColumns = @JoinColumn(name = "MaPhim"),
            inverseJoinColumns = @JoinColumn(name = "MaDinhDang")
    )
    private Set<DinhDang> dinhDangs = new LinkedHashSet<>();

    /**
     * Chuỗi tên định dạng ngăn cách bằng dấu phẩy để hiển thị trên bảng/thẻ phim (VD: "2D, 3D, IMAX")
     */
    public String getTenDinhDangsStr() {
        if (dinhDangs == null || dinhDangs.isEmpty()) {
            return "";
        }
        return dinhDangs.stream()
                .map(DinhDang::getTenDinhDang)
                .collect(Collectors.joining(", "));
    }

    /**
     * Chuỗi mã định dạng ngăn cách bằng dấu phẩy để tự động tick checkbox khi sửa (VD: "1,2")
     */
    public String getMaDinhDangsStr() {
        if (dinhDangs == null || dinhDangs.isEmpty()) {
            return "";
        }
        return dinhDangs.stream()
                .map(dd -> String.valueOf(dd.getMaDinhDang()))
                .collect(Collectors.joining(","));
    }

    /**
     * Chuỗi tên thể loại ngăn cách bằng dấu phẩy để hiển thị trên bảng và pop-up Chi tiết.
     */
    public String getTenTheLoaisStr() {
        if (theLoais == null || theLoais.isEmpty()) {
            return "";
        }
        return theLoais.stream()
                .map(TheLoai::getTenTheLoai)
                .collect(Collectors.joining(", "));
    }

    /**
     * Chuỗi mã thể loại ngăn cách bằng dấu phẩy để tự tick checkbox khi mở pop-up Sửa.
     */
    public String getMaTheLoaisStr() {
        if (theLoais == null || theLoais.isEmpty()) {
            return "";
        }
        return theLoais.stream()
                .map(tl -> String.valueOf(tl.getMaTheLoai()))
                .collect(Collectors.joining(","));
    }

    /**
     * [TỰ ĐỘNG TÍNH TRẠNG THÁI PHIM THEO THỜI GIAN THỰC]
     * Tự động so sánh ngày hôm nay (LocalDate.now()) với ngày khởi chiếu và ngày kết thúc:
     * - Nếu hôm nay trước ngày khởi chiếu -> "Sắp chiếu"
     * - Nếu hôm nay sau ngày kết thúc     -> "Ngừng chiếu"
     * - Nếu nằm trong khoảng chiếu        -> "Đang chiếu"
     */
    public String getTrangThai() {
        LocalDate homNay = LocalDate.now();
        if (ngayKhoiChieu != null && homNay.isBefore(ngayKhoiChieu)) {
            return "Sắp chiếu";
        }
        if (ngayKetThuc != null && homNay.isAfter(ngayKetThuc)) {
            return "Ngừng chiếu";
        }
        if (ngayKhoiChieu != null) {
            return "Đang chiếu";
        }
        return trangThai != null ? trangThai : "Đang chiếu";
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }
}
