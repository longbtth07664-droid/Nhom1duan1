package entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "TaiKhoan")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class TaiKhoan {

    @Id
    @Column(name = "MaTK", length = 20)
    private String maTK;

    @Column(name = "HoTen", nullable = false, length = 100)
    private String hoTen;

    @Column(name = "CCCD", length = 20, unique = true)
    private String cccd;

    @Column(name = "Email", length = 100, unique = true)
    private String email;

    @Column(name = "SoDienThoai", length = 15)
    private String soDienThoai;

    @Column(name = "DiaChi", length = 255)
    private String diaChi;

    @Column(name = "VaiTro", nullable = false, length = 30)
    private String vaiTro; // 'QuanLy', 'NhanVien'

    @Column(name = "Username", nullable = false, unique = true, length = 50)
    private String username;

    @Column(name = "Password", nullable = false, length = 255)
    private String password;

    @Column(name = "TrangThai", length = 30)
    private String trangThai; // N'Đang làm việc'
}
