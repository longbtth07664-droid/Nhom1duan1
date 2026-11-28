package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDate;
import java.time.Period;

// Thực thể ánh xạ bảng Khách hàng thành viên của rạp chiếu phim trong CSDL
@Entity
@Table(name = "KhachHang")
public class KhachHang {

    // Mã định danh duy nhất của khách hàng (VD: KH001, KH002)
    @Id
    @Column(name = "MaKH", length = 20, nullable = false)
    private String maKH;

    // Họ và tên đầy đủ của khách hàng
    @Column(name = "HoTen", length = 100, nullable = false)
    private String hoTen;

    // Số điện thoại liên lạc chính duy nhất của khách hàng
    @Column(name = "SDT", length = 15, nullable = false, unique = true)
    private String sdt;

    // Điểm thưởng tích lũy từ các hóa đơn xem phim và dịch vụ
    @Column(name = "DiemTichLuy")
    private Integer diemTichLuy = 0;

    // Giới tính của khách hàng (Nam, Nữ, Khác)
    @Column(name = "GioiTinh", length = 10)
    private String gioiTinh;

    // Ngày sinh (phục vụ ưu đãi sinh nhật và phân loại độ tuổi HSSV / Trẻ em / Người cao tuổi)
    @Column(name = "NgaySinh")
    private LocalDate ngaySinh;

    public KhachHang() {}

    public KhachHang(String maKH, String hoTen, String sdt, Integer diemTichLuy, String gioiTinh) {
        this.maKH = maKH;
        this.hoTen = hoTen;
        this.sdt = sdt;
        this.diemTichLuy = diemTichLuy != null ? diemTichLuy : 0;
        this.gioiTinh = gioiTinh;
    }

    public KhachHang(String maKH, String hoTen, String sdt, Integer diemTichLuy, String gioiTinh, LocalDate ngaySinh) {
        this.maKH = maKH;
        this.hoTen = hoTen;
        this.sdt = sdt;
        this.diemTichLuy = diemTichLuy != null ? diemTichLuy : 0;
        this.gioiTinh = gioiTinh;
        this.ngaySinh = ngaySinh;
    }

    // Tính tuổi khách hàng dựa trên ngày sinh
    public int getTuoi() {
        if (ngaySinh == null) return 0;
        return Period.between(ngaySinh, LocalDate.now()).getYears();
    }

    // Tự động phân loại hạng thành viên của khách hàng dựa trên số điểm tích lũy
    public String getHangThanhVien() {
        int d = (diemTichLuy != null) ? diemTichLuy : 0;
        if (d >= 1000) return "Kim Cương";
        if (d >= 500) return "Vàng";
        if (d >= 200) return "Bạc";
        return "Chuẩn";
    }

    // Các hàm getter và setter
    public String getMaKH() { return maKH; }
    public void setMaKH(String maKH) { this.maKH = maKH; }

    public String getHoTen() { return hoTen; }
    public void setHoTen(String hoTen) { this.hoTen = hoTen; }

    public String getSdt() { return sdt; }
    public void setSdt(String sdt) { this.sdt = sdt; }

    public Integer getDiemTichLuy() { return diemTichLuy != null ? diemTichLuy : 0; }
    public void setDiemTichLuy(Integer diemTichLuy) { this.diemTichLuy = diemTichLuy; }

    public String getGioiTinh() { return gioiTinh; }
    public void setGioiTinh(String gioiTinh) { this.gioiTinh = gioiTinh; }

    public LocalDate getNgaySinh() { return ngaySinh; }
    public void setNgaySinh(LocalDate ngaySinh) { this.ngaySinh = ngaySinh; }
}
