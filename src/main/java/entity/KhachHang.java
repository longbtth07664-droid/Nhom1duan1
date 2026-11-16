package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "KhachHang")
public class KhachHang {

    @Id
    @Column(name = "MaKH", length = 20, nullable = false)
    private String maKH;

    @Column(name = "HoTen", length = 100, nullable = false)
    private String hoTen;

    @Column(name = "SDT", length = 15, nullable = false, unique = true)
    private String sdt;

    @Column(name = "DiemTichLuy")
    private Integer diemTichLuy;

    @Column(name = "GioiTinh", length = 10)
    private String gioiTinh;

    // Constructor không tham số - bắt buộc cho Hibernate
    public KhachHang() {}

    public KhachHang(String maKH, String hoTen, String sdt, Integer diemTichLuy, String gioiTinh) {
        this.maKH = maKH;
        this.hoTen = hoTen;
        this.sdt = sdt;
        this.diemTichLuy = diemTichLuy;
        this.gioiTinh = gioiTinh;
    }

    public String getMaKH() { return maKH; }
    public void setMaKH(String maKH) { this.maKH = maKH; }

    public String getHoTen() { return hoTen; }
    public void setHoTen(String hoTen) { this.hoTen = hoTen; }

    public String getSdt() { return sdt; }
    public void setSdt(String sdt) { this.sdt = sdt; }

    public Integer getDiemTichLuy() { return diemTichLuy; }
    public void setDiemTichLuy(Integer diemTichLuy) { this.diemTichLuy = diemTichLuy; }

    public String getGioiTinh() { return gioiTinh; }
    public void setGioiTinh(String gioiTinh) { this.gioiTinh = gioiTinh; }
}
