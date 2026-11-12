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
@Table(name = "TheLoai")
public class TheLoai {

    @Id
    @Column(name = "MaTheLoai", length = 20, nullable = false)
    private String maTheLoai;

    @Column(name = "TenTheLoai", length = 100, nullable = false)
    private String tenTheLoai;
}
