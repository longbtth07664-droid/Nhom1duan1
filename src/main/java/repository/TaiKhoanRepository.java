package repository;

import entity.TaiKhoan;
import org.hibernate.Session;
import org.hibernate.query.Query;
import util.HibernateConfig;

public class TaiKhoanRepository {

    public TaiKhoan checkLogin(String username, String password) {
        System.out.println("[TaiKhoanRepository] Dang kiem tra dang nhap cho: [" + username + "] voi pass: [" + password + "]");
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            // So sánh linh hoạt không bị chặn bởi dấu tiếng Việt của Trạng Thái
            String hql = "FROM TaiKhoan tk WHERE tk.username = :user AND tk.password = :pass";
            Query<TaiKhoan> query = session.createQuery(hql, TaiKhoan.class);
            query.setParameter("user", username.trim());
            query.setParameter("pass", password.trim());
            
            TaiKhoan tk = query.uniqueResult();
            if (tk != null) {
                System.out.println("[TaiKhoanRepository] Tim thay tai khoan: " + tk.getHoTen() + " | Vai tro: " + tk.getVaiTro());
            } else {
                System.out.println("[TaiKhoanRepository] KHONG tim thay tai khoan hop le hoac sai mat khau!");
            }
            return tk;
        } catch (Exception e) {
            System.err.println("[TaiKhoanRepository] LOI HIBERNATE TRUY VAN DB: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
}
