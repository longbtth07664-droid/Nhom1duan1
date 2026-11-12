package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
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
    @Column(name = "MaPhim", length = 20, nullable = false)
    private String maPhim;

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

    @Column(name = "Poster", length = 255)
    private String poster;

    @Column(name = "Trailer", length = 255)
    private String trailer;

    @Column(name = "DoTuoi", length = 20)
    private String doTuoi;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "Phim_TheLoai",
            joinColumns = @JoinColumn(name = "MaPhim"),
            inverseJoinColumns = @JoinColumn(name = "MaTheLoai")
    )
    private Set<TheLoai> theLoais = new LinkedHashSet<>();

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
                .map(TheLoai::getMaTheLoai)
                .collect(Collectors.joining(","));
    }
}
