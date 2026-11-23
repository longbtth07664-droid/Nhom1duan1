package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

// Thực thể ánh xạ bảng Phòng chiếu phim trong CSDL
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "PhongChieu")
public class PhongChieu {

    // Mã phòng chiếu định danh duy nhất (khóa chính tự tăng trong CSDL)
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaPhong", nullable = false)
    private Integer maPhong;

    // Tên phòng chiếu hiển thị trong hệ thống rạp (VD: Phòng 01 - Tiêu Chuẩn)
    @Column(name = "TenPhong", length = 100, nullable = false)
    private String tenPhong;

    // Tên hoặc mã loại phòng chiếu tương ứng (2D, 3D, IMAX, Gold Class)
    @Column(name = "LoaiPhong", length = 50)
    private String loaiPhong;

    // Sức chứa số lượng chỗ ngồi tối đa cho phép của phòng chiếu
    @Column(name = "SucChua", nullable = false)
    private Integer sucChua;

    public PhongChieu(String tenPhong, String loaiPhong, Integer sucChua) {
        this.tenPhong = tenPhong;
        this.loaiPhong = loaiPhong;
        this.sucChua = sucChua;
    }

    public PhongChieu(String maPhong, String tenPhong, String loaiPhong, Integer sucChua) {
        if (maPhong != null && !maPhong.trim().isEmpty()) {
            try {
                this.maPhong = Integer.parseInt(maPhong.trim());
            } catch (NumberFormatException ignored) {}
        }
        this.tenPhong = tenPhong;
        this.loaiPhong = loaiPhong;
        this.sucChua = sucChua;
    }

    public String getMaPhongStr() {
        return maPhong != null ? String.valueOf(maPhong) : "";
    }
}
