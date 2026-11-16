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
@Table(name = "LoaiPhong")
public class LoaiPhong {

    @Id
    @Column(name = "MaLoaiPhong", length = 50, nullable = false)
    private String maLoaiPhong;

    @Column(name = "TenLoaiPhong", length = 100, nullable = false)
    private String tenLoaiPhong;
}
