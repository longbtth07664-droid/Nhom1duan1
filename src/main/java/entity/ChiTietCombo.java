package entity;

import jakarta.persistence.*;

// Ánh xạ bảng liên kết "ChiTietCombo" — lưu các sản phẩm lẻ nằm bên trong 1 combo
// Khóa chính ghép gồm 2 cột: (MaCombo, MaSP) → dùng @IdClass
@Entity
@Table(name = "ChiTietCombo")
@IdClass(ChiTietComboId.class)
public class ChiTietCombo {

    // Phần 1 của khóa chính — mã combo cha
    @Id
    @Column(name = "MaCombo", length = 20, nullable = false)
    private String maCombo;

    // Phần 2 của khóa chính — mã sản phẩm con
    @Id
    @Column(name = "MaSP", length = 20, nullable = false)
    private String maSP;

    // Số lượng sản phẩm trong combo, mặc định = 1
    @Column(name = "SoLuong", nullable = false)
    private int soLuong = 1;

    // Ghi chú bổ sung, VD: "Vị phô mai", "Size L", "Ít đá"
    @Column(name = "GhiChu", length = 100)
    private String ghiChu;

    // Liên kết tới SanPham → lấy tên món, đơn vị, giá lẻ khi hiển thị chi tiết
    // insertable/updatable = false vì cột MaSP đã do thuộc tính @Id ở trên quản lý
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MaSP", insertable = false, updatable = false)
    private SanPham sanPham;

    // Liên kết tới Combo — cùng lý do insertable/updatable = false
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MaCombo", insertable = false, updatable = false)
    private Combo combo;

    // Constructor rỗng — Hibernate bắt buộc
    public ChiTietCombo() {
    }

    // Constructor đầy đủ — dùng khi đọc dữ liệu từ Form
    public ChiTietCombo(String maCombo, String maSP, int soLuong, String ghiChu) {
        this.maCombo = maCombo;
        this.maSP = maSP;
        this.soLuong = soLuong;
        this.ghiChu = ghiChu;
    }

    // --- Getter & Setter ---

    public String getMaCombo() {
        return maCombo;
    }

    public void setMaCombo(String maCombo) {
        this.maCombo = maCombo;
    }

    public String getMaSP() {
        return maSP;
    }

    public void setMaSP(String maSP) {
        this.maSP = maSP;
    }

    public int getSoLuong() {
        return soLuong;
    }

    public void setSoLuong(int soLuong) {
        this.soLuong = soLuong;
    }

    public String getGhiChu() {
        return ghiChu;
    }

    public void setGhiChu(String ghiChu) {
        this.ghiChu = ghiChu;
    }

    public SanPham getSanPham() {
        return sanPham;
    }

    public void setSanPham(SanPham sanPham) {
        this.sanPham = sanPham;
    }

    public Combo getCombo() {
        return combo;
    }

    public void setCombo(Combo combo) {
        this.combo = combo;
    }

    @Override
    public String toString() {
        return "ChiTietCombo{maCombo='" + maCombo + "', maSP='" + maSP
                + "', soLuong=" + soLuong + ", ghiChu='" + ghiChu + "'}";
    }
}
