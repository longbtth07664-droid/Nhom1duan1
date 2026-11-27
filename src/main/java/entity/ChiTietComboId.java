package entity;

import java.io.Serializable;
import java.util.Objects;

// Lớp khóa chính ghép cho bảng ChiTietCombo — gồm (maCombo, maSP)
// JPA yêu cầu: implements Serializable, tên thuộc tính trùng với @Id trong ChiTietCombo,
// và bắt buộc ghi đè equals() + hashCode() để Hibernate phân biệt từng dòng
// [DL-CHITIETCOMBOID] Các trường ánh xạ cột SQL; constructor tạo đối tượng, getter/setter đọc và gán giá trị.
public class ChiTietComboId implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer maCombo; // Trùng tên với @Id maCombo trong ChiTietCombo
    private Integer maSP;    // Trùng tên với @Id maSP trong ChiTietCombo

    public ChiTietComboId() {
    }

    public ChiTietComboId(Integer maCombo, Integer maSP) {
        this.maCombo = maCombo;
        this.maSP = maSP;
    }

    // --- Getter & Setter ---

    public Integer getMaCombo() { return maCombo; }

    public void setMaCombo(Integer maCombo) { this.maCombo = maCombo; }

    public Integer getMaSP() { return maSP; }

    public void setMaSP(Integer maSP) { this.maSP = maSP; }

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
    public int hashCode() { return Objects.hash(maCombo, maSP); }

    @Override
    public String toString() { return "ChiTietComboId{maCombo='" + maCombo + "', maSP='" + maSP + "'}"; }
}
