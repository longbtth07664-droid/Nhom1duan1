package entity;

import java.time.LocalDateTime;

public class ThanhToan {
    private Integer maThanhToan;
    private Integer maDatVe;
    private String phuongThuc;
    private LocalDateTime ngayThanhToan;
    private String trangThai = "Thành công";

    public ThanhToan() {}

    public ThanhToan(Integer maThanhToan, Integer maDatVe, String phuongThuc, LocalDateTime ngayThanhToan, String trangThai) {
        this.maThanhToan = maThanhToan;
        this.maDatVe = maDatVe;
        this.phuongThuc = phuongThuc;
        this.ngayThanhToan = ngayThanhToan;
        this.trangThai = trangThai;
    }

    // Getters and Setters
    public Integer getMaThanhToan() { return maThanhToan; }
    public void setMaThanhToan(Integer maThanhToan) { this.maThanhToan = maThanhToan; }

    public Integer getMaDatVe() { return maDatVe; }
    public void setMaDatVe(Integer maDatVe) { this.maDatVe = maDatVe; }

    public String getPhuongThuc() { return phuongThuc; }
    public void setPhuongThuc(String phuongThuc) { this.phuongThuc = phuongThuc; }

    public LocalDateTime getNgayThanhToan() { return ngayThanhToan; }
    public void setNgayThanhToan(LocalDateTime ngayThanhToan) { this.ngayThanhToan = ngayThanhToan; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String trangThai) { this.trangThai = trangThai; }
}
