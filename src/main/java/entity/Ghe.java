package entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

// Thực thể ánh xạ bảng Ghế ngồi vật lý của phòng chiếu trong CSDL
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "Ghe")
public class Ghe {

    // Mã định danh của ghế (khóa chính tự tăng trong SQL Server)
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaGhe", nullable = false)
    private Integer maGhe;

    // Phòng chiếu chứa chiếc ghế này (liên kết khóa ngoại với bảng PhongChieu)
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "MaPhong", nullable = false)
    private PhongChieu phongChieu;

    // Loại ghế: Ghế thường, Ghế VIP hoặc Ghế Đôi (liên kết khóa ngoại với LoaiGhe)
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "MaLoaiGhe", nullable = false)
    private LoaiGhe loaiGhe;

    // Ký tự hàng ghế (Ví dụ: A, B, C, D, E)
    @Column(name = "HangGhe", nullable = false, length = 5)
    private String hangGhe;

    // Số thứ tự ghế trong hàng (Ví dụ: 1, 2, 3... 12)
    @Column(name = "SoGhe", nullable = false)
    private Integer soGhe;

    // Trạng thái vận hành của ghế: 'Hoạt động', 'Bảo trì'
    @Column(name = "TrangThai", length = 30)
    private String trangThai = "Hoạt động";

    // Lấy tên ghế ghép từ hàng và số để hiển thị trực quan trên sơ đồ (VD: A1, B6, E2)
    public String getTenGhe() {
        return hangGhe + soGhe;
    }

    // Kiểm tra xem ghế này có phải là ghế đôi (Sweetbox) hay không
    public boolean isGheDoi() {
        if (loaiGhe == null) return false;
        String ten = loaiGhe.getTenLoaiGhe() != null ? loaiGhe.getTenLoaiGhe().toLowerCase() : "";
        return (loaiGhe.getMaLoaiGhe() != null && loaiGhe.getMaLoaiGhe() == 3)
                || ten.contains("đôi")
                || ten.contains("sweetbox");
    }
}
