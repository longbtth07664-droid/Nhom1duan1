package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;

@Entity
@Table(name = "Combo") // Khớp tên bảng Combo trong SQL Server
public class Combo {

    @Id
    @Column(name = "MaCombo", length = 20, nullable = false)
    private String maCombo;

    @Column(name = "TenCombo", length = 100, nullable = false)
    private String tenCombo;

    @Column(name = "GiaCombo", nullable = false, precision = 18, scale = 0) // Khớp DECIMAL(18, 0)
    private BigDecimal giaCombo;

    @Column(name = "MoTa", length = 255)
    private String moTa;

    @Column(name = "HinhAnh", length = 255)
    private String hinhAnh;

    @Column(name = "TrangThai", length = 30)
    private String trangThai = "Đang bán";

    // Constructor không tham số bắt buộc cho Hibernate
    public Combo() {
    }

    public Combo(String maCombo, String tenCombo, BigDecimal giaCombo, String moTa, String hinhAnh, String trangThai) {
        this.maCombo = maCombo;
        this.tenCombo = tenCombo;
        this.giaCombo = giaCombo;
        this.moTa = moTa;
        this.hinhAnh = hinhAnh;
        this.trangThai = trangThai;
    }

    public String getMaCombo() { return maCombo; }
    public void setMaCombo(String maCombo) { this.maCombo = maCombo; }

    public String getTenCombo() { return tenCombo; }
    public void setTenCombo(String tenCombo) { this.tenCombo = tenCombo; }

    public BigDecimal getGiaCombo() { return giaCombo; }
    public void setGiaCombo(BigDecimal giaCombo) { this.giaCombo = giaCombo; }

    public String getMoTa() { return moTa; }
    public void setMoTa(String moTa) { this.moTa = moTa; }

    public String getHinhAnh() { return hinhAnh; }
    public void setHinhAnh(String hinhAnh) { this.hinhAnh = hinhAnh; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String trangThai) { this.trangThai = trangThai; }
}