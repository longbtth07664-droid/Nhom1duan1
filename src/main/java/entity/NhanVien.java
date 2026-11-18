package entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "TaiKhoan") // Ánh xạ vào bảng TaiKhoan trong database
public class NhanVien {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MaTK") // Khớp với khóa chính MaTK trong bảng TaiKhoan (kiểu INT -> dùng Integer)
    private Integer id;

    @Column(name = "HoTen")
    private String hoTen;

    @Column(name = "CCCD")
    private String cccd;

    @Column(name = "Email")
    private String email;

    @Column(name = "SoDienThoai")
    private String soDienThoai;

    @Column(name = "DiaChi")
    private String diaChi;

    @Column(name = "VaiTro")
    private String vaiTro;

    @Column(name = "Username")
    private String username;

    @Column(name = "Password")
    private String matKhau;

    @Column(name = "TrangThai")
    private String trangThai;
}