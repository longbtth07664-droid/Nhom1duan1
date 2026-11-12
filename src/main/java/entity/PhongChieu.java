package entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "PhongChieu")
public class PhongChieu {

    @Id
    @Column(name = "MaPhong", length = 20, nullable = false)
    private String maPhong;

    @Column(name = "TenPhong", length = 100, nullable = false)
    private String tenPhong;

    @Column(name = "LoaiPhong", length = 50)
    private String loaiPhong;

    @Column(name = "SucChua", nullable = false)
    private Integer sucChua;
}