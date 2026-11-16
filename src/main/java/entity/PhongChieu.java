package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
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

    // Mã phòng chiếu định danh duy nhất (khóa chính trong CSDL)
    @Id
    @Column(name = "MaPhong", length = 20, nullable = false)
    private String maPhong;

    // Tên phòng chiếu hiển thị trong hệ thống rạp (VD: Phòng 01 - Tiêu Chuẩn)
    @Column(name = "TenPhong", length = 100, nullable = false)
    private String tenPhong;

    // Tên hoặc mã loại phòng chiếu tương ứng (2D, 3D, IMAX, Gold Class)
    @Column(name = "LoaiPhong", length = 50)
    private String loaiPhong;

    // Sức chứa số lượng chỗ ngồi tối đa cho phép của phòng chiếu
    @Column(name = "SucChua", nullable = false)
    private Integer sucChua;
}
