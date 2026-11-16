package entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

// Thực thể ánh xạ bảng Loại Ghế (Ghế thường, Ghế VIP, Ghế đôi) trong CSDL
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "LoaiGhe")
public class LoaiGhe {

    // Mã định danh loại ghế (khóa chính tự tăng trong SQL Server)
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaLoaiGhe", nullable = false)
    private Integer maLoaiGhe;

    // Tên hiển thị loại ghế (VD: Ghế Thường, Ghế VIP, Ghế Đôi Sweetbox)
    @Column(name = "TenLoaiGhe", nullable = false, length = 50)
    private String tenLoaiGhe;

    // Tiền phụ thu cộng thêm vào giá vé cơ bản của suất chiếu
    @Column(name = "PhuThu")
    private BigDecimal phuThu = BigDecimal.ZERO;
}
