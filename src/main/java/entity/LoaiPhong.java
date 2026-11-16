package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

// Thực thể ánh xạ bảng Loại phòng chiếu (2D, 3D, IMAX...) trong CSDL
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "LoaiPhong")
public class LoaiPhong {

    // Mã định danh loại phòng chiếu (khóa chính trong CSDL)
    @Id
    @Column(name = "MaLoaiPhong", length = 50, nullable = false)
    private String maLoaiPhong;

    // Tên hiển thị loại phòng chiếu (VD: 2D Tiêu Chuẩn, 3D Digital, IMAX Laser)
    @Column(name = "TenLoaiPhong", length = 100, nullable = false)
    private String tenLoaiPhong;
}
