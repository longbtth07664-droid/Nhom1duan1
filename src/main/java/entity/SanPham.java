package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;

@Entity
@Table(name = "SanPham") // Khớp tên bảng SanPham trong SQL Server
public class SanPham {

    @Id
    @Column(name = "MaSP", length = 20, nullable = false)
    private String maSP;

    @Column(name = "TenSP", length = 100, nullable = false)
    private String tenSP;

    @Column(name = "LoaiSP", length = 50, nullable = false)
    private String loaiSP;

    @Column(name = "DonViTinh", length = 20, nullable = false)
    private String donViTinh;

    @Column(name = "GiaBan", nullable = false, precision = 18, scale = 0) // Khớp DECIMAL(18, 0)
    private BigDecimal giaBan;

    @Column(name = "SoLuongTon", nullable = false)
    private int soLuongTon;

    @Column(name = "TrangThai", length = 30)
    private String trangThai;

    // Constructor không tham số bắt buộc phải có cho Hibernate
    public SanPham() {
    }

    public SanPham(String maSP, String tenSP, String loaiSP, String donViTinh, BigDecimal giaBan, int soLuongTon, String trangThai) {
        this.maSP = maSP;
        this.tenSP = tenSP;
        this.loaiSP = loaiSP;
        this.donViTinh = donViTinh;
        this.giaBan = giaBan;
        this.soLuongTon = soLuongTon;
        this.trangThai = trangThai;
    }

    public String getMaSP() { return maSP; }
    public void setMaSP(String maSP) { this.maSP = maSP; }

    public String getTenSP() { return tenSP; }
    public void setTenSP(String tenSP) { this.tenSP = tenSP; }

    public String getLoaiSP() { return loaiSP; }
    public void setLoaiSP(String loaiSP) { this.loaiSP = loaiSP; }

    public String getDonViTinh() { return donViTinh; }
    public void setDonViTinh(String donViTinh) { this.donViTinh = donViTinh; }

    public BigDecimal getGiaBan() { return giaBan; }
    public void setGiaBan(BigDecimal giaBan) { this.giaBan = giaBan; }

    public int getSoLuongTon() { return soLuongTon; }
    public void setSoLuongTon(int soLuongTon) { this.soLuongTon = soLuongTon; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String trangThai) { this.trangThai = trangThai; }
}