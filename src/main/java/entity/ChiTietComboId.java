package entity;

import java.io.Serializable;
import java.util.Objects;

// Lớp khóa chính ghép cho bảng ChiTietCombo — gồm (maCombo, maSP)
// JPA yêu cầu: implements Serializable, tên thuộc tính trùng với @Id trong ChiTietCombo,
// và bắt buộc ghi đè equals() + hashCode() để Hibernate phân biệt từng dòng
public class ChiTietComboId implements Serializable {

    private static final long serialVersionUID = 1L;

    private String maCombo; // Trùng tên với @Id maCombo trong ChiTietCombo
    private String maSP;    // Trùng tên với @Id maSP trong ChiTietCombo

    public ChiTietComboId() {
    }

    public ChiTietComboId(String maCombo, String maSP) {
        this.maCombo = maCombo;
        this.maSP = maSP;
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

    // So sánh 2 khóa chính — Hibernate dùng để nhận biết dòng nào đã tồn tại trong Session cache
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ChiTietComboId that = (ChiTietComboId) o;
        return Objects.equals(maCombo, that.maCombo) &&
               Objects.equals(maSP, that.maSP);
    }

    @Override
    public int hashCode() {
        return Objects.hash(maCombo, maSP);
    }

    @Override
    public String toString() {
        return "ChiTietComboId{maCombo='" + maCombo + "', maSP='" + maSP + "'}";
    }
}
