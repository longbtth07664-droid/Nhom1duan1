import entity.*;
import repository.*;
import org.hibernate.*;
import org.hibernate.cfg.Configuration;
import java.math.BigDecimal;
import java.nio.file.*;
import java.sql.*;
import java.util.*;
import java.util.regex.*;

/** Chạy repository thật trên bảng tạm SQL Server; không sửa bảng nghiệp vụ. */
public class CatalogIntegrationCheck {
    static void check(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
    }
    static void sql(Connection c, String sql) throws SQLException {
        try (Statement statement = c.createStatement()) { statement.execute(sql); }
    }
    static String temporaryTables(String sql) {
        for (String table : new String[]{"ChiTietHoaDon", "ChiTietCombo", "Combo", "SanPham"}) {
            sql = sql.replaceAll("(?i)\\b" + table + "\\b", "#catalog_" + table);
        }
        return sql;
    }
    static List<ChiTietCombo> details(Integer comboId, Integer productId, int qty) {
        return new ArrayList<>(Collections.singletonList(new ChiTietCombo(comboId, productId, qty, "")));
    }
    public static void main(String[] args) throws Exception {
        String config = Files.readString(Path.of("src/main/java/util/HibernateConfig.java"));
        String[] keys = {"URL", "USER", "PASS"}, values = new String[3];
        for (int i = 0; i < keys.length; i++) {
            Matcher match = Pattern.compile("Environment\\." + keys[i] + ",\\s*\"([^\"]+)\"").matcher(config);
            if (!match.find()) throw new IllegalStateException("Missing database configuration");
            values[i] = match.group(1);
        }
        try (Connection connection = DriverManager.getConnection(values[0] + "loginTimeout=5;", values[1], values[2])) {
            sql(connection, "CREATE TABLE #catalog_SanPham (MaSP INT IDENTITY(1,1) PRIMARY KEY,"
                + "TenSP NVARCHAR(100) NOT NULL,LoaiSP NVARCHAR(50) NOT NULL,DonViTinh NVARCHAR(20) NOT NULL,"
                + "GiaBan DECIMAL(18,0) NOT NULL,SoLuongTon INT NOT NULL,TrangThai NVARCHAR(30));"
                + "CREATE TABLE #catalog_Combo (MaCombo INT IDENTITY(1,1) PRIMARY KEY,TenCombo NVARCHAR(100) NOT NULL,"
                + "GiaCombo DECIMAL(18,0) NOT NULL,MoTa NVARCHAR(255),HinhAnh VARCHAR(255),TrangThai NVARCHAR(30));"
                + "CREATE TABLE #catalog_ChiTietCombo (MaCombo INT NOT NULL,MaSP INT NOT NULL,SoLuong INT NOT NULL,"
                + "GhiChu NVARCHAR(100),PRIMARY KEY(MaCombo,MaSP));"
                + "CREATE TABLE #catalog_ChiTietHoaDon (MaSP INT NULL,MaCombo INT NULL);");
            Configuration mapping = new Configuration();
            mapping.addAnnotatedClass(Combo.class).addAnnotatedClass(SanPham.class).addAnnotatedClass(ChiTietCombo.class);
            mapping.setProperty("hibernate.dialect", "org.hibernate.dialect.SQLServer2016Dialect");
            mapping.setProperty("hibernate.temp.use_jdbc_metadata_defaults", "false");
            try (SessionFactory factory = mapping.buildSessionFactory()) {
                SanPhamRepository products = new SanPhamRepository() {
                    @Override protected Session openSession() {
                        return factory.withOptions().connection(connection)
                            .statementInspector(CatalogIntegrationCheck::temporaryTables).openSession();
                    }
                };
                ComboRepository combos = new ComboRepository() {
                    @Override protected Session openSession() {
                        return factory.withOptions().connection(connection)
                            .statementInspector(CatalogIntegrationCheck::temporaryTables).openSession();
                    }
                };
                SanPham product = new SanPham(null, "Bắp thử", "Bắp", "Hộp", new BigDecimal("45000"), 20, "Đang kinh doanh");
                check(products.add(product) && product.getMaSP() == 1, "Product IDENTITY insert");
                String productId = product.getMaSP().toString();
                check(products.getOne(productId).getGiaBan().intValueExact() == 45000, "Read product by integer key");
                check(products.search(productId, "Tất cả").size() == 1, "Search integer product key");
                check(products.search("Bắp", "Đang kinh doanh").size() == 1, "Search Unicode product name");

                Combo combo = new Combo(null, "Combo thử", BigDecimal.ONE, "", "combo_solo.png", "Đang bán");
                check(combos.save(combo, details(null, product.getMaSP(), 2), 10, true, null), "Create combo");
                check(combo.getMaCombo() == 1 && combo.getGiaCombo().intValueExact() == 81000, "Combo IDENTITY and server price");
                String comboId = combo.getMaCombo().toString();
                check(products.getOne(productId).getSoLuongTon() == 20, "Creating combo does not consume stock");
                List<ChiTietCombo> oldDetails = combos.getChiTiet(comboId);
                check(oldDetails.size() == 1 && oldDetails.get(0).getSanPham().getTenSP().equals("Bắp thử"), "Integer composite key and eager detail lookup");
                check(combos.search(comboId, "Đang bán").size() == 1, "Search integer combo key");
                Combo edited = combos.getOne(comboId);
                String version = combos.fingerprint(edited, oldDetails);
                edited.setTenCombo("Combo đã sửa");
                combos.save(edited, details(edited.getMaCombo(), product.getMaSP(), 3), -1, false, version);
                check(combos.getOne(comboId).getGiaCombo().intValueExact() == 81000, "Preserve saved price on edit");
                check(combos.getChiTiet(comboId).get(0).getSoLuong() == 3, "Replace composite-key details");
                try {
                    combos.save(edited, details(edited.getMaCombo(), product.getMaSP(), 4), 0, false, version);
                    throw new AssertionError("Stale version accepted");
                } catch (IllegalArgumentException expected) { }
                Combo bad = new Combo(null, "Sai tồn kho", BigDecimal.ONE, "", "", "Đang bán");
                try {
                    combos.save(bad, details(null, product.getMaSP(), 21), 0, true, null);
                    throw new AssertionError("Insufficient stock accepted");
                } catch (IllegalArgumentException expected) { }
                check(combos.getAll().size() == 1, "Failed save rolled back");
                check(products.isSanPhamUsed(productId), "Product used by combo");
                check(!products.delete(productId) && products.getOne(productId) != null, "Protect referenced product");
                sql(connection, "INSERT INTO #catalog_ChiTietHoaDon VALUES (NULL," + combo.getMaCombo() + ")");
                try {
                    combos.delete(comboId);
                    throw new AssertionError("Sold combo deleted");
                } catch (IllegalArgumentException expected) { }
                sql(connection, "DELETE FROM #catalog_ChiTietHoaDon");
                check(combos.delete(comboId) && combos.getChiTiet(comboId).isEmpty(), "Delete unused combo and details");
                product.setSoLuongTon(12);
                check(products.update(product) && products.getOne(productId).getSoLuongTon() == 12, "Update product");
                check(products.delete(productId) && products.getOne(productId) == null, "Delete unused product");
                check(!products.update(product), "Updating deleted product must not insert a new row");
                Combo defaultImage = new Combo(null, "Ảnh mặc định", BigDecimal.ONE, "", "", "Đang bán");
                SanPham next = new SanPham(null, "Nước thử", "Nước có gas", "Ly", new BigDecimal("35000"), 5, "Đang kinh doanh");
                check(products.add(next) && next.getMaSP() > 1, "SQL Server keeps assigning identities after delete");
                combos.save(defaultImage, details(null, next.getMaSP(), 1), 0, true, null);
                check(combos.getOne(defaultImage.getMaCombo().toString()).getHinhAnh().equals(defaultImage.getMaCombo() + ".jpg"), "Default image uses generated identity");
            }
        }
        System.out.println("PASS: INT IDENTITY catalog CRUD, searches, composite keys, pricing, images, stock checks, stale edits, deletion guards and rollback; temporary tables only.");
    }
}
