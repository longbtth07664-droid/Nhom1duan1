package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;

// Ánh xạ bảng "Combo" trong SQL Server — lưu thông tin gói combo bắp nước
@Entity
@Table(name = "Combo")
public class Combo {

    // Mã combo — Khóa chính, VD: "CB01", "CB02"
    @Id
    @Column(name = "MaCombo", length = 20, nullable = false)
    private String maCombo;

    // Tên combo hiển thị, VD: "Combo Solo", "Combo Couple"
    @Column(name = "TenCombo", length = 100, nullable = false)
    private String tenCombo;

    // Giá bán combo (VNĐ) — dùng BigDecimal tránh sai số tiền tệ, khớp DECIMAL(18,0) trong DB
    @Column(name = "GiaCombo", nullable = false, precision = 18, scale = 0)
    private BigDecimal giaCombo;

    // Mô tả ngắn, VD: "1 Bắp lớn + 2 Pepsi"
    @Column(name = "MoTa", length = 255)
    private String moTa;

    // Tên file ảnh trong thư mục assets/images/combo/, mặc định: "[maCombo].jpg"
    @Column(name = "HinhAnh", length = 255)
    private String hinhAnh;

    // Trạng thái kinh doanh: "Đang bán" hoặc "Ngừng bán"
    @Column(name = "TrangThai", length = 30)
    private String trangThai = "Đang bán";

    // Constructor rỗng — Hibernate bắt buộc phải có
    public Combo() {
    }

    // Constructor đầy đủ — dùng khi nhận dữ liệu từ Form
    public Combo(String maCombo, String tenCombo, BigDecimal giaCombo, String moTa, String hinhAnh, String trangThai) {
        this.maCombo = maCombo;
        this.tenCombo = tenCombo;
        this.giaCombo = giaCombo;
        this.moTa = moTa;
        this.hinhAnh = hinhAnh;
        this.trangThai = trangThai;
    }

    // --- Getter & Setter ---

    public String getMaCombo() {
        return maCombo;
    }

    public void setMaCombo(String maCombo) {
        this.maCombo = maCombo;
    }

    public String getTenCombo() {
        return tenCombo;
    }

    public void setTenCombo(String tenCombo) {
        this.tenCombo = tenCombo;
    }

    public BigDecimal getGiaCombo() {
        return giaCombo;
    }

    public void setGiaCombo(BigDecimal giaCombo) {
        this.giaCombo = giaCombo;
    }

    public String getMoTa() {
        return moTa;
    }

    public void setMoTa(String moTa) {
        this.moTa = moTa;
    }

    public String getHinhAnh() {
        return hinhAnh;
    }

    public void setHinhAnh(String hinhAnh) {
        this.hinhAnh = hinhAnh;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    @Override
    public String toString() {
        return "Combo{maCombo='" + maCombo + "', tenCombo='" + tenCombo
                + "', giaCombo=" + giaCombo + ", trangThai='" + trangThai + "'}";
    }
}
