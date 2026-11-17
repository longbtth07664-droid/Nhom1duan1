package entity;

import java.math.BigDecimal;
import java.text.DecimalFormat;

public class Ve {
    private Integer maVe;
    private Integer maDatVe;
    private Integer maSuat;
    private Integer maGhe;
    private String tenGhe;
    private String tenPhim;
    private String gioChieu;
    private String ngayChieu;
    private String tenPhong;
    private BigDecimal giaVe = BigDecimal.ZERO;
    private String maQR;
    private String trangThai = "Đã in";

    public Ve() {}

    public Ve(Integer maVe, Integer maDatVe, Integer maSuat, Integer maGhe, BigDecimal giaVe, String maQR, String trangThai) {
        this.maVe = maVe;
        this.maDatVe = maDatVe;
        this.maSuat = maSuat;
        this.maGhe = maGhe;
        this.giaVe = giaVe;
        this.maQR = maQR;
        this.trangThai = trangThai;
    }

    public String getGiaVeFormatted() {
        if (giaVe == null) return "0 đ";
        DecimalFormat df = new DecimalFormat("#,##0");
        return df.format(giaVe) + " đ";
    }

    // Getters and Setters
    public Integer getMaVe() { return maVe; }
    public void setMaVe(Integer maVe) { this.maVe = maVe; }

    public Integer getMaDatVe() { return maDatVe; }
    public void setMaDatVe(Integer maDatVe) { this.maDatVe = maDatVe; }

    public Integer getMaSuat() { return maSuat; }
    public void setMaSuat(Integer maSuat) { this.maSuat = maSuat; }

    public Integer getMaGhe() { return maGhe; }
    public void setMaGhe(Integer maGhe) { this.maGhe = maGhe; }

    public String getTenGhe() { return tenGhe; }
    public void setTenGhe(String tenGhe) { this.tenGhe = tenGhe; }

    public String getTenPhim() { return tenPhim; }
    public void setTenPhim(String tenPhim) { this.tenPhim = tenPhim; }

    public String getGioChieu() { return gioChieu; }
    public void setGioChieu(String gioChieu) { this.gioChieu = gioChieu; }

    public String getNgayChieu() { return ngayChieu; }
    public void setNgayChieu(String ngayChieu) { this.ngayChieu = ngayChieu; }

    public String getTenPhong() { return tenPhong; }
    public void setTenPhong(String tenPhong) { this.tenPhong = tenPhong; }

    public BigDecimal getGiaVe() { return giaVe; }
    public void setGiaVe(BigDecimal giaVe) { this.giaVe = giaVe; }

    public String getMaQR() { return maQR; }
    public void setMaQR(String maQR) { this.maQR = maQR; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String trangThai) { this.trangThai = trangThai; }
}
