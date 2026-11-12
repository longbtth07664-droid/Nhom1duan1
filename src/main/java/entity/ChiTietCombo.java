package entity;

import jakarta.persistence.*;

@Entity
@Table(name = "ChiTietCombo")
@IdClass(ChiTietComboId.class) // Khai báo khóa chính ghép (MaCombo, MaSP)
public class ChiTietCombo {

    @Id
    @Column(name = "MaCombo", length = 20, nullable = false)
    private String maCombo;

    @Id
    @Column(name = "MaSP", length = 20, nullable = false)
    private String maSP;

    @Column(name = "SoLuong", nullable = false)
    private int soLuong = 1;

    @Column(name = "GhiChu", length = 100)
    private String ghiChu;

    // Liên kết lấy thông tin SanPham (TenSP, DonViTinh, GiaBan) khi truy vấn chi tiết
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MaSP", insertable = false, updatable = false)
    private SanPham sanPham;

    // Liên kết tới bảng Combo
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MaCombo", insertable = false, updatable = false)
    private Combo combo;

    public ChiTietCombo() {
    }

    public ChiTietCombo(String maCombo, String maSP, int soLuong, String ghiChu) {
        this.maCombo = maCombo;
        this.maSP = maSP;
        this.soLuong = soLuong;
        this.ghiChu = ghiChu;
    }

    public String getMaCombo() { return maCombo; }
    public void setMaCombo(String maCombo) { this.maCombo = maCombo; }

    public String getMaSP() { return maSP; }
    public void setMaSP(String maSP) { this.maSP = maSP; }

    public int getSoLuong() { return soLuong; }
    public void setSoLuong(int soLuong) { this.soLuong = soLuong; }

    public String getGhiChu() { return ghiChu; }
    public void setGhiChu(String ghiChu) { this.ghiChu = ghiChu; }

    public SanPham getSanPham() { return sanPham; }
    public void setSanPham(SanPham sanPham) { this.sanPham = sanPham; }

    public Combo getCombo() { return combo; }
    public void setCombo(Combo combo) { this.combo = combo; }
}