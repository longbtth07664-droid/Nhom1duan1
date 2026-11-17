package entity;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

public class HoaDon {
    private Integer maDatVe;
    private Integer maTK;
    private String tenThuNgan;
    private Integer maKH;
    private String tenKhachHang;
    private String sdtKhachHang;
    private Integer maKM;
    private LocalDateTime ngayDat;
    private BigDecimal tongTien = BigDecimal.ZERO;
    private BigDecimal tienGiam = BigDecimal.ZERO;
    private String trangThai = "Đã hoàn tất";
    private String phuongThuc = "Tiền mặt";

    private List<Ve> danhSachVe = new ArrayList<>();
    private List<ChiTietHoaDon> danhSachChiTiet = new ArrayList<>();

    public HoaDon() {}

    public HoaDon(Integer maDatVe, Integer maTK, LocalDateTime ngayDat, BigDecimal tongTien, String trangThai) {
        this.maDatVe = maDatVe;
        this.maTK = maTK;
        this.ngayDat = ngayDat;
        this.tongTien = tongTien != null ? tongTien : BigDecimal.ZERO;
        this.trangThai = trangThai;
    }

    public String getMaHienThi() {
        return maDatVe != null ? "HD" + maDatVe : "HD-NEW";
    }

    public String getNgayDatFormatted() {
        if (ngayDat == null) return "";
        return ngayDat.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    public String getTongTienFormatted() {
        if (tongTien == null) return "0 đ";
        DecimalFormat df = new DecimalFormat("#,##0");
        return df.format(tongTien) + " đ";
    }

    // Getters and Setters
    public Integer getMaDatVe() { return maDatVe; }
    public void setMaDatVe(Integer maDatVe) { this.maDatVe = maDatVe; }

    public Integer getMaTK() { return maTK; }
    public void setMaTK(Integer maTK) { this.maTK = maTK; }

    public String getTenThuNgan() { return tenThuNgan; }
    public void setTenThuNgan(String tenThuNgan) { this.tenThuNgan = tenThuNgan; }

    public Integer getMaKH() { return maKH; }
    public void setMaKH(Integer maKH) { this.maKH = maKH; }

    public String getTenKhachHang() { return tenKhachHang != null ? tenKhachHang : "Khách vãng lai"; }
    public void setTenKhachHang(String tenKhachHang) { this.tenKhachHang = tenKhachHang; }

    public String getSdtKhachHang() { return sdtKhachHang; }
    public void setSdtKhachHang(String sdtKhachHang) { this.sdtKhachHang = sdtKhachHang; }

    public Integer getMaKM() { return maKM; }
    public void setMaKM(Integer maKM) { this.maKM = maKM; }

    public LocalDateTime getNgayDat() { return ngayDat; }
    public void setNgayDat(LocalDateTime ngayDat) { this.ngayDat = ngayDat; }

    public BigDecimal getTongTien() { return tongTien; }
    public void setTongTien(BigDecimal tongTien) { this.tongTien = tongTien; }

    public BigDecimal getTienGiam() { return tienGiam; }
    public void setTienGiam(BigDecimal tienGiam) { this.tienGiam = tienGiam; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String trangThai) { this.trangThai = trangThai; }

    public String getPhuongThuc() { return phuongThuc; }
    public void setPhuongThuc(String phuongThuc) { this.phuongThuc = phuongThuc; }

    public List<Ve> getDanhSachVe() { return danhSachVe; }
    public void setDanhSachVe(List<Ve> danhSachVe) { this.danhSachVe = danhSachVe; }

    public List<ChiTietHoaDon> getDanhSachChiTiet() { return danhSachChiTiet; }
    public void setDanhSachChiTiet(List<ChiTietHoaDon> danhSachChiTiet) { this.danhSachChiTiet = danhSachChiTiet; }
}
