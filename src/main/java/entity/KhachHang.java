package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

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

    // Khởi tạo đối tượng khách hàng rỗng theo yêu cầu bắt buộc của Hibernate
    public KhachHang() {}

    // Khởi tạo đối tượng khách hàng với đầy đủ các thuộc tính thông tin
    public KhachHang(String maKH, String hoTen, String sdt, Integer diemTichLuy, String gioiTinh) {
        this.maKH = maKH;
        this.hoTen = hoTen;
        this.sdt = sdt;
        this.diemTichLuy = diemTichLuy != null ? diemTichLuy : 0;
        this.gioiTinh = gioiTinh;
    }

    // Tự động phân loại hạng thành viên của khách hàng dựa trên số điểm tích lũy
    public String getHangThanhVien() {
        int d = (diemTichLuy != null) ? diemTichLuy : 0;
        if (d >= 1000) return "Kim Cương";
        if (d >= 500) return "Vàng";
        if (d >= 200) return "Bạc";
        return "Chuẩn";
    }

    // Các hàm getter và setter truy xuất dữ liệu thuộc tính
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
}
