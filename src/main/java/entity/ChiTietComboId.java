package entity;

import java.io.Serializable;
import java.util.Objects;

// Lớp khóa chính ghép bắt buộc implements Serializable
public class ChiTietComboId implements Serializable {

    private String maCombo; // Phải trùng tên biến @Id trong ChiTietCombo
    private String maSP;    // Phải trùng tên biến @Id trong ChiTietCombo

    public ChiTietComboId() {
    }

    public ChiTietComboId(String maCombo, String maSP) {
        this.maCombo = maCombo;
        this.maSP = maSP;
    }

    public String getMaCombo() { return maCombo; }
    public void setMaCombo(String maCombo) { this.maCombo = maCombo; }

    public String getMaSP() { return maSP; }
    public void setMaSP(String maSP) { this.maSP = maSP; }

    // Bắt buộc override equals và hashCode để Hibernate phân biệt từng dòng chi tiết
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ChiTietComboId that = (ChiTietComboId) o;
        return Objects.equals(maCombo, that.maCombo) && Objects.equals(maSP, that.maSP);
    }

    @Override
    public int hashCode() {
        return Objects.hash(maCombo, maSP);
    }
}