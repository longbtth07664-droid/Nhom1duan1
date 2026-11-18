package entity;

import java.math.BigDecimal;
import java.text.DecimalFormat;

public class ChiTietHoaDon {
    private Integer maChiTiet;
    private Integer maDatVe;
    private Integer maSP;
    private Integer maCombo;
    private String tenCombo;
    private Integer soLuong = 1;
    private BigDecimal donGia = BigDecimal.ZERO;

    public ChiTietHoaDon() {}

    public ChiTietHoaDon(Integer maChiTiet, Integer maDatVe, Integer maCombo, Integer soLuong, BigDecimal donGia) {
        this.maChiTiet = maChiTiet;
        this.maDatVe = maDatVe;
        this.maCombo = maCombo;
        this.soLuong = soLuong != null ? soLuong : 1;
        this.donGia = donGia != null ? donGia : BigDecimal.ZERO;
    }

    public BigDecimal getThanhTien() {
        if (donGia == null || soLuong == null) return BigDecimal.ZERO;
        return donGia.multiply(new BigDecimal(soLuong));
    }

    public String getThanhTienFormatted() {
        DecimalFormat df = new DecimalFormat("#,##0");
        return df.format(getThanhTien()) + " đ";
    }

    public String getDonGiaFormatted() {
        if (donGia == null) return "0 đ";
        DecimalFormat df = new DecimalFormat("#,##0");
        return df.format(donGia) + " đ";
    }

    // Getters and Setters
    public Integer getMaChiTiet() { return maChiTiet; }
    public void setMaChiTiet(Integer maChiTiet) { this.maChiTiet = maChiTiet; }

    public Integer getMaDatVe() { return maDatVe; }
    public void setMaDatVe(Integer maDatVe) { this.maDatVe = maDatVe; }

    public Integer getMaSP() { return maSP; }
    public void setMaSP(Integer maSP) { this.maSP = maSP; }

    public Integer getMaCombo() { return maCombo; }
    public void setMaCombo(Integer maCombo) { this.maCombo = maCombo; }

    public String getTenCombo() { return tenCombo; }
    public void setTenCombo(String tenCombo) { this.tenCombo = tenCombo; }

    public Integer getSoLuong() { return soLuong; }
    public void setSoLuong(Integer soLuong) { this.soLuong = soLuong; }

    public BigDecimal getDonGia() { return donGia; }
    public void setDonGia(BigDecimal donGia) { this.donGia = donGia; }
}
