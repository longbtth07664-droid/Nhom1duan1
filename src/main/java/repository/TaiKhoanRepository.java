package repository;

import entity.TaiKhoan;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import util.HibernateConfig;

import java.util.List;

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
    // TaiKhoanRepository
    public List<TaiKhoan> getAll() {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.createQuery("FROM TaiKhoan", TaiKhoan.class).list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // 2. Lấy 1 tài khoản dựa theo mã tài khoản (maTK)
    public TaiKhoan getOne(Integer maTK) {
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            return session.get(TaiKhoan.class, maTK);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // 3. Thêm mới tài khoản bằng Hibernate Session & Transaction
    public boolean add(TaiKhoan tk) {
        Transaction transaction = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            transaction = session.beginTransaction();
            session.persist(tk); // Hoặc session.save(tk) tùy phiên bản Hibernate
            transaction.commit();
            return true;
        } catch (Exception e) {
            if (transaction != null) {
                transaction.rollback();
            }
            e.printStackTrace();
            return false;
        }
    }

    // 4. Cập nhật thông tin tài khoản an toàn (Không làm mất dữ liệu cũ và tránh lỗi NOT NULL)
    public boolean update(TaiKhoan tkMoi) {
        Transaction transaction = null;
        try (Session session = HibernateConfig.getFACTORY().openSession()) {
            transaction = session.beginTransaction();

            if (tkMoi.getMaTK() != null) {
                // Lấy bản ghi cũ đang có trong CSDL lên trước
                TaiKhoan tkCu = session.get(TaiKhoan.class, tkMoi.getMaTK());
                if (tkCu != null) {
                    // Chỉ cập nhật các thông tin thay đổi từ form sửa
                    tkCu.setUsername(tkMoi.getUsername());
                    tkCu.setPassword(tkMoi.getPassword());
                    tkCu.setVaiTro(tkMoi.getVaiTro());
                    tkCu.setTrangThai(tkMoi.getTrangThai());

                    // Gộp và lưu lại bản ghi đã có đủ thông tin cũ
                    session.merge(tkCu);
                }
            }

            transaction.commit();
            return true;
        } catch (Exception e) {
            if (transaction != null) {
                transaction.rollback();
            }
            e.printStackTrace();
            return false;
        }
    }
}
