package util;

import entity.TaiKhoan;
import org.hibernate.Session;
import org.hibernate.query.Query;

import java.util.List;

public class TestDB {
    public static void main(String[] args) {
        System.out.println("====== DANG KIEM TRA KET NOI HIBERNATE ======");
        try {
            Session session = HibernateConfig.getFACTORY().openSession();
            System.out.println("[1] Ket noi SQL Server THANH CONG!");

            Query<TaiKhoan> query = session.createQuery("FROM TaiKhoan", TaiKhoan.class);
            List<TaiKhoan> list = query.getResultList();

            System.out.println("[2] So luong tai khoan tim thay trong DB: " + list.size());
            for (TaiKhoan tk : list) {
                System.out.println(" -> Username: [" + tk.getUsername() + "] | Pass: [" + tk.getPassword() + "] | VaiTro: [" + tk.getVaiTro() + "] | TrangThai: [" + tk.getTrangThai() + "]");
            }
            session.close();
            System.out.println("====== KIEM TRA HOAN TAT! ======");
        } catch (Throwable e) {
            System.err.println("====== LOI KET NOI DATABASE! ======");
            e.printStackTrace();
        }
    }
}
